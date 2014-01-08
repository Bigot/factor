! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel make grouping sequences math.trig math.functions
math memoize ;
IN: 4DStroll.adsoda.tools.math


: quot-to-matrix ( quot width -- matrix ) 
    [ { } make ] dip group nip ; inline


MEMO: Rz ( angle -- Rx ) deg>rad
[ dup cos ,     dup sin neg ,   0 ,
  dup sin ,     dup cos ,       0 ,
  0 ,           0 ,             1 , ] 3 quot-to-matrix ;

MEMO: Ry ( angle -- Ry ) deg>rad
[ dup cos ,     0 ,             dup sin ,
  0 ,           1 ,             0 ,
  dup sin neg , 0 ,             dup cos , ] 3 quot-to-matrix ;

MEMO: Rx ( angle -- Rz ) deg>rad
[ 1 ,           0 ,             0 ,
  0 ,           dup cos ,       dup sin neg ,
  0 ,           dup sin ,       dup cos , ] 3 quot-to-matrix ;


MEMO: Rxy ( angle -- Rxy ) deg>rad
[ 1.0 ,  0.0 , 0.0 ,       0.0 ,
  0.0 , 1.0 , 0.0 ,       0.0 ,
  0.0 , 0.0 ,  dup cos ,  dup sin neg ,
  0.0 , 0.0 ,  dup sin ,  dup cos , ]  4 quot-to-matrix ;

MEMO: Rxz ( angle -- Rxz ) deg>rad
[ 1.0 , 0.0 ,       0.0 , 0.0 ,
  0.0 , dup cos ,  0.0  , dup sin neg , 
  0.0 , 0.0     ,   1.0 , 0.0 ,
  0.0 , dup sin ,  0.0  , dup cos ,    ] 4 quot-to-matrix ;

MEMO: Rxw ( angle -- Rxw ) deg>rad
[ 1.0 , 0.0   ,     0.0          ,  0.0 ,
  0.0 , dup cos ,   dup sin neg ,  0.0 ,
  0.0 , dup sin ,   dup cos ,     0.0 ,
  0.0 , 0.0     ,   0.0        ,    1.0 , ]  4 quot-to-matrix ;

MEMO: Ryz ( angle -- Ryz ) deg>rad
[  dup cos ,  0.0 , 0.0  , dup sin neg , 
  0.0  ,      1.0 , 0.0 , 0.0 ,
  0.0   ,     0.0 , 1.0 , 0.0 ,
  dup sin ,  0.0 , 0.0  , dup cos , ]   4 quot-to-matrix ;

MEMO: Ryw ( angle -- Ryw ) deg>rad
[  dup cos ,  0.0  , dup sin neg ,  0.0 ,
  0.0  ,      1.0 , 0.0 ,           0.0 ,
  dup sin ,  0.0  , dup cos ,     0.0 ,
  0.0 ,       0.0 , 0.0     ,       1.0  , ]  4 quot-to-matrix ;

MEMO: Rzw ( angle -- Rzw ) deg>rad
[  dup cos , dup sin neg ,  0.0 , 0.0 ,
   dup sin , dup cos ,     0.0 , 0.0 ,
  0.0      ,  0.0         ,   1.0 , 0.0 ,
  0.0      ,  0.0         ,   0.0 , 1.0  , ] 4 quot-to-matrix ;

