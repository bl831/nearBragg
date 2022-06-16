#! /bin/tcsh -f
#
#	read deviates from 
#
#
set scale = "$1"
if($scale == "") set scale = 0

set deviates = `cat deviates.txt | wc -l`

set group = 300
set n = 0
set start = 0

rm floatimage.bin
while ( $start < $deviates )
@ n = ( $n + 1 )

@ start = ( $n * $group )

tail -n +$start deviates.txt |\
head -$group |\
awk -v scale=$scale '{++i;dx=$1;getline;dy=$1;getline;dz=$1;\
   print dx*scale,dy*scale,(i-50)*1000+dz*scale}' |\
cat > ! atoms.txt


./nearBragg2D -file atoms.txt -curved_detector -detpixels_y 1 \
  -Xbeam 0 -Ybeam 0 \
  -source_distance 1e7 \
  -distance 10000 -detsize_x 100 -pixel 0.01 \
  -printout -accumulate |\
awk -v n=$n '/stol/{stol=$NF} /^I\/sr /{print stol,$NF/n}' >! plotme

cp plotme plotme_latest
echo $n

end

