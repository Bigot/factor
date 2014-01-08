! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors arrays 4DStroll.adsoda.nDobject 
prettyprint combinators sequences ;

IN: 4DStroll.adsoda.light


TUPLE: light < nDobject { direction array }  ;

: <light> ( -- tuple ) 
    light new 
    t >>selected? ; inline

M: light >log 
"\n light : " .
     { 
        [ direction>> "direction : " pprint . ] 
        [ color>> "color : " pprint . ]
    }   cleave
    ; 

M: light >table 
{ } swap
     { 
        [ direction>> seq>string "  light direction : " swap 2array suffix ] 
        [ color>> seq>string "  light color : " swap 2array suffix ]
    }   cleave
    ; 

