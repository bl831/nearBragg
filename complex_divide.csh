#! /bin/tcsh -f
#
#	use float_mult and float_add to divide two complex numbers
#	Fa +i*Fb = (a+i*b)/(c+i*d)
#
#	then use floatimage.bin to make a phase-only image F0a +i*F0b
#

./float_mult a.bin c.bin ac.bin > /dev/null
./float_mult a.bin d.bin ad.bin > /dev/null
./float_mult b.bin c.bin bc.bin > /dev/null
./float_mult b.bin d.bin bd.bin > /dev/null
./float_mult c.bin c.bin cc.bin > /dev/null
./float_mult d.bin d.bin dd.bin > /dev/null
./float_add cc.bin dd.bin cc+dd.bin > /dev/null
./float_add ac.bin bd.bin ac+bd.bin > /dev/null
./float_add bc.bin ad.bin bc-ad.bin -scale2 -1 > /dev/null
./float_mult ac+bd.bin cc+dd.bin Fa.bin -power2 -1 > /dev/null
./float_mult bc-ad.bin cc+dd.bin Fb.bin -power2 -1 > /dev/null

./float_mult floatimage.bin floatimage.bin invdist.bin -power1 0.5 -power2 0 > /dev/null
./float_mult Fa.bin invdist.bin FOa.bin > /dev/null
./float_mult Fb.bin invdist.bin FOb.bin > /dev/null

