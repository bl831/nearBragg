#! /bin/awk -f
#
#	Generate a lattice of NxNxN points with a given unit cell
#
#
#
BEGIN{pi=2*atan2(1,0);RTD = 180/pi}

{
    N = $1; a = $2; b = $3; c = $4; alpha = $5; beta = $6; gamma = $7;

    if(alpha=="") alpha = 90;
    if(beta== "") beta = 90;
    if(gamma=="") gamma = 90;
    if(b=="") b = a;
    if(c=="") c = b;

    # convert degrees to radians
    alpha = alpha/RTD; beta = beta/RTD; gamma = gamma/RTD;

    # convention: a along x axis and b in x-y plane
    a_x = a; a_y = 0; a_z = 0;
    b_x = b*cos(gamma); b_y = b*sin(gamma); b_z = 0;

    c_x = c*cos(beta);
    c_y = ( b*c*cos(alpha) - b_x*c_x )/b_y;
    c_z = sqrt(c^2 - c_x^2 - c_y^2);

    for(x=-N;x<=N;++x)for(y=-N;y<=N;++y)for(z=-N;z<=N;++z){
        printf "%.12f %.12f %.12f\n", x*(a_x+b_x+c_x), y*(a_y+b_y+c_y), z*(a_z+b_z+c_z);
    }
}

