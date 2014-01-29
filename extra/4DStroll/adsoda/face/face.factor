! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors  4DStroll.adsoda.nDobject 4DStroll.adsoda.halfspace 
4DStroll.adsoda.tools arrays prettyprint fry 4DStroll.adsoda.tools.combinators
variables math.parser models
combinators math.vectors math.order sequences math namespaces ;
IN: 4DStroll.adsoda.face


QUALIFIED-WITH: namespaces name

VAR: pv
: >pv ( x -- ) \ pv set ; inline 
: pv> ( -- x ) pv ; inline 

: with-pv ( i quot -- )  \ pv swap with-variable ; inline


TUPLE: face < nDobject { halfspace array } touching-corners 
    adjacent-faces ;

: <face> ( v -- tuple )       
    face new 
    t >>selected?
    swap >>halfspace ; inline

M: face >log 
     {
        [ halfspace>> "halfspace : " pprint . ] 
        [ touching-corners>> "touching corners : " pprint . ]
    }   cleave
    ;

M: face >table 
!     {
        
         halfspace>> seq>string "   face : " 
    swap 2array ! "halfspace : " prepend ] 
!        [ touching-corners>> "touching corners : " pprint . ]
!    }   cleave
    ;

: flip-face ( face -- face ) 
    [ vneg ] change-halfspace ; inline

: erase-face-touching-corners ( face -- face ) 
    f >>touching-corners ; inline

: erase-face-adjacent-faces ( face -- face )   
    f >>adjacent-faces ; inline

: faces-intersection ( faces -- v )  
    [ halfspace>> ] map intersect-hyperplanes ; inline

: face-translate ( face v -- face ) 
    [ translate ] curry change-halfspace ; inline

: face-transform ( face m -- face )
    [ transform ] curry change-halfspace ; inline

: face-orientation ( face -- x )  
    pv swap halfspace>> nth sgn ; inline

: backface? ( face -- face ? )      
    dup face-orientation 0 <= ; inline
    
: pv-factor ( face -- f face )     
    halfspace>> [ pv swap nth [ * ] curry ] keep ; inline

: suffix-touching-corner ( face corner -- face ) 
    [ suffix ] curry   change-touching-corners ; inline

: real-face? ( face -- ? )
    [ touching-corners>> length ] 
    [ halfspace>> dimension ] bi 
    >= ; inline

: (add-to-adjacent-faces) ( face face -- face )
    over adjacent-faces>> 2dup member?
    [ 2drop ] [ swap suffix >>adjacent-faces ] if ; inline

: add-to-adjacent-faces ( face face -- face )
    2dup =   
    [ drop ] 
    [ (add-to-adjacent-faces) ] 
    if ; inline

: update-adjacent-faces ( faces corner -- )
   '[ [ _ suffix-touching-corner drop ] each ] keep 
    2 among [ 
        [ first ] keep second  
        [ add-to-adjacent-faces drop ] 2keep 
        swap add-to-adjacent-faces drop  
    ] each ; 

: face-project-dim ( face -- x )  
    halfspace>> length 2 -  ; inline

: apply-light ( color light normal -- u )
    over direction>>  v. 
    neg dup 0 > 
    [ 
        [ color>> swap ] dip 
        [ * ] curry map v+ 
        [ 1 min ] map 
    ] 
    [ 2drop ] 
    if
;

: enlight-projection ( array face -- color )
    ! array = lights + ambient color
  !  [ [ third ] [ second ] [ first ] tri ]
  !  [ halfspace>> \ pv get-global project-vector normalize ] bi*
  !  [ apply-light ] curry each
  !  v*
! problem => solution simple
drop third
;

: (intersection-into-face) ( face-init face-adja quot -- face )
    [
        [  [ pv-factor ] bi@ 
           roll 
            [ map ] 2bi@
           v-
        ] 2keep
        [ touching-corners>> ] bi@
        [ swap  [ = ] curry find  nip f = ] curry find nip
    ] dip  over
     [
        call
        dupd
        point-inside-halfspace? [ vneg ] unless 
        <face> 
     ] [ 3drop f ] if 
    ; inline

: intersection-into-face ( face-init face-adja -- face )
    [ [ pv project-vector ] bi@ ]     
    (intersection-into-face) ; inline 

: intersection-into-silhouette-face ( face-init face-adja -- face )
    backface?
    [ [ ] (intersection-into-face) ] [ 2drop f ]  if
    ; inline


: intersections-into-faces ( face -- faces )
    [ parent>> ] keep
    [ name>> " proj " append 
                 pv number>string append ] keep
    clone dup  
    adjacent-faces>> [ intersection-into-face ] with 
    map 
    [ ] filter 
    swap [ >>name ] curry map        
    swap [ >>parent ] curry map
    ;

: (face-silhouette) ( face -- faces )
!    [ parent>> ] keep
!    [ name>> ] keep
    clone dup adjacent-faces>>
    [ intersection-into-silhouette-face ] with map 
    [ ] filter
!    swap [ >>name ] curry map        
!    swap [ >>parent ] curry map
; inline

: face-silhouette ( face -- faces )     
    backface? [ drop f ] [ (face-silhouette) ] if ;

: point-inside-or-on-face? ( face v -- ? ) 
    [ halfspace>> ] dip point-inside-or-on-halfspace?  ; inline

: point-inside-face? ( face v -- ? ) 
    [ halfspace>> ] dip  point-inside-halfspace? ; inline


M: face +->XML  
    halfspace>> 
    seq->str   
    "face" append->XML
;

M: face ->selected? selected?>> set-model ;


