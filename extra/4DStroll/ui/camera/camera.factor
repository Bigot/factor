! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math arrays math.vectors combinators
namespaces
math.constants 
sequences accessors models
memoize literals
math.vectors.simd math.matrices.simd typed ;
IN: 4DStroll.ui.camera

TUPLE: camera  
    { location float-4 }
    { yaw float }
    { pitch float }
    { rroll float }
    projection-mode collision-mode ;

: reset-camera ( camera -- camera ) 
    float-4{ 30.0 175.0 74.0 1.0 } clone >>location 
    -48.0 >>yaw
    -18.0 >>pitch
    3.0 >>rroll
    0 <model> >>projection-mode 
    f <model> >>collision-mode

    ; inline


: <camera> ( -- object )
    camera new
    reset-camera
;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: degrees ( deg -- rad )
    pi 180.0 / * ; inline


TYPED: eye-rotate ( yaw: float pitch: float rroll: float 
                    v: float-4 -- v': float-4 )
   { [ float-4{  0.0 -1.0  0.0 0.0 } swap degrees rotation-matrix4 ]
     [ float-4{  0.0  0.0 -1.0 0.0 } swap degrees rotation-matrix4 m4. ]
     [ float-4{ -1.0  0.0  0.0 0.0 } swap degrees rotation-matrix4 m4. ]
     [ m4.v ] 
    } spread
    
    float-4{ t t t f } vand ;

MEMO: (-vector) ( x x -- seq )
    float-4{ 0.0 0.0 0.0 1.0 } [ set-nth ] keep
;

: forward-vector ( camera step -- v )
    [ yaw>> 0.0 0.0 ] dip
    2 (-vector)
     vneg eye-rotate ; inline
: rightward-vector ( camera step -- v )
    [ yaw>> 0.0 0.0 ] dip 
    0 (-vector) eye-rotate ; inline

: upward-vector ( camera step -- v )
    [ rroll>> 0.0 0.0 ] dip
    1 (-vector) eye-rotate ; inline


: camera-strafe-front ( camera step -- camera ) 
  dupd forward-vector [ v+ ] curry change-location
; inline

: camera-strafe-back ( camera step -- camera ) 
  dupd forward-vector [ v- ] curry change-location
; inline

: camera-strafe-up ( camera step -- camera )
 dupd upward-vector [ v+ ] curry change-location
 ; inline

: camera-strafe-down ( camera step -- camera )
 dupd upward-vector [ v- ] curry change-location ; inline

: camera-strafe-left ( camera step -- camera )
 dupd rightward-vector [ v- ] curry change-location ; inline

: camera-strafe-right ( camera step -- camera )
 dupd rightward-vector [ v+ ] curry change-location ; inline

