! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING:  kernel accessors arrays   4DStroll.adsoda.nDobject
4DStroll.adsoda.face
4DStroll.adsoda.spacegroup
4DStroll.adsoda.solid math continuations
4DStroll.adsoda.tools.combinators
math.parser
prettyprint combinators sequences math.vectors assocs
fry ;
IN: 4DStroll.adsoda.space

: remove-hidden-solids? ( -- x ) f ; inline


TUPLE: space < nDobject solids ambient-color lights
spacegroups mainspacegroup activegroup ;


: suffix-spacegroups-array ( space group -- space group )
   [ [ spacegroups>> ] dip
    define-ID rot set-at ] 2keep
    ; inline

: suffix-activegroup ( space nDobject -- space )
    [ dup activegroup>> content>> ] dip
    define-ID rot set-at 
    ; inline

: union-activegroup ( space1 space2 -- space1 )
    [ dup activegroup>> dup content>> ] 
    [ activegroup>> content>> ] bi*
    assoc-union >>content >>activegroup
    ; inline


: suffix-mainspacegroup ( space nDobject -- space )
    [ dup mainspacegroup>> content>> ] dip
    define-ID rot set-at 
    ; inline


: <space> ( -- space )     
    space new 
    H{ } clone >>solids
    H{ } clone >>spacegroups
    <spacegroup> 
    suffix-spacegroups-array
    [ >>mainspacegroup ] keep 
    >>activegroup

; inline

M: space >log 
     {
        [ dimension>> "dimension : " pprint . ] 
        [ ambient-color>> "ambient-color : " pprint . ]
        [ solids>> "composed of solids : " pprint [ nip >log ]
        assoc-each ]
        [ lights>> "composed of lights : " pprint [ >log ] each ] 
    }   cleave
    ;

M: space >table 
  { } swap  {
        [ name>> "name : " swap 2array suffix ] 
        [ color>> seq>string "color : " swap 2array suffix ]         
        [ ambient-color>> seq>string "ambient-color : " swap 2array suffix ]
        [ solids>> [ nip >table append ] assoc-each ]
        [ lights>> [ >table append ] each ] 
    }   cleave
    ;


M: space ->selected? mainspacegroup>> ->selected? ;

: suffix-solids-array ( space solid -- space solid )
   [ [ solids>> ] dip
    define-ID rot set-at ] 2keep
    ; inline

: union-solids-array ( space1 space2 -- space1 space2 )
   2dup 
   [ solids>> ] bi@ assoc-union  
   swap [ >>solids ] dip 
    ; inline


: suffix-lights ( space light -- space ) 
    [ suffix ] curry change-lights ; inline

: space-union-solids ( space space -- space )
    union-solids-array 
    union-activegroup
  ; inline

: space-suffix-solids ( space solid -- space )
    suffix-solids-array 
    suffix-activegroup
  ; inline

: space-suffix-lights ( space light -- space ) 
    suffix-lights ; inline

: clear-space-solids ( space -- space )     
    H{ } clone >>solids ; inline

: space-solids-apply ( space quot -- space ) 
    [ dup solids>> ] dip assoc-each
; inline

: space-solids-filter ( space quot -- space ) 
    [ dup solids>> ] dip assoc-filter  >>solids
; inline

: space-ensure-solids ( space -- space ) 
    [ nip ensure-adjacencies drop ] space-solids-apply ; inline

! : space-unvalid-adj-solids ( space -- space ) 
!    [ [ unvalid-adjacencies ] map ] change-solids ; inline

: eliminate-empty-solids ( space -- space ) 
    [ nip non-empty-solid? ] space-solids-filter 
    ; inline

: remove-from-spacegroups ( space id -- ) 
    over spacegroups>> delete-at drop ; inline


: delete-selected-solids ( space -- space ) 
    [ nip selected?>> value>> not ] space-solids-filter
    dup 
    mainspacegroup>> 
    [ [ nip selected?>> value>> not ] assoc-filter ]
    change-content drop
    ; inline

: group-selected-ndobjects ( space -- space ) 
    dup mainspacegroup>> content>>
    [ nip selected?>> value>> ] assoc-partition ! true false   
    <spacegroup> 
    rot >>content
    pick dimension>> >>dimension
    [ [ dup mainspacegroup>> ] dip >>content >>mainspacegroup ] dip
    suffix-spacegroups-array 
    suffix-mainspacegroup
    dup t swap ->selected?
    ! to be cleaned
    ; inline


: remove-group-from-mainspacegroup ( space id value -- ) 
    [ mainspacegroup>> content>> ] 2dip
    [ over delete-at ] dip 
    content>>
    swap [ swapd set-at ] curry assoc-each
    ;

: ungroup-selected-ndobjects ( space -- space ) 
! ignore non group object
    dup
    mainspacegroup>> content>>
    [ nip selected?>> value>> ] assoc-filter
    over [ -rot 
        [ remove-group-from-mainspacegroup ] 3keep
        drop
        remove-from-spacegroups
    ] curry assoc-each 
;

: space-transform ( space m -- space ) 
    '[ nip _ solid-transform drop ] space-solids-apply
    ; inline

: space-translate ( space v -- space ) 
    '[ nip _ solid-translate drop ] space-solids-apply ; inline

: describe-space ( space -- ) 
    solids>>  [  nip
        [ corners>>  [ pprint ] each ] 
        [ name>> . ] 
        bi 
    ] assoc-each ; inline

: solids->assoc ( seq -- assoc )
    [ dup identity-hashcode swap ] 
            H{ } clone map>assoc
; inline

! TODO H{
: (solids-silhouette-subtract) ( solids solid -- solids ) 
!     [  clip-solid solids->assoc assoc-union ] curry 
!     H{ } clone -rot 
!     assoc-each 
2drop H{ } clone
; inline

: solids-silhouette-subtract ( solids i solid -- solids )
! solids is an array of 1 solid arrays
!      [ (solids-silhouette-subtract) ] curry assoc-each-but 
3drop H{ } clone
; inline 

: remove-hidden-solids ( space -- space ) 
! We must include each solid in a sequence because during substration 
! a solid can be divided in more than on solid
! TODO H{
   dup
    solids>>
        [  [ over H{ } clone [ set-at ] keep ] assoc-map ] 
        [ assoc-size ] 
        [ ] 
        tri     
        [ solids-silhouette-subtract ] 2each
        { } [ append ] reduce 

! [ nip non-empty-solid? ] assoc-filter 
    >>solids
    
    eliminate-empty-solids
;

: space-project-name ( old new -- old new )
    over name>> 
    " projection axis " pv> number>string append
    append >>name
; inline

: space-project-lights ( old new -- old new )
    ! TODO project lights
; inline


: space-project-solids ( old new -- old new )
! verify when solids list is empty
    over
        [ solids>> clone ] 
        [ lights>> ] 
        [ ambient-color>> ]  tri 
        ! stack : H{ solids }  { lights }  color
        '[ nip _ _ rot solid-project 
            solids->assoc 
            assoc-union
         ]
        H{ } clone -rot
        assoc-each
     >>solids
;

: space-project ( space i -- space )
  [ 
     remove-hidden-solids? [ remove-hidden-solids ] when
    ! 
        <space>  
        over dimension>> 1 -  >>dimension
        over ambient-color>> clone >>ambient-color
        space-project-name
        space-project-lights
        space-project-solids
        nip
 !       projected-space 
      ! remove-inner-faces 
      ! 
        eliminate-empty-solids
        space-ensure-solids
    ] with-pv 
; inline

: middle-of-space ( space -- point )
    ! only take into account selected solid 
    space-ensure-solids
    solids>> values 
    [ selected?>> value>> ] filter
    dup empty?
     [ drop { 0 0 0 } ] [
        [ corners>> ] map concat
        [ [ ] [ v+ ] map-reduce ] [ length ] bi v/n
    ] if

; inline


M: space +->XML 
    "" swap
 {
    [  name>> "name" append->XML ]
    [ dimension>> number>string "dimension" append->XML ]
    [ mainspacegroup>> content>> [ nip +->XML ] assoc-each ]
    [ lights>> [ +->XML ] each ]
    } cleave
    "space" append->XML
    "" swap   "model" append->XML

;


