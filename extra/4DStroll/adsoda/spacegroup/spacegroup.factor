! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING:  kernel 4DStroll.adsoda.nDobject accessors math.parser
assocs combinators models accessors ;
IN: 4DStroll.adsoda.spacegroup


TUPLE: spacegroup < nDobject content ;

: <spacegroup> ( -- spacegroup )
    spacegroup new
    { 0 0 0 0 } clone >>refpoint ! TODO rewrite
    f <model> >>selected? 
    H{ } clone >>content
;


M: spacegroup +->XML 
    "" swap
    {
    [ ID>> [ number>string "ID" append->XML ] when* ]
    [ name>> [ "name" append->XML ] when* ]
    [ dimension>> [ number>string "dimension" append->XML  ] when* ]
    [ color>> [ seq->str "color" append->XML  ] when* ]  
    [ refpoint>> [ seq->str "refpoint" append->XML  ] when* ]
    [ content>> [ nip +->XML ] assoc-each ]
    } cleave
    "spacegroup" append->XML
;


M: spacegroup ->selected? 
    [ selected?>> set-model ] 2keep
    content>> 
    [ ->selected? drop ] with assoc-each

;
