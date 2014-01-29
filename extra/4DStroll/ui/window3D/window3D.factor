! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel 
ui.gadgets
ui.gadgets.worlds
ui.render
opengl
opengl.gl
opengl.glu
ui.pens
4DStroll.ui.camera
math
math.vectors
accessors
namespaces
models
accessors
prettyprint
4DStroll.ui.3DspaceGL
calendar
timers
sequences
ui.gestures
variables
fry
combinators
ui.utils
literals
math.order
math.functions
opengl
fonts ui.text
;

IN: 4DStroll.ui.window3D

VAR: remove-hidden-solids?
VAR: orig
CONSTANT: translation-step 2
CONSTANT: rotation-step 3

CONSTANT: FOV $[ 2.0 sqrt 1 + ]
CONSTANT: NEAR-PLANE 1/1024.
CONSTANT: FAR-PLANE 2.0
CONSTANT: MOUSE-SCALE 1/20.

: frustum ( dim -- -x x -y y near far )
    dup first2 min v/n
    NEAR-PLANE FOV / v*n first2 [ [ neg ] keep ] bi@
    NEAR-PLANE FAR-PLANE ; inline

TUPLE: window3D  < gadget 3d-cam ; 

: set-modelview-matrix ( gadget -- )
    3d-cam>>
    { 
    [ pitch>> 1.0 0.0 0.0 glRotatef ]
    [ yaw>>   0.0 1.0 0.0 glRotatef ]
    [ rroll>> 0.0 0.0 1.0 glRotatef ]
    [ location>> vneg first3 glTranslatef ] 
    } cleave ;


: do-look-at ( gadget -- )
    3d-cam>>  camera-look-at gluLookAt ; inline

: <window3D>  ( model observer -- gadget )
    window3D  new 
    t >>clipped?
    t >>root?
    swap  
    [ projection-mode>> add-connection ] 2keep
    [ collision-mode>>  add-connection ] 2keep
    >>3d-cam 
    swap >>model 
; inline

M: window3D pref-dim* ( gadget -- dim )  
! dup interior>> pen-pref-dim
 drop { 300 300 } 
;


M: window3D draw-gadget* ( gadget -- )
    dup
    '[ _
    {
        [ drop 
        
         GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
            0.9 0.9 0.9 1.0 glClearColor
!           1.0 glClearDepth
            GL_LINE_SMOOTH glEnable
!            GL_LINE_SMOOTH_HINT GL_NICEST glHint
            GL_BLEND glEnable
           GL_DEPTH_TEST glEnable ! <<<<<
!            GL_CULL_FACE glEnable
!            GL_BACK glCullFace
!           GL_FRONT glCullFace

!           GL_LIGHTING glEnable
!           GL_LIGHT0 glEnable
!           GL_LEQUAL glDepthFunc

         GL_PROJECTION glMatrixMode glLoadIdentity 
        ]
!        [ dim>>  [ [ { 0 0 } ] dip gl-viewport ] ! define the area drawn
!            [ frustum glFrustum ]    bi ]
        [ drop
   !       -400.0 400.0 -400.0 400.0 0.0 4000.0 glOrtho
          60.0 1.0 0.1 3000.0 gluPerspective
           ! 3d-cam>> projection-mode>> value>> 1 =    
           ! [  ]
           ! [ -400.0 400.0 -400.0 400.0 0.0 4000.0 glOrtho ] if
        ]
      !  [ 3d-cam>> collision-mode>> value>> 
      !      \ remove-hidden-solids?  set ] 
   !         [  set-modelview-matrix ]
            [  do-look-at ]
        [ drop
           GL_MODELVIEW glMatrixMode
           glLoadIdentity  
!            GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
! 
            1.25 glLineWidth
!            glLoadIdentity
!            GL_COLOR_MATERIAL glEnable
!            GL_FRONT GL_AMBIENT_AND_DIFFUSE glColorMaterial
            ]

           [ model>> value>> [  space->GL ] when* ]
!            [ drop  { 10 10 } [ monospace-font "foo" draw-text ] with-translation  ]
           [ drop glFlush ]
            } cleave 
         

            ]    with-w/h
         !   with-translation
;

: tick ( gadget -- )  relayout-1  ; 


M: window3D graft* 
        dup find-gl-context 
        [ [ tick ] curry 100 milliseconds every ] keep 2drop ;

M: window3D ungraft* drop
       ! find-gl-context 
         ;

M: window3D model-changed nip relayout ; 

: mvt-3D-X ( gadget turn pitch -- )
    '[  _ camera-turn-left 
        _ camera-pitch-up 
     ] change-3d-cam  drop         
        ; inline

: mvt-3D-1 ( gadget -- )    90  0 mvt-3D-X  ; inline
: mvt-3D-2 ( gadget -- )     0 90 mvt-3D-X  ; inline
: mvt-3D-3 ( gadget -- )     0  0 mvt-3D-X  ; inline
: mvt-3D-4 ( gadget -- )    45 45 mvt-3D-X  ; inline


: mvt-3D-cam ( gadget quot -- ) 
    over [ [ 3d-cam>> ] dip call( -- ) ] dip swap >>3d-cam
    relayout-1 ; inline

! : rotation-3D-cam    ( gadget quot -- ) mvt-3D-cam ; inline
! : translation-3D-cam ( gadget quot -- ) mvt-3D-cam ; inline

window3D H{
    { T{ button-down f f 1 }     [ request-focus ] }
        { T{ key-down f f "q" }  
            [ [ rotation-step camera-turn-left ] mvt-3D-cam ] }
        { T{ key-down f f "f" } 
           [ [ rotation-step camera-turn-right ] mvt-3D-cam ] }
        { T{ key-down f f "c" }    
            [ [ rotation-step camera-pitch-down ] mvt-3D-cam ] }
        { T{ key-down f f "e" }  
            [ [ rotation-step camera-pitch-up ] mvt-3D-cam ] }
        { T{ key-down f f "s" }  
            [ [ rotation-step camera-roll-left ] mvt-3D-cam ] }
        { T{ key-down f f "d" } 
           [ [ rotation-step camera-roll-right ] mvt-3D-cam ] }



!        { T{ key-down f { C+ } "j" } 
!            [ [      step-camera ] rotation-3D-cam ] }
!        { T{ key-down f { C+ } "m" } 
!            [ [ neg step-camera ] rotation-3D-cam ]  }
!        { T{ key-down f { C+ } "i" } 
!            [ [ camera-roll-left ] rotation-3D-cam ]  }
!        { T{ key-down f { C+ } ";" } 
!            [ [ camera-roll-right ] rotation-3D-cam ]  }
!        { T{ key-down f { C+ } "k" } 
!            [ [ camera-roll-left ] rotation-3D-cam ]  }
!        { T{ key-down f { C+ } "l" } 
!            [ [ camera-roll-right ] rotation-3D-cam ]  }


        { T{ key-down f f "j" }  
            [ [ translation-step camera-strafe-left ] mvt-3D-cam ]  }
        { T{ key-down f f "m" } 
            [ [ translation-step camera-strafe-right ] mvt-3D-cam ]  }
        { T{ key-down f f "i" }    
            [ [ translation-step camera-strafe-up ] mvt-3D-cam ]  }
        { T{ key-down f f ";" }  
            [ [ translation-step camera-strafe-down ] mvt-3D-cam ]  }
        { T{ key-down f f "k" }    
            [ [ translation-step camera-strafe-front ] mvt-3D-cam ]  }
        { T{ key-down f f "l" }  
            [ [ translation-step camera-strafe-back ] mvt-3D-cam ]  }

        { T{ key-down f f "n" }  
            [ 3d-cam>> reset-camera drop ]  }



        { T{ key-down f f "1" } [ mvt-3D-1 ] }
        { T{ key-down f f "2" } [ mvt-3D-2 ] }
        { T{ key-down f f "3" } [ mvt-3D-3 ] }
        { T{ key-down f f "4" } [ mvt-3D-4 ] }

    } set-gestures
  
! TODO hand-click-loc to find back the solid wich was choosen



