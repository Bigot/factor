! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: io.pathnames variables namespaces
;
IN: 4DStroll.4DWorld.parameters

GLOBAL: work-directory

: work-directory> ( -- b ) \ work-directory get-global ;
: >work-directory ( b --  ) \ work-directory set-global ;

: init-work-directory ( -- ) 
   "resource:extra/4DStroll/save" >work-directory
; 


