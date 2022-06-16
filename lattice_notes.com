#! /bin/tcsh -f
#
#
#


./nearBragg2D -file lattice.txt  \
  -pixel 0.2 -distance 2000 -Zbeam 0 -Xbeam 0 \
  -floatfile lattice.bin \
  -intfile lattice.img | tee lattice.log

set scale = `awk '/^max_I/{print 1/$NF}' lattice.log`

./float_add lattice.bin lattice.bin lattice_mask.bin -scale1 $scale -scale2 0


./float_mult diffuse_Iavg_minus_Favg_256.bin diffuse_Iavg_256.bin \
   -power1 1.0 -power2 -1.0 frac_diff.bin

./float_mult lattice_mask.bin frac_diff.bin weighted_fracdiff.bin

./float_add weighted_fracdiff.bin weighted_fracdiff.bin \
   -scale1 100 -scale2 0 -offset 60 percent_diff.bin

./render.com 1 percent_diff.bin percent_diff.img

