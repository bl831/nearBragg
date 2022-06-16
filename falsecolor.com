#! /bin/tcsh -f
#
#
#
set xsize = 640
set ysize = 480
set scale = 1

set binfile = "$1"
if("$2" != "") set scale = "$2"
if("$3" != "") set xsize = "$3"
if("$4" != "") set ysize = "$4"

set imgfile = ""
if("$binfile" =~ "*.img") then
    set imgfile = $binfile
    set offset = 0
    if("$3" != "") set offset = "$3"
    goto imgfile
endif


od -f -v -w4 $binfile |\
awk -v scale=$scale '{print $2*scale/65535}' |\
awk -v xsize=$xsize -v ysize=$ysize 'BEGIN{pi=4*atan2(1,1);\
    print "P3\n"xsize" "ysize"\n255\n"} {x=$1;\
      l0=x**0.3;\
      if(l0==0)l0=1e-30;\
      r=((1-sin(x*3*pi))/2)**1;\
      g=((1-sin(x*5*pi))/2)**1;\
      b=((1-sin(x*7*pi))/2)**0.5;\
      l=0.30*r+0.59*g+0.11*b;\
      if(l==0)l=l0;\
      g=(l0-0.30*r-0.11*b)/0.59;\
      if(g>1){g=1;r=(l0-0.59*g-0.11*b)/0.30}\
      if(r>1){r=1;b=(l0-0.30*r-0.59*g)/0.11}\
      if(b>1){b=1};\
      if(l0>1){r=0;g=0;b=1};\
print int(255*r),int(255*g),int(255*b)}' |\
cat >! color.ppm
goto convert

imgfile:

set xsize = `head -512c $imgfile | awk -F "=" '/^SIZE1/{print $2+0}' | tail -1`
set ysize = `head -512c $imgfile | awk -F "=" '/^SIZE2/{print $2+0}' | tail -1`

echo "xsize=$xsize ysize=$ysize"

od -tu2 -j512 -v -w2 $imgfile |\
awk -v scale=$scale -v offset=$offset '{print ($2-offset-40)*scale/(65535-offset-40)}' |\
awk -v xsize=$xsize -v ysize=$ysize 'BEGIN{pi=4*atan2(1,1);\
    print "P3\n"xsize" "ysize"\n255\n"} {x=$1;\
      if(x<0)x=0;\
      l0=x**0.3;\
      if(l0==0)l0=1e-30;\
      r=((1-sin(x*3*pi))/2)**1;\
      g=((1-sin(x*5*pi))/2)**1;\
      b=((1-sin(x*7*pi))/2)**0.5;\
      l=0.30*r+0.59*g+0.11*b;\
      if(l==0)l=l0;\
      g=(l0-0.30*r-0.11*b)/0.59;\
      if(g>1){g=1;r=(l0-0.59*g-0.11*b)/0.30}\
      if(r>1){r=1;b=(l0-0.30*r-0.59*g)/0.11}\
      if(b>1){b=1};\
      if(l0>1){r=0;g=0;b=1};\
print int(255*r),int(255*g),int(255*b)}' |\
cat >! color.ppm

convert:

convert color.ppm color.png

exit


      r=((1-cos(x*3*pi))/2)**1;\
      g=((1-cos(x*5*pi))/2)**1;\
      b=((1-cos(x*7*pi))/2)**0.5;\
