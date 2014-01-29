! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.parser accessors sequences math math.functions arrays ;
IN: 4DStroll.adsoda.nDobject

GENERIC: >log ( x -- ) 
GENERIC: >table ( x -- x ) 

TUPLE: nDobject ID name color dimension selected? parent 
 { refpoint array } ;

: frnd ( x -- x )
    1000 * round 1000 /
; inline

: seq>string ( seq -- string ) 
  dup 
  [  "{ " swap 
    [ frnd number>string append " " append ] each
    "}" append     
    ] [ drop "f" ] if
; inline

: define-ID ( nDobject -- nDobject ID )
    dup identity-hashcode [ >>ID ] keep ; inline


: append->XML ( xml string tag -- string ) 
    [ "<" ">" surround prepend ] keep
     "</" ">\n" surround append 
    append
; inline

: seq->str ( seq -- str )
    [ number>string ] map
    "," join
; inline

GENERIC: +->XML ( xml nDobject -- xml )
GENERIC: ->selected? ( b nDobject -- )


