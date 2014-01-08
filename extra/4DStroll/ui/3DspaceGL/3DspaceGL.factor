! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences math 
math.libm assocs sorting math.vectors math.matrices 4DStroll.adsoda.halfspace
4DStroll.adsoda.face 4DStroll.adsoda.solid 4DStroll.adsoda.space
opengl.gl opengl.demo-support assocs
;
IN: 4DStroll.ui.3DspaceGL


! --------------------------------------------------------------
! 3D rendering
! --------------------------------------------------------------

: gl-vertex ( point -- )   
    first3 glVertex3d
; inline


: face-reference ( face -- halfspace point vect )
       [ halfspace>> ] 
       [ touching-corners>> first ] 
       [ touching-corners>> second ] tri 
       over v-
; inline

: theta ( v halfspace point vect -- v x )
   [ [ over ] dip v- ] dip    
   [ cross dup norm >float ]
   [ v. >float ]  
   2bi 
   fatan2
   -rot v. 
   0 < [ neg ] when
; inline

: ordered-face-points ( face -- corners )  
    [ touching-corners>> 1 head ] 
    [ touching-corners>> 1 tail ] 
    [ face-reference [ theta ] 3curry ]         tri
    { } map>assoc    sort-values keys 
    append
    ; inline

: point->GL  ( point -- )   gl-vertex ; inline
! : points->GL ( array -- )   do-cycle [ point->GL ] each ;

: selected->color ( bool -- x x x x )
    [ 1 0.4 0.7 1 ] [ 0 0 0 1 ] if
; inline

: face->GL (  face selected color -- )
   [ ordered-face-points ] 2dip
   [ first3 1.0 glColor4d GL_POLYGON [ [ point->GL  ] each ] 
        do-state ] curry
   swap
   [  selected->color glColor4d GL_LINE_LOOP [ [ point->GL  ] each ]
        do-state ] curry
   bi
; inline

: solid->GL ( solid -- )   
    [ faces>> ] 
    [ selected?>> value>> ]   
    [ color>> ] tri
    [ face->GL ] 2curry each 
; inline

: space->GL ( space -- )
    solids>> values
    [ solid->GL ] each 
; inline





