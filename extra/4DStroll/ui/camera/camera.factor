! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math arrays math.vectors combinators
namespaces
math.constants 
sequences accessors models
memoize literals math.trig
math.vectors.simd math.matrices.simd typed ;
IN: 4DStroll.ui.camera

TUPLE: camera  
    { location float-4 }
    { yaw float }
    { pitch float }
    { rroll float }
    projection-mode collision-mode ;

: reset-camera ( camera -- camera ) 
    float-4{ 500.0 0.0 0.0 1.0 } clone >>location 
    0.0 >>yaw
    0.0 >>pitch
    0.0 >>rroll
    0 <model> >>projection-mode 
    f <model> >>collision-mode

    ; inline

: <camera> ( -- object )  camera new reset-camera ; inline

: camera-pitch-up   ( camera angle -- camera ) 
   [ - ] curry change-pitch ; inline

: camera-pitch-down ( camera angle -- camera )     
   [ + ] curry change-pitch ; inline

: camera-turn-left  ( camera angle -- camera )     
   [ - ] curry change-yaw  ; inline

: camera-turn-right ( camera angle -- camera )  
   [ + ] curry change-yaw  ; inline 

: camera-roll-left  ( camera angle -- camera ) 
   [ - ] curry change-rroll  ; inline

: camera-roll-right ( camera angle -- camera )     
   [ + ] curry change-rroll ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! roll-until-horizontal
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


! : distance ( camera camera -- n ) 
!   [ location>> ] bi@ v- [ sq ] map sum sqrt ; inline

! : camera-move-by ( camera point -- camera ) 
!   [ v+ ] curry change-position ; inline


TYPED: eye-rotate ( yaw: float pitch: float rroll: float 
                    v: float-4 -- v': float-4 )
   { [ float-4{  0.0 0.0  -1.0 0.0 } swap deg>rad rotation-matrix4 ]
     [ float-4{  0.0  -1.0  0.0 0.0 } swap deg>rad rotation-matrix4 m4. ]
     [ float-4{ -1.0  0.0  0.0 0.0 } swap deg>rad rotation-matrix4 m4. ]
     [ m4.v ] 
    } spread
    
    float-4{ t t t f } vand ;

: (vector) ( x x -- seq )
     float-4{ 0.0 0.0 0.0 1.0 } clone ! float-4-boa 
     [ set-nth ] keep
; inline

: camera-angles ( camera -- yaw pitch roll ) 
    [ yaw>> ] [ pitch>> ] [ rroll>> ] tri
; inline

: (n-vector) ( camera step mth -- v )
    [ camera-angles ] 2dip
    (vector)   eye-rotate
; inline

: forward-vector   ( camera step -- v ) 0 (n-vector) ; inline
: rightward-vector ( camera step -- v ) 1 (n-vector) ; inline
: upward-vector    ( camera step -- v ) 2 (n-vector) ; inline


: camera-look-at ( camera -- x x x x x x x x x )
    { 
    [ location>> [ first3 ] keep ]
    [ 10 forward-vector v- first3 ]
    [ 10 upward-vector first3 ] 
    } cleave 
;

: camera-strafe-front ( camera step -- camera ) 
  dupd forward-vector [ v- ] curry change-location ; inline

: camera-strafe-back ( camera step -- camera ) 
  dupd forward-vector [ v+ ] curry change-location ; inline

: camera-strafe-up ( camera step -- camera )
  dupd upward-vector [ v+ ] curry change-location ; inline

: camera-strafe-down ( camera step -- camera )
  dupd upward-vector [ v- ] curry change-location ; inline

: camera-strafe-left ( camera step -- camera )
  dupd rightward-vector [ v- ] curry change-location ; inline

: camera-strafe-right ( camera step -- camera )
  dupd rightward-vector [ v+ ] curry change-location ; inline

