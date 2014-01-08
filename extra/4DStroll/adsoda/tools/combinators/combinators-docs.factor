! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel sequences ;
IN: 4DStroll.adsoda.tools.combinators

HELP: among
{ $values
     { "array" array } { "n" null }
     { "array" array }
}
{ $description "returns an array containings every possibilities of n choices among a given sequence" } ;

HELP: columnize
{ $values
     { "array" array }
     { "array" array }
}
{ $description "flip a sequence into a sequence of 1 element sequences" } ;

HELP: concat-nth
{ $values
     { "seq1" sequence } { "seq2" sequence }
     { "seq" sequence }
}
{ $description "merges 2 sequences of sequences appending corresponding elements" } ;

HELP: do-cycle
{ $values
     { "array" array }
     { "array" array }
}
{ $description "Copy the first element at the end of the sequence in order to close the cycle." } ;


ARTICLE: "4DStroll.adsoda.tools.combinators" "4DStroll.adsoda.tools.combinators"
{ $vocab-link "4DStroll.adsoda.tools.combinators" }
;

ABOUT: "4DStroll.adsoda.tools.combinators"
