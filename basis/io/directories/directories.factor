! Copyright (C) 2004, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
continuations destructors fry io io.backend io.encodings.binary
io.files io.pathnames kernel namespaces sequences system vocabs ;
IN: io.directories

: set-current-directory ( path -- )
    absolute-path current-directory set ;

: with-directory ( path quot -- )
    [ absolute-path current-directory ] dip with-variable ; inline

: with-resource-directory ( quot -- )
    [ "resource:" ] dip with-directory ; inline

! Creating directories
HOOK: make-directory io-backend ( path -- )

: make-directories ( path -- )
    normalize-path trim-tail-separators dup {
        [ "." = ]
        [ root-directory? ]
        [ empty? ]
        [ exists? ]
    } 1|| [
        dup parent-directory make-directories
        dup make-directory
    ] unless drop ;

! Listing directories
TUPLE: directory-entry name type ;

HOOK: >directory-entry os ( byte-array -- directory-entry )

HOOK: (directory-entries) os ( path -- seq )

: directory-entries ( path -- seq )
    normalize-path
    (directory-entries)
    [ name>> { "." ".." } member? not ] filter ;

: directory-files ( path -- seq )
    directory-entries [ name>> ] map! ;

: with-directory-entries ( path quot -- )
    '[ "" directory-entries @ ] with-directory ; inline

: with-directory-files ( path quot -- )
    '[ "" directory-files @ ] with-directory ; inline

! Touching files
HOOK: touch-file io-backend ( path -- )

! Deleting files
HOOK: delete-file io-backend ( path -- )

HOOK: delete-directory io-backend ( path -- )

: ?delete-file ( path -- )
    '[ _ delete-file ] ignore-errors ;

: to-directory ( from to -- from to' )
    over file-name append-path ;

! Moving and renaming files
HOOK: move-file io-backend ( from to -- )

: move-file-into ( from to -- )
    to-directory move-file ;

: move-files-into ( files to -- )
    '[ _ move-file-into ] each ;

! Copying files
HOOK: copy-file io-backend ( from to -- )

M: object copy-file
    dup parent-directory make-directories
    binary <file-writer> [
        swap binary <file-reader> [
            swap stream-copy
        ] with-disposal
    ] with-disposal ;

: copy-file-into ( from to -- )
    to-directory copy-file ;

: copy-files-into ( files to -- )
    '[ _ copy-file-into ] each ;

{
    { [ os unix? ] [ "io.directories.unix" require ] }
    { [ os windows? ] [ "io.directories.windows" require ] }
} cond
