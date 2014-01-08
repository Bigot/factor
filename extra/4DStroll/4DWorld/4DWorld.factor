! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel 
  sequences accessors models
  4DStroll.4DWorld.space-file-decoder
  4DStroll.4DWorld.parameters
  4DStroll.adsoda.space
  4DStroll.ui.camera
  math.vectors
  arrays
  fry
  variables
  namespaces
  assocs
;
IN: 4DStroll.4DWorld



! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


TUPLE: 4DWorld 
    space
    projection1 projection2 projection3 projection4 
    projection-mode collision-mode 
    translation-step  
    rotation-step 
    active-views
    ;


: init-views ( 4DWorld -- )
    dup space>> value>>
    [ 0 space-project >>projection1 ] keep
    [ 1 space-project >>projection2 ] keep
    [ 2 space-project >>projection3 ] keep
    3 space-project  >>projection4
    drop
;

: <4DWorld> ( -- object ) 
    4DWorld new
!    { 0 0 0 } clone >>position
!    3 identity-matrix >>orientation
    0 <model> >>projection-mode 
    f <model> >>collision-mode
    3 >>translation-step  
    5 >>rotation-step 
    t <model> 
    t <model> 
    f <model> 
    t <model> 
    4array >>active-views
;



: >space ( 4DWorld space -- 4DWorld )
    <model> >>space
    dup init-views
;

: file>space ( 4DWorld file -- 4DWorld )
     read-model-file >space
;

: test-file>space ( 4DWorld --  4DWorld )
   ! "D:/Program Files/factor/work/4DStroll/save/hypercube.xml"
    work-directory> "/multi-solids.xml" append
    ! "D:/Program Files/factor/work/4DStroll/save/prismetriagone.xml"
    ! "D:/Program Files/factor/work/4DStroll/save/prismetriagone.xml"    
    file>space
;

: test-world ( -- 4DWorld ) 
    <4DWorld>  test-file>space
;




! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 4D object manipulation
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (apply-to-space) ( 4DWorld quot -- 4DWorld )    
    [ dup space>> dup value>> ] dip 
    call( x -- x )
    swap set-model
    dup
    init-views
   ! space-ensure-solids 
    ! \ present-space set 
!    update-model-projections 

  !  update-observer-projections 
    ; inline

: rotation-4D ( 4DWorld quot -- 4DWorld ) 
    [ dup rotation-step>> ] dip
    call( x -- x )
    '[ _ [ [ middle-of-space dup vneg ] keep swap space-translate ] dip
         space-transform 
         swap space-translate
    ] (apply-to-space) ;

: translation-4D ( 4DWorld v -- 4DWorld ) 
    over translation-step>> v*n
    '[ _ space-translate ] (apply-to-space) ;


: add-space-to-world ( 4DWorld space -- 4DWorld ) 
    [ 
    ! old new
     [ dup solids>> ] [ solids>> ] bi* assoc-union  >>solids
    ] curry (apply-to-space)
; inline


: delete-selected ( 4DWorld -- 4DWorld ) 
    [ delete-selected-solids ] (apply-to-space)
; inline


! M: 4DWorld model-changed
!    nip init-views
! ;



