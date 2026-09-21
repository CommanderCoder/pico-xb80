// From a GenAI model but looks like it was taken from human code. (Markku Reunanen - https://www.kameli.net/marq/?page_id=974)
// I have not verified the correctness of this code. Use at your own risk.

// The crudest possible bin -> mzf converter

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc,char *argv[])
{
    static unsigned char klumppi[64000];
    int i=0,c,len,start;

    if(argc!=3)
    {
        //printf("bin2mzf FILENAME (17 chars max) execaddr (???? hex = loadaddr) <infile.bin >outfile.mzf\n");
        printf("bin2mzf filename_on_tape execaddr_hex < infile.bin > outfile.mzf\n");
        return(1);
    }

    while(1)
    {
        c=getchar();
        if(c==EOF)
            break;

        klumppi[i++]=c;
    }
    len=i;

    putchar(1);                         // file type
    printf("%s\r",argv[1]);             // filename
    for(i=0;i<16-strlen(argv[1]);i++)   // pad
        putchar(0);
    putchar(len&0xff);                  // content len
    putchar(len>>8);

    start=strtol(argv[2],NULL,16);

    putchar(start&0xff);                // Load and exec addresses
    putchar(start>>8);
    putchar(start&0xff);                // Load and exec addresses
    putchar(start>>8);

    for(i=0;i<104;i++)
        putchar(0);

    for(i=0;i<len;i++)
        putchar(klumppi[i]);

    return(0);
}