! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators prettyprint
continuations kernel math.parser sequences splitting xml
xml.syntax xml.traversal 4DStroll.adsoda.space
4DStroll.adsoda.light
4DStroll.adsoda.solid 
io.encodings.ascii
io.files
calendar
4DStroll.4DWorld.parameters
assocs
io.pathnames
;
IN: 4DStroll.4DWorld.space-file-decoder

: debug? ( -- b ) f ;

: scr-debug ( string -- ) 
    debug? [ pprint ] [ drop ] if
;

: scr-debug-cr ( string -- ) 
    debug? [ . ] [ drop ] if
;

: decode-number-array ( x -- y )  
    "," split [ string>number ] map ;

TAGS: 4DStroll-read-model ( obj tag -- obj  )

TAG: model 4DStroll-read-model 
    children-tags  "model" scr-debug-cr [ 4DStroll-read-model ]
    each   ;

TAG: dimension 4DStroll-read-model 
    children>string string>number 
    [ "dimension" scr-debug scr-debug-cr ] keep  
    >>dimension ;
TAG: direction 4DStroll-read-model 
    children>string decode-number-array 
    [ "direction : " scr-debug scr-debug-cr ] keep
    >>direction ;
TAG: color     4DStroll-read-model 
    children>string decode-number-array 
    [ "color : " scr-debug scr-debug-cr ] keep
    >>color ;
TAG: ambient-color     4DStroll-read-model   
    children>string decode-number-array 
    [ "ambient-color : " scr-debug scr-debug-cr ] keep 
    >>ambient-color ;
TAG: name      4DStroll-read-model children>string 
    [ "name : " scr-debug scr-debug-cr ] keep 
    >>name ;

TAG: face      4DStroll-read-model  
    children>string decode-number-array  
    [ "face" scr-debug scr-debug-cr ] keep 
    cut-solid ;

TAG: solid 4DStroll-read-model 
    <solid> swap 
    "<<solid " scr-debug  
    children-tags  [ 4DStroll-read-model ] each 
     "solid>>" scr-debug-cr
  ensure-adjacencies
    suffix-solids
    ;
     


TAG: light 4DStroll-read-model 
    <light> swap 
    "<<light " scr-debug
    children-tags [ 4DStroll-read-model ] each 
    " light>>" scr-debug-cr 
    suffix-lights ; 


TAG: space 4DStroll-read-model 
    children-tags "space" scr-debug-cr
    
    [ 4DStroll-read-model ]
    each   ;

: read-model-file ( path -- x )
   dup scr-debug-cr <space> swap
    file>xml 4DStroll-read-model
!    dup solids>> 
!    [ dup identity-hashcode swap ] H{ } map>assoc >>solids
;

: test-space-file ( -- model ) 
! "D:/Program Files/factor/work/4DStroll/save/hypercube.xml"
!  "D:/Program Files/factor/extra/4DStroll/save/multi-solids.xml"
! "D:/Program Files/factor/extra/4DStroll/save/multi-solids.xml"
   work-directory> "/multi-solids.xml" append ! normalize-path
! "D:/Program Files/factor/work/4DStroll/save/prismetriagone.xml"
read-model-file
;

: append->XML ( xml string tag -- string ) 
    [ "<" ">" surround prepend ] keep
     "</" ">\n" surround append 
    append
;

: seq->str ( seq -- str )
    [ number>string ] map
    "," join
;

: face->XML ( XML face -- xml ) 
    halfspace>> 
    seq->str   
    "face" append->XML
;

: light->XML ( XML solid -- xml )
    ""  swap
    {
    [ name>> dup [ ] [ drop "none" ] if "name" append->XML ]
    [ direction>> seq->str "direction" append->XML ]
    [ color>> seq->str "color" append->XML ]    
    } cleave
    "light" append->XML
;

: solid->XML ( XML solid -- xml )
    "" swap
    {
    [  name>> "name" append->XML ]
    [ dimension>> number>string "dimension" append->XML ]
    [ faces>> [ face->XML ] each ]
    [ color>> seq->str "color" append->XML ]    
    } cleave
    "solid" append->XML
;
: space->XML ( xml space -- xml )
    "" swap
 {
    [  name>> "name" append->XML ]
    [ dimension>> number>string "dimension" append->XML ]
    [ solids>> [ nip solid->XML ] assoc-each ]
    [ lights>> [ light->XML ] each ]
    } cleave
    "space" append->XML
 "" swap   "model" append->XML
;

: autofilename ( -- name )
    work-directory> "/4D-" append
    !  "D:/Program Files/factor/work/4DStroll/save" 
    now  
    { 
    [ year>> number>string append ] 
    [ month>> number>string append ] 
    [ day>> number>string append ] 
    [ drop "-" append ]
    [ hour>> number>string append ] 
    [ minute>> number>string append ]     
    } cleave
    ".xml" append
;

: space->autofile ( space -- )
    "" swap space->XML string-lines autofilename ascii
    set-file-lines
;

