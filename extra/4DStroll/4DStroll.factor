! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel 
namespaces
accessors
sequences
combinators
colors
colors.constants
prettyprint
quotations
io
io.directories
io.pathnames
io.files
 ui
        ui.gadgets.worlds
       ui.gadgets
       ui.gadgets.frames
       ui.gadgets.tracks
       ui.gadgets.labels
       ui.gadgets.buttons
       ui.gadgets.packs
       ui.gadgets.grids
       ui.gadgets.labeled
ui.utils
       ui.gestures
       ui.gadgets.scrollers
4DStroll.ui.camera
4DStroll.4DWorld
4DStroll.4DWorld.space-file-decoder
4DStroll.4DWorld.parameters
4DStroll.ui.window3D
4DStroll.ui.describer
4DStroll.ui.4Dcommands
models
fry
variables
;


IN: 4DStroll
VAR: selected-file

VAR: selected-file-model
! VAR: observer3d 

: .pos1 ( -- ) view1> 3d-cam>> position>> . ;
: .ori1 ( -- ) view1> 3d-cam>> orientation>> . ;
: cam1 ( -- ) .pos1 .ori1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! menu
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: add-border-button ( gadget name quot -- gadget ) 
    <border-button> add-gadget
    ! dup
    ! interior>> plain>> COLOR: dim-grey >>background drop
;

: menu-rotations-4D ( -- gadget )
 3 3  <frame> { 2 2 } >>gap { 1 1 } >>filled-cell
         <pile> 1 >>fill
          "XY +" [ 4D-R+xy ] add-border-button
          "XY -" [ 4D-R-xy ] add-border-button 
         { 0 0 } grid-add
         <pile> 1 >>fill
          "XZ +" [ 4D-R+xz ] add-border-button
          "XZ -" [ 4D-R-xz ] add-border-button 
         { 1 0 } grid-add
         <pile> 1 >>fill
          "XW +" [ 4D-R+xw ] add-border-button
          "XW -" [ 4D-R-xw ] add-border-button 
         { 2 0 } grid-add
         "" <label> 
         { 0 1 } grid-add
         <pile> 1 >>fill
          "YZ +" [ 4D-R+yz ] add-border-button
          "YZ -" [ 4D-R-yz ] add-border-button 
          { 1 1 } grid-add
          <pile> 1 >>fill
          "YW +" [ 4D-R+yw ] add-border-button
          "YW -" [ 4D-R-yw ] add-border-button 
          { 2 1 } grid-add
        <pile> 1 >>fill
          "ZW +" [ 4D-R+zw ] add-border-button
          "ZW -" [ 4D-R-zw ] add-border-button 
        { 2 2 } grid-add
    "4D rotation" <labeled-gadget>       
;

: menu-projection-mode ( -- gadget )
    <shelf>    
    view1> 3d-cam>> projection-mode>>
    { { 1 "perspective" } { 0 "orthogonal" }  } 
      <radio-buttons> add-gadget
! : collision-detection-chooser ( x -- gadget )
    !   { { t "on" } { f "off" }  } <toggle-buttons> ;
          !  "Collision detection (slow and buggy ) : " <label> add-gadget
            ! observer3d> 
          !  collision-mode>> collision-detection-chooser add-gadget
   !     f track-add
    "Projection mode" <labeled-gadget>
;

: menu-translations-4D ( -- gadget )
    2 2  <frame> { 2 2 } >>gap { 1 1 } >>filled-cell 
    <shelf> 1 >>fill  
        "X+" [ 4D-T+x ] add-border-button
        "X-" [ 4D-T-x  ] add-border-button 
    { 0 0 } grid-add
    <shelf> 1 >>fill
                "Y+" [ 4D-T+y ] add-border-button
                "Y-" [ 4D-T-y ] add-border-button 
    { 1 0 } grid-add
    <shelf> 1 >>fill
                "Z+" [ 4D-T+z ] add-border-button
                "Z-" [ 4D-T-z ] add-border-button 
        { 0 1 } grid-add     
            <shelf> 1 >>fill
                "W+" [ 4D-T+w ] add-border-button
                "W-" [ 4D-T-w ] add-border-button 
        { 1 1 } grid-add 

    "4D translation" <labeled-gadget>
;

: close-4DStroll ( gadget -- )
    view1> close-window 
    view2> close-window
    view3> close-window 
    view4> close-window    
    close-window 
;

: save-4DStroll-space ( button -- )
!    find-parent [ relayout ] each
! ajouter le nouvel enregistrement à la liste des fichiers
drop
    4dworld> space>> value>> space->autofile
;

: add-solid ( button -- )
    drop
;

: delete-solid ( button -- )
    pprint
    ! drop
;

: group-solids ( button -- )
    drop
;

: menu-function ( -- gadget )
    <shelf> { 2 2 } >>gap
    "Exit" [ close-4DStroll ] add-border-button
    "Save" [ save-4DStroll-space ] add-border-button
!    "Add solid" [ add-solid ] add-border-button
!    "delete solid" [ delete-solid ] add-border-button
!    "group solids" [ delete-solid ] add-border-button
!    "function" <labeled-gadget>
;

: load-model-file ( -- )
    [ 
        dup space>> 
        selected-file
        read-model-file
        swap
        set-model
        dup init-views ! TODO faire une mise à jour par model sur
    ]
    apply-to-world
;


! ----------------------------------------------------------
! file chooser
! ----------------------------------------------------------
: <run-file-button> ( file-name -- button )
  dup '[ drop  _  \ selected-file set load-model-file 
   ]   <button> { 0 0 } >>align 
;

: <list-runner> ( -- gadget )
     work-directory>
!    "resource:extra/4DStroll/save"
! "D:/Program Files/factor/work/4DStroll/save"
!    "resource:extra/4DStroll" 
  <pile> 1 >>fill 
    over dup directory-files  
    [ ".xml" tail? ] filter 
    [ append-path ] with map
    [ <run-file-button> add-gadget ] each
    <scroller>
    swap <labeled-gadget> ;

! -----------------------------------------------------

: menu-rotations-3D ( -- gadget )
   2 2 <frame>
        "Turn\n left"  [ drop ! rotation-step  turn-left  
        ] <border-button>      
            { 0 0 } grid-add     
        "Turn\n right" [ drop ! rotation-step turn-right 
        ] <border-button>      
            { 0 0 } grid-add     
        "Pitch down"   [ drop ! rotation-step  pitch-down 
        ] <border-button>      
            { 0 0 } grid-add     
        "Pitch up"     [ drop ! rotation-step  pitch-up   
        ] <border-button>      
            { 0 0 } grid-add     
        <shelf>  1 >>fill
            "Roll left\n (ctl)"  [ drop ! rotation-step  roll-left  
            ] <border-button>
                add-gadget  
            "Roll right\n(ctl)"  [ drop ! rotation-step  roll-right 
            ] <border-button> 
                add-gadget  
        { 0 0 } grid-add 
;

: menu-translations-3D ( -- gadget )
    2 2 <frame>
        "left\n(alt)"          [ drop ! translation-step  strafe-left 
        ] <border-button>
            { 0 0 } grid-add  
        "right\n(alt)"         [ drop ! translation-step  strafe-right 
        ] <border-button>
            { 0 0 } grid-add     
        "Strafe up \n (alt)"   [ drop ! translation-step strafe-up    
        ] <border-button>
            { 0 0 } grid-add
        "Strafe down \n (alt)" [ drop ! translation-step strafe-down 
        ] <border-button>
        COLOR: dim-grey >>color
            { 0 0 } grid-add    
        <pile>  1 >>fill
            "Forward (ctl)"  [  drop ! translation-step step-turtle 
            ] <border-button>
                add-gadget
            "Backward (ctl)" [ drop ! translation-step neg step-turtle 
            ] <border-button>
                add-gadget
        { 0 0 } grid-add
;

: menu-quick-views ( -- gadget )
    <shelf>
!        "View 1 (1)" mvt-3D-1 <border-button>   add-gadget
!        "View 2 (2)" mvt-3D-2 <border-button>   add-gadget
!        "View 3 (3)" mvt-3D-3 <border-button>   add-gadget 
!        "View 4 (4)" mvt-3D-4 <border-button>   add-gadget 
;

: menu-3D ( -- gadget ) 
    <pile>
        <shelf>   
            menu-rotations-3D    add-gadget
            menu-translations-3D add-gadget
            0.5 >>align
            { 0 10 } >>gap
        add-gadget
        menu-quick-views add-gadget ; 


: menu-bar ( -- gadget )
       <shelf>
             "reinit" [ drop load-model-file ] add-border-button
             selected-file-model <label-control> add-gadget
    ;


: 3Dwindows-buttons ( -- gadget )
    <pile>
        4dworld> active-views>> first "YZW" <checkbox> add-gadget 
        4dworld> active-views>> second "XZW" <checkbox> add-gadget
        4dworld> active-views>> third "XYW" <checkbox> add-gadget
        4dworld> active-views>> fourth "XYZ" <checkbox> add-gadget
    "3D window views" <labeled-gadget>
;


: menu-mvt4D ( -- gadget )
        <shelf>
            menu-rotations-4D  add-gadget
            menu-translations-4D  add-gadget
            { 2 2 } >>gap 
;

: menu-3Dview ( -- gadget ) ! not working
        <shelf>
! not working
!            menu-projection-mode add-gadget
            3Dwindows-buttons add-gadget
            { 2 2 } >>gap 

;

: 3Dview-gadget ( -- gadget )
    <shelf>  { 2 2 } >>gap
        <pile> { 2 2 } >>gap
            view1>  add-gadget
            view2>   add-gadget
            add-gadget
        <pile> { 2 2 } >>gap
            view3>  add-gadget
            view4>   add-gadget
        add-gadget
;

: command-gadgets ( -- gadgets )
<shelf>
    <pile> { 2 2 } >>gap 
        menu-function add-gadget
        menu-mvt4D add-gadget
        4dworld> space>> <space-describer> add-gadget
!      4dworld> space>> value>> space-describ add-gadget
    <list-runner> add-gadget
!        menu-3Dview add-gadget
    add-gadget
!    add-gadget
!    3Dview-gadget add-gadget

;


: 4Dwindows ( -- )
[
    f T{ world-attributes { title "4DStroll Commands" } } clone
    command-gadgets >>gadgets open-window

    f T{ world-attributes { title "YZW 4DStroll" } } clone 
    view1> >>gadgets open-window

    f T{ world-attributes { title "XZW 4DStroll" } } clone
    view2> >>gadgets open-window

    f T{ world-attributes { title "XYW 4DStroll" } } clone
    view3> >>gadgets open-window

    f T{ world-attributes { title "XYZ 4DStroll" } } clone 
    view4> >>gadgets open-window
] with-ui 

;


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-variables ( -- )
    init-work-directory
    <4DWorld> 
    test-file>space
    >4dworld
;


: init-3Dwiews ( -- )
    4dworld>
    dup projection1>> <model> <camera> <window3D> >view1  
    dup projection2>> <model> <camera> <window3D> >view2
    dup projection3>> <model> <camera> <window3D> >view3 
        projection4>> <model> <camera> <window3D> >view4
;

: 4DStroll ( -- ) 
    init-variables
    init-3Dwiews
    4Dwindows
;

: 4DS ( -- ) 
    4DStroll
;

MAIN: 4DStroll

