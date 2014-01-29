! Copyright (C) 2008 Jean-François Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations strings 
4DStroll.adsoda
;
IN: 4DStroll



ARTICLE: "implementation details" "How 4DStroll is done"
"4DStroll (former name was 4DNav) is build using an implementation of " { $vocab-link "4DStroll.adsoda" } " library."
$nl
"Adsoda is an algorithm proposed by Greg Ferrar."


! { $subsection "4DStroll.camera" }
! { $subsection "adsoda-main-page" }
;

ARTICLE: "Space file" "Create a new space file"
"To build a new space, create an XML file using " { $vocab-link "4DStroll.adsoda" } " model description. A solid is not caracterized by its corners but is defined as the intersection of hyperplanes."

$nl
"An example is:"
$nl

"\n<model>"
"\n<space>"
"\n <dimension>4</dimension>"
"\n <solid>"
"\n     <name>4cube1</name>"
"\n     <dimension>4</dimension>"
"\n     <face>1,0,0,0,100</face>"
"\n     <face>-1,0,0,0,-150</face>"
"\n     <face>0,1,0,0,100</face>"
"\n     <face>0,-1,0,0,-150</face>"
"\n     <face>0,0,1,0,100</face>"
"\n     <face>0,0,-1,0,-150</face>"
"\n     <face>0,0,0,1,100</face>"
"\n     <face>0,0,0,-1,-150</face>"
"\n     <color>1,0,0</color>"
"\n </solid>"
"\n <solid>"
"\n     <name>4triancube</name>"
"\n     <dimension>4</dimension>"
"\n     <face>1,0,0,0,160</face>"
"\n     <face>-0.4999999999999998,-0.8660254037844387,0,0,-130</face>"
"\n     <face>-0.5000000000000004,0.8660254037844384,0,0,-130</face>"
"\n     <face>0,0,1,0,140</face>"
"\n     <face>0,0,-1,0,-180</face>"
"\n     <face>0,0,0,1,110</face>"
"\n     <face>0,0,0,-1,-180</face>"
"\n     <color>0,1,0</color>"
"\n </solid>"
"\n <solid>"
"\n     <name>triangone</name>"
"\n     <dimension>4</dimension>"
"\n     <face>1,0,0,0,60</face>"
"\n     <face>0.5,0.8660254037844386,0,0,60</face>"
"\n     <face>-0.5,0.8660254037844387,0,0,-20</face>"
"\n     <face>-1.0,0,0,0,-100</face>"
"\n     <face>-0.5,-0.8660254037844384,0,0,-100</face>"
"\n     <face>0.5,-0.8660254037844387,0,0,-20</face>"
"\n     <face>0,0,1,0,120</face>"
"\n     <face>0,0,-0.4999999999999998,-0.8660254037844387,-120</face>"
"\n     <face>0,0,-0.5000000000000004,0.8660254037844384,-120</face>"
"\n     <color>0,1,1</color>"
"\n </solid>"
"\n <light>"
"\n     <direction>1,1,1,1</direction>"
"\n     <color>0.2,0.2,0.6</color>"
"\n </light>"
"\n <color>0.8,0.9,0.9</color>"
"\n</space>"
"\n</model>"


;

ARTICLE: "TODO" "Todo"
    "Things to add to 4Dstroll :" 
{ $list 
    "A vocab to initialize parameters"
    "a tree describing the space"
    "an editor mode for solids" 
        { $list "add a face to a solid"
                "move a face"
                "select a solid in a list"
                "select a face"
                "display selected face"
                "use a colorpicker to change solid color"
                "add a light"
                "edit a light color"
                "move a light"
                "modify size of a solid"
                }
    "display reference arrows"
    "save 3D position in save file"
    "choose file name when save"
    "choose space name"
    "log modifications"
    "undo button"

    "add a tool wich give an hyperplane normal vector with enought points. Will use adsoda.intersect-hyperplanes with { { 0 } { 0 } { 1 } } "
    "add ability to view the result of the intersection of the space with an hyperplane"

} ;


ARTICLE: "4DStroll" "4DStroll"
{ $vocab-link "4DStroll" }
$nl
{ $heading "4D Navigator" }
"4DStroll is a simple tool to visualize 4 dimensionnal objects."
"\n"
"It uses " { $vocab-link "4DStroll.adsoda" } " library to display a 4D space and navigate thru it."
$nl
"It will display:"
{ $list
    { "a menu window" }
    {  "4 visualization windows" }
}
"Each visualization window represents the projection of the 4D space on a particular 3D space."

{ $heading "Start" }
"type:" { $code "\"4DStroll\" load" } 
{ $code "4DStroll" } 


{ $heading "Navigation" }
"Menu window is divided in 2 areas"
{ $list
    { "a space describer listing solids" }
!    { "a parametrization area to select the projection mode" }
    { "4D submenu to translate and rotate selected solids" }
! { "3D submenu to move the camera in 3D space. Cameras in every 3D spaces are manipulated as a single one" }

}

$nl

"Navigation in each 3D window is done individualy using keys: "

{ $table
    {    { "j / m" } { " strafe left / right" } }
    { { "k / l" } { " strafe front / back" } }
    { { "i / ;" } { " strafe up / down" } }
    { { "q / f" } { " turn left / right" } }
    { { "s / d" } { " pitch down / up" } }
    { { "e / c" } { " roll left / right" } }
    { { "n" } { " reinit camera position" } }
! { "3D submenu to move the camera in 3D space. Cameras in every 3D spaces are manipulated as a single one" }

}


{ $heading "hyperspace manipulations" }
"First select one or more solid in the space descriptor screen and then move the selection using rotation or translation buttons."
$nl
"The delete button remove selected solid"
$nl
"The Add button open a window in order to select space to add."
$nl
"The group and ungroup buttons handle packing function."

{ $heading "Links" }
{ $subsection "Space file" }

{ $subsection "TODO" }
{ $subsection "implementation details" }

;

ABOUT: "4DStroll"
