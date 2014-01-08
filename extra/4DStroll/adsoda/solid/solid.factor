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

TUPLE: solid < nDobject dimension silhouettes faces corners
adjacencies-valid  ;

: <solid> ( -- tuple ) 
    solid new 
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
    swap selected?>> >>selected? 
    ;

: erase-old-adjacencies ( solid -- solid )
    erase-solid-corners
    [ dup [ erase-face-touching-corners erase-face-adjacent-faces drop ] each ]
    change-faces ;

: point-inside-solid? ( solid point -- ? )
    [ faces>> ] dip [ point-inside-face? ] curry  all?   ; inline

: point-inside-or-on-solid? ( solid point -- ? )
    [ faces>> ] dip [ point-inside-or-on-face? ] curry  all?   ; inline

: unvalid-adjacencies ( solid -- solid )  
    erase-old-adjacencies f >>adjacencies-valid erase-silhouettes ;

: add-face ( solid face -- solid ) 
    suffix-face unvalid-adjacencies ; inline

: cut-solid ( solid halfspace -- solid )   
    <face> add-face ; inline

: slice-solid ( solid face  -- solid1 solid2 )
    [ [ clone ] bi@ flip-face add-face 
    [ "/outer/" append ] change-name  ] 2keep
    add-face [ "/inner/" append ] change-name ;

! -------------


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
   suffix-silhouettes ; inline

: find-silhouettes ( solid -- solid )
    { } >>silhouettes 
    dup dimension>> iota [ [ add-silhouette ] with-pv ] each ;

: ensure-silhouettes ( solid  -- solid )
    dup  silhouettes>>  [ f = ] all?
    [ find-silhouettes  ]  when ; 

! ------------

: corner-added? ( solid corner -- ? ) 
    ! add corner to solid if it is inside solid
    [ ] 
    [ point-inside-or-on-solid? ] 
    [ swap corners>> member? not ] 
    2tri and
    [ suffix-corner drop t ] [ 2drop f ] if ;

: process-corner ( solid faces corner -- )
    swapd 
    [ corner-added? ] keep swap ! test if corner is inside solid
    [ update-adjacent-faces ] 
    [ 2drop ]
    if ;

: compute-intersection ( solid faces -- )
    dup faces-intersection
    dup f = [ 3drop ] [ process-corner ]  if ;

: test-faces-combinaisons ( solid n -- solid )
    [ dup faces>> ] dip among   
    over swap
    [ compute-intersection ] with each ;

: compute-adjacencies ( solid -- solid )
    dup dimension>> 
    MAX-FACE-PER-CORNER
    [a,b] 
    [ test-faces-combinaisons ] each ;

: find-adjacencies ( solid -- solid ) 
    erase-old-adjacencies   
    compute-adjacencies
    filter-real-faces 
    t >>adjacencies-valid ;

: ensure-adjacencies ( solid -- solid ) 
    dup adjacencies-valid>> 
    [ find-adjacencies ] unless 
    ensure-silhouettes
    ;

: (non-empty-solid?) ( solid -- ? ) 
    [ dimension>> ] [ corners>> length ] bi < ; inline


: non-empty-solid? ( solid -- ? )   
    ensure-adjacencies (non-empty-solid?) ; inline

: face-project ( array face -- seq )
    backface? 
  [ 2drop f ]
    [   [ enlight-projection ] 
        [ initiate-solid-from-face ]
        [ intersections-into-faces ]  tri
        >>faces
        swap >>color        
    ]    if ;

: propagate-selection ( solid -- solid )
    [ ] 
    [ faces>> ] 
    [ selected?>> [ >>selected? drop ] curry ] tri  
    each
;

: solid-project ( lights ambient solid -- solids )
    [ clone ] [ selected?>> ] bi >>selected? 
    propagate-selection
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

: solid-translate ( solid v -- solid ) 
    over selected?>> value>> [
        [ face-translate ] (solid-move) 
    ] [ drop ] if
    ;

: solid-transform ( solid m -- solid ) 
    over selected?>> value>> [
        [ face-transform ] (solid-move) 
    ] [ drop ] if
    ; 

: find-corner-in-silhouette ( s1 s2 -- elt bool )
    pv swap silhouettes>> nth     
    swap corners>>
    [ point-inside-solid? ] with find swap ;

: valid-face-for-order ( solid point -- face )
    [ point-inside-face? not ] 
    [ drop face-orientation  0 = not ] 2bi and ;

: check-orientation ( s1 s2 pt -- int )
    [ nip faces>> ] dip
    [ valid-face-for-order ] curry find swap
    [ face-orientation ] [ drop f ] if ;

: (order-solid) ( s1 s2 -- int )
    2dup find-corner-in-silhouette
    [ check-orientation ] [ 3drop f ] if ;

: order-solid ( solid solid  -- i ) 
    2dup (order-solid)
    [ 2nip ]
    [   swap (order-solid)
        [ neg ] [ f ] if*
    ] if* ;

: subtract ( solid1 solid2 -- solids )
    faces>> swap clone ensure-adjacencies ensure-silhouettes  
    [ swap slice-solid drop ]  curry map
    [ non-empty-solid? ] filter
    [ ensure-adjacencies ] map
; inline

: get-silhouette ( solid -- silhouette )   
    silhouettes>> 
    pv swap nth ; inline

: solid= ( solid solid -- ? )               
    [ corners>> ]  bi@ = ; inline


: clip-solid ( solid solid -- solids )
    [ ]
    [ solid= not ]
    [ order-solid -1 = ] 2tri 
    and
    [ get-silhouette subtract ] 
    [  drop 1array ] 
    if 
    
    ;

: (solids-silhouette-subtract) ( solids solid -- solids ) 
     [  clip-solid append ] curry { } -rot each 
     ; inline

: solids-silhouette-subtract ( solids i solid -- solids )
! solids is an array of 1 solid arrays
      [ (solids-silhouette-subtract) ] curry map-but 
; inline 


