#! /bin/tcsh -f

set n = "$1"

if("$n" == "") set n = 100

./random_mosaic_domains.com 180 1000 >! mats.txt

echo -n "" >! rotated_displacements.txt
foreach mat ( `seq 1 $n` )
    echo "$mat"
    set matrix = `egrep "^$mat " mats.txt | awk '{print $2,$3,$4}'`
    ./rotate.awk -v matrix="$matrix" displacements.txt >> rotated_displacements.txt
end

cat rotated_displacements.txt |\
awk '{print $1;print $2;print $3}' |\
awk '{print sqrt(($1)^2)}' |\
~/awk/histogram.awk -v bs=0.00001 |\
sort -g | tee hist.txt

cat rotated_displacements.txt |\
awk '{print $1;print $2;print $3}' |\
awk '{print sqrt(($1)^2)}' |\
~/awk/histogram.awk -v bs=0.1 -v logscale=1 |\
sort -g | tee loghist.txt


