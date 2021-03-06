USING: editors.vim io.backend kernel namespaces system
vocabs editors ;
IN: editors.gvim

! This code builds on the code in editors.vim; see there for
! more information.

TUPLE: gvim < vim ;
T{ gvim } editor-class set-global

HOOK: find-gvim-path io-backend ( -- path )
M: object find-gvim-path f ;

M: gvim find-vim-path find-gvim-path "gvim" or ;
M: gvim vim-ui? t ;
M: gvim editor-detached? t ;

os windows? [ "editors.gvim.windows" require ] when
