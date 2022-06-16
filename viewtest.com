#! /bin/tcsh -f


set floatimage = floatimage.bin
if(-e "$1") set floatimage = "$1"
if("$2" != "") then
    set scale = "$2"
    goto makeimage
endif

set stat =  `od -f -w4 $floatimage | awk '$2>max{max=$2} {++n;sumsqr+=$2*$2} END{print max,sqrt(sumsqr/n)}'`
echo "$stat"
set stat =  `od -f -w4 $floatimage | awk -v rms=$stat[2] '$2>max{max=$2} $2<5*rms{++n;sumsqr+=$2*$2} END{print max,sqrt(sumsqr/n)}'`
echo "$stat"
set stat =  `od -f -w4 $floatimage | awk -v rms=$stat[2] '$2>max{max=$2} $2<5*rms{++n;sumsqr+=$2*$2} END{print max,sqrt(sumsqr/n)}'`
echo "$stat"
set scale = `echo $stat | awk '{print 256/(3*$2)}'`
echo "scale = $scale"
makeimage:
cat << EOF >! test.pgm
P2
1000 1000
255
EOF
od -f -w4 $floatimage | awk -v scale=$scale '{v=$2*scale} v<0{v=0} v>255{v=255} {print int(v)}' >> test.pgm
convert -negate test.pgm test.png

convert -type TrueColor -fill yellow -draw "color 500,500 replace" test.png out.gif

convert out.gif test.png



cat << EOF >! test.pgm
P2
1000 1000
255
EOF
od -f -w4 $floatimage | awk -v scale=$scale '{v=$2*scale+128} v<0{v=0} v>255{v=255} {print int(v)}' >> test.pgm
convert test.pgm grey.png


