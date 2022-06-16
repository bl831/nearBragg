#! /bin/awk -f
#
#	rotate x y z on each line by phix phiy phiz on command line
#
#	
# example input:
# echo "1 1 1 " | rotate.awk -v phix=1.23 -v phiy=2.345 -v phiz=3.456
#


BEGIN{
    PI = 4*atan2(1,1)
    RTD = 180./PI
    DTR = PI/180.

    # default rotation matrix
    uxx=1;uxy=0;uxz=0; 
    uyx=0;uyy=1;uyz=0;
    uzx=0;uzy=0;uzz=1;

    rotX=-phix*DTR; rotY=-phiy*DTR; rotZ=-phiz*DTR;
    
    # rotate each basis vector in the U matrix
    rotate(uxx,uxy,uxz,rotX,rotY,rotZ);
    uxx=new_x;uxy=new_y;uxz=new_z;
    rotate(uyx,uyy,uyz,rotX,rotY,rotZ);
    uyx=new_x;uyy=new_y;uyz=new_z;
    rotate(uzx,uzy,uzz,rotX,rotY,rotZ);
    uzx=new_x;uzy=new_y;uzz=new_z;

}

{
    X=$1;Y=$2;Z=$3; rest=$4; 
    for(i=5;i<=NF;++i) rest=rest" "$i;

    newX = uxx*X + uxy*Y + uxz*Z;
    newY = uyx*X + uyy*Y + uyz*Z;
    newZ = uzx*X + uzy*Y + uzz*Z;
    print newX,newY,newZ,rest;
}


# rotate a vector v_x,v_y,v_z about z then y then x axes
# creates new_x,new_y,new_z
function rotate(v_x,v_y,v_z,phix,phiy,phiz) {

new_x=v_x;new_y=v_y;new_z=v_z;


# rotate around z axis
rxx= cos(phiz); rxy=-sin(phiz); rxz= 0; 
ryx= sin(phiz); ryy= cos(phiz); ryz= 0;
rzx= 0;         rzy= 0;         rzz= 1;

rotated_x = new_x*rxx + new_y*rxy + new_z*rxz
rotated_y = new_x*ryx + new_y*ryy + new_z*ryz
rotated_z = new_x*rzx + new_y*rzy + new_z*rzz
new_x = rotated_x; new_y = rotated_y; new_z = rotated_z; 


# rotate around y axis
rxx= cos(phiy); rxy= 0;         rxz= sin(phiy); 
ryx= 0;         ryy= 1;         ryz= 0;
rzx=-sin(phiy); rzy= 0;         rzz= cos(phiy);

rotated_x = new_x*rxx + new_y*rxy + new_z*rxz
rotated_y = new_x*ryx + new_y*ryy + new_z*ryz
rotated_z = new_x*rzx + new_y*rzy + new_z*rzz
new_x = rotated_x; new_y = rotated_y; new_z = rotated_z; 


# rotate around x axis
rxx= 1;         rxy= 0;         rxz= 0; 
ryx= 0;         ryy= cos(phix); ryz=-sin(phix);
rzx= 0;         rzy= sin(phix); rzz= cos(phix);

rotated_x = new_x*rxx + new_y*rxy + new_z*rxz
rotated_y = new_x*ryx + new_y*ryy + new_z*ryz
rotated_z = new_x*rzx + new_y*rzy + new_z*rzz
new_x = rotated_x; new_y = rotated_y; new_z = rotated_z; 


}

