! Copyright (C) 2013 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel
sequences
ui.gadgets
ui.gadgets.packs
ui.gadgets.labels
ui.gadgets.scrollers
ui.gadgets.labeled
ui.gadgets.buttons
ui.gadgets.menus
ui.gadgets.editors
ui.gadgets.glass
ui.gadgets.tables
ui.images
ui.gestures
ui.commands
ui.pens.solid
accessors
4DStroll.4DWorld
4DStroll.4DWorld.parameters
4DStroll.4DWorld.space-file-decoder
4DStroll.ui.4Dcommands
4DStroll.adsoda.space
4DStroll.adsoda.nDobject
math.rectangles
models
colors
colors.constants
namespaces
variables
present
combinators.smart
math.parser
math
definitions.icons
arrays
assocs
combinators
io.pathnames
;

IN: 4DStroll.ui.describer

GLOBAL: spacetodescribe

TUPLE: space-describe < table space-model ;

: <space-describe> ( row renderer -- table )
    space-describe new-table
;

: get-solid ( i -- solid )
    string>number \ spacetodescribe get-global at
;

SINGLETON: space-lister-renderer

M: space-lister-renderer filled-column drop 3 ;

M: space-lister-renderer column-titles   drop { "key" "img" "select" "name" "color"
 } ;

M: space-lister-renderer column-alignment drop { 0 0 0 0 0 } ;


M: space-lister-renderer row-columns
    drop [ 
        dup
        get-solid    
        "constant-word" definition-icon-path  <image-name> swap
       { 
!        [ selected?>> value>> [ "X" ] [ "-" ] if  ]
        [ selected?>> value>> [ "X" ] [ "-" ] if  ]
        [ name>> present ]
        [ color>>    [ number>string ] map
    "," join ]
    }
     cleave 
   
    ] output>array ;

M: space-lister-renderer prototype-row
    drop \ + definition-icon <image-name> "" 2array ;


M: space-lister-renderer row-color  drop 
    get-solid color>> first3 1 <rgba> ;

M: space-lister-renderer row-value  drop
        get-solid ;

: toggle-solid-selection ( i -- ) 
    selected?>> [ not ] change-value
    drop
;

: space-describ ( space -- gadget )
    solids>> dup \ spacetodescribe set-global keys [
    number>string ] map <model>
    space-lister-renderer <space-describe> 
    5 >>gap
        COLOR: dark-gray >>column-line-color
        10 >>min-rows
        10 >>max-rows
        [ toggle-solid-selection ] >>action
 !       { 300 200 } >>pref-dim
 !       <scroller>
  !      { 300 200 } >>pref-dim
;


: space-describer-line ( x -- gadget )
    first2 swap <shelf> swap <label> add-gadget 
    swap <label> add-gadget
;

: solid-line ( solid -- gadget )
    [ color>> first3 1 <rgba> ]
    [ selected?>> ]
    [ name>> "solid : " prepend ] tri
    <checkbox> 
    [ <solid> ] dip swap >>interior
;




TUPLE: space-describer < pack space-model ;


: add-solid ( gadget -- ) drop 
    [ 
     work-directory> "/hypercube.xml" append
    read-model-file
    add-space-to-world ] apply-to-world
; inline

: delete-solid ( gadget -- ) 
    drop [ delete-selected ] apply-to-world
; inline

: askname ( -- x ) 
    pack new vertical >>orientation
    { 2 2 } >>gap
    <shelf> { 2 2 } >>gap
    "OK" [  ] <border-button> add-gadget
    "Cancel" [  ] <border-button> add-gadget    
    add-gadget    
    "group name" <model> <model-field> "field" set 
     "field" get 
    add-gadget   
     "field" get field-model>> value>>
drop
;

: group-solids ( gadget -- ) 
drop 
;
: ungroup-solids ( gadget -- ) drop ;

: draw-space-describer ( gadget -- gadget )
    pack new vertical >>orientation
    { 2 2 } >>gap

      <shelf> { 2 2 } >>gap
!    "Exit" [ close-4DStroll ] add-border-button
!    "Save" [ save-4DStroll-space ] add-border-button
    "Add" [ add-solid ] <border-button> add-gadget
    "delete" [ delete-solid ] <border-button> add-gadget
    "group" [ group-solids ] <border-button> add-gadget
    "ungroup" [ ungroup-solids ] <border-button> add-gadget
    add-gadget
  !  pack new vertical >>orientation
  !  { 2 2 } >>gap
    swap space-model>> value>>
    !  dup [ 
      space-describ
     ! ] dip

!    >table
!    solids>>
  !      [ solid-line add-gadget ] each
!       [ space-describer-line add-gadget ] each
   <scroller>    
   { 350 150 } >>pref-dim
   add-gadget

   "space descriptor" <labeled-gadget>
;

: <space-describer> ( space-model -- gadget ) 
    space-describer new 

    2dup swap add-connection

    vertical >>orientation
    swap >>space-model
    dup draw-space-describer add-gadget
 
;

M: space-describer pref-dim* drop { 400 200 } ;

M: space-describer model-changed 
    nip 
    dup  clear-gadget
    dup draw-space-describer add-gadget
 drop
;

: space-lister-menu ( editor -- )
    {
        add-solid
        delete-solid
        ----
        group-solids
        ungroup-solids

    } show-commands-menu ;




space-describe "misc" f {
 !   { T{ button-down f f 2 } toggle-solid-selection }
    { T{ button-down f f 3 } space-lister-menu }
} define-command-map

