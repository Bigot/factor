USING: adsoda.combinators
sequences
    tools.test 
 ;

IN: 4DStroll.adsoda.tools.combinators.tests


[ { "atoto" "b" "ctoto" } ] [ { "a" "b" "c" } 1 [ "toto" append ] map-but ] 
    unit-test

[ { "1a" "2b" "3c" } ] [ { "1" "2" "3" } { "a" "b" "c" } concat-nth ] 
    unit-test

[ { "1" "2" "3" "1" } ] [ { "1" "2" "3" } do-cycle ] unit-test

