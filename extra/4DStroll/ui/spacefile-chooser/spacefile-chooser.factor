! Copyright (C) 2013 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel
ui.gadgets
ui.gadgets.buttons
ui.gadgets.packs
io.directories
sequences
io.pathnames
ui.gadgets.labeled
ui.gadgets.scrollers
4DStroll.4DWorld.parameters
locals
fry
accessors
ui
;

IN: 4DStroll.ui.spacefile-chooser

! ----------------------------------------------------------
! file chooser
! ----------------------------------------------------------
: <run-file-button> ( gadget file-name quot -- gadget button )
  [ 2dup ] dip rot '[ drop  _  @ _ close-window ]   
  
  <button> { 0 0 } >>align 
; inline

:: <spacefile-chooser> ( quot -- gadget )
     work-directory>
  <pile> 1 >>fill 
    over dup directory-files  
    [ ".xml" tail? ] filter 
    [ append-path ] with map
    [ quot <run-file-button> add-gadget ] each
    <scroller>
    swap <labeled-gadget> ;

