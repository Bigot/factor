! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators continuations fry io io.backend
io.directories io.directories.hierarchy io.files io.pathnames
kernel locals math math.bitwise math.parser namespaces random
sequences system vocabs random.data ;
IN: io.files.unique

HOOK: (touch-unique-file) io-backend ( path -- )
: touch-unique-file ( path -- )
    normalize-path (touch-unique-file) ;

HOOK: default-temporary-directory io-backend ( -- path )

SYMBOL: current-temporary-directory

SYMBOL: unique-length
SYMBOL: unique-retries

10 unique-length set-global
10 unique-retries set-global

: with-temporary-directory ( path quot -- )
    [ current-temporary-directory ] dip with-variable ; inline

<PRIVATE

: random-file-name ( -- string )
    unique-length get random-string ;

: retry ( quot: ( -- ? ) n -- )
    iota swap [ drop ] prepose attempt-all ; inline

: (make-unique-file) ( path prefix suffix -- path )
    '[
        _ _ _ random-file-name glue append-path
        dup touch-unique-file
    ] unique-retries get retry ;

PRIVATE>

: make-unique-file ( prefix suffix -- path )
    [ current-temporary-directory get ] 2dip (make-unique-file) ;

: cleanup-unique-file ( prefix suffix quot: ( path -- ) -- )
    [ make-unique-file ] dip [ delete-file ] bi ; inline

: unique-directory ( -- path )
    [
        current-temporary-directory get
        random-file-name append-path
        dup make-directory
    ] unique-retries get retry ;

: with-unique-directory ( quot -- path )
    [ unique-directory ] dip
    [ with-temporary-directory ] [ drop ] 2bi ; inline

: cleanup-unique-directory ( quot: ( -- ) -- )
    [ unique-directory ] dip
    '[ _ with-temporary-directory ] [ delete-tree ] bi ; inline

: unique-file ( prefix -- path )
    "" make-unique-file ;

: move-file-unique ( path prefix suffix -- path' )
    make-unique-file [ move-file ] keep ;

: copy-file-unique ( path prefix suffix -- path' )
    make-unique-file [ copy-file ] keep ;

: temporary-file ( -- path ) "" unique-file ;

:: cleanup-unique-working-directory ( quot -- )
    unique-directory :> path
    path [ path quot with-temporary-directory ] with-directory
    path delete-tree ; inline

{
    { [ os unix? ] [ "io.files.unique.unix" ] }
    { [ os windows? ] [ "io.files.unique.windows" ] }
} cond require

default-temporary-directory current-temporary-directory set-global
