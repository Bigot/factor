! Copyright (C) 2013 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel
classes
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
ui.gadgets.theme
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
ui.gadgets.slots
ui.gadgets.status-bar
ui
fry
mirrors
refs
hashtables
4DStroll.ui.spacefile-chooser
;

IN: 4DStroll.ui.describer

GLOBAL: spacetolister


TUPLE: space-lister-table < table space-model ;

: <space-lister> ( row renderer -- table )
    space-lister-table new-table
; inline

: get-ndobject ( i -- solid )
    string>number \ spacetolister get-global at
; 

SINGLETON: space-lister-renderer

M: space-lister-renderer filled-column drop 2 ;

M: space-lister-renderer column-titles   
    drop {  "sel" "typ" "key" "name" "ref" "color" } ;

M: space-lister-renderer column-alignment 
    drop { 0 0 0 0 0 0 } ;

M: space-lister-renderer row-columns
    drop [ 
        dup
        get-ndobject    
       { 
        [ selected?>> value>> 
            [ "checkbox-set"  ] 
            [ "checkbox"  ] if  
            theme-image 
            swap
            ]
        [ class-of present { 
            { "solid" [ "radio" ] }
            { "spacegroup" [ "radio-clicked" ] } 
            [ drop "radio-set" ]
            } case theme-image 
            swap ]
        [ name>> [ "empty" ] unless* present ]
        [ refpoint>> [ { 0 0 0 0 } ] unless* [ number>string ] map  "," join ]
        [ color>> [ { 0 0 0 } ] unless* [ number>string ] map  "," join ]
    }
     cleave    
    ] output>array ;

M: space-lister-renderer prototype-row
    drop \ + definition-icon <image-name> "" 2array ;

M: space-lister-renderer row-color  drop 
    get-ndobject color>>  [ first3 1 ] [  0 0 0 1 ] if* <rgba> ;

M: space-lister-renderer row-value  drop
        get-ndobject ;

: toggle-selection ( ndobject -- ) 
    [ selected?>> [ not ] change-value value>>
    ] keep ->selected? 
; inline

: space-lister ( space -- gadget )
    mainspacegroup>> content>> 
    dup \ spacetolister set-global keys 
    [ number>string ] map <model>
    space-lister-renderer <space-lister> 
    5 >>gap
        COLOR: dark-gray >>column-line-color
        10 >>min-rows
        10 >>max-rows
        [ toggle-selection ] >>action
; inline

TUPLE: space-describer < pack space-model ;

: desc-add-ndobject ( gadget -- ) drop 
   [ [  read-model-file
    add-space-to-world ] curry apply-to-world ]
    <spacefile-chooser>  "Choose a file to add " 
    open-status-window
; inline

: desc-delete-ndobject ( gadget -- ) 
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

: desc-group-ndobjects ( gadget -- ) 
    drop [ group-selected ] apply-to-world ;

: desc-ungroup-ndobjects ( gadget -- ) 
    drop [ ungroup-selected ] apply-to-world ;

: com-refresh ( describer -- ) 
    model>> notify-connections ; inline

: slot-editor-window ( close-hook update-hook assoc key key-string -- )
    [ <slot-ref> <slot-editor>  ] [ "Slot editor: " prepend ] bi*
    open-status-window ; inline

: com-edit-name ( describer -- )
    [ close-window ] swap 
    [ '[ _ com-refresh ] ] keep
    selected-row    
    [  3  "name"
        slot-editor-window       
    ] 
    [ 3drop ] if 
    ;

: com-edit-color ( describer -- )
    [ close-window ] swap ! close-hook
    [ '[ _ com-refresh ] ] keep ! update-hook
    selected-row    
    [  4  "color"
        slot-editor-window       
    ] 
    [ 3drop ] if 
    ;

: com-edit-refpoint ( describer -- )
    [ close-window ] swap ! close-hook
    [ '[ _ com-refresh ] ] keep ! update-hook
    selected-row    
    [  7  "refpoint" ! verify number
        slot-editor-window       
    ] 
    [ 3drop ] if 
    ;

: com-moveto-refpoint ( describer -- )
    [ close-window ] swap ! close-hook
    [ '[ _ com-refresh ] ] keep ! update-hook
    selected-row    
    [  7  "refpoint" ! verify number
        slot-editor-window       
    ] 
    [ 3drop ] if 
    ;

! ________________



: draw-space-describer ( gadget -- gadget )
    pack new vertical >>orientation
    { 2 2 } >>gap
      <shelf> { 2 2 } >>gap
!    "Exit" [ close-4DStroll ] add-border-button
!    "Save" [ save-4DStroll-space ] add-border-button
    "Add"     [ desc-add-ndobject ]      <border-button> add-gadget
    "delete"  [ desc-delete-ndobject ]   <border-button> add-gadget
    "group"   [ desc-group-ndobjects ]   <border-button> add-gadget
    "ungroup" [ desc-ungroup-ndobjects ] <border-button> add-gadget
    add-gadget
    swap space-model>> value>>
      space-lister
   <scroller> { 250 150 } >>pref-dim
   add-gadget
   "space descriptor" <labeled-gadget>
;

: <space-describer> ( space-model -- gadget ) 
    space-describer new 
    2dup swap add-connection
    vertical >>orientation
    swap >>space-model
    dup draw-space-describer add-gadget
; inline

M: space-describer pref-dim* drop { 270 200 } ;

M: space-describer model-changed 
    nip 
    dup clear-gadget
    dup draw-space-describer add-gadget
 drop
;

: space-lister-menu ( editor -- )
    {
        com-edit-name
        com-edit-color
        com-edit-refpoint
        ----
        desc-group-ndobjects
        desc-ungroup-ndobjects
        desc-add-ndobject
        desc-delete-ndobject
    } show-commands-menu 
; inline

space-lister-table "misc" f {
 !   { T{ button-down f f 2 } toggle-selection }
    { T{ button-down f f 3 } space-lister-menu }
} define-command-map

