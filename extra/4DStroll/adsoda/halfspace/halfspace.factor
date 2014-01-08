! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry math sequences 4DStroll.adsoda.tools.solution2
sequences.deep math.vectors math.matrices 4DStroll.adsoda.tools  ;

IN: 4DStroll.adsoda.halfspace


: VERY-SMALL-NUM ( -- x ) 0.0000001  ; inline
: ZERO-VALUE ( -- x ) 0.0000001 ; inline


: constant+ ( v x -- w )  
    '[ [ _ + ] change-last ] keep ; inline

: translate ( u v -- w )   
    dupd     v* sum     constant+ ; inline

: transform ( u matrix -- w )
    [ swap m.v ] 2keep ! compute new normal vector    
    [
        [ [ abs ZERO-VALUE > ] find ] keep ! find a point on the frontier
        ! be sure it's not null vector
        last ! get constant
        swap /f neg swap ! intercept value
    ] dip  
    flip 
    nth
    [ * ] with map ! apply intercep value
    over v*
    sum  neg
    suffix ! add value as constant at the end of equation
;

: position-point ( halfspace v -- x ) 
    -1 suffix v* sum  ; inline

: point-inside-halfspace? ( halfspace v -- ? )       
    position-point VERY-SMALL-NUM  > ; inline

: point-inside-or-on-halfspace? ( halfspace v -- ? ) 
    position-point VERY-SMALL-NUM neg > ; inline

: get-intersection ( matrice -- seq )     
    [ 1 tail* ] map     flip first ; inline

: islenght=? ( seq n -- seq n ? ) 
    2dup [ length ] [ = ] bi*  ; inline

: compare-nleft-to-identity-matrix ( seq n -- ? ) 
    [ [ head ] curry map ] keep  identity-matrix m- 
    flatten
    [ abs ZERO-VALUE < ] all?
;

: valid-solution? ( matrice n -- ? )
    islenght=?
    [ compare-nleft-to-identity-matrix ]  
    [ 2drop f ] if ; inline

: intersect-hyperplanes ( matrice -- seq )
    [ solution dup ] [ first dimension ] bi
    valid-solution?     [ get-intersection ] [ drop f ] if ;

: compare-corners-roughly ( corner corner -- ? )
    2drop t ; inline
! : remove-inner-faces ( -- ) ;

: project-vector ( pv seq -- seq ) ! pv 
    [ head ] [ 1 +  tail ] 2bi append ; inline

