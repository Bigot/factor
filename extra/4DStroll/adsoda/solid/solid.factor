! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING:  kernel accessors  4DStroll.adsoda.nDobject 4DStroll.adsoda.halfspace 
4DStroll.adsoda.face 4DStroll.adsoda.tools arrays prettyprint fry
4DStroll.adsoda.tools.combinators
combinators math.vectors math.order sequences math namespaces
variables  math.ranges 
math.parser models ;
IN: 4DStroll.adsoda.solid

: MAX-FACE-PER-CORNER ( -- x ) 4 ;

TUPLE: solid < nDobject silhouettes faces corners
adjacencies-valid ;

: <solid> ( -- tuple ) 
    solid new 
    { 0 0 0 0 } clone >>refpoint ! TODO dimension independant
    f <model> >>selected?
    ; inline

M: solid >log 
     {
        [ name>> "solid called : " pprint . ] 
        [ color>> "color : " pprint . ]
        [ dimension>> "dimension : " pprint . ]
        [ faces>> "composed of faces : " pprint [ >log ] each ]
    }   cleave
    ;

M: solid >table
 { } swap  {
        [ name>> "  solid name : " swap 2array suffix ] 
        [ color>> seq>string "  solid color : " swap 2array suffix ]
 !       [ dimension>> "dimension : " pprint . ]
        [ faces>> [ >table suffix ] each ]
    }   cleave
;    

: propagate-refpoint ( solid -- solid )
    [ ] 
    [ faces>> ] 
    [ refpoint>> [ >>refpoint drop ] curry ] tri  
    each
; inline

M: solid ->selected? 
! b obj
    [ selected?>> set-model ] 2keep
    faces>> 
    [ ->selected? ] with each 
;



: suffix-silhouettes ( solid silhouette -- solid )  
    [ suffix ] curry change-silhouettes ; inline

: suffix-face ( solid face -- solid ) 
    [ suffix ] curry change-faces ; inline

: suffix-corner ( solid corner -- solid ) 
    [ suffix ] curry change-corners ; inline

: erase-solid-corners ( solid -- solid )  
    f >>corners ; inline

: erase-silhouettes ( solid -- solid ) 
    dup dimension>> f <array> >>silhouettes ; inline

: filter-real-faces ( solid -- solid ) 
    [ [ real-face? ] filter ] change-faces ; inline

: initiate-solid-from-face ( face -- solid ) 
    <solid>
    over face-project-dim >>dimension
    over refpoint>> 
        >>refpoint
    over parent>> >>parent
    over name>> " proj " append 
                 pv number>string append  >>name
    swap selected?>> >>selected? 
    ;

: erase-old-adjacencies ( solid -- solid )
    erase-solid-corners
    [ 
      [ erase-face-touching-corners 
        erase-face-adjacent-faces  ]
     map ]
    change-faces ; inline

: point-inside-solid? ( solid point -- ? )
    [ faces>> ] dip [ point-inside-face? ] curry  all?   
    ; inline

: point-inside-or-on-solid? ( solid point -- ? )
    [ faces>> ] dip [ point-inside-or-on-face? ] curry  all?   
    ; inline

: unvalid-adjacencies ( solid -- solid )  
    erase-old-adjacencies 
    f >>adjacencies-valid 
    erase-silhouettes ; inline
! ensure REFPOINT

: add-face ( solid face -- solid )
    over >>parent
    over name>> >>name
    over refpoint>> >>refpoint
    suffix-face unvalid-adjacencies ; inline

: cut-solid ( solid halfspace -- solid )   
    <face> add-face ; inline

: slice-solid ( solid face  -- solid1 solid2 )
    [ [ clone ] bi@ flip-face add-face 
    [ "/outer/" append ] change-name  ] 2keep
    add-face [ "/inner/" append ] change-name 
; inline

: add-silhouette ( solid  -- solid )
   dup 
   ! find-adjacencies 
   faces>> { } 
   [ face-silhouette append ] reduce
   [ ] filter 
   <solid> 
        swap >>faces
        over dimension>> >>dimension 
!        over selected?>> >>selected?
        over name>> " silhouette " append 
                 pv number>string append 
        >>name
     !   ensure-adjacencies
   suffix-silhouettes ;

: find-silhouettes ( solid -- solid )
    { } >>silhouettes 
    dup dimension>> iota [ [ add-silhouette ] with-pv ] each 
; inline

: ensure-silhouettes ( solid  -- solid )
    dup  silhouettes>>  [ f = ] all?
    [ find-silhouettes  ]  when ; 

: get-pv-silhouette ( solid -- silhouette )   
    silhouettes>> 
    pv swap nth ; inline

: corner-added? ( solid corner -- ? ) 
    ! add corner to solid if it is inside solid
    [ ] 
    [ point-inside-or-on-solid? ] 
    [ swap corners>> member? not ] 
    2tri and
    [ suffix-corner drop t ] [ 2drop f ] if 
; inline

: process-corner ( solid faces corner -- )
    swapd 
    [ corner-added? ] keep swap ! test if corner is inside solid
    [ update-adjacent-faces ] 
    [ 2drop ]
    if ; inline

: compute-intersection ( solid faces -- )
    dup faces-intersection
    dup f = [ 3drop ] [ process-corner ]  if 
; inline

: test-faces-combinaisons ( solid n -- solid )
    [ dup faces>> ] dip among   
    over swap
    [ compute-intersection ] with each ;

: compute-adjacencies ( solid -- solid )
    dup dimension>> 
    MAX-FACE-PER-CORNER
    [a,b] 
    [ test-faces-combinaisons ] each 
;

: find-adjacencies ( solid -- solid ) 
    erase-old-adjacencies   
    compute-adjacencies
    filter-real-faces 
    t >>adjacencies-valid ;

: ensure-adjacencies ( solid -- solid ) 
    dup adjacencies-valid>> 
    [ find-adjacencies ] unless 
    ensure-silhouettes
    ; inline

: (non-empty-solid?) ( solid -- ? ) 
    [ dimension>> ] [ corners>> length ] bi < ; inline

: non-empty-solid? ( solid -- ? )   
    ensure-adjacencies (non-empty-solid?) ; inline

: refpoint-project ( solid -- solid ) 
    [ pv project-vector ] change-refpoint 
    propagate-refpoint
; inline

: face-project ( array face -- seq )
    backface? 
  [ 2drop f ]
    [   [ enlight-projection ] 
        [ initiate-solid-from-face ]
        [ intersections-into-faces ]  tri
        >>faces
        swap >>color
        refpoint-project
    ]    if ;


: link-faces-selected?  ( solid -- solid )
    [ ] [ faces>> ] 
    [ selected?>> [ >>selected? drop ] curry ] tri  
    each ; inline

: link-clone-selected? ( solid -- solid ) 
    [ clone ] [ selected?>> ] bi >>selected? ; inline

: solid-project ( lights ambient solid -- solids )
    link-clone-selected? 
    link-faces-selected?
    dup name>> " projection" append >>name
  ensure-adjacencies
    [ color>> ] [ faces>> ] bi [ 3array  ] dip
    [ face-project ] with map 
    [ ] filter 
    [ ensure-adjacencies ] map
 !   [ dup identity-hashcode swap ] H{ } clone map>assoc

;
 
: (solid-move) ( solid v move -- solid ) 
   curry [ map ] curry 
   [ dup faces>> ] dip call drop  
   unvalid-adjacencies ; inline


: if-selected ( solid quot -- solid )
    [ dup selected?>> value>> ] dip  when
; inline

: move-if-selected ( solid v quot -- solid )
    pick selected?>> value>> 
    [ (solid-move) ] [ 2drop ] if
; inline

: solid-translate ( solid v -- solid ) 
   [ [ face-translate ] move-if-selected ] keep 
   '[ [ _ v+ ] change-refpoint 
      propagate-refpoint
    ] if-selected 
; inline

: solid-transform ( solid m -- solid ) 
    [ face-transform ] move-if-selected ; inline 

: find-corner-in-silhouette ( s1 s2 -- elt bool )
    get-pv-silhouette ! pv swap silhouettes>> nth     
    swap corners>>
    [ point-inside-solid? ] with find swap ; inline

: valid-face-for-order ( solid point -- face )
    [ point-inside-face? not ] 
    [ drop face-orientation  0 = not ] 2bi and 
; inline

: check-orientation ( s1 s2 pt -- int )
    [ nip faces>> ] dip
    [ valid-face-for-order ] curry find swap
    [ face-orientation ] [ drop f ] if 
; inline

: (order-solid) ( s1 s2 -- int )
    2dup find-corner-in-silhouette
    [ check-orientation ] [ 3drop f ] if 
; inline

: order-solid ( solid solid  -- i ) 
    2dup (order-solid)
    [ 2nip ]
    [ swap (order-solid)
        [ neg ] [ f ] if*
    ] if* ; inline

: subtract ( solid1 solid2 -- seqsolids )
    faces>> swap clone ensure-adjacencies ensure-silhouettes  
    [ swap slice-solid drop ]  curry map
    [ non-empty-solid? ] filter
    [ ensure-adjacencies ] map
; inline

: solid= ( solid solid -- ? )               
    [ corners>> ]  bi@ = ; inline

: clip-solid ( solid solid -- seqsolids )
    [ ]
    [ solid= not ]
    [ order-solid -1 = ] 2tri 
    and
    [ get-pv-silhouette subtract ] 
    [  drop 1array ] 
    if 
; inline

M: solid +->XML
    "" swap
    {
    [ ID>> number>string "ID" append->XML ]
    [ name>> "name" append->XML ]
    [ dimension>> number>string "dimension" append->XML ]
    [ faces>> [ +->XML ] each ]
    [ color>> seq->str "color" append->XML ]  
    [ refpoint>> seq->str "refpoint" append->XML ]
    } cleave
    "solid" append->XML
;

