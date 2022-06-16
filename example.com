#! /bin/tcsh -f
#
#	quick example of how to use nearBragg2D to make a diffraction pattern
#

gcc -O -O -o nearBragg2D nearBragg2D.c -lm -static

# make a 21x21x21 cube grid with the cell spacing of silicon
echo "10 5.43071" | ./makelattice.awk >! silicon_nanoparticle.txt

# twirl it around
./rotate.awk -v phix=10 -v phiy=20 -v phiz=30 silicon_nanoparticle.txt >! rotated_xtal.txt

# jiggle the atoms by a B factor of 20
awk '{print $0,20}' rotated_xtal.txt | ./Bscatter.awk >! atoms.txt

# count how many atoms we have
set atoms = `cat atoms.txt | wc -l`

# do a fast calculation with a "perfect" beam
./nearBragg2D -atoms $atoms -file ./atoms.txt -lambda 1.0 -dispersion 0 \
   -hdivrange 0.0 -vdivrange 0.0 \
 -intfile intimage_ideal.img -floatfile floatimage_ideal.bin 

# add some divergence and dispersion
./nearBragg2D -atoms $atoms -file ./atoms.txt -lambda 1.0 -dispersion 0.1 \
   -hdivrange 0.062 -vdivrange 0.062 -hdivstep 0.031 -vdivstep 0.031 \
 -intfile intimage_realistic.img -floatfile floatimage_realistic.bin

# view the result
adxv intimage_ideal.img

