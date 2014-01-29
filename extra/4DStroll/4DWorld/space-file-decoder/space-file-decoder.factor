! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators prettyprint
continuations kernel math.parser sequences splitting xml
xml.syntax xml.traversal 4DStroll.adsoda.space
4DStroll.adsoda.light
4DStroll.adsoda.solid 
4DStroll.adsoda.nDobject 
4DStroll.adsoda.spacegroup
io.encodings.ascii
io.files
calendar
4DStroll.4DWorld.parameters
assocs
io.pathnames
;
IN: 4DStroll.4DWorld.space-file-decoder

: debug? ( -- b ) f ;
: when-debug ( string quot -- ) debug? swap [ drop ] if ; inline
: scr-debug ( string -- ) [ pprint ] when-debug ; inline
: scr-debug-cr ( string -- ) [ . ] when-debug ; inline
: tag-debug ( obj string -- obj )
    scr-debug dup scr-debug-cr ; inline  

: decode-number-array ( string -- array )  
    "," split [ string>number ] map ; inline

TAGS: 4DStroll-read-model ( obj tag -- obj  )

TAG: model 4DStroll-read-model 
    children-tags  "model" scr-debug-cr [ 4DStroll-read-model ]
    each   ;

TAG: dimension 4DStroll-read-model 
    children>string string>number 
    "dimension : " tag-debug  
    >>dimension ;

TAG: direction 4DStroll-read-model 
    children>string decode-number-array 
    "direction : " tag-debug
    >>direction ;

TAG: color     4DStroll-read-model 
    children>string decode-number-array 
    "color : " tag-debug
    >>color ;

TAG: refpoint    4DStroll-read-model 
    children>string decode-number-array 
    "refpoint : " tag-debug 
    >>refpoint ;

TAG: ambient-color     4DStroll-read-model   
    children>string decode-number-array 
    "ambient-color : " tag-debug 
    >>ambient-color ;

TAG: name      4DStroll-read-model 
    children>string 
    "name : " tag-debug 
    >>name ;

TAG: ID      4DStroll-read-model 
    children>string string>number
    "ID : " tag-debug 
    >>ID ;

TAG: face      4DStroll-read-model  
    children>string decode-number-array  
    "face" tag-debug 
    cut-solid ;

: register-spacegroup ( space group -- )
    over >>parent ! space group
    define-ID ! space group id
    [ rot spacegroups>> set-at ] 3keep ! add to spacegroups
    [ rot activegroup>> content>> set-at ] 3keep
    drop >>activegroup drop
;

TAG: spacegroup 4DStroll-read-model 
    [ dup activegroup>> swap ] dip ! save previous activegroup
    over
    <spacegroup> 
    register-spacegroup
    "<<spacegroup " scr-debug  
    children-tags  [ 4DStroll-read-model ] each 
     "spacegroup>>" scr-debug-cr
    swap >>activegroup ! restore previous activegroup
!  ensure-adjacencies    
!    parent>> >>activegroup
!    structure-group
!    suffix-solids
    ;

TAG: solid 4DStroll-read-model 
    <solid> swap 
    "<<solid " scr-debug  
    children-tags  [ 4DStroll-read-model ] each 
     "solid>>" scr-debug-cr
    ensure-adjacencies
    space-suffix-solids
    ;
     
TAG: light 4DStroll-read-model 
    <light> swap 
    "<<light " scr-debug
    children-tags [ 4DStroll-read-model ] each 
    " light>>" scr-debug-cr 
    space-suffix-lights ; 

TAG: space 4DStroll-read-model 
    children-tags "space" scr-debug-cr
    
    [ 4DStroll-read-model ]
    each   ;

: read-model-file ( path -- x )
    [ scr-debug-cr <space> ] keep
    file>xml 4DStroll-read-model
;

: test-space-file ( -- model ) 
    work-directory> "/multi-solids.xml" append ! normalize-path
    read-model-file
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
    "" swap +->XML string-lines autofilename ascii
    set-file-lines
;

