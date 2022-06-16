
/* take two binary "float" files as sin and cos of structure factor
   generate color image in ppm format						-James Holton		7-15-11

example:

gcc -O -O -o phase_color phase_color.c -lm
./phase_color sinfile.bin cosfile.bin output.ppm

 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


char *sinfilename = "";
char *cosfilename = "";
FILE *sinfile = NULL;
FILE *cosfile = NULL;
char *outfilename = "output.ppm\0";
FILE *outfile = NULL;

int main(int argc, char** argv)
{
     
    int n,i,j,k,pixels,xpixels,ypixels;
    int r,g,b;
    float *outimage_red;
    float *outimage_green;
    float *outimage_blue;
    float *sinimage;
    float *cosimage;
    float sum,sumd,sumsq,sumdsq,avg,rms,rmsd,min,max;
    float max_red,max_green,max_blue;
    float min_red,min_green,min_blue;
    float scale=0.0,magnitude,unit_x,unit_y,unit_red,unit_green,unit_blue;
        
    /* check argument list */
    for(i=1; i<argc; ++i)
    {
	if(strlen(argv[i]) > 4)
	{
	    if(strstr(argv[i]+strlen(argv[i])-4,".bin"))
	    {
		printf("filename: %s\n",argv[i]);
		if(sinfile == NULL){
		    sinfile = fopen(argv[i],"r");
		    if(sinfile != NULL) sinfilename = argv[i];
		}
		else
		{
		    if(cosfile == NULL){
		        cosfile = fopen(argv[i],"r");
			if(cosfile != NULL) cosfilename = argv[i];
		    }
		}
	    }
	    if(strstr(argv[i]+strlen(argv[i])-4,".ppm"))
	    {
		outfilename = argv[i];
	    }
	}

        if(argv[i][0] == '-')
        {
            /* option specified */
            if(strstr(argv[i], "-scale") && (argc >= (i+1)))
            {
                scale = atof(argv[i+1]);
            }
        }
    }

    if(sinfile == NULL || cosfile == NULL){
	printf("usage: phase_color sinfile.bin cosfile.bin [outfile.ppm]\n");
	printf("options:\n");\
exit(9);
    }


    /* load first float-image */
    fseek(sinfile,0,SEEK_END);
    n = ftell(sinfile);
    rewind(sinfile);
    sinimage = calloc(n,1);
    cosimage = calloc(n,1);
    fread(sinimage,n,1,sinfile);
    fclose(sinfile);
    fread(cosimage,n,1,cosfile);
    fclose(cosfile);

    pixels = n/sizeof(float);
    outfile = fopen(outfilename,"w");
    if(outfile == NULL)
    {
	printf("ERROR: unable to open %s\n", outfilename);
	exit(9);
    }
    

    outimage_red   = calloc(pixels,sizeof(float));
    outimage_green = calloc(pixels,sizeof(float));
    outimage_blue  = calloc(pixels,sizeof(float));
    sum = sumsq = sumd = sumdsq = 0.0;
    min = 1e99;max=-1e99;
    min_red = 1e99;max_red=-1e99;
    min_green = 1e99;max_green=-1e99;
    min_blue = 1e99;max_blue=-1e99;
    for(i=0;i<pixels;++i)
    {
	/* calculate magnitude of the vector */
	magnitude = sqrt(sinimage[i]*sinimage[i]+cosimage[i]*cosimage[i]);

	if(magnitude*magnitude > max) max=magnitude*magnitude;
	if(magnitude*magnitude < min) min=magnitude*magnitude;
	sumsq += magnitude*magnitude*magnitude*magnitude;

	/* equivalent unit vector */
	unit_x = sinimage[i]/magnitude;
	unit_y = cosimage[i]/magnitude;

	/* red is straight down x-axis */
	unit_red   = 0.0*unit_x + 1.0*unit_y                 + 0.75;
	unit_green = 0.866025403784439*unit_x -0.5*unit_y    + 0.75;
	unit_blue  = -0.866025403784439*unit_x -0.5*unit_y   + 0.75;

	outimage_red[i]   = magnitude*magnitude*unit_red;
	outimage_green[i] = magnitude*magnitude*unit_green;
	outimage_blue[i]  = magnitude*magnitude*unit_blue;

	if(outimage_red[i] > max_red) max_red=outimage_red[i];
	if(outimage_green[i] > max_green) max_green=outimage_green[i];
	if(outimage_blue[i] > max_blue) max_blue=outimage_blue[i];
	if(outimage_red[i] < min_red) min_red=outimage_red[i];
	if(outimage_green[i] < min_green) min_green=outimage_green[i];
	if(outimage_blue[i] < min_blue) min_blue=outimage_blue[i];
    }

    if(scale == 0.0) {
	scale = 255.0 / sqrt( sumsq / pixels );
	printf("auto-scaling\n");
    }
    printf("scale set to %f\n",scale);

    for(i=0;i<pixels;++i)
    {
	outimage_red[i]   *= scale;
	outimage_green[i] *= scale;
	outimage_blue[i]  *= scale;	
    }
    max_red   *=scale;
    min_red   *=scale;
    max_green *=scale;
    min_green *=scale;
    max_blue  *=scale;
    min_blue  *=scale;

    printf("writing %s as ppm\n",outfilename);
    outfile = fopen(outfilename,"w");
    xpixels = sqrt(pixels);
    ypixels = xpixels;
    fprintf(outfile,"P3\n%d %d\n255\n",xpixels,ypixels);
    for(i=0;i<pixels;++i)
    {
	magnitude = sqrt(outimage_red[i]*outimage_red[i] + outimage_green[i]*outimage_green[i] + outimage_blue[i]*outimage_blue[i]);

	if(magnitude>255.0)
       	{
	    outimage_red[i]=outimage_red[i]*255.0/magnitude;
	    outimage_green[i]=outimage_green[i]*255.0/magnitude;
	    outimage_blue[i]=outimage_blue[i]*255.0/magnitude;
	}
        r = outimage_red[i];
        g = outimage_green[i];
        b = outimage_blue[i];
	if(r > 255) r=255;
	if(g > 255) g=255;
	if(b > 255) b=255;
	if(r < 0) r = 0;
	if(g < 0) g = 0;
	if(b < 0) b = 0;

        fprintf(outfile,"%3d %3d %3d  ",r,g,b);
	if(i%3 == 0) fprintf(outfile,"\n");
    }
    fclose(outfile);

    printf("max red   = %f  min_red   = %f\n",max_red,min_red);
    printf("max green = %f  min_green = %f\n",max_green,min_green);
    printf("max blue  = %f  min_blue  = %f\n",max_blue,min_blue);

    return;
}

