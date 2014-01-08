! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.parser sequences math math.functions ;
IN: 4DStroll.adsoda.nDobject

GENERIC: >log ( x -- ) 
GENERIC: >table ( x -- x ) 

TUPLE: nDobject name color selected? ;

: frnd ( x -- x )
    1000 * round 1000 /
; inline

: seq>string ( seq -- string ) 
  dup 
  [  "{ " swap 
    [ frnd number>string append " " append ] each
    "}" append     
    ] [ drop "f" ] if
;

