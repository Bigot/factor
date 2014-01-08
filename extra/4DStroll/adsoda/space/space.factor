! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING:  kernel accessors arrays   4DStroll.adsoda.nDobject
4DStroll.adsoda.face
4DStroll.adsoda.solid math continuations
math.parser
prettyprint combinators sequences math.vectors assocs
fry ;
IN: 4DStroll.adsoda.space

: remove-hidden-solids? ( -- x ) f ; inline


TUPLE: space < nDobject dimension solids ambient-color lights  ;

: <space> ( -- space )     
    space new 
    H{ } clone >>solids
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


: suffix-solids ( space solid -- space )
!    [ suffix ] curry change-solids 
     [ dup  solids>> ] dip
   dup identity-hashcode rot set-at 
    ; inline

: suffix-lights ( space light -- space ) 
    [ suffix ] curry change-lights ; inline

: clear-space-solids ( space -- space )     
    H{ } clone >>solids ; inline

: space-ensure-solids ( space -- space ) 
    dup 
    solids>>
    [ nip ensure-adjacencies drop ] assoc-each ; inline

! : space-unvalid-adj-solids ( space -- space ) 
!    [ [ unvalid-adjacencies ] map ] change-solids ; inline



: eliminate-empty-solids ( space -- space ) 
    dup
    solids>>
    [ nip non-empty-solid? ] assoc-filter 
    >>solids
    ; inline

: space-apply ( space quot -- space ) 
    [ dup solids>> ] dip assoc-each
; inline

: space-transform ( space m -- space ) 
    '[ nip _ solid-transform drop ] space-apply
    ; inline

: space-translate ( space v -- space ) 
    '[ nip _ solid-translate drop ] space-apply ; inline

: describe-space ( space -- ) 
    solids>>  [  nip
        [ corners>>  [ pprint ] each ] 
        [ name>> . ] 
        bi 
    ] assoc-each ;

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
        ! H{ solids } / { lights } / color
        '[ nip _ _ rot solid-project 
            [ dup identity-hashcode swap ] 
            H{ } clone map>assoc 
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
; 

: middle-of-space ( space -- point )
    ! only take into account selected solid or all ? 
    space-ensure-solids
    solids>> values 
    [ selected?>> value>> ] filter
    dup empty?
     [ drop { 0 0 0 } ] [
        [ corners>> ] map concat
        [ [ ] [ v+ ] map-reduce ] [ length ] bi v/n
    ] if

;

: delete-selected-solids ( space -- space ) 
    solids>>
    [ nip selected?>> value>> not ] assoc-filter 
    ! ] change-solids
!    space-unvalid-adj-solids
!    space-ensure-solids
    ; inline


