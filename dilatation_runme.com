#! /bin/tcsh -f
#
#	read deviates from a file and dilatate lattice
#
#
set scale = "$1"
if("$scale" == "") set scale = 0
echo "scale = $scale"

set deviates = `cat deviates.txt | wc -l`

set group = 3000
set n = 0
set start = 0

rm floatimage.bin 
rm sinimage.bin cosimage.bin
while ( $start < $deviates )
@ n = ( $n + 1 )

@ start = ( $n * $group )

tail -n +$start deviates.txt |\
head -$group |\
awk -v a=1000 -v scale=$scale 'BEGIN{\
   for(i=1;i<=100;++i){x[i]=0;y[i]=0;z[i]=(i-50)*a}\
  }\
  {dx=0*$1;getline;dy=0*$1;getline;dz=a*1000*$1;\
   for(i=1;i<=100;++i){\
	r=sqrt((x[i]-dx)^2+(y[i]-dy)^2+(z[i]-dz)^2);\
	u=scale/r^2;\
	u_x=u*x[i]/r;\
	u_y=u*y[i]/r;\
	u_z=u*z[i]/r;\
	x[i]+=u_x;y[i]+=u_y;z[i]+=u_z;\
    }}\
 END{for(i=1;i<=100;++i){print x[i],y[i],z[i]}}' |\
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

