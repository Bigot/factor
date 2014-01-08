! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private math fry ;
IN: 4DStroll.adsoda.tools

: dimension ( array -- x )      length 1 - ; inline 

: change-last ( seq quot -- ) 
    swap  [ dimension ] keep rot
    [ [ nth ] dip call( x -- x ) ] 3keep drop set-nth-unsafe ; inline

: roll ( x y z t -- y z t x ) [ rot ] dip swap ;   inline

