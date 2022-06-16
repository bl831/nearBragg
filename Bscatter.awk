#! /bin/awk -f
#
#	Generate a random number with a Gaussian distribution
#
#
#
BEGIN{srand();pi=atan2(1,1)*4}

{
    X = $1; Y = $2; Z = $3; B = $4;
    u0 = sqrt(B/8/pi/pi);
    print X+u0*gaussrand(), Y+u0*gaussrand(), Z+u0*gaussrand() 
}

function gaussrand(sigma){
    if(! sigma) sigma=1
    rsq=0
    while((rsq >= 1)||(rsq == 0))
    {
	x=2.0*rand()-1.0
	y=2.0*rand()-1.0
	rsq=x*x+y*y
    }
    fac = sqrt(-2.0*log(rsq)/rsq);
    return sigma*x*fac
}

