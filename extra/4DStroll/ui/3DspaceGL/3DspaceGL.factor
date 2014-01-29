! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences math 
math.libm assocs sorting math.vectors math.matrices 4DStroll.adsoda.halfspace
4DStroll.adsoda.face 4DStroll.adsoda.solid 4DStroll.adsoda.space
opengl.gl opengl.demo-support assocs combinators
opengl
fonts ui.text
;
IN: 4DStroll.ui.3DspaceGL


! --------------------------------------------------------------
! 3D rendering
! --------------------------------------------------------------

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
   0 > [ neg ] when ! TODO verif
; inline

: ordered-face-points ( face -- corners )  
    [ touching-corners>> 1 head ] 
    [ touching-corners>> 1 tail ] 
    [ face-reference [ theta ] 3curry ]         tri
    { } map>assoc    sort-values keys 
    append
    ; inline

: point->GL  ( point -- )     first3 glVertex3f ; inline
! : points->GL ( array -- )   do-cycle [ point->GL ] each ;

: selected->color ( bool -- x x x )
    [ 1 0.4 0.7 ] [ 0 0 0 ] if
; inline


: surface->GL ( face seq -- )
    swap color>>
    first3 glColor3f 
    dup length { 
        { 3 [ GL_TRIANGLES ] }
        { 4 [ GL_QUADS ] }
        [ drop  GL_POLYGON ]
    } case
    [ [ point->GL  ] each ] do-state
; inline

: edge->GL ( face seq -- )
    swap selected?>> value>> 
    selected->color glColor3f
 
    GL_LINE_LOOP 
    [ [ point->GL  ] each ] do-state
; inline

: face->GL ( face -- ) 
    dup
    ordered-face-points 
    [ surface->GL ] 2keep  
!    [ { } swap [ prefix ] each surface->gl ] 2keep
    edge->GL  

; inline


: with-3Dtranslation ( loc quot -- )
    [ [ first3 glTranslated ] dip call ] do-matrix ; inline

: (refpoint->GL) ( solid -- )
 [ color>> first3 glColor3f ] keep 
    refpoint>> 
    3 glPointSize
    GL_POINTS [ point->GL ] do-state
; inline

: refpoint->GL ( solid -- )
   [ dup (refpoint->GL) ] if-selected drop
; inline

: solid->GL ( solid -- ) 
    [ refpoint->GL ] keep 
    [ faces>> ] 
    [ selected?>> [ >>selected? ] curry map ]
    [ color>> [ >>color ] curry map ] 
    tri
    [ face->GL ] each 
; inline

: space->GL ( space -- )
    solids>> values
    [ solid->GL ] each 
 !   { 10 10 } [ monospace-font "foo" draw-text ] with-translation 

; inline


