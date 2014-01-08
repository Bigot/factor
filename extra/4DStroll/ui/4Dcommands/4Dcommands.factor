! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel variables namespaces models accessors
4DStroll.4DWorld ui.gadgets
4DStroll.adsoda.tools.math math
;
IN: 4DStroll.ui.4Dcommands

GLOBAL: view1 
GLOBAL: view2
GLOBAL: view3
GLOBAL: view4

GLOBAL: 4dworld



: view1> ( -- x ) \ view1 get-global ; inline
: view2> ( -- x ) \ view2 get-global ; inline
: view3> ( -- x ) \ view3 get-global ; inline
: view4> ( -- x ) \ view4 get-global ; inline

: >view1 ( x -- ) \ view1 set-global ; inline
: >view2 ( x -- ) \ view2 set-global ; inline
: >view3 ( x -- ) \ view3 set-global ; inline
: >view4 ( x -- ) \ view4 set-global ; inline

: 4dworld-model> ( -- x ) \ 4dworld get-global ; inline
: 4dworld> ( -- x ) 4dworld-model> value>> ; inline
: >4dworld ( x -- ) <model> \ 4dworld set-global ; inline


: update-model-projections ( 4DWorld -- 4DWorld )

    dup projection1>> <model> view1> model<<
    dup projection2>> <model> view2> model<<
    dup projection3>> <model> view3> model<<
    dup projection4>> <model> view4> model<<    
;

: apply-to-world ( quot -- ) 
    4dworld> swap call( x -- x ) 
    update-model-projections
    drop
; inline

: update-observer-projections (  -- )
    view1> relayout-1 
    view2> relayout-1 
    view3> relayout-1 
    view4> relayout-1 ;



: (4D-T) ( gadget x -- ) 
    nip
    [ translation-4D ] curry apply-to-world 
    ; inline

: 4D-T+x ( gadget -- ) {  1  0  0  0 } (4D-T) ;
: 4D-T-x ( gadget -- ) { -1  0  0  0 } (4D-T) ;
: 4D-T+y ( gadget -- ) {  0  1  0  0 } (4D-T) ;
: 4D-T-y ( gadget -- ) {  0 -1  0  0 } (4D-T) ;
: 4D-T+z ( gadget -- ) {  0  0  1  0 } (4D-T) ;
: 4D-T-z ( gadget -- ) {  0  0 -1  0 } (4D-T) ;
: 4D-T+w ( gadget -- ) {  0  0  0  1 } (4D-T) ;
: 4D-T-w ( gadget -- ) {  0  0  0 -1 } (4D-T) ;

: (4D-R) ( gadget quot -- )
    nip
    [ rotation-4D ] curry apply-to-world
; inline

: 4D-R+xy ( gadget -- ) [     Rxy ] (4D-R) ;
: 4D-R-xy ( gadget -- ) [ neg Rxy ] (4D-R) ;
: 4D-R+xz ( gadget -- ) [     Rxz ] (4D-R) ;
: 4D-R-xz ( gadget -- ) [ neg Rxz ] (4D-R) ;
: 4D-R+yz ( gadget -- ) [     Ryz ] (4D-R) ;
: 4D-R-yz ( gadget -- ) [ neg Ryz ] (4D-R) ;
: 4D-R+xw ( gadget -- ) [     Rxw ] (4D-R) ;
: 4D-R-xw ( gadget -- ) [ neg Rxw ] (4D-R) ;
: 4D-R+yw ( gadget -- ) [     Ryw ] (4D-R) ;
: 4D-R-yw ( gadget -- ) [ neg Ryw ] (4D-R) ;
: 4D-R+zw ( gadget -- ) [     Rzw ] (4D-R) ;
: 4D-R-zw ( gadget -- ) [ neg Rzw ] (4D-R) ;


