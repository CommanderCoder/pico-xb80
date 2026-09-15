commands

FDL:File list display
> STLT: (list)
> DIRLIST:

A= 0x83
> STCD: (command)
> SNDBYTE:
> RCVBYTE: 
status 00H = ok



=== 

in arduino

      case 0x83:
//// Serial.println("FILE LIST START");
//Sending status code (OK)
        snd1byte(0x00);
        sdinit();
        dirlist();


> dirlist
Get comparison string (up to 32+1 characters)

send name + 0x0d + 0x00
snd1byte(0xFF);
snd1byte(0x00);