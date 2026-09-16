XOR A                  ;1200 > AF            ¯
LD (3D16H),A           ;1201   32 16 3D      2=
LD (FFFFH),A           ;1204   32 FF FF      2ÿÿ
LD HL,43FFH            ;1207   21 FF 43      !ÿC
LD D,D0H               ;120A   16 D0         Ð
INC HL                 ;120C   23            #
LD A,H                 ;120D   7C            |
CP D                   ;120E   BA            º
JR Z,121BH             ;120F   28 0A         (

LD A,FFH               ;1211   3E FF         >ÿ
LD (HL),A              ;1213   77            w
SUB (HL)               ;1214   96            
JR NZ,121BH            ;1215   20 04          
LD (HL),A              ;1217   77            w
CP (HL)                ;1218   BE            ¾
JR Z,120CH             ;1219   28 F1         (ñ
LD (4561H),HL          ;121B   22 61 45      "aE
LD (4563H),HL          ;121E   22 63 45      "cE
LD SP,HL               ;1221   F9            ù
CALL 0006H             ;1222   CD 06 00      Í
LD DE,12E2H            ;1225   11 E2 12      â
CALL 0015H             ;1228   CD 15 00      Í
CALL 1832H             ;122B   CD 32 18      Í2
LD BC,000AH            ;122E   01 0A 00      

CALL 173FH             ;1231   CD 3F 17      Í?
LD DE,4400H            ;1234   11 00 44      D
PUSH DE                ;1237   D5            Õ
CALL 16F7H             ;1238   CD F7 16      Í÷
POP DE                 ;123B   D1            Ñ
CALL 1357H             ;123C   CD 57 13      ÍW
LD DE,1326H            ;123F   11 26 13      &
CALL 0015H             ;1242   CD 15 00      Í
XOR A                  ;1245   AF            ¯
LD D,A                 ;1246   57            W
LD E,A                 ;1247   5F            _
CALL 0033H             ;1248   CD 33 00      Í3
LD DE,12FEH            ;124B   11 FE 12      þ
CALL 0030H             ;124E   CD 30 00      Í0
LD DE,12F9H            ;1251   11 F9 12      ù
CALL 1357H             ;1254   CD 57 13      ÍW
LD A,(4565H)           ;1257   3A 65 45      :eE
OR A                   ;125A   B7            ·
JP Z,1274H             ;125B   CA 74 12      Êt
LD HL,(47FFH)          ;125E   2A FF 47      *ÿG
LD A,H                 ;1261   7C            |
OR L                   ;1262   B5            µ
JP Z,1278H             ;1263   CA 78 12      Êx
LD BC,0006H            ;1266   01 06 00      
LD DE,4566H            ;1269   11 66 45      fE
LD HL,47FDH            ;126C   21 FD 47      !ýG
CALL 1799H             ;126F   CD 99 17      Í
JR 1278H               ;1272   18 04         
LD HL,(4563H)          ;1274   2A 63 45      *cE
LD SP,HL               ;1277   F9            ù
CALL 184EH             ;1278   CD 4E 18      ÍN
CALL 0009H             ;127B   CD 09 00      Í	
LD DE,4400H            ;127E   11 00 44      D
CALL 0003H             ;1281   CD 03 00      Í
CALL 13CEH             ;1284   CD CE 13      ÍÎ
CALL 1443H             ;1287   CD 43 14      ÍC
LD HL,(4457H)          ;128A   2A 57 44      *WD
LD A,L                 ;128D   7D            }
OR H                   ;128E   B4            ´
JR NZ,12A0H            ;128F   20 0F          
LD HL,4459H            ;1291   21 59 44      !YD
LD (4801H),HL          ;1294   22 01 48      "H
CALL 168BH             ;1297   CD 8B 16      Í
DEC C                  ;129A   0D            
POP HL                 ;129B   E1            á
ADD HL,DE              ;129C   19            
JP 1278H               ;129D   C3 78 12      Ãx
CALL 1987H             ;12A0   CD 87 19      Í
CALL 13C1H             ;12A3   CD C1 13      ÍÁ
CALL 17A5H             ;12A6   CD A5 17      Í¥
CP (HL)                ;12A9   BE            ¾
LD (DE),A              ;12AA   12            
JR NZ,12BEH            ;12AB   20 11          
CALL 17E8H             ;12AD   CD E8 17      Íè
EX DE,HL               ;12B0   EB            ë
CALL 1766H             ;12B1   CD 66 17      Íf
CALL 1651H             ;12B4   CD 51 16      ÍQ
CALL 189CH             ;12B7   CD 9C 18      Í
EX DE,HL               ;12BA   EB            ë
CALL 17E0H             ;12BB   CD E0 17      Íà
LD A,(4459H)           ;12BE   3A 59 44      :YD
CP 0DH                 ;12C1   FE 0D         þ
JP Z,1257H             ;12C3   CA 57 12      ÊW
CALL 17A8H             ;12C6   CD A8 17      Í¨
RL D                   ;12C9   CB 12         Ë
LD (4455H),HL          ;12CB   22 55 44      "UD
EX DE,HL               ;12CE   EB            ë
LD HL,4455H            ;12CF   21 55 44      !UD
CALL 17E8H             ;12D2   CD E8 17      Íè
CALL 1796H             ;12D5   CD 96 17      Í
CALL 189CH             ;12D8   CD 9C 18      Í
EX DE,HL               ;12DB   EB            ë
CALL 17E0H             ;12DC   CD E0 17      Íà
JP 1257H               ;12DF   C3 57 12      ÃW
JR NZ,130EH            ;12E2   20 2A          *
JR NZ,1339H            ;12E4   20 53          S
LD C,B                 ;12E6   48            H
LD B,C                 ;12E7   41            A
LD D,D                 ;12E8   52            R
LD D,B                 ;12E9   50            P
JR NZ,132EH            ;12EA   20 42          B
LD B,C                 ;12EC   41            A
LD D,E                 ;12ED   53            S
LD C,C                 ;12EE   49            I
LD B,E                 ;12EF   43            C
JR NZ,1345H            ;12F0   20 53          S
LD D,B                 ;12F2   50            P
DEC L                  ;12F3   2D            -
DEC (HL)               ;12F4   35            5
JR NC,1329H            ;12F5   30 32         02
DEC (HL)               ;12F7   35            5
DEC C                  ;12F8   0D            
LD D,D                 ;12F9   52            R
LD B,L                 ;12FA   45            E
LD B,C                 ;12FB   41            A
LD B,H                 ;12FC   44            D
LD E,C                 ;12FD   59            Y
DEC C                  ;12FE   0D            
JR NZ,1346H            ;12FF   20 45          E
LD D,D                 ;1301   52            R
LD D,D                 ;1302   52            R
LD C,A                 ;1303   4F            O
LD D,D                 ;1304   52            R
DEC C                  ;1305   0D            
JR NZ,1351H            ;1306   20 49          I
LD C,(HL)              ;1308   4E            N
DEC C                  ;1309   0D            
LD D,E                 ;130A   53            S
LD E,C                 ;130B   59            Y
LD C,(HL)              ;130C   4E            N
LD D,H                 ;130D   54            T
LD B,C                 ;130E   41            A
LD E,B                 ;130F   58            X
DEC C                  ;1310   0D            
LD C,L                 ;1311   4D            M
LD B,L                 ;1312   45            E
LD C,L                 ;1313   4D            M
LD C,A                 ;1314   4F            O
LD D,D                 ;1315   52            R
LD E,C                 ;1316   59            Y
DEC C                  ;1317   0D            
LD B,H                 ;1318   44            D
LD B,C                 ;1319   41            A
LD D,H                 ;131A   54            T
LD B,C                 ;131B   41            A
DEC C                  ;131C   0D            
LD C,L                 ;131D   4D            M
LD C,C                 ;131E   49            I
LD D,E                 ;131F   53            S
LD C,L                 ;1320   4D            M
LD B,C                 ;1321   41            A
LD D,H                 ;1322   54            T
LD B,E                 ;1323   43            C
LD C,B                 ;1324   48            H
DEC C                  ;1325   0D            
JR NZ,136AH            ;1326   20 42          B
LD E,C                 ;1328   59            Y
LD D,H                 ;1329   54            T
LD B,L                 ;132A   45            E
LD D,E                 ;132B   53            S
DEC C                  ;132C   0D            
LD B,D                 ;132D   42            B
LD D,D                 ;132E   52            R
LD B,L                 ;132F   45            E
LD B,C                 ;1330   41            A
LD C,E                 ;1331   4B            K
DEC C                  ;1332   0D            
LD SP,4636H            ;1333   31 36 46      16F
LD C,A                 ;1336   4F            O
LD D,D                 ;1337   52            R
DEC C                  ;1338   0D            
LD SP,4736H            ;1339   31 36 47      16G
LD C,A                 ;133C   4F            O
LD D,E                 ;133D   53            S
LD D,L                 ;133E   55            U
LD B,D                 ;133F   42            B
DEC C                  ;1340   0D            
LD (HL),46H            ;1341   36 46         6F
LD C,(HL)              ;1343   4E            N
DEC C                  ;1344   0D            
LD B,E                 ;1345   43            C
LD C,A                 ;1346   4F            O
LD C,(HL)              ;1347   4E            N
LD D,H                 ;1348   54            T
DEC C                  ;1349   0D            
LD B,(HL)              ;134A   46            F
LD C,C                 ;134B   49            I
LD C,H                 ;134C   4C            L
LD B,L                 ;134D   45            E
DEC C                  ;134E   0D            
LD C,A                 ;134F   4F            O
LD D,(HL)              ;1350   56            V
LD B,L                 ;1351   45            E
LD D,D                 ;1352   52            R
LD C,H                 ;1353   4C            L
LD B,C                 ;1354   41            A
LD E,C                 ;1355   59            Y
DEC C                  ;1356   0D            
CALL 0009H             ;1357   CD 09 00      Í	
JP 0015H               ;135A   C3 15 00      Ã
CALL 187CH             ;135D   CD 7C 18      Í|
CALL 1357H             ;1360   CD 57 13      ÍW
LD DE,12FFH            ;1363   11 FF 12      ÿ
CALL 0015H             ;1366   CD 15 00      Í
LD HL,(47FFH)          ;1369   2A FF 47      *ÿG
LD A,L                 ;136C   7D            }
OR H                   ;136D   B4            ´
JP Z,124BH             ;136E   CA 4B 12      ÊK
LD DE,4400H            ;1371   11 00 44      D
PUSH DE                ;1374   D5            Õ
CALL 16F7H             ;1375   CD F7 16      Í÷
LD DE,1306H            ;1378   11 06 13      
CALL 0015H             ;137B   CD 15 00      Í
POP DE                 ;137E   D1            Ñ
CALL 0015H             ;137F   CD 15 00      Í
JP 124BH               ;1382   C3 4B 12      ÃK
CALL 0009H             ;1385   CD 09 00      Í	
LD DE,132DH            ;1388   11 2D 13      -
JP 1366H               ;138B   C3 66 13      Ãf
LD DE,130AH            ;138E   11 0A 13      

JR 1396H               ;1391   18 03         
LD DE,1311H            ;1393   11 11 13      
JR 139BH               ;1396   18 03         
LD DE,1318H            ;1398   11 18 13      
JR 13A0H               ;139B   18 03         
LD DE,131DH            ;139D   11 1D 13      
JR 13A5H               ;13A0   18 03         
LD DE,1333H            ;13A2   11 33 13      3
JR 13AAH               ;13A5   18 03         
LD DE,1339H            ;13A7   11 39 13      9
JR 13AFH               ;13AA   18 03         
LD DE,1341H            ;13AC   11 41 13      A
JR 13B4H               ;13AF   18 03         
LD DE,134AH            ;13B1   11 4A 13      J
JR 13B9H               ;13B4   18 03         
LD DE,134FH            ;13B6   11 4F 13      O
JR 13BEH               ;13B9   18 03         
LD DE,1345H            ;13BB   11 45 13      E
JP 135DH               ;13BE   C3 5D 13      Ã]
XOR A                  ;13C1   AF            ¯
JR 13C6H               ;13C2   18 02         
LD A,01H               ;13C4   3E 01         >
JR 13CAH               ;13C6   18 02         
LD A,02H               ;13C8   3E 02         >
LD (4565H),A           ;13CA   32 65 45      2eE
RET                    ;13CD   C9            É
LD HL,4400H            ;13CE   21 00 44      !D
CALL 16F1H             ;13D1   CD F1 16      Íñ
EX DE,HL               ;13D4   EB            ë
LD (4457H),HL          ;13D5   22 57 44      "WD
LD HL,4459H            ;13D8   21 59 44      !YD
LD C,00H               ;13DB   0E 00         
EX DE,HL               ;13DD   EB            ë
CALL 162DH             ;13DE   CD 2D 16      Í-
CALL 1491H             ;13E1   CD 91 14      Í
RET Z                  ;13E4   C8            È
DEC DE                 ;13E5   1B            
CP 3FH                 ;13E6   FE 3F         þ?
JR NZ,13F0H            ;13E8   20 06          
LD A,85H               ;13EA   3E 85         >
LD (DE),A              ;13EC   12            
INC DE                 ;13ED   13            
JR 13E1H               ;13EE   18 F1         ñ
DEC HL                 ;13F0   2B            +
EX DE,HL               ;13F1   EB            ë
PUSH HL                ;13F2   E5            å
LD HL,14D8H            ;13F3   21 D8 14      !Ø
LD B,80H               ;13F6   06 80         
PUSH DE                ;13F8   D5            Õ
CALL 162DH             ;13F9   CD 2D 16      Í-
EX DE,HL               ;13FC   EB            ë
CALL 162DH             ;13FD   CD 2D 16      Í-
EX DE,HL               ;1400   EB            ë
CP (HL)                ;1401   BE            ¾
INC HL                 ;1402   23            #
INC DE                 ;1403   13            
JR Z,13F9H             ;1404   28 F3         (ó
DEC HL                 ;1406   2B            +
CP FFH                 ;1407   FE FF         þÿ
JP Z,1415H             ;1409   CA 15 14      Ê
ADD A,80H              ;140C   C6 80         Æ
JP C,138EH             ;140E   DA 8E 13      Ú
CP (HL)                ;1411   BE            ¾
JP Z,1427H             ;1412   CA 27 14      Ê'
INC B                  ;1415   04            
LD A,DCH               ;1416   3E DC         >Ü
CP B                   ;1418   B8            ¸
JP Z,143BH             ;1419   CA 3B 14      Ê;
LD A,7FH               ;141C   3E 7F         >
CP (HL)                ;141E   BE            ¾
INC HL                 ;141F   23            #
JP NC,141EH            ;1420   D2 1E 14      Ò
POP DE                 ;1423   D1            Ñ
JP 13F8H               ;1424   C3 F8 13      Ãø
POP AF                 ;1427   F1            ñ
POP HL                 ;1428   E1            á
LD (HL),B              ;1429   70            p
INC HL                 ;142A   23            #
EX DE,HL               ;142B   EB            ë
LD A,B                 ;142C   78            x
CP 82H                 ;142D   FE 82         þ
JP NC,13E1H            ;142F   D2 E1 13      Òá
CALL 14C5H             ;1432   CD C5 14      ÍÅ
CP 3AH                 ;1435   FE 3A         þ:
JP Z,13E1H             ;1437   CA E1 13      Êá
RET                    ;143A   C9            É
POP DE                 ;143B   D1            Ñ
POP HL                 ;143C   E1            á
INC DE                 ;143D   13            
INC HL                 ;143E   23            #
EX DE,HL               ;143F   EB            ë
JP 13E1H               ;1440   C3 E1 13      Ãá
LD HL,(4457H)          ;1443   2A 57 44      *WD
LD DE,4400H            ;1446   11 00 44      D
LD C,B2H               ;1449   0E B2         ²
CALL 16F9H             ;144B   CD F9 16      Íù
LD A,20H               ;144E   3E 20         > 
LD (DE),A              ;1450   12            
INC DE                 ;1451   13            
LD HL,4459H            ;1452   21 59 44      !YD
CALL 1491H             ;1455   CD 91 14      Í
RET Z                  ;1458   C8            È
SUB 80H                ;1459   D6 80         Ö
JP M,1455H             ;145B   FA 55 14      úU
DEC C                  ;145E   0D            
PUSH AF                ;145F   F5            õ
DEC DE                 ;1460   1B            
PUSH HL                ;1461   E5            å
LD HL,14D8H            ;1462   21 D8 14      !Ø
OR A                   ;1465   B7            ·
JP Z,1475H             ;1466   CA 75 14      Êu
PUSH AF                ;1469   F5            õ
LD A,7FH               ;146A   3E 7F         >
CP (HL)                ;146C   BE            ¾
INC HL                 ;146D   23            #
JR NC,146CH            ;146E   30 FC         0ü
POP AF                 ;1470   F1            ñ
DEC A                  ;1471   3D            =
JP 1465H               ;1472   C3 65 14      Ãe
CALL 14BAH             ;1475   CD BA 14      Íº
OR A                   ;1478   B7            ·
JP P,1475H             ;1479   F2 75 14      òu
DEC DE                 ;147C   1B            
AND 7FH                ;147D   E6 7F         æ
LD (DE),A              ;147F   12            
INC DE                 ;1480   13            
POP HL                 ;1481   E1            á
POP AF                 ;1482   F1            ñ
CP 02H                 ;1483   FE 02         þ
JP NC,1455H            ;1485   D2 55 14      ÒU
CALL 14C5H             ;1488   CD C5 14      ÍÅ
CP 3AH                 ;148B   FE 3A         þ:
JP Z,1455H             ;148D   CA 55 14      ÊU
RET                    ;1490   C9            É
CALL 14BAH             ;1491   CD BA 14      Íº
RET Z                  ;1494   C8            È
CALL 14A5H             ;1495   CD A5 14      Í¥
JR Z,1491H             ;1498   28 F7         (÷
CP 22H                 ;149A   FE 22         þ"
RET NZ                 ;149C   C0            À
CALL 14B1H             ;149D   CD B1 14      Í±
CP 0DH                 ;14A0   FE 0D         þ
JR NZ,1491H            ;14A2   20 ED          í
RET                    ;14A4   C9            É
CP 20H                 ;14A5   FE 20         þ 
RET Z                  ;14A7   C8            È
CP FFH                 ;14A8   FE FF         þÿ
RET Z                  ;14AA   C8            È
CP 28H                 ;14AB   FE 28         þ(
RET Z                  ;14AD   C8            È
CP 29H                 ;14AE   FE 29         þ)
RET                    ;14B0   C9            É
CALL 14BAH             ;14B1   CD BA 14      Íº
RET Z                  ;14B4   C8            È
CP 22H                 ;14B5   FE 22         þ"
JR NZ,14B1H            ;14B7   20 F8          ø
RET                    ;14B9   C9            É
LD A,(HL)              ;14BA   7E            ~
LD (DE),A              ;14BB   12            
INC HL                 ;14BC   23            #
INC DE                 ;14BD   13            
INC C                  ;14BE   0C            
JP Z,1398H             ;14BF   CA 98 13      Ê
CP 0DH                 ;14C2   FE 0D         þ
RET                    ;14C4   C9            É
CALL 14BAH             ;14C5   CD BA 14      Íº
RET Z                  ;14C8   C8            È
CP 3AH                 ;14C9   FE 3A         þ:
RET Z                  ;14CB   C8            È
CP 22H                 ;14CC   FE 22         þ"
JR NZ,14C5H            ;14CE   20 F5          õ
CALL 14B1H             ;14D0   CD B1 14      Í±
CP 0DH                 ;14D3   FE 0D         þ
JR NZ,14C5H            ;14D5   20 EE          î
RET                    ;14D7   C9            É
LD D,D                 ;14D8   52            R
LD B,L                 ;14D9   45            E
CALL 4144H             ;14DA   CD 44 41      ÍDA
LD D,H                 ;14DD   54            T
POP BC                 ;14DE   C1            Á
LD C,H                 ;14DF   4C            L
LD C,C                 ;14E0   49            I
LD D,E                 ;14E1   53            S
CALL NC,5552H          ;14E2   D4 52 55      ÔRU
ADC A,4EH              ;14E5   CE 4E         ÎN
LD B,L                 ;14E7   45            E
RST 10H                ;14E8   D7            ×
LD D,B                 ;14E9   50            P
LD D,D                 ;14EA   52            R
LD C,C                 ;14EB   49            I
LD C,(HL)              ;14EC   4E            N
CALL NC,454CH          ;14ED   D4 4C 45      ÔLE
CALL NC,4F46H          ;14F0   D4 46 4F      ÔFO
JP NC,C649H            ;14F3   D2 49 C6      ÒIÆ
LD B,A                 ;14F6   47            G
LD C,A                 ;14F7   4F            O
LD D,H                 ;14F8   54            T
RST 08H                ;14F9   CF            Ï
LD D,D                 ;14FA   52            R
LD B,L                 ;14FB   45            E
LD B,C                 ;14FC   41            A
CALL NZ,4F47H          ;14FD   C4 47 4F      ÄGO
LD D,E                 ;1500   53            S
LD D,L                 ;1501   55            U
JP NZ,4552H            ;1502   C2 52 45      ÂRE
LD D,H                 ;1505   54            T
LD D,L                 ;1506   55            U
LD D,D                 ;1507   52            R
ADC A,4EH              ;1508   CE 4E         ÎN
LD B,L                 ;150A   45            E
LD E,B                 ;150B   58            X
CALL NC,5453H          ;150C   D4 53 54      ÔST
LD C,A                 ;150F   4F            O
RET NC                 ;1510   D0            Ð
LD B,L                 ;1511   45            E
LD C,(HL)              ;1512   4E            N
CALL NZ,CE4FH          ;1513   C4 4F CE      ÄOÎ
LD C,H                 ;1516   4C            L
LD C,A                 ;1517   4F            O
LD B,C                 ;1518   41            A
CALL NZ,4153H          ;1519   C4 53 41      ÄSA
LD D,(HL)              ;151C   56            V
PUSH BC                ;151D   C5            Å
LD D,(HL)              ;151E   56            V
LD B,L                 ;151F   45            E
LD D,D                 ;1520   52            R
LD C,C                 ;1521   49            I
LD B,(HL)              ;1522   46            F
EXX                    ;1523   D9            Ù
LD D,B                 ;1524   50            P
LD C,A                 ;1525   4F            O
LD C,E                 ;1526   4B            K
PUSH BC                ;1527   C5            Å
LD B,H                 ;1528   44            D
LD C,C                 ;1529   49            I
CALL 4544H             ;152A   CD 44 45      ÍDE
LD B,(HL)              ;152D   46            F
JR NZ,1576H            ;152E   20 46          F
ADC A,49H              ;1530   CE 49         ÎI
LD C,(HL)              ;1532   4E            N
LD D,B                 ;1533   50            P
LD D,L                 ;1534   55            U
CALL NC,4552H          ;1535   D4 52 45      ÔRE
LD D,E                 ;1538   53            S
LD D,H                 ;1539   54            T
LD C,A                 ;153A   4F            O
LD D,D                 ;153B   52            R
PUSH BC                ;153C   C5            Å
LD B,E                 ;153D   43            C
LD C,H                 ;153E   4C            L
JP NC,554DH            ;153F   D2 4D 55      ÒMU
LD D,E                 ;1542   53            S
LD C,C                 ;1543   49            I
JP 4554H               ;1544   C3 54 45      ÃTE
LD C,L                 ;1547   4D            M
LD D,B                 ;1548   50            P
RST 08H                ;1549   CF            Ï
LD D,L                 ;154A   55            U
LD D,E                 ;154B   53            S
LD D,D                 ;154C   52            R
XOR B                  ;154D   A8            ¨
LD D,A                 ;154E   57            W
LD C,A                 ;154F   4F            O
LD D,B                 ;1550   50            P
LD B,L                 ;1551   45            E
ADC A,52H              ;1552   CE 52         ÎR
LD C,A                 ;1554   4F            O
LD D,B                 ;1555   50            P
LD B,L                 ;1556   45            E
ADC A,43H              ;1557   CE 43         ÎC
LD C,H                 ;1559   4C            L
LD C,A                 ;155A   4F            O
LD D,E                 ;155B   53            S
PUSH BC                ;155C   C5            Å
LD B,D                 ;155D   42            B
LD E,C                 ;155E   59            Y
PUSH BC                ;155F   C5            Å
LD C,H                 ;1560   4C            L
LD C,C                 ;1561   49            I
LD C,L                 ;1562   4D            M
LD C,C                 ;1563   49            I
CALL NC,4F43H          ;1564   D4 43 4F      ÔCO
LD C,(HL)              ;1567   4E            N
CALL NC,4553H          ;1568   D4 53 45      ÔSE
CALL NC,4552H          ;156B   D4 52 45      ÔRE
LD D,E                 ;156E   53            S
LD B,L                 ;156F   45            E
CALL NC,4547H          ;1570   D4 47 45      ÔGE
CALL NC,4E49H          ;1573   D4 49 4E      ÔIN
LD D,B                 ;1576   50            P
AND E                  ;1577   A3            £
LD C,A                 ;1578   4F            O
LD D,L                 ;1579   55            U
LD D,H                 ;157A   54            T
AND E                  ;157B   A3            £
RST 38H                ;157C   FF            ÿ
RST 38H                ;157D   FF            ÿ
RST 38H                ;157E   FF            ÿ
RST 38H                ;157F   FF            ÿ
RST 38H                ;1580   FF            ÿ
LD D,H                 ;1581   54            T
LD C,B                 ;1582   48            H
LD B,L                 ;1583   45            E
ADC A,54H              ;1584   CE 54         ÎT
RST 08H                ;1586   CF            Ï
LD D,E                 ;1587   53            S
LD D,H                 ;1588   54            T
LD B,L                 ;1589   45            E
RET NC                 ;158A   D0            Ð
LD A,BCH               ;158B   3E BC         >¼
INC A                  ;158D   3C            <
CP (HL)                ;158E   BE            ¾
DEC A                  ;158F   3D            =
CP H                   ;1590   BC            ¼
INC A                  ;1591   3C            <
CP L                   ;1592   BD            ½
DEC A                  ;1593   3D            =
CP (HL)                ;1594   BE            ¾
LD A,BDH               ;1595   3E BD         >½
CP L                   ;1597   BD            ½
CP (HL)                ;1598   BE            ¾
CP H                   ;1599   BC            ¼
LD B,C                 ;159A   41            A
LD C,(HL)              ;159B   4E            N
CALL NZ,D24FH          ;159C   C4 4F D2      ÄOÒ
LD C,(HL)              ;159F   4E            N
LD C,A                 ;15A0   4F            O
CALL NC,ADABH          ;15A1   D4 AB AD      Ô«­
XOR D                  ;15A4   AA            ª
XOR A                  ;15A5   AF            ¯
LD C,H                 ;15A6   4C            L
LD B,L                 ;15A7   45            E
LD B,(HL)              ;15A8   46            F
LD D,H                 ;15A9   54            T
INC H                  ;15AA   24            $
XOR B                  ;15AB   A8            ¨
LD D,D                 ;15AC   52            R
LD C,C                 ;15AD   49            I
LD B,A                 ;15AE   47            G
LD C,B                 ;15AF   48            H
LD D,H                 ;15B0   54            T
INC H                  ;15B1   24            $
XOR B                  ;15B2   A8            ¨
LD C,L                 ;15B3   4D            M
LD C,C                 ;15B4   49            I
LD B,H                 ;15B5   44            D
INC H                  ;15B6   24            $
XOR B                  ;15B7   A8            ¨
LD C,H                 ;15B8   4C            L
LD B,L                 ;15B9   45            E
LD C,(HL)              ;15BA   4E            N
XOR B                  ;15BB   A8            ¨
LD B,E                 ;15BC   43            C
LD C,B                 ;15BD   48            H
LD D,D                 ;15BE   52            R
INC H                  ;15BF   24            $
XOR B                  ;15C0   A8            ¨
LD D,E                 ;15C1   53            S
LD D,H                 ;15C2   54            T
LD D,D                 ;15C3   52            R
INC H                  ;15C4   24            $
XOR B                  ;15C5   A8            ¨
LD B,C                 ;15C6   41            A
LD D,E                 ;15C7   53            S
LD B,E                 ;15C8   43            C
XOR B                  ;15C9   A8            ¨
LD D,(HL)              ;15CA   56            V
LD B,C                 ;15CB   41            A
LD C,H                 ;15CC   4C            L
XOR B                  ;15CD   A8            ¨
LD D,B                 ;15CE   50            P
LD B,L                 ;15CF   45            E
LD B,L                 ;15D0   45            E
LD C,E                 ;15D1   4B            K
XOR B                  ;15D2   A8            ¨
LD D,H                 ;15D3   54            T
LD B,C                 ;15D4   41            A
LD B,D                 ;15D5   42            B
XOR B                  ;15D6   A8            ¨
LD D,E                 ;15D7   53            S
LD D,B                 ;15D8   50            P
LD B,E                 ;15D9   43            C
XOR B                  ;15DA   A8            ¨
LD D,E                 ;15DB   53            S
LD C,C                 ;15DC   49            I
LD E,D                 ;15DD   5A            Z
PUSH BC                ;15DE   C5            Å
RST 38H                ;15DF   FF            ÿ
RST 38H                ;15E0   FF            ÿ
RST 38H                ;15E1   FF            ÿ
SBC A,52H              ;15E2   DE 52         ÞR
LD C,(HL)              ;15E4   4E            N
LD B,H                 ;15E5   44            D
XOR B                  ;15E6   A8            ¨
LD D,E                 ;15E7   53            S
LD C,C                 ;15E8   49            I
LD C,(HL)              ;15E9   4E            N
XOR B                  ;15EA   A8            ¨
LD B,E                 ;15EB   43            C
LD C,A                 ;15EC   4F            O
LD D,E                 ;15ED   53            S
XOR B                  ;15EE   A8            ¨
LD D,H                 ;15EF   54            T
LD B,C                 ;15F0   41            A
LD C,(HL)              ;15F1   4E            N
XOR B                  ;15F2   A8            ¨
LD B,C                 ;15F3   41            A
LD D,H                 ;15F4   54            T
LD C,(HL)              ;15F5   4E            N
XOR B                  ;15F6   A8            ¨
LD B,L                 ;15F7   45            E
LD E,B                 ;15F8   58            X
LD D,B                 ;15F9   50            P
XOR B                  ;15FA   A8            ¨
LD C,C                 ;15FB   49            I
LD C,(HL)              ;15FC   4E            N
LD D,H                 ;15FD   54            T
XOR B                  ;15FE   A8            ¨
LD C,H                 ;15FF   4C            L
LD C,A                 ;1600   4F            O
LD B,A                 ;1601   47            G
XOR B                  ;1602   A8            ¨
LD C,H                 ;1603   4C            L
LD C,(HL)              ;1604   4E            N
XOR B                  ;1605   A8            ¨
LD B,C                 ;1606   41            A
LD B,D                 ;1607   42            B
LD D,E                 ;1608   53            S
XOR B                  ;1609   A8            ¨
LD D,E                 ;160A   53            S
LD B,A                 ;160B   47            G
LD C,(HL)              ;160C   4E            N
XOR B                  ;160D   A8            ¨
LD D,E                 ;160E   53            S
LD D,C                 ;160F   51            Q
LD D,D                 ;1610   52            R
XOR B                  ;1611   A8            ¨
RST 38H                ;1612   FF            ÿ
RST 38H                ;1613   FF            ÿ
POP BC                 ;1614   C1            Á
NOP                    ;1615   00            
NOP                    ;1616   00            
NOP                    ;1617   00            
ADD A,B                ;1618   80            
ADD A,B                ;1619   80            
NOP                    ;161A   00            
NOP                    ;161B   00            
NOP                    ;161C   00            
NOP                    ;161D   00            
LD B,C                 ;161E   41            A
NOP                    ;161F   00            
NOP                    ;1620   00            
NOP                    ;1621   00            
ADD A,B                ;1622   80            
JP NZ,DAA1H            ;1623   C2 A1 DA      Â¡Ú
RRCA                   ;1626   0F            
RET                    ;1627   C9            É
LD HL,(4801H)          ;1628   2A 01 48      *H
DEC HL                 ;162B   2B            +
INC HL                 ;162C   23            #
LD A,(HL)              ;162D   7E            ~
CP 20H                 ;162E   FE 20         þ 
RET NZ                 ;1630   C0            À
JR 162CH               ;1631   18 F9         ù
PUSH AF                ;1633   F5            õ
LD A,0DH               ;1634   3E 0D         >
CP (HL)                ;1636   BE            ¾
INC HL                 ;1637   23            #
JR NZ,1636H            ;1638   20 FC          ü
POP AF                 ;163A   F1            ñ
RET                    ;163B   C9            É
INC HL                 ;163C   23            #
CALL 1829H             ;163D   CD 29 18      Í)
RET Z                  ;1640   C8            È
CP 22H                 ;1641   FE 22         þ"
JR NZ,163CH            ;1643   20 F7          ÷
CALL 162CH             ;1645   CD 2C 16      Í,
CP 0DH                 ;1648   FE 0D         þ
RET Z                  ;164A   C8            È
CP 22H                 ;164B   FE 22         þ"
JR NZ,1645H            ;164D   20 F6          ö
JR 163CH               ;164F   18 EB         ë
LD A,C                 ;1651   79            y
CPL                    ;1652   2F            /
LD C,A                 ;1653   4F            O
LD A,B                 ;1654   78            x
CPL                    ;1655   2F            /
LD B,A                 ;1656   47            G
INC BC                 ;1657   03            
RET                    ;1658   C9            É
CALL 162DH             ;1659   CD 2D 16      Í-
SUB 30H                ;165C   D6 30         Ö0
CP 0AH                 ;165E   FE 0A         þ

LD A,(HL)              ;1660   7E            ~
RET                    ;1661   C9            É
LD A,H                 ;1662   7C            |
SUB D                  ;1663   92            
RET NZ                 ;1664   C0            À
LD A,L                 ;1665   7D            }
SUB E                  ;1666   93            
RET                    ;1667   C9            É
LD A,E                 ;1668   7B            {
SUB L                  ;1669   95            
LD L,A                 ;166A   6F            o
LD A,D                 ;166B   7A            z
SBC A,H                ;166C   9C            
LD H,A                 ;166D   67            g
RET                    ;166E   C9            É
POP HL                 ;166F   E1            á
EX (SP),HL             ;1670   E3            ã
PUSH AF                ;1671   F5            õ
LD A,(HL)              ;1672   7E            ~
INC HL                 ;1673   23            #
LD H,(HL)              ;1674   66            f
LD L,A                 ;1675   6F            o
POP AF                 ;1676   F1            ñ
EX (SP),HL             ;1677   E3            ã
RET                    ;1678   C9            É
POP HL                 ;1679   E1            á
EX (SP),HL             ;167A   E3            ã
INC HL                 ;167B   23            #
INC HL                 ;167C   23            #
EX (SP),HL             ;167D   E3            ã
RET                    ;167E   C9            É
LD HL,(4644H)          ;167F   2A 44 46      *DF
INC HL                 ;1682   23            #
INC HL                 ;1683   23            #
INC HL                 ;1684   23            #
INC HL                 ;1685   23            #
INC HL                 ;1686   23            #
RET                    ;1687   C9            É
LD HL,(4801H)          ;1688   2A 01 48      *H
CALL 162DH             ;168B   CD 2D 16      Í-
EX (SP),HL             ;168E   E3            ã
CP (HL)                ;168F   BE            ¾
INC HL                 ;1690   23            #
JP NZ,1671H            ;1691   C2 71 16      Âq
INC HL                 ;1694   23            #
JR 16A2H               ;1695   18 0B         
LD HL,(4801H)          ;1697   2A 01 48      *H
CALL 162DH             ;169A   CD 2D 16      Í-
EX (SP),HL             ;169D   E3            ã
CP (HL)                ;169E   BE            ¾
JP NZ,138EH            ;169F   C2 8E 13      Â
INC HL                 ;16A2   23            #
EX (SP),HL             ;16A3   E3            ã
JP 162CH               ;16A4   C3 2C 16      Ã,
XOR A                  ;16A7   AF            ¯
CP H                   ;16A8   BC            ¼
JR Z,16B0H             ;16A9   28 05         (
EX DE,HL               ;16AB   EB            ë
CP H                   ;16AC   BC            ¼
JP NZ,1670H            ;16AD   C2 70 16      Âp
LD A,L                 ;16B0   7D            }
LD L,H                 ;16B1   6C            l
OR A                   ;16B2   B7            ·
JR NZ,16B9H            ;16B3   20 04          
EX DE,HL               ;16B5   EB            ë
JP 167AH               ;16B6   C3 7A 16      Ãz
SRL A                  ;16B9   CB 3F         Ë?
JR NC,16C1H            ;16BB   30 04         0
ADD HL,DE              ;16BD   19            
JP C,1670H             ;16BE   DA 70 16      Úp
SLA E                  ;16C1   CB 23         Ë#
RL D                   ;16C3   CB 12         Ë
JP 16B2H               ;16C5   C3 B2 16      Ã²
CALL 16A7H             ;16C8   CD A7 16      Í
SBC A,B                ;16CB   98            
INC DE                 ;16CC   13            
RET                    ;16CD   C9            É
LD DE,0000H            ;16CE   11 00 00      
CALL 1659H             ;16D1   CD 59 16      ÍY
JP NC,167AH            ;16D4   D2 7A 16      Òz
PUSH HL                ;16D7   E5            å
LD HL,000AH            ;16D8   21 0A 00      !

CALL 16A7H             ;16DB   CD A7 16      Í
LD L,A                 ;16DE   6F            o
LD D,E1H               ;16DF   16 E1         á
LD A,(HL)              ;16E1   7E            ~
AND 0FH                ;16E2   E6 0F         æ
ADD A,E                ;16E4   83            
LD E,A                 ;16E5   5F            _
LD A,D                 ;16E6   7A            z
ADC A,00H              ;16E7   CE 00         Î
LD D,A                 ;16E9   57            W
JP C,1670H             ;16EA   DA 70 16      Úp
INC HL                 ;16ED   23            #
JP 16D1H               ;16EE   C3 D1 16      ÃÑ
CALL 16CEH             ;16F1   CD CE 16      ÍÎ
ADC A,(HL)             ;16F4   8E            
INC DE                 ;16F5   13            
RET                    ;16F6   C9            É
LD C,00H               ;16F7   0E 00         
LD A,20H               ;16F9   3E 20         > 
LD (DE),A              ;16FB   12            
INC DE                 ;16FC   13            
PUSH DE                ;16FD   D5            Õ
LD B,00H               ;16FE   06 00         
LD DE,2710H            ;1700   11 10 27      '
CALL 1722H             ;1703   CD 22 17      Í"
LD DE,03E8H            ;1706   11 E8 03      è
CALL 1722H             ;1709   CD 22 17      Í"
LD DE,0064H            ;170C   11 64 00      d
CALL 1722H             ;170F   CD 22 17      Í"
LD DE,000AH            ;1712   11 0A 00      

CALL 1722H             ;1715   CD 22 17      Í"
LD A,L                 ;1718   7D            }
POP DE                 ;1719   D1            Ñ
OR 30H                 ;171A   F6 30         ö0
LD (DE),A              ;171C   12            
INC DE                 ;171D   13            
LD A,0DH               ;171E   3E 0D         >
LD (DE),A              ;1720   12            
RET                    ;1721   C9            É
LD A,FFH               ;1722   3E FF         >ÿ
INC A                  ;1724   3C            <
OR A                   ;1725   B7            ·
SBC HL,DE              ;1726   ED 52         íR
JR NC,1724H            ;1728   30 FA         0ú
ADD HL,DE              ;172A   19            
OR A                   ;172B   B7            ·
JR NZ,1731H            ;172C   20 03          
OR B                   ;172E   B0            °
RET Z                  ;172F   C8            È
XOR A                  ;1730   AF            ¯
INC B                  ;1731   04            
OR 30H                 ;1732   F6 30         ö0
POP DE                 ;1734   D1            Ñ
EX (SP),HL             ;1735   E3            ã
LD (HL),A              ;1736   77            w
INC HL                 ;1737   23            #
EX (SP),HL             ;1738   E3            ã
PUSH DE                ;1739   D5            Õ
INC C                  ;173A   0C            
RET                    ;173B   C9            É
LD BC,0000H            ;173C   01 00 00      
LD HL,(4644H)          ;173F   2A 44 46      *DF
ADD HL,BC              ;1742   09            	
JP C,1393H             ;1743   DA 93 13      Ú
EX DE,HL               ;1746   EB            ë
LD HL,FF9CH            ;1747   21 9C FF      !ÿ
ADD HL,SP              ;174A   39            9
XOR A                  ;174B   AF            ¯
SBC HL,DE              ;174C   ED 52         íR
RET NC                 ;174E   D0            Ð
JP 1393H               ;174F   C3 93 13      Ã
PUSH HL                ;1752   E5            å
PUSH DE                ;1753   D5            Õ
CALL 173FH             ;1754   CD 3F 17      Í?
POP DE                 ;1757   D1            Ñ
POP HL                 ;1758   E1            á
RET                    ;1759   C9            É
LD E,(HL)              ;175A   5E            ^
INC HL                 ;175B   23            #
LD D,(HL)              ;175C   56            V
INC HL                 ;175D   23            #
LD A,(HL)              ;175E   7E            ~
INC HL                 ;175F   23            #
LD H,(HL)              ;1760   66            f
LD L,A                 ;1761   6F            o
EX DE,HL               ;1762   EB            ë
LD A,L                 ;1763   7D            }
OR H                   ;1764   B4            ´
RET                    ;1765   C9            É
PUSH BC                ;1766   C5            Å
PUSH HL                ;1767   E5            å
PUSH DE                ;1768   D5            Õ
EX DE,HL               ;1769   EB            ë
ADD HL,BC              ;176A   09            	
EX DE,HL               ;176B   EB            ë
CALL 167FH             ;176C   CD 7F 16      Í
LD A,L                 ;176F   7D            }
SUB E                  ;1770   93            
LD C,A                 ;1771   4F            O
LD A,H                 ;1772   7C            |
SBC A,D                ;1773   9A            
LD B,A                 ;1774   47            G
INC BC                 ;1775   03            
POP HL                 ;1776   E1            á
PUSH HL                ;1777   E5            å
EX DE,HL               ;1778   EB            ë
JP 179CH               ;1779   C3 9C 17      Ã
CALL 1752H             ;177C   CD 52 17      ÍR
PUSH BC                ;177F   C5            Å
PUSH HL                ;1780   E5            å
PUSH DE                ;1781   D5            Õ
CALL 167FH             ;1782   CD 7F 16      Í
PUSH HL                ;1785   E5            å
ADD HL,BC              ;1786   09            	
EX (SP),HL             ;1787   E3            ã
LD A,L                 ;1788   7D            }
SUB E                  ;1789   93            
LD C,A                 ;178A   4F            O
LD A,H                 ;178B   7C            |
SBC A,D                ;178C   9A            
LD B,A                 ;178D   47            G
INC BC                 ;178E   03            
POP DE                 ;178F   D1            Ñ
LDDR                   ;1790   ED B8         í¸
POP DE                 ;1792   D1            Ñ
POP HL                 ;1793   E1            á
POP BC                 ;1794   C1            Á
RET                    ;1795   C9            É
CALL 177CH             ;1796   CD 7C 17      Í|
PUSH BC                ;1799   C5            Å
PUSH HL                ;179A   E5            å
PUSH DE                ;179B   D5            Õ
LD A,C                 ;179C   79            y
OR B                   ;179D   B0            °
JR Z,17A2H             ;179E   28 02         (
LDIR                   ;17A0   ED B0         í°
JP 1792H               ;17A2   C3 92 17      Ã
LD (462EH),HL          ;17A5   22 2E 46      ".F
LD HL,4806H            ;17A8   21 06 48      !H
PUSH HL                ;17AB   E5            å
CALL 175AH             ;17AC   CD 5A 17      ÍZ
JP Z,166FH             ;17AF   CA 6F 16      Êo
PUSH HL                ;17B2   E5            å
LD HL,(462EH)          ;17B3   2A 2E 46      *.F
CALL 1662H             ;17B6   CD 62 16      Íb
POP HL                 ;17B9   E1            á
JP Z,1679H             ;17BA   CA 79 16      Êy
JP C,1679H             ;17BD   DA 79 16      Úy
POP AF                 ;17C0   F1            ñ
JP 17ABH               ;17C1   C3 AB 17      Ã«
PUSH HL                ;17C4   E5            å
LD E,(HL)              ;17C5   5E            ^
INC HL                 ;17C6   23            #
LD D,(HL)              ;17C7   56            V
LD A,E                 ;17C8   7B            {
OR D                   ;17C9   B2            ²
JP Z,166FH             ;17CA   CA 6F 16      Êo
LD HL,(4630H)          ;17CD   2A 30 46      *0F
CALL 1662H             ;17D0   CD 62 16      Íb
POP HL                 ;17D3   E1            á
INC HL                 ;17D4   23            #
INC HL                 ;17D5   23            #
JP 167AH               ;17D6   C3 7A 16      Ãz
ADD HL,BC              ;17D9   09            	
EX DE,HL               ;17DA   EB            ë
POP HL                 ;17DB   E1            á
LD (HL),E              ;17DC   73            s
INC HL                 ;17DD   23            #
LD (HL),D              ;17DE   72            r
EX DE,HL               ;17DF   EB            ë
PUSH HL                ;17E0   E5            å
CALL 175AH             ;17E1   CD 5A 17      ÍZ
JR NZ,17D9H            ;17E4   20 F3          ó
POP HL                 ;17E6   E1            á
RET                    ;17E7   C9            É
PUSH HL                ;17E8   E5            å
LD BC,0004H            ;17E9   01 04 00      
ADD HL,BC              ;17EC   09            	
CALL 17F6H             ;17ED   CD F6 17      Íö
INC BC                 ;17F0   03            
POP HL                 ;17F1   E1            á
RET                    ;17F2   C9            É
LD BC,0000H            ;17F3   01 00 00      
PUSH HL                ;17F6   E5            å
LD A,0DH               ;17F7   3E 0D         >
CP (HL)                ;17F9   BE            ¾
INC HL                 ;17FA   23            #
INC BC                 ;17FB   03            
JR NZ,17F9H            ;17FC   20 FB          û
DEC BC                 ;17FE   0B            
POP HL                 ;17FF   E1            á
RET                    ;1800   C9            É
LD A,E                 ;1801   7B            {
EX DE,HL               ;1802   EB            ë
LD HL,(4642H)          ;1803   2A 42 46      *BF
INC A                  ;1806   3C            <
DEC A                  ;1807   3D            =
CALL NZ,1633H          ;1808   C4 33 16      Ä3
JR NZ,1807H            ;180B   20 FA          ú
EX DE,HL               ;180D   EB            ë
RET                    ;180E   C9            É
LD A,D                 ;180F   7A            z
OR A                   ;1810   B7            ·
RET NZ                 ;1811   C0            À
JR 1817H               ;1812   18 03         
LD A,D                 ;1814   7A            z
OR A                   ;1815   B7            ·
RET Z                  ;1816   C8            È
JP 139DH               ;1817   C3 9D 13      Ã
LD HL,(4644H)          ;181A   2A 44 46      *DF
EX DE,HL               ;181D   EB            ë
LD BC,0005H            ;181E   01 05 00      
LDIR                   ;1821   ED B0         í°
RET                    ;1823   C9            É
LD HL,(4644H)          ;1824   2A 44 46      *DF
JR 181EH               ;1827   18 F5         õ
CALL 162DH             ;1829   CD 2D 16      Í-
CP 0DH                 ;182C   FE 0D         þ
RET Z                  ;182E   C8            È
CP 3AH                 ;182F   FE 3A         þ:
RET                    ;1831   C9            É
LD HL,0000H            ;1832   21 00 00      !
LD (4632H),HL          ;1835   22 32 46      "2F
LD HL,4806H            ;1838   21 06 48      !H
CALL 1896H             ;183B   CD 96 18      Í
LD (4634H),HL          ;183E   22 34 46      "4F
XOR A                  ;1841   AF            ¯
LD (29B8H),A           ;1842   32 B8 29      2¸)
CALL 13C1H             ;1845   CD C1 13      ÍÁ
CALL 1857H             ;1848   CD 57 18      ÍW
CALL 187CH             ;184B   CD 7C 18      Í|
LD HL,47FDH            ;184E   21 FD 47      !ýG
CALL 1896H             ;1851   CD 96 18      Í
JP 1896H               ;1854   C3 96 18      Ã
LD HL,(4634H)          ;1857   2A 34 46      *4F
LD B,09H               ;185A   06 09         	
CALL 1896H             ;185C   CD 96 18      Í
DJNZ 185CH             ;185F   10 FB         û
LD DE,4636H            ;1861   11 36 46      6F
LD HL,(4634H)          ;1864   2A 34 46      *4F
EX DE,HL               ;1867   EB            ë
LD B,07H               ;1868   06 07         
INC DE                 ;186A   13            
INC DE                 ;186B   13            
LD (HL),E              ;186C   73            s
INC HL                 ;186D   23            #
LD (HL),D              ;186E   72            r
INC HL                 ;186F   23            #
DJNZ 186AH             ;1870   10 F8         ø
LD HL,(4642H)          ;1872   2A 42 46      *BF
CALL 1896H             ;1875   CD 96 18      Í
LD (4644H),HL          ;1878   22 44 46      "DF
RET                    ;187B   C9            É
LD HL,47F0H            ;187C   21 F0 47      !ðG
LD (464AH),HL          ;187F   22 4A 46      "JF
LD HL,4787H            ;1882   21 87 47      !G
LD (4648H),HL          ;1885   22 48 46      "HF
LD HL,466AH            ;1888   21 6A 46      !jF
LD (4646H),HL          ;188B   22 46 46      "FF
LD HL,4803H            ;188E   21 03 48      !H
CALL 1896H             ;1891   CD 96 18      Í
LD (HL),A              ;1894   77            w
RET                    ;1895   C9            É
XOR A                  ;1896   AF            ¯
LD (HL),A              ;1897   77            w
INC HL                 ;1898   23            #
LD (HL),A              ;1899   77            w
INC HL                 ;189A   23            #
RET                    ;189B   C9            É
PUSH HL                ;189C   E5            å
LD A,E                 ;189D   7B            {
EX AF,AF'              ;189E   08            
LD A,D                 ;189F   7A            z
LD HL,4644H            ;18A0   21 44 46      !DF
LD E,(HL)              ;18A3   5E            ^
INC HL                 ;18A4   23            #
LD D,(HL)              ;18A5   56            V
CP D                   ;18A6   BA            º
JP C,18B3H             ;18A7   DA B3 18      Ú³
JP NZ,18BFH            ;18AA   C2 BF 18      Â¿
EX AF,AF'              ;18AD   08            
CP E                   ;18AE   BB            »
JP NC,18BEH            ;18AF   D2 BE 18      Ò¾
EX AF,AF'              ;18B2   08            
EX DE,HL               ;18B3   EB            ë
ADD HL,BC              ;18B4   09            	
EX DE,HL               ;18B5   EB            ë
LD (HL),D              ;18B6   72            r
DEC HL                 ;18B7   2B            +
LD (HL),E              ;18B8   73            s
DEC HL                 ;18B9   2B            +
DEC HL                 ;18BA   2B            +
JP 18A3H               ;18BB   C3 A3 18      Ã£
EX AF,AF'              ;18BE   08            
LD D,A                 ;18BF   57            W
EX AF,AF'              ;18C0   08            
LD E,A                 ;18C1   5F            _
POP HL                 ;18C2   E1            á
RET                    ;18C3   C9            É
CALL 162DH             ;18C4   CD 2D 16      Í-
LD BC,0000H            ;18C7   01 00 00      
LD DE,0D2CH            ;18CA   11 2C 0D      ,
CP 22H                 ;18CD   FE 22         þ"
JR NZ,18D3H            ;18CF   20 02          
LD E,A                 ;18D1   5F            _
INC HL                 ;18D2   23            #
PUSH HL                ;18D3   E5            å
LD A,(HL)              ;18D4   7E            ~
CP D                   ;18D5   BA            º
JR Z,18E0H             ;18D6   28 08         (
CP E                   ;18D8   BB            »
INC HL                 ;18D9   23            #
JR Z,18E0H             ;18DA   28 04         (
INC BC                 ;18DC   03            
JR 18D4H               ;18DD   18 F5         õ
PUSH HL                ;18DF   E5            å
EX (SP),HL             ;18E0   E3            ã
EX DE,HL               ;18E1   EB            ë
LD HL,(4642H)          ;18E2   2A 42 46      *BF
XOR A                  ;18E5   AF            ¯
PUSH AF                ;18E6   F5            õ
LD A,(HL)              ;18E7   7E            ~
OR A                   ;18E8   B7            ·
JR Z,18F2H             ;18E9   28 07         (
CALL 1633H             ;18EB   CD 33 16      Í3
POP AF                 ;18EE   F1            ñ
INC A                  ;18EF   3C            <
JR 18E6H               ;18F0   18 F4         ô
EX DE,HL               ;18F2   EB            ë
INC BC                 ;18F3   03            
CALL 1796H             ;18F4   CD 96 17      Í
PUSH HL                ;18F7   E5            å
LD HL,(4644H)          ;18F8   2A 44 46      *DF
ADD HL,BC              ;18FB   09            	
LD (4644H),HL          ;18FC   22 44 46      "DF
POP HL                 ;18FF   E1            á
EX DE,HL               ;1900   EB            ë
DEC BC                 ;1901   0B            
ADD HL,BC              ;1902   09            	
LD (HL),0DH            ;1903   36 0D         6
POP AF                 ;1905   F1            ñ
LD E,A                 ;1906   5F            _
LD D,01H               ;1907   16 01         
POP HL                 ;1909   E1            á
JP 162DH               ;190A   C3 2D 16      Ã-
CALL 162DH             ;190D   CD 2D 16      Í-
CP 0DH                 ;1910   FE 0D         þ
JP Z,1670H             ;1912   CA 70 16      Êp
PUSH HL                ;1915   E5            å
DEC HL                 ;1916   2B            +
INC HL                 ;1917   23            #
CALL 162DH             ;1918   CD 2D 16      Í-
CP 2BH                 ;191B   FE 2B         þ+
JR NZ,1921H            ;191D   20 02          
LD A,BCH               ;191F   3E BC         >¼
CP 2DH                 ;1921   FE 2D         þ-
JR NZ,1927H            ;1923   20 02          
LD A,BDH               ;1925   3E BD         >½
LD (HL),A              ;1927   77            w
CALL 193DH             ;1928   CD 3D 19      Í=
JR Z,1917H             ;192B   28 EA         (ê
CP 45H                 ;192D   FE 45         þE
JR Z,1917H             ;192F   28 E6         (æ
CP 0DH                 ;1931   FE 0D         þ
JP NZ,166FH            ;1933   C2 6F 16      Âo
POP HL                 ;1936   E1            á
CALL 22AFH             ;1937   CD AF 22      Í¯"
JP 167AH               ;193A   C3 7A 16      Ãz
CALL 1659H             ;193D   CD 59 16      ÍY
JR NC,1944H            ;1940   30 02         0
CP (HL)                ;1942   BE            ¾
RET                    ;1943   C9            É
CP 2EH                 ;1944   FE 2E         þ.
RET Z                  ;1946   C8            È
CP BDH                 ;1947   FE BD         þ½
RET Z                  ;1949   C8            È
CP BCH                 ;194A   FE BC         þ¼
RET                    ;194C   C9            É
PUSH HL                ;194D   E5            å
LD HL,(4644H)          ;194E   2A 44 46      *DF
LD DE,0000H            ;1951   11 00 00      
LD A,(HL)              ;1954   7E            ~
OR A                   ;1955   B7            ·
JP P,1398H             ;1956   F2 98 13      ò
CP C1H                 ;1959   FE C1         þÁ
JP C,1974H             ;195B   DA 74 19      Út
SUB D1H                ;195E   D6 D1         ÖÑ
JP NC,1398H            ;1960   D2 98 13      Ò
LD E,03H               ;1963   1E 03         
ADD HL,DE              ;1965   19            
LD E,(HL)              ;1966   5E            ^
INC HL                 ;1967   23            #
LD D,(HL)              ;1968   56            V
JP 1970H               ;1969   C3 70 19      Ãp
SRL D                  ;196C   CB 3A         Ë:
RR E                   ;196E   CB 1B         Ë
INC A                  ;1970   3C            <
JP NZ,196CH            ;1971   C2 6C 19      Âl
POP HL                 ;1974   E1            á
RET                    ;1975   C9            É
LD HL,456CH            ;1976   21 6C 45      !lE
JR 197EH               ;1979   18 03         
LD HL,4570H            ;197B   21 70 45      !pE
LD (HL),C              ;197E   71            q
INC HL                 ;197F   23            #
LD (HL),B              ;1980   70            p
INC HL                 ;1981   23            #
LD (HL),E              ;1982   73            s
INC HL                 ;1983   23            #
LD (HL),D              ;1984   72            r
INC HL                 ;1985   23            #
RET                    ;1986   C9            É
XOR A                  ;1987   AF            ¯
LD (4577H),A           ;1988   32 77 45      2wE
RET                    ;198B   C9            É
EXX                    ;198C   D9            Ù
LD BC,0005H            ;198D   01 05 00      
CALL 19A0H             ;1990   CD A0 19      Í 
CALL 22AFH             ;1993   CD AF 22      Í¯"
CALL 1814H             ;1996   CD 14 18      Í
CALL 194DH             ;1999   CD 4D 19      ÍM
EXX                    ;199C   D9            Ù
LD BC,FFFBH            ;199D   01 FB FF      ûÿ
LD HL,(4644H)          ;19A0   2A 44 46      *DF
ADD HL,BC              ;19A3   09            	
LD (4644H),HL          ;19A4   22 44 46      "DF
EXX                    ;19A7   D9            Ù
RET                    ;19A8   C9            É
CALL 198CH             ;19A9   CD 8C 19      Í
LD A,D                 ;19AC   7A            z
OR A                   ;19AD   B7            ·
RET Z                  ;19AE   C8            È
JP 1398H               ;19AF   C3 98 13      Ã
LD HL,(4801H)          ;19B2   2A 01 48      *H
CALL 162DH             ;19B5   CD 2D 16      Í-
CP 0DH                 ;19B8   FE 0D         þ
JP Z,19C7H             ;19BA   CA C7 19      ÊÇ
CALL 169AH             ;19BD   CD 9A 16      Í
LD A,(0122H)           ;19C0   3A 22 01      :"
LD C,B                 ;19C3   48            H
JP 19E1H               ;19C4   C3 E1 19      Ãá
LD HL,(47FDH)          ;19C7   2A FD 47      *ýG
XOR A                  ;19CA   AF            ¯
OR H                   ;19CB   B4            ´
JP Z,124BH             ;19CC   CA 4B 12      ÊK
LD DE,47FDH            ;19CF   11 FD 47      ýG
LD BC,0004H            ;19D2   01 04 00      
LDIR                   ;19D5   ED B0         í°
LD (4801H),HL          ;19D7   22 01 48      "H
LD A,(47FEH)           ;19DA   3A FE 47      :þG
OR A                   ;19DD   B7            ·
JP Z,1B2DH             ;19DE   CA 2D 1B      Ê-
LD HL,E000H            ;19E1   21 00 E0      !à
LD (HL),F8H            ;19E4   36 F8         6ø
INC HL                 ;19E6   23            #
LD A,(HL)              ;19E7   7E            ~
INC A                  ;19E8   3C            <
JP Z,19F7H             ;19E9   CA F7 19      Ê÷
CALL 001EH             ;19EC   CD 1E 00      Í
JR NZ,19F7H            ;19EF   20 06          
CALL 13C8H             ;19F1   CD C8 13      ÍÈ
JP 1385H               ;19F4   C3 85 13      Ã
LD HL,(4642H)          ;19F7   2A 42 46      *BF
XOR A                  ;19FA   AF            ¯
LD (HL),A              ;19FB   77            w
INC HL                 ;19FC   23            #
LD (HL),A              ;19FD   77            w
INC HL                 ;19FE   23            #
LD (4644H),HL          ;19FF   22 44 46      "DF
LD HL,(4801H)          ;1A02   2A 01 48      *H
LD A,(HL)              ;1A05   7E            ~
OR A                   ;1A06   B7            ·
JP P,1B3FH             ;1A07   F2 3F 1B      ò?
CP AAH                 ;1A0A   FE AA         þª
JP NC,138EH            ;1A0C   D2 8E 13      Ò
LD DE,1A1FH            ;1A0F   11 1F 1A      
INC HL                 ;1A12   23            #
EX DE,HL               ;1A13   EB            ë
ADD A,A                ;1A14   87            
LD C,A                 ;1A15   4F            O
LD B,00H               ;1A16   06 00         
ADD HL,BC              ;1A18   09            	
LD C,(HL)              ;1A19   4E            N
INC HL                 ;1A1A   23            #
LD B,(HL)              ;1A1B   46            F
EX DE,HL               ;1A1C   EB            ë
PUSH BC                ;1A1D   C5            Å
RET                    ;1A1E   C9            É
DAA                    ;1A1F   27            '
DEC DE                 ;1A20   1B            
DAA                    ;1A21   27            '
DEC DE                 ;1A22   1B            
HALT                   ;1A23   76            v
LD A,(DE)              ;1A24   1A            
RR H                   ;1A25   CB 1C         Ë
LD L,A                 ;1A27   6F            o
LD A,(DE)              ;1A28   1A            
CPL                    ;1A29   2F            /
INC E                  ;1A2A   1C            
CCF                    ;1A2B   3F            ?
DEC DE                 ;1A2C   1B            
LD E,H                 ;1A2D   5C            \
DEC E                  ;1A2E   1D            
ADD A,D                ;1A2F   82            
LD HL,1CDBH            ;1A30   21 DB 1C      !Û
XOR A                  ;1A33   AF            ¯
RRA                    ;1A34   1F            
OR 1CH                 ;1A35   F6 1C         ö
LD HL,(F41DH)          ;1A37   2A 1D F4      *ô
DEC E                  ;1A3A   1D            
LD (HL),1BH            ;1A3B   36 1B         6
DEC L                  ;1A3D   2D            -
DEC DE                 ;1A3E   1B            
OR 1FH                 ;1A3F   F6 1F         ö
LD (HL),2AH            ;1A41   36 2A         6*
CP E                   ;1A43   BB            »
ADD HL,HL              ;1A44   29            )
ADC A,A                ;1A45   8F            
ADD HL,HL              ;1A46   29            )
LD H,(HL)              ;1A47   66            f
LD HL,2050H            ;1A48   21 50 20      !P 
OR B                   ;1A4B   B0            °
LD HL,1E7CH            ;1A4C   21 7C 1E      !|
INC H                  ;1A4F   24            $
DEC DE                 ;1A50   1B            
LD (HL),A              ;1A51   77            w
LD HL,2226H            ;1A52   21 26 22      !&"
LD B,(HL)              ;1A55   46            F
LD (28B2H),HL          ;1A56   22 B2 28      "²(
AND A                  ;1A59   A7            
DEC HL                 ;1A5A   2B            +
RST 10H                ;1A5B   D7            ×
DEC HL                 ;1A5C   2B            +
DEC B                  ;1A5D   05            
INC L                  ;1A5E   2C            ,
LD D,H                 ;1A5F   54            T
JR Z,1A24H             ;1A60   28 C2         (Â
JR Z,1A60H             ;1A62   28 FC         (ü
JR Z,1A90H             ;1A64   28 2A         (*
ADD HL,HL              ;1A66   29            )
LD L,29H               ;1A67   2E 29         .)
LD D,A                 ;1A69   57            W
JR Z,1A44H             ;1A6A   28 D8         (Ø
INC L                  ;1A6C   2C            ,
LD L,2DH               ;1A6D   2E 2D         .-
CALL 1832H             ;1A6F   CD 32 18      Í2
JP 124BH               ;1A72   C3 4B 12      ÃK
NOP                    ;1A75   00            
LD A,(29B8H)           ;1A76   3A B8 29      :¸)
OR A                   ;1A79   B7            ·
JP NZ,124BH            ;1A7A   C2 4B 12      ÂK
LD B,A                 ;1A7D   47            G
CALL 168BH             ;1A7E   CD 8B 16      Í
CP A                   ;1A81   BF            ¿
ADC A,H                ;1A82   8C            
LD A,(DE)              ;1A83   1A            
CALL 169AH             ;1A84   CD 9A 16      Í
LD D,B                 ;1A87   50            P
CALL 3C75H             ;1A88   CD 75 3C      Íu<
INC B                  ;1A8B   04            
LD A,B                 ;1A8C   78            x
LD (1A75H),A           ;1A8D   32 75 1A      2u
PUSH HL                ;1A90   E5            å
CALL 1B08H             ;1A91   CD 08 1B      Í
LD HL,457EH            ;1A94   21 7E 45      !~E
CALL 1896H             ;1A97   CD 96 18      Í
DEC A                  ;1A9A   3D            =
CALL 1897H             ;1A9B   CD 97 18      Í
POP HL                 ;1A9E   E1            á
CALL 168BH             ;1A9F   CD 8B 16      Í
DEC C                  ;1AA2   0D            
PUSH HL                ;1AA3   E5            å
LD A,(DE)              ;1AA4   1A            
LD HL,4806H            ;1AA5   21 06 48      !H
PUSH HL                ;1AA8   E5            å
CALL 175AH             ;1AA9   CD 5A 17      ÍZ
POP HL                 ;1AAC   E1            á
JP Z,124BH             ;1AAD   CA 4B 12      ÊK
CALL 17E8H             ;1AB0   CD E8 17      Íè
LD DE,4455H            ;1AB3   11 55 44      UD
CALL 1799H             ;1AB6   CD 99 17      Í
LD HL,(457EH)          ;1AB9   2A 7E 45      *~E
EX DE,HL               ;1ABC   EB            ë
LD HL,(4457H)          ;1ABD   2A 57 44      *WD
CALL 1662H             ;1AC0   CD 62 16      Íb
JP C,1ADFH             ;1AC3   DA DF 1A      Úß
EX DE,HL               ;1AC6   EB            ë
LD HL,(4580H)          ;1AC7   2A 80 45      *E
CALL 1662H             ;1ACA   CD 62 16      Íb
JP C,1ADFH             ;1ACD   DA DF 1A      Úß
CALL 1443H             ;1AD0   CD 43 14      ÍC
LD DE,4400H            ;1AD3   11 00 44      D
CALL 1B12H             ;1AD6   CD 12 1B      Í
CALL 001EH             ;1AD9   CD 1E 00      Í
JP Z,124BH             ;1ADC   CA 4B 12      ÊK
LD HL,(4455H)          ;1ADF   2A 55 44      *UD
JP 1AA8H               ;1AE2   C3 A8 1A      Ã¨
CALL 16F1H             ;1AE5   CD F1 16      Íñ
LD (457EH),DE          ;1AE8   ED 53 7E 45   íS~E
CALL 168BH             ;1AEC   CD 8B 16      Í
DEC C                  ;1AEF   0D            
LD SP,HL               ;1AF0   F9            ù
LD A,(DE)              ;1AF1   1A            
EX DE,HL               ;1AF2   EB            ë
LD (4580H),HL          ;1AF3   22 80 45      "E
JP 1AA5H               ;1AF6   C3 A5 1A      Ã¥
CALL 169AH             ;1AF9   CD 9A 16      Í
CP L                   ;1AFC   BD            ½
CP 0DH                 ;1AFD   FE 0D         þ
JP Z,1AA5H             ;1AFF   CA A5 1A      Ê¥
CALL 16F1H             ;1B02   CD F1 16      Íñ
JP 1AF2H               ;1B05   C3 F2 1A      Ãò
LD A,(1A75H)           ;1B08   3A 75 1A      :u
OR A                   ;1B0B   B7            ·
JP Z,0009H             ;1B0C   CA 09 00      Ê	
JP 3BA1H               ;1B0F   C3 A1 3B      Ã¡;
LD A,(1A75H)           ;1B12   3A 75 1A      :u
OR A                   ;1B15   B7            ·
JR NZ,1B1EH            ;1B16   20 06          
CALL 0018H             ;1B18   CD 18 00      Í
JP 0009H               ;1B1B   C3 09 00      Ã	
CALL 3C05H             ;1B1E   CD 05 3C      Í<
JP 3BA1H               ;1B21   C3 A1 3B      Ã¡;
CALL 1987H             ;1B24   CD 87 19      Í
CALL 163DH             ;1B27   CD 3D 16      Í=
JP 19B8H               ;1B2A   C3 B8 19      Ã¸
CALL 13C4H             ;1B2D   CD C4 13      ÍÄ
LD (4801H),HL          ;1B30   22 01 48      "H
JP 124BH               ;1B33   C3 4B 12      ÃK
CALL 13C4H             ;1B36   CD C4 13      ÍÄ
LD (4801H),HL          ;1B39   22 01 48      "H
JP 1385H               ;1B3C   C3 85 13      Ã
PUSH HL                ;1B3F   E5            å
CALL 1829H             ;1B40   CD 29 18      Í)
JP Z,138EH             ;1B43   CA 8E 13      Ê
CP B6H                 ;1B46   FE B6         þ¶
INC HL                 ;1B48   23            #
JR NZ,1B40H            ;1B49   20 F5          õ
CALL 22AFH             ;1B4B   CD AF 22      Í¯"
LD (4801H),HL          ;1B4E   22 01 48      "H
CALL 1976H             ;1B51   CD 76 19      Ív
POP HL                 ;1B54   E1            á
CALL 2613H             ;1B55   CD 13 26      Í&
CALL 2436H             ;1B58   CD 36 24      Í6$
CALL 169AH             ;1B5B   CD 9A 16      Í
OR (HL)                ;1B5E   B6            ¶
CALL 197BH             ;1B5F   CD 7B 19      Í{
CALL 1B6AH             ;1B62   CD 6A 1B      Íj
SBC A,L                ;1B65   9D            
INC DE                 ;1B66   13            
JP 19B2H               ;1B67   C3 B2 19      Ã²
LD HL,456FH            ;1B6A   21 6F 45      !oE
LD B,(HL)              ;1B6D   46            F
INC HL                 ;1B6E   23            #
LD C,(HL)              ;1B6F   4E            N
INC HL                 ;1B70   23            #
LD A,(HL)              ;1B71   7E            ~
LD DE,(4572H)          ;1B72   ED 5B 72 45   í[rE
OR A                   ;1B76   B7            ·
JP NZ,1B84H            ;1B77   C2 84 1B      Â
OR B                   ;1B7A   B0            °
JP NZ,1670H            ;1B7B   C2 70 16      Âp
CALL 1824H             ;1B7E   CD 24 18      Í$
JP 167AH               ;1B81   C3 7A 16      Ãz
XOR A                  ;1B84   AF            ¯
OR B                   ;1B85   B0            °
JP Z,1670H             ;1B86   CA 70 16      Êp
LD HL,4559H            ;1B89   21 59 45      !YE
XOR A                  ;1B8C   AF            ¯
LD B,A                 ;1B8D   47            G
SBC HL,DE              ;1B8E   ED 52         íR
JP Z,1BC0H             ;1B90   CA C0 1B      ÊÀ
LD HL,(456CH)          ;1B93   2A 6C 45      *lE
PUSH HL                ;1B96   E5            å
XOR A                  ;1B97   AF            ¯
SBC HL,BC              ;1B98   ED 42         íB
LD B,H                 ;1B9A   44            D
LD C,L                 ;1B9B   4D            M
JR C,1BA3H             ;1B9C   38 05         8
CALL 177CH             ;1B9E   CD 7C 17      Í|
JR 1BABH               ;1BA1   18 08         
PUSH BC                ;1BA3   C5            Å
CALL 1651H             ;1BA4   CD 51 16      ÍQ
CALL 1766H             ;1BA7   CD 66 17      Íf
POP BC                 ;1BAA   C1            Á
CALL 189CH             ;1BAB   CD 9C 18      Í
LD HL,(456EH)          ;1BAE   2A 6E 45      *nE
EX DE,HL               ;1BB1   EB            ë
CALL 1801H             ;1BB2   CD 01 18      Í
EX DE,HL               ;1BB5   EB            ë
POP BC                 ;1BB6   C1            Á
LD A,C                 ;1BB7   79            y
OR A                   ;1BB8   B7            ·
JR Z,1BBDH             ;1BB9   28 02         (
LDIR                   ;1BBB   ED B0         í°
JP 167AH               ;1BBD   C3 7A 16      Ãz
LD HL,(456EH)          ;1BC0   2A 6E 45      *nE
EX DE,HL               ;1BC3   EB            ë
CALL 1801H             ;1BC4   CD 01 18      Í
EX DE,HL               ;1BC7   EB            ë
LD DE,4559H            ;1BC8   11 59 45      YE
PUSH DE                ;1BCB   D5            Õ
LD B,03H               ;1BCC   06 03         
LD C,02H               ;1BCE   0E 02         
CALL 1659H             ;1BD0   CD 59 16      ÍY
JP NC,1398H            ;1BD3   D2 98 13      Ò
LD (DE),A              ;1BD6   12            
INC DE                 ;1BD7   13            
INC HL                 ;1BD8   23            #
DEC C                  ;1BD9   0D            
JR NZ,1BD0H            ;1BDA   20 F4          ô
LD A,0DH               ;1BDC   3E 0D         >
LD (DE),A              ;1BDE   12            
INC DE                 ;1BDF   13            
DEC B                  ;1BE0   05            
JR NZ,1BCEH            ;1BE1   20 EB          ë
CALL 168BH             ;1BE3   CD 8B 16      Í
DEC C                  ;1BE6   0D            
SBC A,B                ;1BE7   98            
INC DE                 ;1BE8   13            
POP HL                 ;1BE9   E1            á
CALL 198CH             ;1BEA   CD 8C 19      Í
LD B,00H               ;1BED   06 00         
LD A,E                 ;1BEF   7B            {
CP 18H                 ;1BF0   FE 18         þ
JP NC,1398H            ;1BF2   D2 98 13      Ò
SUB 0CH                ;1BF5   D6 0C         Ö
JR C,1BFBH             ;1BF7   38 02         8
LD E,A                 ;1BF9   5F            _
INC B                  ;1BFA   04            
LD A,B                 ;1BFB   78            x
PUSH AF                ;1BFC   F5            õ
PUSH HL                ;1BFD   E5            å
LD HL,0E10H            ;1BFE   21 10 0E      !
CALL 16C8H             ;1C01   CD C8 16      ÍÈ
POP HL                 ;1C04   E1            á
PUSH DE                ;1C05   D5            Õ
INC HL                 ;1C06   23            #
CALL 198CH             ;1C07   CD 8C 19      Í
LD A,E                 ;1C0A   7B            {
CP 3CH                 ;1C0B   FE 3C         þ<
JP NC,1398H            ;1C0D   D2 98 13      Ò
PUSH HL                ;1C10   E5            å
LD HL,003CH            ;1C11   21 3C 00      !<
CALL 16C8H             ;1C14   CD C8 16      ÍÈ
POP HL                 ;1C17   E1            á
EX (SP),HL             ;1C18   E3            ã
ADD HL,DE              ;1C19   19            
EX (SP),HL             ;1C1A   E3            ã
INC HL                 ;1C1B   23            #
CALL 198CH             ;1C1C   CD 8C 19      Í
LD A,E                 ;1C1F   7B            {
CP 3CH                 ;1C20   FE 3C         þ<
JP NC,1398H            ;1C22   D2 98 13      Ò
POP HL                 ;1C25   E1            á
ADD HL,DE              ;1C26   19            
EX DE,HL               ;1C27   EB            ë
POP AF                 ;1C28   F1            ñ
CALL 0033H             ;1C29   CD 33 00      Í3
JP 167AH               ;1C2C   C3 7A 16      Ãz
LD B,00H               ;1C2F   06 00         
CALL 168BH             ;1C31   CD 8B 16      Í
CP A                   ;1C34   BF            ¿
LD B,L                 ;1C35   45            E
INC E                  ;1C36   1C            
INC HL                 ;1C37   23            #
INC B                  ;1C38   04            
CP 54H                 ;1C39   FE 54         þT
JP Z,1C45H             ;1C3B   CA 45 1C      ÊE
CP 50H                 ;1C3E   FE 50         þP
JP NZ,138EH            ;1C40   C2 8E 13      Â
LD B,80H               ;1C43   06 80         
LD A,B                 ;1C45   78            x
LD (457DH),A           ;1C46   32 7D 45      2}E
CALL 1829H             ;1C49   CD 29 18      Í)
JP NZ,1C60H            ;1C4C   C2 60 1C      Â`
LD A,(457DH)           ;1C4F   3A 7D 45      :}E
LD BC,19B5H            ;1C52   01 B5 19      µ
PUSH BC                ;1C55   C5            Å
CP 01H                 ;1C56   FE 01         þ
RET Z                  ;1C58   C8            È
OR A                   ;1C59   B7            ·
JP Z,0006H             ;1C5A   CA 06 00      Ê
JP 3BA6H               ;1C5D   C3 A6 3B      Ã¦;
CALL 168BH             ;1C60   CD 8B 16      Í
DEC SP                 ;1C63   3B            ;
LD H,(HL)              ;1C64   66            f
INC E                  ;1C65   1C            
CALL 168BH             ;1C66   CD 8B 16      Í
INC L                  ;1C69   2C            ,
LD A,L                 ;1C6A   7D            }
INC E                  ;1C6B   1C            
LD A,(457DH)           ;1C6C   3A 7D 45      :}E
LD BC,1C7DH            ;1C6F   01 7D 1C      }
PUSH BC                ;1C72   C5            Å
CP 01H                 ;1C73   FE 01         þ
RET Z                  ;1C75   C8            È
OR A                   ;1C76   B7            ·
JP Z,000FH             ;1C77   CA 0F 00      Ê
JP 3C4AH               ;1C7A   C3 4A 3C      ÃJ<
CALL 1829H             ;1C7D   CD 29 18      Í)
JP Z,19B5H             ;1C80   CA B5 19      Êµ
CP 3BH                 ;1C83   FE 3B         þ;
JR Z,1C89H             ;1C85   28 02         (
CP 2CH                 ;1C87   FE 2C         þ,
JP Z,1C60H             ;1C89   CA 60 1C      Ê`
CALL 22AFH             ;1C8C   CD AF 22      Í¯"
PUSH HL                ;1C8F   E5            å
LD A,D                 ;1C90   7A            z
OR A                   ;1C91   B7            ·
JP NZ,1CC5H            ;1C92   C2 C5 1C      ÂÅ
LD HL,(4644H)          ;1C95   2A 44 46      *DF
LD DE,4400H            ;1C98   11 00 44      D
PUSH DE                ;1C9B   D5            Õ
CALL 322DH             ;1C9C   CD 2D 32      Í-2
POP DE                 ;1C9F   D1            Ñ
LD A,(457DH)           ;1CA0   3A 7D 45      :}E
LD BC,1CB3H            ;1CA3   01 B3 1C      ³
PUSH BC                ;1CA6   C5            Å
CP 01H                 ;1CA7   FE 01         þ
JP Z,2C4EH             ;1CA9   CA 4E 2C      ÊN,
OR A                   ;1CAC   B7            ·
JP Z,3D17H             ;1CAD   CA 17 3D      Ê=
JP 3BB6H               ;1CB0   C3 B6 3B      Ã¶;
POP HL                 ;1CB3   E1            á
CALL 1829H             ;1CB4   CD 29 18      Í)
JR Z,1CBFH             ;1CB7   28 06         (
CP 3BH                 ;1CB9   FE 3B         þ;
JR Z,1CBFH             ;1CBB   28 02         (
CP 2CH                 ;1CBD   FE 2C         þ,
JP Z,1C49H             ;1CBF   CA 49 1C      ÊI
JP 138EH               ;1CC2   C3 8E 13      Ã
CALL 1801H             ;1CC5   CD 01 18      Í
JP 1CA0H               ;1CC8   C3 A0 1C      Ã 
CALL 1987H             ;1CCB   CD 87 19      Í
XOR A                  ;1CCE   AF            ¯
LD (457AH),A           ;1CCF   32 7A 45      2zE
LD (4565H),A           ;1CD2   32 65 45      2eE
CALL 1659H             ;1CD5   CD 59 16      ÍY
JP NC,1CEAH            ;1CD8   D2 EA 1C      Òê
CALL 16F1H             ;1CDB   CD F1 16      Íñ
EX DE,HL               ;1CDE   EB            ë
CALL 17A5H             ;1CDF   CD A5 17      Í¥
ADC A,(HL)             ;1CE2   8E            
INC DE                 ;1CE3   13            
JP NZ,138EH            ;1CE4   C2 8E 13      Â
JP 19CFH               ;1CE7   C3 CF 19      ÃÏ
CALL 1857H             ;1CEA   CD 57 18      ÍW
CALL 187CH             ;1CED   CD 7C 18      Í|
LD HL,4806H            ;1CF0   21 06 48      !H
JP 19CFH               ;1CF3   C3 CF 19      ÃÏ
CALL 16F1H             ;1CF6   CD F1 16      Íñ
LD (4801H),HL          ;1CF9   22 01 48      "H
EX DE,HL               ;1CFC   EB            ë
CALL 17A5H             ;1CFD   CD A5 17      Í¥
ADC A,(HL)             ;1D00   8E            
INC DE                 ;1D01   13            
JP NZ,138EH            ;1D02   C2 8E 13      Â
EXX                    ;1D05   D9            Ù
LD HL,4805H            ;1D06   21 05 48      !H
LD A,(HL)              ;1D09   7E            ~
CP 0FH                 ;1D0A   FE 0F         þ
JP Z,13A7H             ;1D0C   CA A7 13      Ê
INC (HL)               ;1D0F   34            4
DEC HL                 ;1D10   2B            +
DEC HL                 ;1D11   2B            +
LD DE,(464AH)          ;1D12   ED 5B 4A 46   í[JF
DEC DE                 ;1D16   1B            
LD BC,0007H            ;1D17   01 07 00      
LDDR                   ;1D1A   ED B8         í¸
INC DE                 ;1D1C   13            
LD (464AH),DE          ;1D1D   ED 53 4A 46   íSJF
LD C,07H               ;1D21   0E 07         
ADD HL,BC              ;1D23   09            	
LD (HL),00H            ;1D24   36 00         6
EXX                    ;1D26   D9            Ù
JP 19CFH               ;1D27   C3 CF 19      ÃÏ
LD HL,4805H            ;1D2A   21 05 48      !H
XOR A                  ;1D2D   AF            ¯
CP (HL)                ;1D2E   BE            ¾
JP Z,138EH             ;1D2F   CA 8E 13      Ê
DEC (HL)               ;1D32   35            5
LD HL,4803H            ;1D33   21 03 48      !H
LD A,(HL)              ;1D36   7E            ~
OR A                   ;1D37   B7            ·
JP Z,1D4BH             ;1D38   CA 4B 1D      ÊK
DEC (HL)               ;1D3B   35            5
INC HL                 ;1D3C   23            #
DEC (HL)               ;1D3D   35            5
LD HL,(4648H)          ;1D3E   2A 48 46      *HF
LD BC,0013H            ;1D41   01 13 00      
ADD HL,BC              ;1D44   09            	
LD (4648H),HL          ;1D45   22 48 46      "HF
JP 1D33H               ;1D48   C3 33 1D      Ã3
LD HL,(464AH)          ;1D4B   2A 4A 46      *JF
LD DE,47FDH            ;1D4E   11 FD 47      ýG
LD BC,0007H            ;1D51   01 07 00      
LDIR                   ;1D54   ED B0         í°
LD (464AH),HL          ;1D56   22 4A 46      "JF
JP 19B2H               ;1D59   C3 B2 19      Ã²
CALL 2613H             ;1D5C   CD 13 26      Í&
CALL 169AH             ;1D5F   CD 9A 16      Í
OR (HL)                ;1D62   B6            ¶
PUSH DE                ;1D63   D5            Õ
CALL 1DEBH             ;1D64   CD EB 1D      Íë
POP HL                 ;1D67   E1            á
LD (47F0H),HL          ;1D68   22 F0 47      "ðG
EX DE,HL               ;1D6B   EB            ë
CALL 2441H             ;1D6C   CD 41 24      ÍA$
CALL 1824H             ;1D6F   CD 24 18      Í$
CALL 1697H             ;1D72   CD 97 16      Í
XOR (HL)               ;1D75   AE            ®
CALL 1DEBH             ;1D76   CD EB 1D      Íë
LD DE,47F8H            ;1D79   11 F8 47      øG
CALL 1824H             ;1D7C   CD 24 18      Í$
CALL 1688H             ;1D7F   CD 88 16      Í
XOR A                  ;1D82   AF            ¯
ADC A,L                ;1D83   8D            
DEC E                  ;1D84   1D            
CALL 1DEBH             ;1D85   CD EB 1D      Íë
LD HL,(4644H)          ;1D88   2A 44 46      *DF
JR 1D90H               ;1D8B   18 03         
LD HL,1614H            ;1D8D   21 14 16      !
LD DE,47F2H            ;1D90   11 F2 47      òG
LD A,(HL)              ;1D93   7E            ~
LD (47F7H),A           ;1D94   32 F7 47      2÷G
LD BC,0005H            ;1D97   01 05 00      
LDIR                   ;1D9A   ED B0         í°
LD HL,(4648H)          ;1D9C   2A 48 46      *HF
LD DE,(47F0H)          ;1D9F   ED 5B F0 47   í[ðG
LD A,(4803H)           ;1DA3   3A 03 48      :H
INC A                  ;1DA6   3C            <
DEC A                  ;1DA7   3D            =
JP Z,1DCCH             ;1DA8   CA CC 1D      ÊÌ
EX AF,AF'              ;1DAB   08            
LD A,(HL)              ;1DAC   7E            ~
SUB E                  ;1DAD   93            
LD B,A                 ;1DAE   47            G
INC HL                 ;1DAF   23            #
LD A,(HL)              ;1DB0   7E            ~
SUB D                  ;1DB1   92            
OR B                   ;1DB2   B0            °
LD BC,0012H            ;1DB3   01 12 00      
ADD HL,BC              ;1DB6   09            	
JP Z,1DBEH             ;1DB7   CA BE 1D      Ê¾
EX AF,AF'              ;1DBA   08            
JP 1DA7H               ;1DBB   C3 A7 1D      Ã
LD (4648H),HL          ;1DBE   22 48 46      "HF
EX AF,AF'              ;1DC1   08            
DEC A                  ;1DC2   3D            =
LD HL,4803H            ;1DC3   21 03 48      !H
LD B,(HL)              ;1DC6   46            F
LD (HL),A              ;1DC7   77            w
SUB B                  ;1DC8   90            
INC HL                 ;1DC9   23            #
ADD A,(HL)             ;1DCA   86            
LD (HL),A              ;1DCB   77            w
LD HL,4804H            ;1DCC   21 04 48      !H
LD A,(HL)              ;1DCF   7E            ~
CP 0FH                 ;1DD0   FE 0F         þ
JP Z,13A2H             ;1DD2   CA A2 13      Ê¢
INC (HL)               ;1DD5   34            4
DEC HL                 ;1DD6   2B            +
INC (HL)               ;1DD7   34            4
DEC HL                 ;1DD8   2B            +
LD DE,(4648H)          ;1DD9   ED 5B 48 46   í[HF
LD BC,0013H            ;1DDD   01 13 00      
DEC DE                 ;1DE0   1B            
LDDR                   ;1DE1   ED B8         í¸
INC DE                 ;1DE3   13            
EX DE,HL               ;1DE4   EB            ë
LD (4648H),HL          ;1DE5   22 48 46      "HF
JP 19B2H               ;1DE8   C3 B2 19      Ã²
CALL 22AFH             ;1DEB   CD AF 22      Í¯"
LD (4801H),HL          ;1DEE   22 01 48      "H
JP 1814H               ;1DF1   C3 14 18      Ã
LD A,(4803H)           ;1DF4   3A 03 48      :H
OR A                   ;1DF7   B7            ·
JP Z,138EH             ;1DF8   CA 8E 13      Ê
CALL 25CDH             ;1DFB   CD CD 25      ÍÍ%
LD (4801H),HL          ;1DFE   22 01 48      "H
LD HL,(4648H)          ;1E01   2A 48 46      *HF
CALL NC,1E77H          ;1E04   D4 77 1E      Ôw
LD A,E                 ;1E07   7B            {
SUB (HL)               ;1E08   96            
INC HL                 ;1E09   23            #
LD B,A                 ;1E0A   47            G
LD A,D                 ;1E0B   7A            z
SUB (HL)               ;1E0C   96            
OR B                   ;1E0D   B0            °
JP Z,1E28H             ;1E0E   CA 28 1E      Ê(
EXX                    ;1E11   D9            Ù
LD HL,4803H            ;1E12   21 03 48      !H
LD A,(HL)              ;1E15   7E            ~
DEC A                  ;1E16   3D            =
JP Z,138EH             ;1E17   CA 8E 13      Ê
LD (HL),A              ;1E1A   77            w
INC HL                 ;1E1B   23            #
DEC (HL)               ;1E1C   35            5
EXX                    ;1E1D   D9            Ù
LD BC,0012H            ;1E1E   01 12 00      
ADD HL,BC              ;1E21   09            	
LD (4648H),HL          ;1E22   22 48 46      "HF
JP 1E07H               ;1E25   C3 07 1E      Ã
INC HL                 ;1E28   23            #
CALL 2441H             ;1E29   CD 41 24      ÍA$
PUSH DE                ;1E2C   D5            Õ
PUSH HL                ;1E2D   E5            å
CALL 2D4DH             ;1E2E   CD 4D 2D      ÍM-
POP HL                 ;1E31   E1            á
POP DE                 ;1E32   D1            Ñ
LD BC,0005H            ;1E33   01 05 00      
ADD HL,BC              ;1E36   09            	
LD A,(HL)              ;1E37   7E            ~
INC HL                 ;1E38   23            #
PUSH HL                ;1E39   E5            å
OR A                   ;1E3A   B7            ·
JP P,1E57H             ;1E3B   F2 57 1E      òW
EX DE,HL               ;1E3E   EB            ë
CALL 33EEH             ;1E3F   CD EE 33      Íî3
POP HL                 ;1E42   E1            á
LD BC,0005H            ;1E43   01 05 00      
JP C,1E62H             ;1E46   DA 62 1E      Úb
ADD HL,BC              ;1E49   09            	
LD DE,47FDH            ;1E4A   11 FD 47      ýG
INC C                  ;1E4D   0C            
LDIR                   ;1E4E   ED B0         í°
LD HL,(4801H)          ;1E50   2A 01 48      *H
LD A,(HL)              ;1E53   7E            ~
JP 19B8H               ;1E54   C3 B8 19      Ã¸
CALL 33EEH             ;1E57   CD EE 33      Íî3
POP HL                 ;1E5A   E1            á
LD BC,0005H            ;1E5B   01 05 00      
CCF                    ;1E5E   3F            ?
JP C,1E49H             ;1E5F   DA 49 1E      ÚI
LD C,0BH               ;1E62   0E 0B         
ADD HL,BC              ;1E64   09            	
LD (4648H),HL          ;1E65   22 48 46      "HF
LD HL,4803H            ;1E68   21 03 48      !H
DEC (HL)               ;1E6B   35            5
INC HL                 ;1E6C   23            #
DEC (HL)               ;1E6D   35            5
CALL 1688H             ;1E6E   CD 88 16      Í
INC L                  ;1E71   2C            ,
OR D                   ;1E72   B2            ²
ADD HL,DE              ;1E73   19            
JP 1DF4H               ;1E74   C3 F4 1D      Ãô
LD E,(HL)              ;1E77   5E            ^
INC HL                 ;1E78   23            #
LD D,(HL)              ;1E79   56            V
DEC HL                 ;1E7A   2B            +
RET                    ;1E7B   C9            É
CALL 2C39H             ;1E7C   CD 39 2C      Í9,
PUSH HL                ;1E7F   E5            å
LD HL,(47FFH)          ;1E80   2A FF 47      *ÿG
LD A,L                 ;1E83   7D            }
OR H                   ;1E84   B4            ´
JP Z,138EH             ;1E85   CA 8E 13      Ê
XOR A                  ;1E88   AF            ¯
LD (4574H),A           ;1E89   32 74 45      2tE
POP HL                 ;1E8C   E1            á
LD (4801H),HL          ;1E8D   22 01 48      "H
PUSH HL                ;1E90   E5            å
CALL 162DH             ;1E91   CD 2D 16      Í-
CP 22H                 ;1E94   FE 22         þ"
LD DE,1EAFH            ;1E96   11 AF 1E      ¯
JP NZ,1EA9H            ;1E99   C2 A9 1E      Â©
CALL 2383H             ;1E9C   CD 83 23      Í#
CALL 169AH             ;1E9F   CD 9A 16      Í
DEC SP                 ;1EA2   3B            ;
LD (4801H),HL          ;1EA3   22 01 48      "H
CALL 1801H             ;1EA6   CD 01 18      Í
CALL 1EC1H             ;1EA9   CD C1 1E      ÍÁ
JP 1F06H               ;1EAC   C3 06 1F      Ã
CCF                    ;1EAF   3F            ?
JR NZ,1EBFH            ;1EB0   20 0D          
XOR A                  ;1EB2   AF            ¯
LD (1194H),A           ;1EB3   32 94 11      2
RET                    ;1EB6   C9            É
LD A,(457DH)           ;1EB7   3A 7D 45      :}E
OR A                   ;1EBA   B7            ·
CALL Z,0009H           ;1EBB   CC 09 00      Ì	
LD DE,1EAFH            ;1EBE   11 AF 1E      ¯
LD A,(457DH)           ;1EC1   3A 7D 45      :}E
OR A                   ;1EC4   B7            ·
CALL Z,0015H           ;1EC5   CC 15 00      Ì
CALL NZ,1EB2H          ;1EC8   C4 B2 1E      Ä²
LD DE,4455H            ;1ECB   11 55 44      UD
LD A,(1194H)           ;1ECE   3A 94 11      :
CALL 2C7AH             ;1ED1   CD 7A 2C      Íz,
CALL 0003H             ;1ED4   CD 03 00      Í
EX DE,HL               ;1ED7   EB            ë
LD A,(457DH)           ;1ED8   3A 7D 45      :}E
OR A                   ;1EDB   B7            ·
JP NZ,1EF8H            ;1EDC   C2 F8 1E      Âø
LD A,1BH               ;1EDF   3E 1B         >
CP (HL)                ;1EE1   BE            ¾
JP Z,1EFCH             ;1EE2   CA FC 1E      Êü
LD A,0DH               ;1EE5   3E 0D         >
CP (HL)                ;1EE7   BE            ¾
JP Z,1EB7H             ;1EE8   CA B7 1E      Ê·
INC HL                 ;1EEB   23            #
DEC C                  ;1EEC   0D            
JR NZ,1EE7H            ;1EED   20 F8          ø
CALL 168BH             ;1EEF   CD 8B 16      Í
DEC C                  ;1EF2   0D            
RET M                  ;1EF3   F8            ø
LD E,C3H               ;1EF4   1E C3         Ã
OR A                   ;1EF6   B7            ·
LD E,22H               ;1EF7   1E 22         "
LD (HL),L              ;1EF9   75            u
LD B,L                 ;1EFA   45            E
RET                    ;1EFB   C9            É
LD A,81H               ;1EFC   3E 81         >
LD (4565H),A           ;1EFE   32 65 45      2eE
POP AF                 ;1F01   F1            ñ
POP HL                 ;1F02   E1            á
JP 1B39H               ;1F03   C3 39 1B      Ã9
LD HL,(4801H)          ;1F06   2A 01 48      *H
CALL 1829H             ;1F09   CD 29 18      Í)
JP Z,1FA4H             ;1F0C   CA A4 1F      Ê¤
CALL 2613H             ;1F0F   CD 13 26      Í&
CALL 2436H             ;1F12   CD 36 24      Í6$
CALL 1829H             ;1F15   CD 29 18      Í)
JR Z,1F1EH             ;1F18   28 04         (
CALL 169AH             ;1F1A   CD 9A 16      Í
INC L                  ;1F1D   2C            ,
LD (4801H),HL          ;1F1E   22 01 48      "H
CALL 197BH             ;1F21   CD 7B 19      Í{
LD HL,(4575H)          ;1F24   2A 75 45      *uE
CALL 168BH             ;1F27   CD 8B 16      Í
INC L                  ;1F2A   2C            ,
DEC L                  ;1F2B   2D            -
RRA                    ;1F2C   1F            
LD (4575H),HL          ;1F2D   22 75 45      "uE
LD A,(457DH)           ;1F30   3A 7D 45      :}E
OR A                   ;1F33   B7            ·
JP NZ,1F3DH            ;1F34   C2 3D 1F      Â=
CALL 1829H             ;1F37   CD 29 18      Í)
CALL Z,1F9AH           ;1F3A   CC 9A 1F      Ì
LD HL,(4575H)          ;1F3D   2A 75 45      *uE
CALL 18C4H             ;1F40   CD C4 18      ÍÄ
LD A,(4574H)           ;1F43   3A 74 45      :tE
OR A                   ;1F46   B7            ·
JP Z,1F4DH             ;1F47   CA 4D 1F      ÊM
LD (4578H),HL          ;1F4A   22 78 45      "xE
LD (4575H),HL          ;1F4D   22 75 45      "uE
LD A,(4571H)           ;1F50   3A 71 45      :qE
OR A                   ;1F53   B7            ·
CALL Z,1F72H           ;1F54   CC 72 1F      Ìr
CALL 1976H             ;1F57   CD 76 19      Ív
CALL 1B6AH             ;1F5A   CD 6A 1B      Íj
SBC A,L                ;1F5D   9D            
INC DE                 ;1F5E   13            
LD A,(457DH)           ;1F5F   3A 7D 45      :}E
OR A                   ;1F62   B7            ·
JP Z,1F06H             ;1F63   CA 06 1F      Ê
LD HL,(4801H)          ;1F66   2A 01 48      *H
CALL 1829H             ;1F69   CD 29 18      Í)
CALL NZ,1EC1H          ;1F6C   C4 C1 1E      ÄÁ
JP 1F06H               ;1F6F   C3 06 1F      Ã
CALL 1801H             ;1F72   CD 01 18      Í
EX DE,HL               ;1F75   EB            ë
CALL 190DH             ;1F76   CD 0D 19      Í

LD A,H                 ;1F79   7C            |
RRA                    ;1F7A   1F            
RET                    ;1F7B   C9            É
POP AF                 ;1F7C   F1            ñ
LD A,(4574H)           ;1F7D   3A 74 45      :tE
OR A                   ;1F80   B7            ·
JP NZ,1398H            ;1F81   C2 98 13      Â
LD A,(457DH)           ;1F84   3A 7D 45      :}E
OR A                   ;1F87   B7            ·
JP NZ,1398H            ;1F88   C2 98 13      Â
LD DE,1318H            ;1F8B   11 18 13      
CALL 1357H             ;1F8E   CD 57 13      ÍW
LD DE,12FFH            ;1F91   11 FF 12      ÿ
CALL 0015H             ;1F94   CD 15 00      Í
JP 1E8CH               ;1F97   C3 8C 1E      Ã
LD A,(4574H)           ;1F9A   3A 74 45      :tE
OR A                   ;1F9D   B7            ·
JP Z,1EB7H             ;1F9E   CA B7 1E      Ê·
JP 1FD4H               ;1FA1   C3 D4 1F      ÃÔ
LD A,(4574H)           ;1FA4   3A 74 45      :tE
OR A                   ;1FA7   B7            ·
JP NZ,19B2H            ;1FA8   C2 B2 19      Â²
POP AF                 ;1FAB   F1            ñ
JP 19B2H               ;1FAC   C3 B2 19      Ã²
LD (4801H),HL          ;1FAF   22 01 48      "H
LD A,(4577H)           ;1FB2   3A 77 45      :wE
OR A                   ;1FB5   B7            ·
CALL Z,1FCAH           ;1FB6   CC CA 1F      ÌÊ
LD HL,(4578H)          ;1FB9   2A 78 45      *xE
LD (4575H),HL          ;1FBC   22 75 45      "uE
XOR A                  ;1FBF   AF            ¯
LD (457DH),A           ;1FC0   32 7D 45      2}E
INC A                  ;1FC3   3C            <
LD (4574H),A           ;1FC4   32 74 45      2tE
JP 1F06H               ;1FC7   C3 06 1F      Ã
INC A                  ;1FCA   3C            <
LD (4577H),A           ;1FCB   32 77 45      2wE
LD HL,4806H            ;1FCE   21 06 48      !H
JP 1FE0H               ;1FD1   C3 E0 1F      Ãà
LD HL,(4575H)          ;1FD4   2A 75 45      *uE
CALL 163DH             ;1FD7   CD 3D 16      Í=
INC HL                 ;1FDA   23            #
CP 3AH                 ;1FDB   FE 3A         þ:
JP Z,1FE9H             ;1FDD   CA E9 1F      Êé
LD A,(HL)              ;1FE0   7E            ~
INC HL                 ;1FE1   23            #
OR (HL)                ;1FE2   B6            ¶
JP Z,1385H             ;1FE3   CA 85 13      Ê
INC HL                 ;1FE6   23            #
INC HL                 ;1FE7   23            #
INC HL                 ;1FE8   23            #
CALL 168BH             ;1FE9   CD 8B 16      Í
ADD A,C                ;1FEC   81            
RST 10H                ;1FED   D7            ×
RRA                    ;1FEE   1F            
LD (4578H),HL          ;1FEF   22 78 45      "xE
LD (4575H),HL          ;1FF2   22 75 45      "uE
RET                    ;1FF5   C9            É
CALL 22AFH             ;1FF6   CD AF 22      Í¯"
CALL 1814H             ;1FF9   CD 14 18      Í
LD DE,(4644H)          ;1FFC   ED 5B 44 46   í[DF
LD A,(DE)              ;2000   1A            
LD DE,0000H            ;2001   11 00 00      
CP C1H                 ;2004   FE C1         þÁ
JP C,2019H             ;2006   DA 19 20      Ú 
SUB D1H                ;2009   D6 D1         ÖÑ
JP NC,2019H            ;200B   D2 19 20      Ò 
LD BC,2019H            ;200E   01 19 20       
PUSH BC                ;2011   C5            Å
PUSH HL                ;2012   E5            å
LD HL,(4644H)          ;2013   2A 44 46      *DF
JP 1963H               ;2016   C3 63 19      Ãc
LD A,(HL)              ;2019   7E            ~
INC HL                 ;201A   23            #
SUB 89H                ;201B   D6 89         Ö
JR Z,2024H             ;201D   28 05         (
CP 02H                 ;201F   FE 02         þ
JP NZ,138EH            ;2021   C2 8E 13      Â
EX AF,AF'              ;2024   08            
LD A,E                 ;2025   7B            {
OR A                   ;2026   B7            ·
JP Z,1B27H             ;2027   CA 27 1B      Ê'
LD A,D                 ;202A   7A            z
OR A                   ;202B   B7            ·
JP NZ,1B27H            ;202C   C2 27 1B      Â'
DEC E                  ;202F   1D            
JP Z,2042H             ;2030   CA 42 20      ÊB 
CALL 1829H             ;2033   CD 29 18      Í)
JP Z,19B8H             ;2036   CA B8 19      Ê¸
CP 2CH                 ;2039   FE 2C         þ,
INC HL                 ;203B   23            #
JP NZ,2033H            ;203C   C2 33 20      Â3 
JP 202FH               ;203F   C3 2F 20      Ã/ 
CALL 16F1H             ;2042   CD F1 16      Íñ
CALL 163DH             ;2045   CD 3D 16      Í=
EX AF,AF'              ;2048   08            
OR A                   ;2049   B7            ·
JP NZ,1CF9H            ;204A   C2 F9 1C      Âù
JP 1CDEH               ;204D   C3 DE 1C      ÃÞ
CALL 2613H             ;2050   CD 13 26      Í&
LD BC,0000H            ;2053   01 00 00      
CP 24H                 ;2056   FE 24         þ$
JR NZ,205CH            ;2058   20 02          
INC HL                 ;205A   23            #
INC B                  ;205B   04            
CALL 169AH             ;205C   CD 9A 16      Í
JR Z,202EH             ;205F   28 CD         (Í
EXX                    ;2061   D9            Ù
JR NZ,2026H            ;2062   20 C2          Â
OR L                   ;2064   B5            µ
JR NZ,204CH            ;2065   20 E5          å
LD HL,(20D7H)          ;2067   2A D7 20      *× 
LD E,H                 ;206A   5C            \
LD D,A                 ;206B   57            W
LD H,A                 ;206C   67            g
INC HL                 ;206D   23            #
INC DE                 ;206E   13            
CALL 16A7H             ;206F   CD A7 16      Í
SUB E                  ;2072   93            
INC DE                 ;2073   13            
LD A,(20D6H)           ;2074   3A D6 20      :Ö 
OR A                   ;2077   B7            ·
POP HL                 ;2078   E1            á
PUSH DE                ;2079   D5            Õ
PUSH HL                ;207A   E5            å
JR NZ,2085H            ;207B   20 08          
LD HL,0005H            ;207D   21 05 00      !
CALL 16A7H             ;2080   CD A7 16      Í
SUB E                  ;2083   93            
INC DE                 ;2084   13            
LD HL,0004H            ;2085   21 04 00      !
ADD HL,DE              ;2088   19            
JP C,1393H             ;2089   DA 93 13      Ú
LD B,H                 ;208C   44            D
LD C,L                 ;208D   4D            M
POP DE                 ;208E   D1            Ñ
CALL 177CH             ;208F   CD 7C 17      Í|
CALL 189CH             ;2092   CD 9C 18      Í
LD HL,(4630H)          ;2095   2A 30 46      *0F
EX DE,HL               ;2098   EB            ë
LD (HL),E              ;2099   73            s
INC HL                 ;209A   23            #
LD (HL),D              ;209B   72            r
INC HL                 ;209C   23            #
LD DE,(20D7H)          ;209D   ED 5B D7 20   í[× 
LD (HL),E              ;20A1   73            s
INC HL                 ;20A2   23            #
LD (HL),D              ;20A3   72            r
INC HL                 ;20A4   23            #
POP BC                 ;20A5   C1            Á
LD A,(20D6H)           ;20A6   3A D6 20      :Ö 
OR A                   ;20A9   B7            ·
JP Z,20C1H             ;20AA   CA C1 20      ÊÁ 
LD (HL),0DH            ;20AD   36 0D         6
INC HL                 ;20AF   23            #
DEC BC                 ;20B0   0B            
LD A,B                 ;20B1   78            x
OR C                   ;20B2   B1            ±
JR NZ,20ADH            ;20B3   20 F8          ø
LD HL,(20D4H)          ;20B5   2A D4 20      *Ô 
CALL 168BH             ;20B8   CD 8B 16      Í
INC L                  ;20BB   2C            ,
OR L                   ;20BC   B5            µ
ADD HL,DE              ;20BD   19            
JP 2050H               ;20BE   C3 50 20      ÃP 
EX DE,HL               ;20C1   EB            ë
PUSH BC                ;20C2   C5            Å
LD HL,1619H            ;20C3   21 19 16      !
LD BC,0005H            ;20C6   01 05 00      
LDIR                   ;20C9   ED B0         í°
POP BC                 ;20CB   C1            Á
DEC BC                 ;20CC   0B            
LD A,B                 ;20CD   78            x
OR C                   ;20CE   B1            ±
JR NZ,20C2H            ;20CF   20 F1          ñ
JP 20B5H               ;20D1   C3 B5 20      Ãµ 
DEC HL                 ;20D4   2B            +
AND E                  ;20D5   A3            £
INC SP                 ;20D6   33            3
LD A,9EH               ;20D7   3E 9E         >
PUSH DE                ;20D9   D5            Õ
PUSH BC                ;20DA   C5            Å
CALL 19A9H             ;20DB   CD A9 19      Í©
POP BC                 ;20DE   C1            Á
LD A,(HL)              ;20DF   7E            ~
CP 2CH                 ;20E0   FE 2C         þ,
CALL Z,215AH           ;20E2   CC 5A 21      ÌZ!
CALL 169AH             ;20E5   CD 9A 16      Í
ADD HL,HL              ;20E8   29            )
LD (20D4H),HL          ;20E9   22 D4 20      "Ô 
POP HL                 ;20EC   E1            á
LD (4630H),HL          ;20ED   22 30 46      "0F
EX DE,HL               ;20F0   EB            ë
LD (20D7H),HL          ;20F1   22 D7 20      "× 
LD A,B                 ;20F4   78            x
LD (20D6H),A           ;20F5   32 D6 20      2Ö 
LD HL,4636H            ;20F8   21 36 46      !6F
LD DE,0006H            ;20FB   11 06 00      
OR A                   ;20FE   B7            ·
JR NZ,2102H            ;20FF   20 01          
ADD HL,DE              ;2101   19            
LD A,C                 ;2102   79            y
LD E,02H               ;2103   1E 02         
OR A                   ;2105   B7            ·
JR NZ,2109H            ;2106   20 01          
ADD HL,DE              ;2108   19            
LD E,(HL)              ;2109   5E            ^
INC HL                 ;210A   23            #
LD D,(HL)              ;210B   56            V
EX DE,HL               ;210C   EB            ë
CALL 17C4H             ;210D   CD C4 17      ÍÄ
LD B,E                 ;2110   43            C
LD HL,45CAH            ;2111   21 CA 45      !ÊE
LD HL,235EH            ;2114   21 5E 23      !^#
PUSH HL                ;2117   E5            å
LD L,(HL)              ;2118   6E            n
LD D,00H               ;2119   16 00         
LD H,D                 ;211B   62            b
INC HL                 ;211C   23            #
INC DE                 ;211D   13            
CALL 16C8H             ;211E   CD C8 16      ÍÈ
LD A,(20D6H)           ;2121   3A D6 20      :Ö 
OR A                   ;2124   B7            ·
JP NZ,2134H            ;2125   C2 34 21      Â4!
LD HL,0005H            ;2128   21 05 00      !
CALL 16C8H             ;212B   CD C8 16      ÍÈ
POP HL                 ;212E   E1            á
ADD HL,DE              ;212F   19            
INC HL                 ;2130   23            #
JP 210DH               ;2131   C3 0D 21      Ã
!
POP HL                 ;2134   E1            á
LD A,0DH               ;2135   3E 0D         >
INC HL                 ;2137   23            #
CP (HL)                ;2138   BE            ¾
JR NZ,2137H            ;2139   20 FC          ü
DEC DE                 ;213B   1B            
LD A,D                 ;213C   7A            z
OR E                   ;213D   B3            ³
JR NZ,2135H            ;213E   20 F5          õ
JP 2130H               ;2140   C3 30 21      Ã0!
XOR A                  ;2143   AF            ¯
RET                    ;2144   C9            É
LD C,(HL)              ;2145   4E            N
INC HL                 ;2146   23            #
LD B,(HL)              ;2147   46            F
INC HL                 ;2148   23            #
LD DE,(20D7H)          ;2149   ED 5B D7 20   í[× 
LD A,B                 ;214D   78            x
CP D                   ;214E   BA            º
JR C,2153H             ;214F   38 02         8
LD A,C                 ;2151   79            y
CP E                   ;2152   BB            »
JP C,138EH             ;2153   DA 8E 13      Ú
LD A,01H               ;2156   3E 01         >
OR A                   ;2158   B7            ·
RET                    ;2159   C9            É
INC C                  ;215A   0C            
PUSH BC                ;215B   C5            Å
PUSH DE                ;215C   D5            Õ
INC HL                 ;215D   23            #
CALL 19A9H             ;215E   CD A9 19      Í©
LD A,E                 ;2161   7B            {
POP DE                 ;2162   D1            Ñ
LD D,A                 ;2163   57            W
POP BC                 ;2164   C1            Á
RET                    ;2165   C9            É
CALL 198CH             ;2166   CD 8C 19      Í
PUSH DE                ;2169   D5            Õ
CALL 169AH             ;216A   CD 9A 16      Í
INC L                  ;216D   2C            ,
CALL 19A9H             ;216E   CD A9 19      Í©
EX (SP),HL             ;2171   E3            ã
LD (HL),E              ;2172   73            s
POP HL                 ;2173   E1            á
JP 19B5H               ;2174   C3 B5 19      Ãµ
PUSH HL                ;2177   E5            å
CALL 1857H             ;2178   CD 57 18      ÍW
CALL 1872H             ;217B   CD 72 18      Ír
POP HL                 ;217E   E1            á
JP 19B5H               ;217F   C3 B5 19      Ãµ
CALL 2258H             ;2182   CD 58 22      ÍX"
CALL 1814H             ;2185   CD 14 18      Í
LD IX,(4644H)          ;2188   DD 2A 44 46   Ý*DF
BIT 7,(IX+4H)          ;218C   DD CB 04 7E   ÝË~
JP Z,19C7H             ;2190   CA C7 19      ÊÇ
LD A,(HL)              ;2193   7E            ~
INC HL                 ;2194   23            #
CP 89H                 ;2195   FE 89         þ
JP Z,1CDBH             ;2197   CA DB 1C      ÊÛ
CP 8BH                 ;219A   FE 8B         þ
JP Z,1CF6H             ;219C   CA F6 1C      Êö
CP ADH                 ;219F   FE AD         þ­
JP NZ,138EH            ;21A1   C2 8E 13      Â
CALL 1659H             ;21A4   CD 59 16      ÍY
JP C,1CDBH             ;21A7   DA DB 1C      ÚÛ
LD (4801H),HL          ;21AA   22 01 48      "H
JP 19E1H               ;21AD   C3 E1 19      Ãá
CALL 162DH             ;21B0   CD 2D 16      Í-
SUB 41H                ;21B3   D6 41         ÖA
CP 1AH                 ;21B5   FE 1A         þ
JP NC,138EH            ;21B7   D2 8E 13      Ò
LD E,(HL)              ;21BA   5E            ^
INC HL                 ;21BB   23            #
CALL 169AH             ;21BC   CD 9A 16      Í
JR Z,2197H             ;21BF   28 D6         (Ö
LD B,C                 ;21C1   41            A
CP 1AH                 ;21C2   FE 1A         þ
JP NC,138EH            ;21C4   D2 8E 13      Ò
LD D,(HL)              ;21C7   56            V
INC HL                 ;21C8   23            #
CALL 169AH             ;21C9   CD 9A 16      Í
ADD HL,HL              ;21CC   29            )
CALL 169AH             ;21CD   CD 9A 16      Í
OR (HL)                ;21D0   B6            ¶
PUSH HL                ;21D1   E5            å
CALL 163DH             ;21D2   CD 3D 16      Í=
POP BC                 ;21D5   C1            Á
PUSH HL                ;21D6   E5            å
XOR A                  ;21D7   AF            ¯
SBC HL,BC              ;21D8   ED 42         íB
PUSH BC                ;21DA   C5            Å
PUSH HL                ;21DB   E5            å
LD HL,(4634H)          ;21DC   2A 34 46      *4F
LD A,(HL)              ;21DF   7E            ~
CP E                   ;21E0   BB            »
JP Z,2204H             ;21E1   CA 04 22      Ê"
CP 00H                 ;21E4   FE 00         þ
JR Z,21EFH             ;21E6   28 07         (
INC HL                 ;21E8   23            #
INC HL                 ;21E9   23            #
CALL 1633H             ;21EA   CD 33 16      Í3
JR 21DFH               ;21ED   18 F0         ð
EX DE,HL               ;21EF   EB            ë
LD BC,0003H            ;21F0   01 03 00      
CALL 177CH             ;21F3   CD 7C 17      Í|
CALL 189CH             ;21F6   CD 9C 18      Í
EX DE,HL               ;21F9   EB            ë
LD (HL),E              ;21FA   73            s
INC HL                 ;21FB   23            #
LD (HL),D              ;21FC   72            r
INC HL                 ;21FD   23            #
LD (HL),0DH            ;21FE   36 0D         6
EX DE,HL               ;2200   EB            ë
JP 221AH               ;2201   C3 1A 22      Ã"
INC HL                 ;2204   23            #
LD (HL),D              ;2205   72            r
INC HL                 ;2206   23            #
PUSH HL                ;2207   E5            å
CALL 163DH             ;2208   CD 3D 16      Í=
POP DE                 ;220B   D1            Ñ
XOR A                  ;220C   AF            ¯
SBC HL,DE              ;220D   ED 52         íR
LD B,H                 ;220F   44            D
LD C,L                 ;2210   4D            M
CALL 1766H             ;2211   CD 66 17      Íf
CALL 1651H             ;2214   CD 51 16      ÍQ
CALL 189CH             ;2217   CD 9C 18      Í
POP BC                 ;221A   C1            Á
POP HL                 ;221B   E1            á
CALL 1796H             ;221C   CD 96 17      Í
CALL 189CH             ;221F   CD 9C 18      Í
POP HL                 ;2222   E1            á
JP 19B5H               ;2223   C3 B5 19      Ãµ
CALL 1829H             ;2226   CD 29 18      Í)
JP Z,19B5H             ;2229   CA B5 19      Êµ
CALL 22AFH             ;222C   CD AF 22      Í¯"
CALL 1829H             ;222F   CD 29 18      Í)
JR Z,2235H             ;2232   28 01         (
INC HL                 ;2234   23            #
PUSH HL                ;2235   E5            å
CALL 180FH             ;2236   CD 0F 18      Í
CALL 1801H             ;2239   CD 01 18      Í
CALL 0030H             ;223C   CD 30 00      Í0
JP C,1385H             ;223F   DA 85 13      Ú
POP HL                 ;2242   E1            á
JP 2226H               ;2243   C3 26 22      Ã&"
CALL 19A9H             ;2246   CD A9 19      Í©
LD A,E                 ;2249   7B            {
DEC A                  ;224A   3D            =
CP 07H                 ;224B   FE 07         þ
JP NC,1398H            ;224D   D2 98 13      Ò
INC A                  ;2250   3C            <
CALL 0041H             ;2251   CD 41 00      ÍA
JP 1B27H               ;2254   C3 27 1B      Ã'
INC HL                 ;2257   23            #
CALL 22AFH             ;2258   CD AF 22      Í¯"
CP B0H                 ;225B   FE B0         þ°
RET C                  ;225D   D8            Ø
CP BCH                 ;225E   FE BC         þ¼
RET NC                 ;2260   D0            Ð
EX AF,AF'              ;2261   08            
LD A,D                 ;2262   7A            z
OR A                   ;2263   B7            ·
JP NZ,2272H            ;2264   C2 72 22      Âr"
EX AF,AF'              ;2267   08            
EXX                    ;2268   D9            Ù
LD BC,225BH            ;2269   01 5B 22      ["
LD DE,22AEH            ;226C   11 AE 22      ®"
JP 2339H               ;226F   C3 39 23      Ã9#
EX AF,AF'              ;2272   08            
CP B6H                 ;2273   FE B6         þ¶
JP NZ,138EH            ;2275   C2 8E 13      Â
LD A,C                 ;2278   79            y
PUSH DE                ;2279   D5            Õ
PUSH AF                ;227A   F5            õ
CALL 22AEH             ;227B   CD AE 22      Í®"
CALL 180FH             ;227E   CD 0F 18      Í
POP AF                 ;2281   F1            ñ
EX (SP),HL             ;2282   E3            ã
LD B,A                 ;2283   47            G
SUB C                  ;2284   91            
JP NZ,22A1H            ;2285   C2 A1 22      Â¡"
OR B                   ;2288   B0            °
JP Z,229CH             ;2289   CA 9C 22      Ê"
CALL 1801H             ;228C   CD 01 18      Í
EX DE,HL               ;228F   EB            ë
CALL 1801H             ;2290   CD 01 18      Í
LD A,(DE)              ;2293   1A            
CP (HL)                ;2294   BE            ¾
INC HL                 ;2295   23            #
INC DE                 ;2296   13            
JP NZ,22A1H            ;2297   C2 A1 22      Â¡"
DJNZ 2293H             ;229A   10 F7         ÷
LD DE,161EH            ;229C   11 1E 16      
JR Z,22A4H             ;229F   28 03         (
LD DE,1619H            ;22A1   11 19 16      
CALL 181AH             ;22A4   CD 1A 18      Í
POP HL                 ;22A7   E1            á
CALL 237BH             ;22A8   CD 7B 23      Í{#
JP 225BH               ;22AB   C3 5B 22      Ã["
INC HL                 ;22AE   23            #
LD A,(HL)              ;22AF   7E            ~
CP 20H                 ;22B0   FE 20         þ 
JR Z,22AEH             ;22B2   28 FA         (ú
CP BCH                 ;22B4   FE BC         þ¼
JP Z,22C7H             ;22B6   CA C7 22      ÊÇ"
CP BDH                 ;22B9   FE BD         þ½
JP NZ,22C8H            ;22BB   C2 C8 22      ÂÈ"
CALL 2315H             ;22BE   CD 15 23      Í#
CALL 2393H             ;22C1   CD 93 23      Í#
JP 22CBH               ;22C4   C3 CB 22      ÃË"
INC HL                 ;22C7   23            #
CALL 2316H             ;22C8   CD 16 23      Í#
CP BCH                 ;22CB   FE BC         þ¼
RET C                  ;22CD   D8            Ø
CP BEH                 ;22CE   FE BE         þ¾
RET NC                 ;22D0   D0            Ð
EX AF,AF'              ;22D1   08            
LD A,D                 ;22D2   7A            z
OR A                   ;22D3   B7            ·
JP NZ,22E2H            ;22D4   C2 E2 22      Ââ"
EX AF,AF'              ;22D7   08            
EXX                    ;22D8   D9            Ù
LD BC,22CBH            ;22D9   01 CB 22      Ë"
LD DE,2315H            ;22DC   11 15 23      #
JP 2339H               ;22DF   C3 39 23      Ã9#
EX AF,AF'              ;22E2   08            
CP BCH                 ;22E3   FE BC         þ¼
JP NZ,138EH            ;22E5   C2 8E 13      Â
PUSH DE                ;22E8   D5            Õ
PUSH BC                ;22E9   C5            Å
CALL 2315H             ;22EA   CD 15 23      Í#
CALL 180FH             ;22ED   CD 0F 18      Í
LD A,C                 ;22F0   79            y
EXX                    ;22F1   D9            Ù
POP BC                 ;22F2   C1            Á
POP DE                 ;22F3   D1            Ñ
ADD A,C                ;22F4   81            
JP C,1398H             ;22F5   DA 98 13      Ú
LD H,B                 ;22F8   60            `
LD L,A                 ;22F9   6F            o
PUSH HL                ;22FA   E5            å
EXX                    ;22FB   D9            Ù
PUSH HL                ;22FC   E5            å
PUSH DE                ;22FD   D5            Õ
EXX                    ;22FE   D9            Ù
POP HL                 ;22FF   E1            á
PUSH HL                ;2300   E5            å
CALL 1801H             ;2301   CD 01 18      Í
EX DE,HL               ;2304   EB            ë
CALL 1801H             ;2305   CD 01 18      Í
CALL 1796H             ;2308   CD 96 17      Í
CALL 189CH             ;230B   CD 9C 18      Í
POP DE                 ;230E   D1            Ñ
POP HL                 ;230F   E1            á
POP BC                 ;2310   C1            Á
LD A,(HL)              ;2311   7E            ~
JP 22CBH               ;2312   C3 CB 22      ÃË"
INC HL                 ;2315   23            #
CALL 232AH             ;2316   CD 2A 23      Í*#
CP BEH                 ;2319   FE BE         þ¾
RET C                  ;231B   D8            Ø
CP C0H                 ;231C   FE C0         þÀ
RET NC                 ;231E   D0            Ð
EXX                    ;231F   D9            Ù
LD BC,2319H            ;2320   01 19 23      #
LD DE,2329H            ;2323   11 29 23      )#
JP 2339H               ;2326   C3 39 23      Ã9#
INC HL                 ;2329   23            #
CALL 2383H             ;232A   CD 83 23      Í#
CP CFH                 ;232D   FE CF         þÏ
RET NZ                 ;232F   C0            À
LD A,C0H               ;2330   3E C0         >À
EXX                    ;2332   D9            Ù
LD BC,232DH            ;2333   01 2D 23      -#
LD DE,2382H            ;2336   11 82 23      #
PUSH BC                ;2339   C5            Å
LD HL,(4644H)          ;233A   2A 44 46      *DF
LD BC,0005H            ;233D   01 05 00      
ADD HL,BC              ;2340   09            	
LD (4644H),HL          ;2341   22 44 46      "DF
SUB B0H                ;2344   D6 B0         Ö°
ADD A,A                ;2346   87            
LD HL,2628H            ;2347   21 28 26      !(&
LD C,A                 ;234A   4F            O
ADD HL,BC              ;234B   09            	
LD C,(HL)              ;234C   4E            N
INC HL                 ;234D   23            #
LD B,(HL)              ;234E   46            F
PUSH BC                ;234F   C5            Å
LD HL,235CH            ;2350   21 5C 23      !\#
PUSH HL                ;2353   E5            å
PUSH DE                ;2354   D5            Õ
EXX                    ;2355   D9            Ù
LD A,D                 ;2356   7A            z
OR A                   ;2357   B7            ·
RET Z                  ;2358   C8            È
JP 139DH               ;2359   C3 9D 13      Ã
LD A,D                 ;235C   7A            z
OR A                   ;235D   B7            ·
JP NZ,139DH            ;235E   C2 9D 13      Â
POP IY                 ;2361   FD E1         ýá
PUSH HL                ;2363   E5            å
LD HL,(4644H)          ;2364   2A 44 46      *DF
LD BC,FFFBH            ;2367   01 FB FF      ûÿ
LD E,L                 ;236A   5D            ]
LD D,H                 ;236B   54            T
ADD HL,BC              ;236C   09            	
LD (4644H),HL          ;236D   22 44 46      "DF
EX DE,HL               ;2370   EB            ë
LD BC,237AH            ;2371   01 7A 23      z#
PUSH BC                ;2374   C5            Å
JP (IY)                ;2375   FD E9         ýé
CALL 181AH             ;2377   CD 1A 18      Í
POP HL                 ;237A   E1            á
LD BC,0005H            ;237B   01 05 00      
LD D,B                 ;237E   50            P
LD E,B                 ;237F   58            X
LD A,(HL)              ;2380   7E            ~
RET                    ;2381   C9            É
INC HL                 ;2382   23            #
CALL 162DH             ;2383   CD 2D 16      Í-
CP BCH                 ;2386   FE BC         þ¼
JP Z,23A8H             ;2388   CA A8 23      Ê¨#
CP BDH                 ;238B   FE BD         þ½
JP NZ,23A9H            ;238D   C2 A9 23      Â©#
CALL 23A8H             ;2390   CD A8 23      Í¨#
EXX                    ;2393   D9            Ù
LD HL,(4644H)          ;2394   2A 44 46      *DF
PUSH HL                ;2397   E5            å
LD BC,0004H            ;2398   01 04 00      
ADD HL,BC              ;239B   09            	
LD A,(HL)              ;239C   7E            ~
POP HL                 ;239D   E1            á
OR A                   ;239E   B7            ·
JR Z,23A5H             ;239F   28 04         (
LD A,(HL)              ;23A1   7E            ~
ADD A,80H              ;23A2   C6 80         Æ
LD (HL),A              ;23A4   77            w
EXX                    ;23A5   D9            Ù
LD A,(HL)              ;23A6   7E            ~
RET                    ;23A7   C9            É
INC HL                 ;23A8   23            #
CALL 25CDH             ;23A9   CD CD 25      ÍÍ%
JP NC,23CCH            ;23AC   D2 CC 23      ÒÌ#
LD A,46H               ;23AF   3E 46         >F
CP E                   ;23B1   BB            »
JR NZ,23BAH            ;23B2   20 06          
LD A,4EH               ;23B4   3E 4E         >N
CP D                   ;23B6   BA            º
JP Z,2476H             ;23B7   CA 76 24      Êv$
CALL 2436H             ;23BA   CD 36 24      Í6$
PUSH HL                ;23BD   E5            å
LD A,B                 ;23BE   78            x
OR A                   ;23BF   B7            ·
JP Z,2377H             ;23C0   CA 77 23      Êw#
EX DE,HL               ;23C3   EB            ë
LD B,00H               ;23C4   06 00         
CALL 18DFH             ;23C6   CD DF 18      Íß
POP HL                 ;23C9   E1            á
LD A,(HL)              ;23CA   7E            ~
RET                    ;23CB   C9            É
CP 28H                 ;23CC   FE 28         þ(
JP Z,23F2H             ;23CE   CA F2 23      Êò#
CP 22H                 ;23D1   FE 22         þ"
JP Z,18C4H             ;23D3   CA C4 18      ÊÄ
CALL 193DH             ;23D6   CD 3D 19      Í=
JP NZ,23E3H            ;23D9   C2 E3 23      Âã#
LD DE,(4644H)          ;23DC   ED 5B 44 46   í[DF
JP 2FD9H               ;23E0   C3 D9 2F      ÃÙ/
CP FFH                 ;23E3   FE FF         þÿ
JP NZ,2400H            ;23E5   C2 00 24      Â$
CALL 162CH             ;23E8   CD 2C 16      Í,
PUSH HL                ;23EB   E5            å
LD DE,1623H            ;23EC   11 23 16      #
JP 2377H               ;23EF   C3 77 23      Ãw#
LD BC,0000H            ;23F2   01 00 00      
CALL 1752H             ;23F5   CD 52 17      ÍR
CALL 2257H             ;23F8   CD 57 22      ÍW"
CALL 169AH             ;23FB   CD 9A 16      Í
ADD HL,HL              ;23FE   29            )
RET                    ;23FF   C9            É
SUB C0H                ;2400   D6 C0         ÖÀ
CP 0FH                 ;2402   FE 0F         þ
JP NC,240DH            ;2404   D2 0D 24      Ò
$
LD DE,264AH            ;2407   11 4A 26      J&
JP 1A12H               ;240A   C3 12 1A      Ã
SUB 10H                ;240D   D6 10         Ö
CP 0FH                 ;240F   FE 0F         þ
JP NC,138EH            ;2411   D2 8E 13      Ò
PUSH AF                ;2414   F5            õ
CALL 22AEH             ;2415   CD AE 22      Í®"
CALL 1814H             ;2418   CD 14 18      Í
CALL 169AH             ;241B   CD 9A 16      Í
ADD HL,HL              ;241E   29            )
POP AF                 ;241F   F1            ñ
PUSH HL                ;2420   E5            å
LD HL,237AH            ;2421   21 7A 23      !z#
PUSH HL                ;2424   E5            å
LD HL,(4644H)          ;2425   2A 44 46      *DF
EX DE,HL               ;2428   EB            ë
LD HL,2662H            ;2429   21 62 26      !b&
ADD A,A                ;242C   87            
LD C,A                 ;242D   4F            O
LD B,00H               ;242E   06 00         
ADD HL,BC              ;2430   09            	
LD A,(HL)              ;2431   7E            ~
INC HL                 ;2432   23            #
LD H,(HL)              ;2433   66            f
LD L,A                 ;2434   6F            o
JP (HL)                ;2435   E9            é
LD A,(HL)              ;2436   7E            ~
CP 24H                 ;2437   FE 24         þ$
JP Z,24F7H             ;2439   CA F7 24      Ê÷$
CP 28H                 ;243C   FE 28         þ(
JP Z,2585H             ;243E   CA 85 25      Ê%
PUSH HL                ;2441   E5            å
LD HL,(4640H)          ;2442   2A 40 46      *@F
LD BC,0005H            ;2445   01 05 00      
LD A,(HL)              ;2448   7E            ~
CP E                   ;2449   BB            »
INC HL                 ;244A   23            #
JR NZ,2452H            ;244B   20 05          
LD A,(HL)              ;244D   7E            ~
CP D                   ;244E   BA            º
JP Z,2471H             ;244F   CA 71 24      Êq$
OR A                   ;2452   B7            ·
JR Z,245AH             ;2453   28 05         (
INC HL                 ;2455   23            #
ADD HL,BC              ;2456   09            	
JP 2448H               ;2457   C3 48 24      ÃH$
LD C,07H               ;245A   0E 07         
DEC HL                 ;245C   2B            +
PUSH DE                ;245D   D5            Õ
EX DE,HL               ;245E   EB            ë
LD HL,1619H            ;245F   21 19 16      !
DEC HL                 ;2462   2B            +
DEC HL                 ;2463   2B            +
CALL 1796H             ;2464   CD 96 17      Í
CALL 189CH             ;2467   CD 9C 18      Í
EX DE,HL               ;246A   EB            ë
POP DE                 ;246B   D1            Ñ
LD (HL),E              ;246C   73            s
INC HL                 ;246D   23            #
LD (HL),D              ;246E   72            r
LD C,05H               ;246F   0E 05         
INC HL                 ;2471   23            #
EX DE,HL               ;2472   EB            ë
POP HL                 ;2473   E1            á
LD A,(HL)              ;2474   7E            ~
RET                    ;2475   C9            É
LD A,(HL)              ;2476   7E            ~
SUB 41H                ;2477   D6 41         ÖA
CP 1AH                 ;2479   FE 1A         þ
JP NC,138EH            ;247B   D2 8E 13      Ò
LD E,(HL)              ;247E   5E            ^
INC HL                 ;247F   23            #
CALL 169AH             ;2480   CD 9A 16      Í
JR Z,245AH             ;2483   28 D5         (Õ
CALL 22AFH             ;2485   CD AF 22      Í¯"
CALL 1814H             ;2488   CD 14 18      Í
CALL 169AH             ;248B   CD 9A 16      Í
ADD HL,HL              ;248E   29            )
POP DE                 ;248F   D1            Ñ
PUSH HL                ;2490   E5            å
LD HL,(4634H)          ;2491   2A 34 46      *4F
LD A,(HL)              ;2494   7E            ~
CP 00H                 ;2495   FE 00         þ
JP Z,138EH             ;2497   CA 8E 13      Ê
CP E                   ;249A   BB            »
JR Z,24A4H             ;249B   28 07         (
INC HL                 ;249D   23            #
INC HL                 ;249E   23            #
CALL 1633H             ;249F   CD 33 16      Í3
JR 2494H               ;24A2   18 F0         ð
INC HL                 ;24A4   23            #
LD E,(HL)              ;24A5   5E            ^
INC HL                 ;24A6   23            #
PUSH HL                ;24A7   E5            å
PUSH DE                ;24A8   D5            Õ
LD D,20H               ;24A9   16 20          
CALL 2441H             ;24AB   CD 41 24      ÍA$
POP HL                 ;24AE   E1            á
PUSH DE                ;24AF   D5            Õ
PUSH HL                ;24B0   E5            å
LD HL,(4646H)          ;24B1   2A 46 46      *FF
LD DE,464CH            ;24B4   11 4C 46      LF
CALL 1662H             ;24B7   CD 62 16      Íb
JP Z,13ACH             ;24BA   CA AC 13      Ê¬
LD BC,FFFAH            ;24BD   01 FA FF      úÿ
ADD HL,BC              ;24C0   09            	
LD (4646H),HL          ;24C1   22 46 46      "FF
POP DE                 ;24C4   D1            Ñ
LD (HL),E              ;24C5   73            s
INC HL                 ;24C6   23            #
POP DE                 ;24C7   D1            Ñ
LD BC,0005H            ;24C8   01 05 00      
EX DE,HL               ;24CB   EB            ë
CALL 1799H             ;24CC   CD 99 17      Í
EX DE,HL               ;24CF   EB            ë
LD HL,(4644H)          ;24D0   2A 44 46      *DF
CALL 1799H             ;24D3   CD 99 17      Í
POP HL                 ;24D6   E1            á
CALL 22AFH             ;24D7   CD AF 22      Í¯"
CALL 1814H             ;24DA   CD 14 18      Í
CALL 1829H             ;24DD   CD 29 18      Í)
JP NZ,138EH            ;24E0   C2 8E 13      Â
LD HL,(4646H)          ;24E3   2A 46 46      *FF
LD E,(HL)              ;24E6   5E            ^
INC HL                 ;24E7   23            #
LD D,20H               ;24E8   16 20          
CALL 2441H             ;24EA   CD 41 24      ÍA$
CALL 1799H             ;24ED   CD 99 17      Í
ADD HL,BC              ;24F0   09            	
LD (4646H),HL          ;24F1   22 46 46      "FF
JP 237AH               ;24F4   C3 7A 23      Ãz#
CALL 162CH             ;24F7   CD 2C 16      Í,
CP 28H                 ;24FA   FE 28         þ(
JP Z,2580H             ;24FC   CA 80 25      Ê%
PUSH HL                ;24FF   E5            å
LD HL,4954H            ;2500   21 54 49      !TI
XOR A                  ;2503   AF            ¯
SBC HL,DE              ;2504   ED 52         íR
JP Z,2539H             ;2506   CA 39 25      Ê9%
EX DE,HL               ;2509   EB            ë
LD (4630H),HL          ;250A   22 30 46      "0F
LD HL,(463AH)          ;250D   2A 3A 46      *:F
CALL 17C4H             ;2510   CD C4 17      ÍÄ
LD E,25H               ;2513   1E 25         %
JP Z,2530H             ;2515   CA 30 25      Ê0%
CALL 1633H             ;2518   CD 33 16      Í3
JP 2510H               ;251B   C3 10 25      Ã%
LD BC,0003H            ;251E   01 03 00      
EX DE,HL               ;2521   EB            ë
LD HL,4630H            ;2522   21 30 46      !0F
CALL 1796H             ;2525   CD 96 17      Í
CALL 189CH             ;2528   CD 9C 18      Í
EX DE,HL               ;252B   EB            ë
INC HL                 ;252C   23            #
INC HL                 ;252D   23            #
LD (HL),0DH            ;252E   36 0D         6
CALL 17F3H             ;2530   CD F3 17      Íó
EX DE,HL               ;2533   EB            ë
LD B,01H               ;2534   06 01         
POP HL                 ;2536   E1            á
LD A,(HL)              ;2537   7E            ~
RET                    ;2538   C9            É
CALL 003BH             ;2539   CD 3B 00      Í;
EX DE,HL               ;253C   EB            ë
OR A                   ;253D   B7            ·
JR Z,2542H             ;253E   28 02         (
LD A,0CH               ;2540   3E 0C         >
EXX                    ;2542   D9            Ù
LD HL,4559H            ;2543   21 59 45      !YE
PUSH HL                ;2546   E5            å
EXX                    ;2547   D9            Ù
LD DE,F1F0H            ;2548   11 F0 F1      ðñ
CALL 2560H             ;254B   CD 60 25      Í`%
LD DE,FFC4H            ;254E   11 C4 FF      Äÿ
CALL 255FH             ;2551   CD 5F 25      Í_%
LD A,L                 ;2554   7D            }
CALL 2569H             ;2555   CD 69 25      Íi%
POP DE                 ;2558   D1            Ñ
LD BC,0106H            ;2559   01 06 01      
POP HL                 ;255C   E1            á
LD A,(HL)              ;255D   7E            ~
RET                    ;255E   C9            É
XOR A                  ;255F   AF            ¯
ADD HL,DE              ;2560   19            
JR NC,2566H            ;2561   30 03         0
INC A                  ;2563   3C            <
JR 2560H               ;2564   18 FA         ú
OR A                   ;2566   B7            ·
SBC HL,DE              ;2567   ED 52         íR
LD BC,30F6H            ;2569   01 F6 30      ö0
ADD A,C                ;256C   81            
JR NC,2572H            ;256D   30 03         0
INC B                  ;256F   04            
JR 256CH               ;2570   18 FA         ú
ADD A,3AH              ;2572   C6 3A         Æ:
EX AF,AF'              ;2574   08            
LD A,B                 ;2575   78            x
EXX                    ;2576   D9            Ù
LD (HL),A              ;2577   77            w
INC HL                 ;2578   23            #
EX AF,AF'              ;2579   08            
LD (HL),A              ;257A   77            w
INC HL                 ;257B   23            #
LD (HL),0DH            ;257C   36 0D         6
EXX                    ;257E   D9            Ù
RET                    ;257F   C9            É
LD BC,0100H            ;2580   01 00 01      
JR 2588H               ;2583   18 03         
LD BC,0000H            ;2585   01 00 00      
INC HL                 ;2588   23            #
CALL 20D9H             ;2589   CD D9 20      ÍÙ 
JP Z,138EH             ;258C   CA 8E 13      Ê
PUSH HL                ;258F   E5            å
LD L,C                 ;2590   69            i
LD H,00H               ;2591   26 00         &
LD C,E                 ;2593   4B            K
LD E,D                 ;2594   5A            Z
LD B,H                 ;2595   44            D
LD D,H                 ;2596   54            T
PUSH BC                ;2597   C5            Å
INC HL                 ;2598   23            #
CALL 16C8H             ;2599   CD C8 16      ÍÈ
POP HL                 ;259C   E1            á
ADD HL,DE              ;259D   19            
EX DE,HL               ;259E   EB            ë
LD A,(20D6H)           ;259F   3A D6 20      :Ö 
OR A                   ;25A2   B7            ·
JP NZ,25B5H            ;25A3   C2 B5 25      Âµ%
LD HL,0005H            ;25A6   21 05 00      !
CALL 16C8H             ;25A9   CD C8 16      ÍÈ
POP HL                 ;25AC   E1            á
ADD HL,DE              ;25AD   19            
EX DE,HL               ;25AE   EB            ë
LD BC,0005H            ;25AF   01 05 00      
JP 25C7H               ;25B2   C3 C7 25      ÃÇ%
POP HL                 ;25B5   E1            á
LD A,D                 ;25B6   7A            z
OR E                   ;25B7   B3            ³
JP Z,25C1H             ;25B8   CA C1 25      ÊÁ%
DEC DE                 ;25BB   1B            
CALL 1633H             ;25BC   CD 33 16      Í3
JR 25B6H               ;25BF   18 F5         õ
CALL 17F3H             ;25C1   CD F3 17      Íó
EX DE,HL               ;25C4   EB            ë
LD B,01H               ;25C5   06 01         
LD HL,(20D4H)          ;25C7   2A D4 20      *Ô 
LD A,(HL)              ;25CA   7E            ~
RET                    ;25CB   C9            É
INC HL                 ;25CC   23            #
LD A,(HL)              ;25CD   7E            ~
CP 20H                 ;25CE   FE 20         þ 
JR Z,25CCH             ;25D0   28 FA         (ú
SUB 41H                ;25D2   D6 41         ÖA
CP 1AH                 ;25D4   FE 1A         þ
LD A,(HL)              ;25D6   7E            ~
RET NC                 ;25D7   D0            Ð
LD E,(HL)              ;25D8   5E            ^
LD D,20H               ;25D9   16 20          
INC HL                 ;25DB   23            #
LD A,(HL)              ;25DC   7E            ~
CP D                   ;25DD   BA            º
JR Z,25DBH             ;25DE   28 FB         (û
SUB 30H                ;25E0   D6 30         Ö0
CP 0AH                 ;25E2   FE 0A         þ

JR C,25EDH             ;25E4   38 07         8
SUB 11H                ;25E6   D6 11         Ö
CP 1AH                 ;25E8   FE 1A         þ
LD A,(HL)              ;25EA   7E            ~
CCF                    ;25EB   3F            ?
RET C                  ;25EC   D8            Ø
LD D,(HL)              ;25ED   56            V
LD A,46H               ;25EE   3E 46         >F
CP E                   ;25F0   BB            »
JR NZ,25F9H            ;25F1   20 06          
LD A,4EH               ;25F3   3E 4E         >N
CP D                   ;25F5   BA            º
JP Z,260EH             ;25F6   CA 0E 26      Ê&
INC HL                 ;25F9   23            #
LD A,(HL)              ;25FA   7E            ~
CP 20H                 ;25FB   FE 20         þ 
JR Z,25F9H             ;25FD   28 FA         (ú
SUB 30H                ;25FF   D6 30         Ö0
CP 0AH                 ;2601   FE 0A         þ

JR C,25F9H             ;2603   38 F4         8ô
SUB 11H                ;2605   D6 11         Ö
CP 1AH                 ;2607   FE 1A         þ
JR C,25F9H             ;2609   38 EE         8î
LD A,(HL)              ;260B   7E            ~
SCF                    ;260C   37            7
RET                    ;260D   C9            É
CALL 162CH             ;260E   CD 2C 16      Í,
SCF                    ;2611   37            7
RET                    ;2612   C9            É
CALL 25CDH             ;2613   CD CD 25      ÍÍ%
JP NC,138EH            ;2616   D2 8E 13      Ò
LD A,46H               ;2619   3E 46         >F
CP E                   ;261B   BB            »
JP NZ,260BH            ;261C   C2 0B 26      Â&
LD A,4EH               ;261F   3E 4E         >N
CP D                   ;2621   BA            º
JP NZ,260BH            ;2622   C2 0B 26      Â&
JP 138EH               ;2625   C3 8E 13      Ã
POP AF                 ;2628   F1            ñ
INC (HL)               ;2629   34            4
POP AF                 ;262A   F1            ñ
INC (HL)               ;262B   34            4
INC E                  ;262C   1C            
DEC (HL)               ;262D   35            5
INC E                  ;262E   1C            
DEC (HL)               ;262F   35            5
JR NZ,2667H            ;2630   20 35          5
JR NZ,2669H            ;2632   20 35          5
LD (DE),A              ;2634   12            
DEC (HL)               ;2635   35            5
INC B                  ;2636   04            
DEC (HL)               ;2637   35            5
EX AF,AF'              ;2638   08            
DEC (HL)               ;2639   35            5
DEC BC                 ;263A   0B            
DAA                    ;263B   27            '
LD C,27H               ;263C   0E 27         '
LD DE,4D27H            ;263E   11 27 4D      'M
DEC L                  ;2641   2D            -
LD C,D                 ;2642   4A            J
DEC L                  ;2643   2D            -
LD E,C                 ;2644   59            Y
LD L,30H               ;2645   2E 30         .0
CPL                    ;2647   2F            /
DEC BC                 ;2648   0B            
DEC SP                 ;2649   3B            ;
LD A,D                 ;264A   7A            z
LD H,ACH               ;264B   26 AC         &¬
LD H,D0H               ;264D   26 D0         &Ð
LD H,14H               ;264F   26 14         &
DAA                    ;2651   27            '
INC HL                 ;2652   23            #
DAA                    ;2653   27            '
DEC A                  ;2654   3D            =
DAA                    ;2655   27            '
HALT                   ;2656   76            v
DAA                    ;2657   27            '
LD E,C                 ;2658   59            Y
DAA                    ;2659   27            '
CP B                   ;265A   B8            ¸
DAA                    ;265B   27            '
EXX                    ;265C   D9            Ù
DAA                    ;265D   27            '
LD BC,2728H            ;265E   01 28 27      ('
JR Z,2692H             ;2661   28 2F         (/
DEC (HL)               ;2663   35            5
OR B                   ;2664   B0            °
DEC (HL)               ;2665   35            5
AND D                  ;2666   A2            ¢
LD (HL),B1H            ;2667   36 B1         6±
LD (HL),25H            ;2669   36 25         6%
LD A,(37A6H)           ;266B   3A A6 37      :¦7
LD C,34H               ;266E   0E 34         4
INC DE                 ;2670   13            
LD A,(38DFH)           ;2671   3A DF 38      :ß8
ADD HL,SP              ;2674   39            9
JR Z,26B5H             ;2675   28 3E         (>
JR Z,2655H             ;2677   28 DC         (Ü
LD (HL),CDH            ;2679   36 CD         6Í
XOR A                  ;267B   AF            ¯
LD (0FCDH),HL          ;267C   22 CD 0F      "Í
JR 2656H               ;267F   18 D5         Õ
PUSH BC                ;2681   C5            Å
CALL 169AH             ;2682   CD 9A 16      Í
INC L                  ;2685   2C            ,
CALL 19A9H             ;2686   CD A9 19      Í©
CALL 169AH             ;2689   CD 9A 16      Í
ADD HL,HL              ;268C   29            )
POP BC                 ;268D   C1            Á
EX (SP),HL             ;268E   E3            ã
EX DE,HL               ;268F   EB            ë
LD A,C                 ;2690   79            y
SUB L                  ;2691   95            
JP C,26A8H             ;2692   DA A8 26      Ú¨&
PUSH HL                ;2695   E5            å
LD C,A                 ;2696   4F            O
PUSH DE                ;2697   D5            Õ
CALL 1801H             ;2698   CD 01 18      Í
ADD HL,DE              ;269B   19            
EX DE,HL               ;269C   EB            ë
CALL 1766H             ;269D   CD 66 17      Íf
CALL 1651H             ;26A0   CD 51 16      ÍQ
CALL 189CH             ;26A3   CD 9C 18      Í
POP DE                 ;26A6   D1            Ñ
POP BC                 ;26A7   C1            Á
POP HL                 ;26A8   E1            á
JP 162DH               ;26A9   C3 2D 16      Ã-
CALL 22AFH             ;26AC   CD AF 22      Í¯"
CALL 180FH             ;26AF   CD 0F 18      Í
PUSH DE                ;26B2   D5            Õ
PUSH BC                ;26B3   C5            Å
CALL 169AH             ;26B4   CD 9A 16      Í
INC L                  ;26B7   2C            ,
CALL 19A9H             ;26B8   CD A9 19      Í©
CALL 169AH             ;26BB   CD 9A 16      Í
ADD HL,HL              ;26BE   29            )
POP BC                 ;26BF   C1            Á
EX (SP),HL             ;26C0   E3            ã
EX DE,HL               ;26C1   EB            ë
LD A,C                 ;26C2   79            y
SUB L                  ;26C3   95            
JP C,26A8H             ;26C4   DA A8 26      Ú¨&
PUSH HL                ;26C7   E5            å
LD C,A                 ;26C8   4F            O
PUSH DE                ;26C9   D5            Õ
CALL 1801H             ;26CA   CD 01 18      Í
JP 269DH               ;26CD   C3 9D 26      Ã&
CALL 22AFH             ;26D0   CD AF 22      Í¯"
CALL 180FH             ;26D3   CD 0F 18      Í
PUSH DE                ;26D6   D5            Õ
PUSH BC                ;26D7   C5            Å
CALL 169AH             ;26D8   CD 9A 16      Í
INC L                  ;26DB   2C            ,
CALL 19A9H             ;26DC   CD A9 19      Í©
LD A,E                 ;26DF   7B            {
DEC A                  ;26E0   3D            =
JP Z,2708H             ;26E1   CA 08 27      Ê'
JP C,2708H             ;26E4   DA 08 27      Ú'
POP BC                 ;26E7   C1            Á
LD E,A                 ;26E8   5F            _
LD A,C                 ;26E9   79            y
SUB E                  ;26EA   93            
JP NC,26F0H            ;26EB   D2 F0 26      Òð&
XOR A                  ;26EE   AF            ¯
LD E,C                 ;26EF   59            Y
LD C,E                 ;26F0   4B            K
LD B,D                 ;26F1   42            B
POP DE                 ;26F2   D1            Ñ
PUSH DE                ;26F3   D5            Õ
PUSH AF                ;26F4   F5            õ
PUSH BC                ;26F5   C5            Å
CALL 1801H             ;26F6   CD 01 18      Í
POP BC                 ;26F9   C1            Á
CALL 1766H             ;26FA   CD 66 17      Íf
CALL 1651H             ;26FD   CD 51 16      ÍQ
CALL 189CH             ;2700   CD 9C 18      Í
POP AF                 ;2703   F1            ñ
LD C,A                 ;2704   4F            O
LD B,00H               ;2705   06 00         
PUSH BC                ;2707   C5            Å
JP 2682H               ;2708   C3 82 26      Ã&
JP 138EH               ;270B   C3 8E 13      Ã
JP 138EH               ;270E   C3 8E 13      Ã
JP 138EH               ;2711   C3 8E 13      Ã
CALL 22AFH             ;2714   CD AF 22      Í¯"
CALL 180FH             ;2717   CD 0F 18      Í
CALL 169AH             ;271A   CD 9A 16      Í
ADD HL,HL              ;271D   29            )
PUSH HL                ;271E   E5            å
LD A,C                 ;271F   79            y
JP 278AH               ;2720   C3 8A 27      Ã'
CALL 19A9H             ;2723   CD A9 19      Í©
CALL 169AH             ;2726   CD 9A 16      Í
ADD HL,HL              ;2729   29            )
PUSH HL                ;272A   E5            å
LD A,E                 ;272B   7B            {
CP 20H                 ;272C   FE 20         þ 
JR NC,2732H            ;272E   30 02         0
LD E,0DH               ;2730   1E 0D         
LD HL,4400H            ;2732   21 00 44      !D
PUSH HL                ;2735   E5            å
LD (HL),E              ;2736   73            s
INC HL                 ;2737   23            #
LD (HL),0DH            ;2738   36 0D         6
JP 2752H               ;273A   C3 52 27      ÃR'
CALL 22AFH             ;273D   CD AF 22      Í¯"
CALL 1814H             ;2740   CD 14 18      Í
CALL 169AH             ;2743   CD 9A 16      Í
ADD HL,HL              ;2746   29            )
PUSH HL                ;2747   E5            å
LD HL,(4644H)          ;2748   2A 44 46      *DF
LD DE,4400H            ;274B   11 00 44      D
PUSH DE                ;274E   D5            Õ
CALL 322DH             ;274F   CD 2D 32      Í-2
POP HL                 ;2752   E1            á
CALL 18C4H             ;2753   CD C4 18      ÍÄ
POP HL                 ;2756   E1            á
LD A,(HL)              ;2757   7E            ~
RET                    ;2758   C9            É
CALL 22AFH             ;2759   CD AF 22      Í¯"
CALL 180FH             ;275C   CD 0F 18      Í
CALL 169AH             ;275F   CD 9A 16      Í
ADD HL,HL              ;2762   29            )
PUSH HL                ;2763   E5            å
CALL 1801H             ;2764   CD 01 18      Í
EX DE,HL               ;2767   EB            ë
CALL 190DH             ;2768   CD 0D 19      Í

LD (HL),B              ;276B   70            p
DAA                    ;276C   27            '
JP 26A8H               ;276D   C3 A8 26      Ã¨&
LD DE,1619H            ;2770   11 19 16      
JP 2377H               ;2773   C3 77 23      Ãw#
CALL 22AFH             ;2776   CD AF 22      Í¯"
CALL 180FH             ;2779   CD 0F 18      Í
CALL 169AH             ;277C   CD 9A 16      Í
ADD HL,HL              ;277F   29            )
PUSH HL                ;2780   E5            å
CALL 1801H             ;2781   CD 01 18      Í
LD A,(DE)              ;2784   1A            
CP 0DH                 ;2785   FE 0D         þ
JP Z,1398H             ;2787   CA 98 13      Ê
OR A                   ;278A   B7            ·
LD BC,8000H            ;278B   01 00 80      
CALL NZ,27A6H          ;278E   C4 A6 27      Ä¦'
LD HL,(4644H)          ;2791   2A 44 46      *DF
LD DE,0003H            ;2794   11 03 00      
LD (HL),B              ;2797   70            p
INC HL                 ;2798   23            #
LD (HL),D              ;2799   72            r
INC HL                 ;279A   23            #
DEC E                  ;279B   1D            
JR NZ,2799H            ;279C   20 FB          û
LD (HL),C              ;279E   71            q
LD BC,0005H            ;279F   01 05 00      
POP HL                 ;27A2   E1            á
JP 162DH               ;27A3   C3 2D 16      Ã-
LD E,08H               ;27A6   1E 08         
OR A                   ;27A8   B7            ·
JP M,27B1H             ;27A9   FA B1 27      ú±'
RLA                    ;27AC   17            
DEC E                  ;27AD   1D            
JP 27A8H               ;27AE   C3 A8 27      Ã¨'
LD C,A                 ;27B1   4F            O
LD A,C0H               ;27B2   3E C0         >À
ADD A,E                ;27B4   83            
LD B,A                 ;27B5   47            G
RET                    ;27B6   C9            É
NOP                    ;27B7   00            
CALL 198CH             ;27B8   CD 8C 19      Í
CALL 169AH             ;27BB   CD 9A 16      Í
ADD HL,HL              ;27BE   29            )
PUSH HL                ;27BF   E5            å
LD A,(27B7H)           ;27C0   3A B7 27      :·'
OR A                   ;27C3   B7            ·
JP NZ,27D1H            ;27C4   C2 D1 27      ÂÑ'
LD HL,(4563H)          ;27C7   2A 63 45      *cE
DEC HL                 ;27CA   2B            +
CALL 1662H             ;27CB   CD 62 16      Íb
JP NC,27D4H            ;27CE   D2 D4 27      ÒÔ'
LD A,(DE)              ;27D1   1A            
JR 27D6H               ;27D2   18 02         
LD A,20H               ;27D4   3E 20         > 
JP 278AH               ;27D6   C3 8A 27      Ã'
CALL 19A9H             ;27D9   CD A9 19      Í©
LD B,13H               ;27DC   06 13         
CALL 169AH             ;27DE   CD 9A 16      Í
ADD HL,HL              ;27E1   29            )
LD A,27H               ;27E2   3E 27         >'
ADD A,A                ;27E4   87            
SUB E                  ;27E5   93            
JP C,1398H             ;27E6   DA 98 13      Ú
LD A,(457DH)           ;27E9   3A 7D 45      :}E
OR A                   ;27EC   B7            ·
LD A,(1194H)           ;27ED   3A 94 11      :
JR Z,27F7H             ;27F0   28 05         (
LD B,20H               ;27F2   06 20          
LD A,(3D16H)           ;27F4   3A 16 3D      :=
LD D,A                 ;27F7   57            W
LD A,E                 ;27F8   7B            {
SUB D                  ;27F9   92            
JP NC,27FEH            ;27FA   D2 FE 27      Òþ'
XOR A                  ;27FD   AF            ¯
JP 280BH               ;27FE   C3 0B 28      Ã(
CALL 19A9H             ;2801   CD A9 19      Í©
LD B,20H               ;2804   06 20          
CALL 169AH             ;2806   CD 9A 16      Í
ADD HL,HL              ;2809   29            )
LD A,E                 ;280A   7B            {
PUSH HL                ;280B   E5            å
LD HL,4400H            ;280C   21 00 44      !D
PUSH HL                ;280F   E5            å
LD C,A                 ;2810   4F            O
OR A                   ;2811   B7            ·
JP Z,281BH             ;2812   CA 1B 28      Ê(
LD (HL),B              ;2815   70            p
INC HL                 ;2816   23            #
DEC A                  ;2817   3D            =
JP 2811H               ;2818   C3 11 28      Ã(
LD (HL),0DH            ;281B   36 0D         6
LD B,00H               ;281D   06 00         
POP HL                 ;281F   E1            á
CALL 18DFH             ;2820   CD DF 18      Íß
POP HL                 ;2823   E1            á
JP 162DH               ;2824   C3 2D 16      Ã-
PUSH HL                ;2827   E5            å
CALL 173CH             ;2828   CD 3C 17      Í<
LD DE,4400H            ;282B   11 00 44      D
PUSH DE                ;282E   D5            Õ
CALL 16F7H             ;282F   CD F7 16      Í÷
POP HL                 ;2832   E1            á
CALL 22AFH             ;2833   CD AF 22      Í¯"
POP HL                 ;2836   E1            á
LD A,(HL)              ;2837   7E            ~
RET                    ;2838   C9            É
LD A,(DE)              ;2839   1A            
OR 80H                 ;283A   F6 80         ö
LD (DE),A              ;283C   12            
RET                    ;283D   C9            É
LD A,(DE)              ;283E   1A            
LD DE,161EH            ;283F   11 1E 16      
OR A                   ;2842   B7            ·
JP P,2851H             ;2843   F2 51 28      òQ(
LD DE,1614H            ;2846   11 14 16      
CP 80H                 ;2849   FE 80         þ
JP NZ,2851H            ;284B   C2 51 28      ÂQ(
LD DE,1619H            ;284E   11 19 16      
JP 181AH               ;2851   C3 1A 18      Ã
JP 0000H               ;2854   C3 00 00      Ã
CALL 2613H             ;2857   CD 13 26      Í&
CALL 2436H             ;285A   CD 36 24      Í6$
LD (4801H),HL          ;285D   22 01 48      "H
CALL 197BH             ;2860   CD 7B 19      Í{
CALL 001BH             ;2863   CD 1B 00      Í
CP 1BH                 ;2866   FE 1B         þ
JP Z,124BH             ;2868   CA 4B 12      ÊK
LD HL,45A2H            ;286B   21 A2 45      !¢E
OR A                   ;286E   B7            ·
JP NZ,28A3H            ;286F   C2 A3 28      Â£(
LD (45A4H),A           ;2872   32 A4 45      2¤E
LD A,(4571H)           ;2875   3A 71 45      :qE
LD B,30H               ;2878   06 30         0
OR A                   ;287A   B7            ·
JP Z,2880H             ;287B   CA 80 28      Ê(
LD B,0DH               ;287E   06 0D         
LD (HL),B              ;2880   70            p
INC HL                 ;2881   23            #
LD (HL),0DH            ;2882   36 0D         6
DEC HL                 ;2884   2B            +
CALL 18C7H             ;2885   CD C7 18      ÍÇ
LD A,(4571H)           ;2888   3A 71 45      :qE
OR A                   ;288B   B7            ·
JP NZ,2898H            ;288C   C2 98 28      Â(
CALL 1801H             ;288F   CD 01 18      Í
EX DE,HL               ;2892   EB            ë
CALL 190DH             ;2893   CD 0D 19      Í

OR D                   ;2896   B2            ²
ADD HL,DE              ;2897   19            
CALL 1976H             ;2898   CD 76 19      Ív
CALL 1B6AH             ;289B   CD 6A 1B      Íj
SBC A,L                ;289E   9D            
INC DE                 ;289F   13            
JP 19B2H               ;28A0   C3 B2 19      Ã²
LD B,A                 ;28A3   47            G
LD A,(45A4H)           ;28A4   3A A4 45      :¤E
CP B                   ;28A7   B8            ¸
JP Z,2875H             ;28A8   CA 75 28      Êu(
LD A,B                 ;28AB   78            x
LD (45A4H),A           ;28AC   32 A4 45      2¤E
JP 2880H               ;28AF   C3 80 28      Ã(
CALL 198CH             ;28B2   CD 8C 19      Í
CALL 169AH             ;28B5   CD 9A 16      Í
ADD HL,HL              ;28B8   29            )
LD (4801H),HL          ;28B9   22 01 48      "H
LD HL,19B2H            ;28BC   21 B2 19      !²
PUSH HL                ;28BF   E5            å
EX DE,HL               ;28C0   EB            ë
JP (HL)                ;28C1   E9            é
CALL 168BH             ;28C2   CD 8B 16      Í
LD C,L                 ;28C5   4D            M
RET C                  ;28C6   D8            Ø
JR Z,2896H             ;28C7   28 CD         (Í
SBC A,D                ;28C9   9A            
LD D,41H               ;28CA   16 41         A
CALL 169AH             ;28CC   CD 9A 16      Í
LD E,B                 ;28CF   58            X
LD (4801H),HL          ;28D0   22 01 48      "H
LD HL,(4561H)          ;28D3   2A 61 45      *aE
JR 28F5H               ;28D6   18 1D         
CALL 198CH             ;28D8   CD 8C 19      Í
LD (4801H),HL          ;28DB   22 01 48      "H
LD HL,(4561H)          ;28DE   2A 61 45      *aE
CALL 1662H             ;28E1   CD 62 16      Íb
JP C,1393H             ;28E4   DA 93 13      Ú
LD HL,(4644H)          ;28E7   2A 44 46      *DF
LD BC,00C8H            ;28EA   01 C8 00      È
ADD HL,BC              ;28ED   09            	
CALL 1662H             ;28EE   CD 62 16      Íb
JP NC,1393H            ;28F1   D2 93 13      Ò
EX DE,HL               ;28F4   EB            ë
LD (4563H),HL          ;28F5   22 63 45      "cE
LD SP,HL               ;28F8   F9            ù
JP 19B2H               ;28F9   C3 B2 19      Ã²
LD HL,(47FFH)          ;28FC   2A FF 47      *ÿG
LD A,L                 ;28FF   7D            }
OR H                   ;2900   B4            ´
JP NZ,13BBH            ;2901   C2 BB 13      Â»
LD A,(4565H)           ;2904   3A 65 45      :eE
OR A                   ;2907   B7            ·
JP Z,13BBH             ;2908   CA BB 13      Ê»
PUSH AF                ;290B   F5            õ
CALL 13C1H             ;290C   CD C1 13      ÍÁ
LD BC,0006H            ;290F   01 06 00      
LD DE,47FDH            ;2912   11 FD 47      ýG
LD HL,4566H            ;2915   21 66 45      !fE
CALL 1799H             ;2918   CD 99 17      Í
POP AF                 ;291B   F1            ñ
LD HL,(4801H)          ;291C   2A 01 48      *H
OR A                   ;291F   B7            ·
JP M,1E7CH             ;2920   FA 7C 1E      ú|
DEC A                  ;2923   3D            =
JP Z,19B2H             ;2924   CA B2 19      Ê²
JP 19E1H               ;2927   C3 E1 19      Ãá
LD A,01H               ;292A   3E 01         >
JR 292FH               ;292C   18 01         
XOR A                  ;292E   AF            ¯
PUSH AF                ;292F   F5            õ
CALL 19A9H             ;2930   CD A9 19      Í©
PUSH DE                ;2933   D5            Õ
CALL 169AH             ;2934   CD 9A 16      Í
INC L                  ;2937   2C            ,
CALL 19A9H             ;2938   CD A9 19      Í©
LD (4801H),HL          ;293B   22 01 48      "H
LD A,E                 ;293E   7B            {
SUB 32H                ;293F   D6 32         Ö2
JR NC,293FH            ;2941   30 FC         0ü
ADD A,32H              ;2943   C6 32         Æ2
LD E,A                 ;2945   5F            _
POP BC                 ;2946   C1            Á
LD A,C                 ;2947   79            y
SUB 50H                ;2948   D6 50         ÖP
JR NC,2948H            ;294A   30 FC         0ü
ADD A,50H              ;294C   C6 50         ÆP
LD C,A                 ;294E   4F            O
XOR A                  ;294F   AF            ¯
SRL C                  ;2950   CB 39         Ë9
JR NC,2962H            ;2952   30 0E         0
SRL E                  ;2954   CB 3B         Ë;
JR NC,295CH            ;2956   30 04         0
ADD A,04H              ;2958   C6 04         Æ
ADD A,02H              ;295A   C6 02         Æ
ADD A,01H              ;295C   C6 01         Æ
ADD A,01H              ;295E   C6 01         Æ
JR 2968H               ;2960   18 06         
SRL E                  ;2962   CB 3B         Ë;
JR NC,295EH            ;2964   30 F8         0ø
JR 295AH               ;2966   18 F2         ò
PUSH AF                ;2968   F5            õ
LD HL,D000H            ;2969   21 00 D0      !Ð
LD A,28H               ;296C   3E 28         >(
ADD HL,DE              ;296E   19            
DEC A                  ;296F   3D            =
JR NZ,296EH            ;2970   20 FC          ü
ADD HL,BC              ;2972   09            	
LD A,(HL)              ;2973   7E            ~
CP F0H                 ;2974   FE F0         þð
JR NC,297AH            ;2976   30 02         0
LD A,F0H               ;2978   3E F0         >ð
POP BC                 ;297A   C1            Á
LD C,A                 ;297B   4F            O
POP AF                 ;297C   F1            ñ
OR A                   ;297D   B7            ·
LD A,B                 ;297E   78            x
JR Z,2984H             ;297F   28 03         (
OR C                   ;2981   B1            ±
JR 2986H               ;2982   18 02         
CPL                    ;2984   2F            /
AND C                  ;2985   A1            ¡
CP F0H                 ;2986   FE F0         þð
JR NZ,298BH            ;2988   20 01          
XOR A                  ;298A   AF            ¯
LD (HL),A              ;298B   77            w
JP 19B2H               ;298C   C3 B2 19      Ã²
XOR A                  ;298F   AF            ¯
JP 2A38H               ;2990   C3 38 2A      Ã8*
LD A,(10F0H)           ;2993   3A F0 10      :ð
CP 02H                 ;2996   FE 02         þ
JP NZ,2A66H            ;2998   C2 66 2A      Âf*
CALL 2B08H             ;299B   CD 08 2B      Í+
CALL 2B48H             ;299E   CD 48 2B      ÍH+
CALL F010H             ;29A1   CD 10 F0      Íð
PUSH AF                ;29A4   F5            õ
CALL 2B60H             ;29A5   CD 60 2B      Í`+
POP AF                 ;29A8   F1            ñ
JP C,2B41H             ;29A9   DA 41 2B      ÚA+
LD DE,29B5H            ;29AC   11 B5 29      µ)
CALL 1357H             ;29AF   CD 57 13      ÍW
JP 19B2H               ;29B2   C3 B2 19      Ã²
LD C,A                 ;29B5   4F            O
LD C,E                 ;29B6   4B            K
DEC C                  ;29B7   0D            
NOP                    ;29B8   00            
NOP                    ;29B9   00            
NOP                    ;29BA   00            
EX DE,HL               ;29BB   EB            ë
CALL 2B9CH             ;29BC   CD 9C 2B      Í+
LD HL,0D02H            ;29BF   21 02 0D      !
LD (10F0H),HL          ;29C2   22 F0 10      "ð
XOR A                  ;29C5   AF            ¯
PUSH AF                ;29C6   F5            õ
LD HL,4806H            ;29C7   21 06 48      !H
LD (1104H),HL          ;29CA   22 04 11      "
LD HL,0000H            ;29CD   21 00 00      !
LD (1106H),HL          ;29D0   22 06 11      "
LD (1108H),HL          ;29D3   22 08 11      "
EX DE,HL               ;29D6   EB            ë
CALL 1829H             ;29D7   CD 29 18      Í)
JP Z,29FBH             ;29DA   CA FB 29      Êû)
CALL 2383H             ;29DD   CD 83 23      Í#
LD A,D                 ;29E0   7A            z
OR A                   ;29E1   B7            ·
JP Z,138EH             ;29E2   CA 8E 13      Ê
LD A,C                 ;29E5   79            y
CP 11H                 ;29E6   FE 11         þ
JP NC,138EH            ;29E8   D2 8E 13      Ò
CALL 1801H             ;29EB   CD 01 18      Í
PUSH HL                ;29EE   E5            å
LD HL,10F1H            ;29EF   21 F1 10      !ñ
EX DE,HL               ;29F2   EB            ë
CALL 1799H             ;29F3   CD 99 17      Í
EX DE,HL               ;29F6   EB            ë
ADD HL,BC              ;29F7   09            	
LD (HL),0DH            ;29F8   36 0D         6
POP HL                 ;29FA   E1            á
LD (4801H),HL          ;29FB   22 01 48      "H
POP AF                 ;29FE   F1            ñ
JP NZ,2BC6H            ;29FF   C2 C6 2B      ÂÆ+
LD HL,(29B9H)          ;2A02   2A B9 29      *¹)
LD (1108H),HL          ;2A05   22 08 11      "
LD A,(29B8H)           ;2A08   3A B8 29      :¸)
OR A                   ;2A0B   B7            ·
JP NZ,124BH            ;2A0C   C2 4B 12      ÂK
LD HL,(4634H)          ;2A0F   2A 34 46      *4F
LD DE,4806H            ;2A12   11 06 48      H
EX DE,HL               ;2A15   EB            ë
CALL 1668H             ;2A16   CD 68 16      Íh
LD (1102H),HL          ;2A19   22 02 11      "
CALL F004H             ;2A1C   CD 04 F0      Íð
JP C,1385H             ;2A1F   DA 85 13      Ú
CALL 0009H             ;2A22   CD 09 00      Í	
CALL 2B48H             ;2A25   CD 48 2B      ÍH+
CALL F007H             ;2A28   CD 07 F0      Íð
PUSH AF                ;2A2B   F5            õ
CALL 2B60H             ;2A2C   CD 60 2B      Í`+
POP AF                 ;2A2F   F1            ñ
JP NC,19B2H            ;2A30   D2 B2 19      Ò²
JP 1385H               ;2A33   C3 85 13      Ã
LD A,01H               ;2A36   3E 01         >
LD (4592H),A           ;2A38   32 92 45      2E
XOR A                  ;2A3B   AF            ¯
LD (458EH),A           ;2A3C   32 8E 45      2E
CALL 1829H             ;2A3F   CD 29 18      Í)
JP Z,2A63H             ;2A42   CA 63 2A      Êc*
CALL 2383H             ;2A45   CD 83 23      Í#
CALL 180FH             ;2A48   CD 0F 18      Í
CALL 1829H             ;2A4B   CD 29 18      Í)
JP NZ,138EH            ;2A4E   C2 8E 13      Â
CALL 1801H             ;2A51   CD 01 18      Í
LD A,C                 ;2A54   79            y
CP 11H                 ;2A55   FE 11         þ
JP NC,138EH            ;2A57   D2 8E 13      Ò
LD A,01H               ;2A5A   3E 01         >
LD (458EH),A           ;2A5C   32 8E 45      2E
LD (458FH),DE          ;2A5F   ED 53 8F 45   íSE
LD (4801H),HL          ;2A63   22 01 48      "H
CALL F00AH             ;2A66   CD 0A F0      Í
ð
JP C,2B41H             ;2A69   DA 41 2B      ÚA+
CALL 2B0DH             ;2A6C   CD 0D 2B      Í
+
LD HL,10F0H            ;2A6F   21 F0 10      !ð
LD A,(HL)              ;2A72   7E            ~
OR A                   ;2A73   B7            ·
JP Z,2A66H             ;2A74   CA 66 2A      Êf*
CP 04H                 ;2A77   FE 04         þ
JP NC,2A66H            ;2A79   D2 66 2A      Òf*
LD A,(458EH)           ;2A7C   3A 8E 45      :E
OR A                   ;2A7F   B7            ·
JP Z,2A99H             ;2A80   CA 99 2A      Ê*
LD HL,(458FH)          ;2A83   2A 8F 45      *E
LD DE,10F1H            ;2A86   11 F1 10      ñ
LD C,10H               ;2A89   0E 10         
LD A,(DE)              ;2A8B   1A            
CP (HL)                ;2A8C   BE            ¾
JP NZ,2A66H            ;2A8D   C2 66 2A      Âf*
CP 0DH                 ;2A90   FE 0D         þ
JR Z,2A99H             ;2A92   28 05         (
INC HL                 ;2A94   23            #
INC DE                 ;2A95   13            
DEC C                  ;2A96   0D            
JR NZ,2A8BH            ;2A97   20 F2          ò
LD A,(10F0H)           ;2A99   3A F0 10      :ð
LD C,A                 ;2A9C   4F            O
LD A,(4592H)           ;2A9D   3A 92 45      :E
OR A                   ;2AA0   B7            ·
JP Z,2993H             ;2AA1   CA 93 29      Ê)
CP 02H                 ;2AA4   FE 02         þ
JP NZ,2AB1H            ;2AA6   C2 B1 2A      Â±*
DEC C                  ;2AA9   0D            
CP C                   ;2AAA   B9            ¹
JP Z,2BEAH             ;2AAB   CA EA 2B      Êê+
JP 2A66H               ;2AAE   C3 66 2A      Ãf*
LD A,C                 ;2AB1   79            y
CP 01H                 ;2AB2   FE 01         þ
JP Z,2B74H             ;2AB4   CA 74 2B      Êt+
CP 02H                 ;2AB7   FE 02         þ
JP NZ,2A66H            ;2AB9   C2 66 2A      Âf*
CALL 2B9CH             ;2ABC   CD 9C 2B      Í+
LD BC,0064H            ;2ABF   01 64 00      d
LD HL,4806H            ;2AC2   21 06 48      !H
CALL 1742H             ;2AC5   CD 42 17      ÍB
EX DE,HL               ;2AC8   EB            ë
LD HL,(1102H)          ;2AC9   2A 02 11      *
CALL 1662H             ;2ACC   CD 62 16      Íb
JP NC,1393H            ;2ACF   D2 93 13      Ò
CALL 2B12H             ;2AD2   CD 12 2B      Í+
LD A,(1108H)           ;2AD5   3A 08 11      :
LD (29B8H),A           ;2AD8   32 B8 29      2¸)
LD HL,4806H            ;2ADB   21 06 48      !H
LD (1104H),HL          ;2ADE   22 04 11      "
CALL F00DH             ;2AE1   CD 0D F0      Í
ð
JP C,2B3CH             ;2AE4   DA 3C 2B      Ú<+
LD DE,4806H            ;2AE7   11 06 48      H
LD HL,(1102H)          ;2AEA   2A 02 11      *
ADD HL,DE              ;2AED   19            
LD (4634H),HL          ;2AEE   22 34 46      "4F
CALL 2B60H             ;2AF1   CD 60 2B      Í`+
CALL 1857H             ;2AF4   CD 57 18      ÍW
CALL 187CH             ;2AF7   CD 7C 18      Í|
LD A,(1109H)           ;2AFA   3A 09 11      :	
OR A                   ;2AFD   B7            ·
JP Z,19B2H             ;2AFE   CA B2 19      Ê²
LD HL,2B07H            ;2B01   21 07 2B      !+
JP 1CCBH               ;2B04   C3 CB 1C      ÃË
DEC C                  ;2B07   0D            
LD DE,2B31H            ;2B08   11 31 2B      1+
JR 2B15H               ;2B0B   18 08         
LD DE,2B21H            ;2B0D   11 21 2B      !+
JR 2B15H               ;2B10   18 03         
LD DE,2B28H            ;2B12   11 28 2B      (+
CALL 1357H             ;2B15   CD 57 13      ÍW
LD DE,10F1H            ;2B18   11 F1 10      ñ
CALL 0015H             ;2B1B   CD 15 00      Í
JP 0009H               ;2B1E   C3 09 00      Ã	
LD B,(HL)              ;2B21   46            F
LD C,A                 ;2B22   4F            O
LD D,L                 ;2B23   55            U
LD C,(HL)              ;2B24   4E            N
LD B,H                 ;2B25   44            D
JR NZ,2B35H            ;2B26   20 0D          
LD C,H                 ;2B28   4C            L
LD C,A                 ;2B29   4F            O
LD B,C                 ;2B2A   41            A
LD B,H                 ;2B2B   44            D
LD C,C                 ;2B2C   49            I
LD C,(HL)              ;2B2D   4E            N
LD B,A                 ;2B2E   47            G
JR NZ,2B3EH            ;2B2F   20 0D          
LD D,(HL)              ;2B31   56            V
LD B,L                 ;2B32   45            E
LD D,D                 ;2B33   52            R
LD C,C                 ;2B34   49            I
LD B,(HL)              ;2B35   46            F
LD E,C                 ;2B36   59            Y
LD C,C                 ;2B37   49            I
LD C,(HL)              ;2B38   4E            N
LD B,A                 ;2B39   47            G
JR NZ,2B49H            ;2B3A   20 0D          
PUSH AF                ;2B3C   F5            õ
CALL 1832H             ;2B3D   CD 32 18      Í2
POP AF                 ;2B40   F1            ñ
DEC A                  ;2B41   3D            =
JP Z,1398H             ;2B42   CA 98 13      Ê
JP 1385H               ;2B45   C3 85 13      Ã
LD HL,4806H            ;2B48   21 06 48      !H
LD E,(HL)              ;2B4B   5E            ^
INC HL                 ;2B4C   23            #
LD D,(HL)              ;2B4D   56            V
LD A,E                 ;2B4E   7B            {
OR D                   ;2B4F   B2            ²
RET Z                  ;2B50   C8            È
PUSH DE                ;2B51   D5            Õ
DEC HL                 ;2B52   2B            +
LD A,E                 ;2B53   7B            {
SUB L                  ;2B54   95            
LD E,A                 ;2B55   5F            _
LD A,D                 ;2B56   7A            z
SBC A,H                ;2B57   9C            
LD D,A                 ;2B58   57            W
LD (HL),E              ;2B59   73            s
INC HL                 ;2B5A   23            #
LD (HL),D              ;2B5B   72            r
POP HL                 ;2B5C   E1            á
JP 2B4BH               ;2B5D   C3 4B 2B      ÃK+
LD HL,4806H            ;2B60   21 06 48      !H
LD E,(HL)              ;2B63   5E            ^
INC HL                 ;2B64   23            #
LD D,(HL)              ;2B65   56            V
LD A,E                 ;2B66   7B            {
OR D                   ;2B67   B2            ²
RET Z                  ;2B68   C8            È
DEC HL                 ;2B69   2B            +
EX DE,HL               ;2B6A   EB            ë
ADD HL,DE              ;2B6B   19            
EX DE,HL               ;2B6C   EB            ë
LD (HL),E              ;2B6D   73            s
INC HL                 ;2B6E   23            #
LD (HL),D              ;2B6F   72            r
EX DE,HL               ;2B70   EB            ë
JP 2B63H               ;2B71   C3 63 2B      Ãc+
LD HL,(1104H)          ;2B74   2A 04 11      *
EX DE,HL               ;2B77   EB            ë
LD HL,(4563H)          ;2B78   2A 63 45      *cE
DEC HL                 ;2B7B   2B            +
CALL 1662H             ;2B7C   CD 62 16      Íb
JP NC,13B6H            ;2B7F   D2 B6 13      Ò¶
LD HL,(1102H)          ;2B82   2A 02 11      *
ADD HL,DE              ;2B85   19            
JP C,1393H             ;2B86   DA 93 13      Ú
EX DE,HL               ;2B89   EB            ë
LD HL,(4561H)          ;2B8A   2A 61 45      *aE
CALL 1662H             ;2B8D   CD 62 16      Íb
JP C,1393H             ;2B90   DA 93 13      Ú
CALL 2B12H             ;2B93   CD 12 2B      Í+
CALL F00DH             ;2B96   CD 0D F0      Í
ð
JP 19B2H               ;2B99   C3 B2 19      Ã²
PUSH HL                ;2B9C   E5            å
LD HL,(47FFH)          ;2B9D   2A FF 47      *ÿG
LD A,H                 ;2BA0   7C            |
OR L                   ;2BA1   B5            µ
JP NZ,138EH            ;2BA2   C2 8E 13      Â
POP HL                 ;2BA5   E1            á
RET                    ;2BA6   C9            É
LD A,(457AH)           ;2BA7   3A 7A 45      :zE
OR A                   ;2BAA   B7            ·
JP NZ,13B1H            ;2BAB   C2 B1 13      Â±
INC A                  ;2BAE   3C            <
PUSH AF                ;2BAF   F5            õ
EX DE,HL               ;2BB0   EB            ë
LD HL,0D03H            ;2BB1   21 03 0D      !
LD (10F0H),HL          ;2BB4   22 F0 10      "ð
LD HL,0080H            ;2BB7   21 80 00      !
LD (1102H),HL          ;2BBA   22 02 11      "
LD HL,45AEH            ;2BBD   21 AE 45      !®E
LD (457BH),HL          ;2BC0   22 7B 45      "{E
JP 29CAH               ;2BC3   C3 CA 29      ÃÊ)
CALL F004H             ;2BC6   CD 04 F0      Íð
JP C,1385H             ;2BC9   DA 85 13      Ú
CALL 0009H             ;2BCC   CD 09 00      Í	
LD A,01H               ;2BCF   3E 01         >
LD (457AH),A           ;2BD1   32 7A 45      2zE
JP 19B2H               ;2BD4   C3 B2 19      Ã²
LD A,(457AH)           ;2BD7   3A 7A 45      :zE
OR A                   ;2BDA   B7            ·
JP NZ,13B1H            ;2BDB   C2 B1 13      Â±
LD A,02H               ;2BDE   3E 02         >
LD (4592H),A           ;2BE0   32 92 45      2E
XOR A                  ;2BE3   AF            ¯
LD (458EH),A           ;2BE4   32 8E 45      2E
JP 2A3FH               ;2BE7   C3 3F 2A      Ã?*
LD (457AH),A           ;2BEA   32 7A 45      2zE
CALL 2B12H             ;2BED   CD 12 2B      Í+
LD HL,45AEH            ;2BF0   21 AE 45      !®E
LD (1104H),HL          ;2BF3   22 04 11      "
LD HL,0080H            ;2BF6   21 80 00      !
LD (1102H),HL          ;2BF9   22 02 11      "
LD HL,462EH            ;2BFC   21 2E 46      !.F
LD (457BH),HL          ;2BFF   22 7B 45      "{E
JP 19B2H               ;2C02   C3 B2 19      Ã²
LD A,(457AH)           ;2C05   3A 7A 45      :zE
OR A                   ;2C08   B7            ·
JP Z,1B27H             ;2C09   CA 27 1B      Ê'
PUSH HL                ;2C0C   E5            å
DEC A                  ;2C0D   3D            =
JP NZ,2C25H            ;2C0E   C2 25 2C      Â%,
LD HL,(457BH)          ;2C11   2A 7B 45      *{E
LD DE,462EH            ;2C14   11 2E 46      .F
CALL 1662H             ;2C17   CD 62 16      Íb
JP NC,2C2DH            ;2C1A   D2 2D 2C      Ò-,
LD (HL),FFH            ;2C1D   36 FF         6ÿ
CALL F007H             ;2C1F   CD 07 F0      Íð
JP C,1385H             ;2C22   DA 85 13      Ú
XOR A                  ;2C25   AF            ¯
LD (457AH),A           ;2C26   32 7A 45      2zE
POP HL                 ;2C29   E1            á
JP 1B27H               ;2C2A   C3 27 1B      Ã'
CALL F007H             ;2C2D   CD 07 F0      Íð
JP C,1385H             ;2C30   DA 85 13      Ú
LD HL,45AEH            ;2C33   21 AE 45      !®E
JP 2C1DH               ;2C36   C3 1D 2C      Ã,
CALL 168BH             ;2C39   CD 8B 16      Í
CP A                   ;2C3C   BF            ¿
LD C,C                 ;2C3D   49            I
INC L                  ;2C3E   2C            ,
CALL 168BH             ;2C3F   CD 8B 16      Í
LD D,H                 ;2C42   54            T
LD C,C                 ;2C43   49            I
INC L                  ;2C44   2C            ,
LD A,01H               ;2C45   3E 01         >
JR 2C4AH               ;2C47   18 01         
XOR A                  ;2C49   AF            ¯
LD (457DH),A           ;2C4A   32 7D 45      2}E
RET                    ;2C4D   C9            É
LD A,(457AH)           ;2C4E   3A 7A 45      :zE
CP 01H                 ;2C51   FE 01         þ
JP NZ,13B1H            ;2C53   C2 B1 13      Â±
LD HL,(457BH)          ;2C56   2A 7B 45      *{E
PUSH DE                ;2C59   D5            Õ
LD DE,462EH            ;2C5A   11 2E 46      .F
CALL 1662H             ;2C5D   CD 62 16      Íb
JP C,2C6CH             ;2C60   DA 6C 2C      Úl,
CALL F007H             ;2C63   CD 07 F0      Íð
JP C,1385H             ;2C66   DA 85 13      Ú
LD HL,45AEH            ;2C69   21 AE 45      !®E
POP DE                 ;2C6C   D1            Ñ
LD A,(DE)              ;2C6D   1A            
LD (HL),A              ;2C6E   77            w
INC HL                 ;2C6F   23            #
INC DE                 ;2C70   13            
CP 0DH                 ;2C71   FE 0D         þ
JP NZ,2C59H            ;2C73   C2 59 2C      ÂY,
LD (457BH),HL          ;2C76   22 7B 45      "{E
RET                    ;2C79   C9            É
LD C,A                 ;2C7A   4F            O
CALL 2CD0H             ;2C7B   CD D0 2C      ÍÐ,
RET Z                  ;2C7E   C8            È
PUSH DE                ;2C7F   D5            Õ
LD C,00H               ;2C80   0E 00         
CP 02H                 ;2C82   FE 02         þ
JP NZ,13B1H            ;2C84   C2 B1 13      Â±
LD (4592H),A           ;2C87   32 92 45      2E
LD HL,(457BH)          ;2C8A   2A 7B 45      *{E
PUSH DE                ;2C8D   D5            Õ
LD DE,462EH            ;2C8E   11 2E 46      .F
CALL 1662H             ;2C91   CD 62 16      Íb
JP C,2CA7H             ;2C94   DA A7 2C      Ú,
CALL F00DH             ;2C97   CD 0D F0      Í
ð
JP NC,2CA4H            ;2C9A   D2 A4 2C      Ò¤,
DEC A                  ;2C9D   3D            =
JP Z,1398H             ;2C9E   CA 98 13      Ê
JP 1385H               ;2CA1   C3 85 13      Ã
LD HL,45AEH            ;2CA4   21 AE 45      !®E
LD A,(HL)              ;2CA7   7E            ~
LD B,A                 ;2CA8   47            G
CP FFH                 ;2CA9   FE FF         þÿ
JP NZ,2CB6H            ;2CAB   C2 B6 2C      Â¶,
LD A,(4592H)           ;2CAE   3A 92 45      :E
CP 02H                 ;2CB1   FE 02         þ
JP Z,13B1H             ;2CB3   CA B1 13      Ê±
XOR A                  ;2CB6   AF            ¯
LD (4592H),A           ;2CB7   32 92 45      2E
LD A,B                 ;2CBA   78            x
POP DE                 ;2CBB   D1            Ñ
LD (DE),A              ;2CBC   12            
INC HL                 ;2CBD   23            #
INC DE                 ;2CBE   13            
INC C                  ;2CBF   0C            
CP 0DH                 ;2CC0   FE 0D         þ
JP NZ,2C8DH            ;2CC2   C2 8D 2C      Â,
DEC C                  ;2CC5   0D            
POP DE                 ;2CC6   D1            Ñ
LD (457BH),HL          ;2CC7   22 7B 45      "{E
POP HL                 ;2CCA   E1            á
INC HL                 ;2CCB   23            #
INC HL                 ;2CCC   23            #
INC HL                 ;2CCD   23            #
PUSH HL                ;2CCE   E5            å
RET                    ;2CCF   C9            É
LD A,(457DH)           ;2CD0   3A 7D 45      :}E
OR A                   ;2CD3   B7            ·
LD A,(457AH)           ;2CD4   3A 7A 45      :zE
RET                    ;2CD7   C9            É
CALL 19A9H             ;2CD8   CD A9 19      Í©
PUSH DE                ;2CDB   D5            Õ
CALL 169AH             ;2CDC   CD 9A 16      Í
INC L                  ;2CDF   2C            ,
CALL 2613H             ;2CE0   CD 13 26      Í&
CALL 2436H             ;2CE3   CD 36 24      Í6$
LD A,B                 ;2CE6   78            x
OR A                   ;2CE7   B7            ·
JP NZ,139DH            ;2CE8   C2 9D 13      Â
LD (4801H),HL          ;2CEB   22 01 48      "H
CALL 197BH             ;2CEE   CD 7B 19      Í{
POP DE                 ;2CF1   D1            Ñ
LD A,E                 ;2CF2   7B            {
CP F0H                 ;2CF3   FE F0         þð
JP NC,1398H            ;2CF5   D2 98 13      Ò
LD (2CFCH),A           ;2CF8   32 FC 2C      2ü,
IN A,(FFH)             ;2CFB   DB FF         Ûÿ
OR A                   ;2CFD   B7            ·
LD B,A                 ;2CFE   47            G
JP Z,2D0FH             ;2CFF   CA 0F 2D      Ê-
LD A,C8H               ;2D02   3E C8         >È
BIT 7,B                ;2D04   CB 78         Ëx
JP NZ,2D11H            ;2D06   C2 11 2D      Â-
SLA B                  ;2D09   CB 20         Ë 
DEC A                  ;2D0B   3D            =
JP 2D04H               ;2D0C   C3 04 2D      Ã-
LD A,80H               ;2D0F   3E 80         >
LD HL,(4644H)          ;2D11   2A 44 46      *DF
LD (HL),A              ;2D14   77            w
INC HL                 ;2D15   23            #
XOR A                  ;2D16   AF            ¯
LD (HL),A              ;2D17   77            w
INC HL                 ;2D18   23            #
LD (HL),A              ;2D19   77            w
INC HL                 ;2D1A   23            #
LD (HL),A              ;2D1B   77            w
INC HL                 ;2D1C   23            #
LD (HL),B              ;2D1D   70            p
LD D,A                 ;2D1E   57            W
LD E,A                 ;2D1F   5F            _
LD B,A                 ;2D20   47            G
LD C,05H               ;2D21   0E 05         
CALL 1976H             ;2D23   CD 76 19      Ív
CALL 1B6AH             ;2D26   CD 6A 1B      Íj
SBC A,L                ;2D29   9D            
INC DE                 ;2D2A   13            
JP 19B2H               ;2D2B   C3 B2 19      Ã²
CALL 19A9H             ;2D2E   CD A9 19      Í©
LD A,E                 ;2D31   7B            {
CP F0H                 ;2D32   FE F0         þð
JP NC,1398H            ;2D34   D2 98 13      Ò
LD (2D43H),A           ;2D37   32 43 2D      2C-
CALL 169AH             ;2D3A   CD 9A 16      Í
INC L                  ;2D3D   2C            ,
CALL 19A9H             ;2D3E   CD A9 19      Í©
LD A,E                 ;2D41   7B            {
OUT (FFH),A            ;2D42   D3 FF         Óÿ
JP 19B5H               ;2D44   C3 B5 19      Ãµ
CALL NZ,1173H          ;2D47   C4 73 11      Äs
XOR A                  ;2D4A   AF            ¯
JR 2D4FH               ;2D4B   18 02         
LD A,80H               ;2D4D   3E 80         >
PUSH DE                ;2D4F   D5            Õ
XOR (HL)               ;2D50   AE            ®
CPL                    ;2D51   2F            /
LD C,A                 ;2D52   4F            O
LD A,(DE)              ;2D53   1A            
AND 80H                ;2D54   E6 80         æ
LD B,A                 ;2D56   47            G
XOR C                  ;2D57   A9            ©
CPL                    ;2D58   2F            /
AND 80H                ;2D59   E6 80         æ
LD C,A                 ;2D5B   4F            O
PUSH BC                ;2D5C   C5            Å
LD B,(HL)              ;2D5D   46            F
RES 7,B                ;2D5E   CB B8         Ë¸
LD A,(DE)              ;2D60   1A            
AND 7FH                ;2D61   E6 7F         æ
CP B                   ;2D63   B8            ¸
JP NC,2D72H            ;2D64   D2 72 2D      Òr-
POP BC                 ;2D67   C1            Á
EX DE,HL               ;2D68   EB            ë
LD A,B                 ;2D69   78            x
XOR C                  ;2D6A   A9            ©
CPL                    ;2D6B   2F            /
AND 80H                ;2D6C   E6 80         æ
LD B,A                 ;2D6E   47            G
JP 2D5CH               ;2D6F   C3 5C 2D      Ã\-
LD C,A                 ;2D72   4F            O
ADD A,40H              ;2D73   C6 40         Æ@
LD (2D49H),A           ;2D75   32 49 2D      2I-
LD A,C                 ;2D78   79            y
SUB B                  ;2D79   90            
POP BC                 ;2D7A   C1            Á
LD (2D47H),BC          ;2D7B   ED 43 47 2D   íCG-
PUSH DE                ;2D7F   D5            Õ
INC HL                 ;2D80   23            #
LD E,(HL)              ;2D81   5E            ^
INC HL                 ;2D82   23            #
LD D,(HL)              ;2D83   56            V
INC HL                 ;2D84   23            #
LD C,(HL)              ;2D85   4E            N
INC HL                 ;2D86   23            #
LD B,(HL)              ;2D87   46            F
POP HL                 ;2D88   E1            á
INC HL                 ;2D89   23            #
JP Z,2DABH             ;2D8A   CA AB 2D      Ê«-
CP 08H                 ;2D8D   FE 08         þ
JP NC,2DA1H            ;2D8F   D2 A1 2D      Ò¡-
SRL B                  ;2D92   CB 38         Ë8
RR C                   ;2D94   CB 19         Ë
RR D                   ;2D96   CB 1A         Ë
RR E                   ;2D98   CB 1B         Ë
DEC A                  ;2D9A   3D            =
JP NZ,2D92H            ;2D9B   C2 92 2D      Â-
JP 2DABH               ;2D9E   C3 AB 2D      Ã«-
LD E,D                 ;2DA1   5A            Z
LD D,C                 ;2DA2   51            Q
LD C,B                 ;2DA3   48            H
LD B,00H               ;2DA4   06 00         
SUB 08H                ;2DA6   D6 08         Ö
JP NZ,2D8DH            ;2DA8   C2 8D 2D      Â-
LD A,(2D47H)           ;2DAB   3A 47 2D      :G-
OR A                   ;2DAE   B7            ·
JP Z,2DEEH             ;2DAF   CA EE 2D      Êî-
LD A,(HL)              ;2DB2   7E            ~
INC HL                 ;2DB3   23            #
ADD A,E                ;2DB4   83            
LD E,A                 ;2DB5   5F            _
LD A,(HL)              ;2DB6   7E            ~
INC HL                 ;2DB7   23            #
ADC A,D                ;2DB8   8A            
LD D,A                 ;2DB9   57            W
LD A,(HL)              ;2DBA   7E            ~
INC HL                 ;2DBB   23            #
ADC A,C                ;2DBC   89            
LD C,A                 ;2DBD   4F            O
LD A,(HL)              ;2DBE   7E            ~
ADC A,B                ;2DBF   88            
LD B,A                 ;2DC0   47            G
JP NC,2DD0H            ;2DC1   D2 D0 2D      ÒÐ-
RR B                   ;2DC4   CB 18         Ë
RR C                   ;2DC6   CB 19         Ë
RR D                   ;2DC8   CB 1A         Ë
RR E                   ;2DCA   CB 1B         Ë
LD HL,2D49H            ;2DCC   21 49 2D      !I-
INC (HL)               ;2DCF   34            4
LD HL,2D49H            ;2DD0   21 49 2D      !I-
LD A,(HL)              ;2DD3   7E            ~
SUB 40H                ;2DD4   D6 40         Ö@
JP C,2DE0H             ;2DD6   DA E0 2D      Úà-
JP M,1398H             ;2DD9   FA 98 13      ú
DEC HL                 ;2DDC   2B            +
OR (HL)                ;2DDD   B6            ¶
JR 2DE3H               ;2DDE   18 03         
CALL 367BH             ;2DE0   CD 7B 36      Í{6
POP HL                 ;2DE3   E1            á
LD (HL),A              ;2DE4   77            w
INC HL                 ;2DE5   23            #
LD (HL),E              ;2DE6   73            s
INC HL                 ;2DE7   23            #
LD (HL),D              ;2DE8   72            r
INC HL                 ;2DE9   23            #
LD (HL),C              ;2DEA   71            q
INC HL                 ;2DEB   23            #
LD (HL),B              ;2DEC   70            p
RET                    ;2DED   C9            É
LD A,(HL)              ;2DEE   7E            ~
INC HL                 ;2DEF   23            #
SUB E                  ;2DF0   93            
LD E,A                 ;2DF1   5F            _
LD A,(HL)              ;2DF2   7E            ~
INC HL                 ;2DF3   23            #
SBC A,D                ;2DF4   9A            
LD D,A                 ;2DF5   57            W
LD A,(HL)              ;2DF6   7E            ~
INC HL                 ;2DF7   23            #
SBC A,C                ;2DF8   99            
LD C,A                 ;2DF9   4F            O
LD A,(HL)              ;2DFA   7E            ~
SBC A,B                ;2DFB   98            
LD B,A                 ;2DFC   47            G
CALL C,2E3DH           ;2DFD   DC 3D 2E      Ü=.
OR C                   ;2E00   B1            ±
OR D                   ;2E01   B2            ²
JP NZ,2E0BH            ;2E02   C2 0B 2E      Â.
LD A,E                 ;2E05   7B            {
CP 3FH                 ;2E06   FE 3F         þ?
JP C,2DE0H             ;2E08   DA E0 2D      Úà-
LD HL,2D49H            ;2E0B   21 49 2D      !I-
LD A,B                 ;2E0E   78            x
OR A                   ;2E0F   B7            ·
JP M,2DD0H             ;2E10   FA D0 2D      úÐ-
JP NZ,2E2BH            ;2E13   C2 2B 2E      Â+.
LD A,(HL)              ;2E16   7E            ~
SUB 08H                ;2E17   D6 08         Ö
JP C,2DE0H             ;2E19   DA E0 2D      Úà-
LD (HL),A              ;2E1C   77            w
LD A,C                 ;2E1D   79            y
OR D                   ;2E1E   B2            ²
OR E                   ;2E1F   B3            ³
JP Z,2DE0H             ;2E20   CA E0 2D      Êà-
LD B,C                 ;2E23   41            A
LD C,D                 ;2E24   4A            J
LD D,E                 ;2E25   53            S
LD E,00H               ;2E26   1E 00         
JP 2E0EH               ;2E28   C3 0E 2E      Ã.
DEC (HL)               ;2E2B   35            5
JP C,2DE0H             ;2E2C   DA E0 2D      Úà-
SLA E                  ;2E2F   CB 23         Ë#
RL D                   ;2E31   CB 12         Ë
RL C                   ;2E33   CB 11         Ë
RL B                   ;2E35   CB 10         Ë
JP P,2E2BH             ;2E37   F2 2B 2E      ò+.
JP 2DD0H               ;2E3A   C3 D0 2D      ÃÐ-
LD HL,2D48H            ;2E3D   21 48 2D      !H-
LD A,(HL)              ;2E40   7E            ~
ADD A,80H              ;2E41   C6 80         Æ
LD (HL),A              ;2E43   77            w
LD A,E                 ;2E44   7B            {
CPL                    ;2E45   2F            /
ADD A,01H              ;2E46   C6 01         Æ
LD E,A                 ;2E48   5F            _
LD A,D                 ;2E49   7A            z
CPL                    ;2E4A   2F            /
ADC A,00H              ;2E4B   CE 00         Î
LD D,A                 ;2E4D   57            W
LD A,C                 ;2E4E   79            y
CPL                    ;2E4F   2F            /
ADC A,00H              ;2E50   CE 00         Î
LD C,A                 ;2E52   4F            O
LD A,B                 ;2E53   78            x
CPL                    ;2E54   2F            /
ADC A,00H              ;2E55   CE 00         Î
LD B,A                 ;2E57   47            G
RET                    ;2E58   C9            É
PUSH DE                ;2E59   D5            Õ
LD A,(DE)              ;2E5A   1A            
XOR (HL)               ;2E5B   AE            ®
CPL                    ;2E5C   2F            /
AND 80H                ;2E5D   E6 80         æ
LD (2D48H),A           ;2E5F   32 48 2D      2H-
LD B,(HL)              ;2E62   46            F
RES 7,B                ;2E63   CB B8         Ë¸
LD A,(DE)              ;2E65   1A            
AND 7FH                ;2E66   E6 7F         æ
ADD A,B                ;2E68   80            
JP Z,2DE0H             ;2E69   CA E0 2D      Êà-
DEC A                  ;2E6C   3D            =
CP 30H                 ;2E6D   FE 30         þ0
JP C,2DE0H             ;2E6F   DA E0 2D      Úà-
CP E0H                 ;2E72   FE E0         þà
JP NC,1398H            ;2E74   D2 98 13      Ò
LD (2D49H),A           ;2E77   32 49 2D      2I-
XOR A                  ;2E7A   AF            ¯
LD (2D47H),A           ;2E7B   32 47 2D      2G-
LD BC,0004H            ;2E7E   01 04 00      
ADD HL,BC              ;2E81   09            	
LD A,(HL)              ;2E82   7E            ~
OR A                   ;2E83   B7            ·
JP P,2DE0H             ;2E84   F2 E0 2D      òà-
PUSH HL                ;2E87   E5            å
POP IY                 ;2E88   FD E1         ýá
LD C,B                 ;2E8A   48            H
EX DE,HL               ;2E8B   EB            ë
INC HL                 ;2E8C   23            #
LD E,(HL)              ;2E8D   5E            ^
INC HL                 ;2E8E   23            #
LD D,(HL)              ;2E8F   56            V
INC HL                 ;2E90   23            #
PUSH HL                ;2E91   E5            å
LD H,B                 ;2E92   60            `
LD L,B                 ;2E93   68            h
EXX                    ;2E94   D9            Ù
POP HL                 ;2E95   E1            á
LD E,(HL)              ;2E96   5E            ^
INC HL                 ;2E97   23            #
LD D,(HL)              ;2E98   56            V
LD HL,0000H            ;2E99   21 00 00      !
LD A,D                 ;2E9C   7A            z
OR A                   ;2E9D   B7            ·
JP P,2DE0H             ;2E9E   F2 E0 2D      òà-
LD C,04H               ;2EA1   0E 04         
LD A,(IY+0H)           ;2EA3   FD 7E 00      ý~
LD B,08H               ;2EA6   06 08         
OR A                   ;2EA8   B7            ·
JP Z,2F24H             ;2EA9   CA 24 2F      Ê$/
RLA                    ;2EAC   17            
JP NC,2EC5H            ;2EAD   D2 C5 2E      ÒÅ.
EX AF,AF'              ;2EB0   08            
EXX                    ;2EB1   D9            Ù
LD A,B                 ;2EB2   78            x
ADD A,C                ;2EB3   81            
LD C,A                 ;2EB4   4F            O
ADC HL,DE              ;2EB5   ED 5A         íZ
EXX                    ;2EB7   D9            Ù
ADC HL,DE              ;2EB8   ED 5A         íZ
JP NC,2EC4H            ;2EBA   D2 C4 2E      ÒÄ.
LD A,(2D47H)           ;2EBD   3A 47 2D      :G-
INC A                  ;2EC0   3C            <
LD (2D47H),A           ;2EC1   32 47 2D      2G-
EX AF,AF'              ;2EC4   08            
SRL D                  ;2EC5   CB 3A         Ë:
RR E                   ;2EC7   CB 1B         Ë
EXX                    ;2EC9   D9            Ù
RR D                   ;2ECA   CB 1A         Ë
RR E                   ;2ECC   CB 1B         Ë
RR B                   ;2ECE   CB 18         Ë
EXX                    ;2ED0   D9            Ù
DJNZ 2EACH             ;2ED1   10 D9         Ù
DEC IY                 ;2ED3   FD 2B         ý+
DEC C                  ;2ED5   0D            
JP NZ,2EA3H            ;2ED6   C2 A3 2E      Â£.
LD A,(2D47H)           ;2ED9   3A 47 2D      :G-
OR A                   ;2EDC   B7            ·
JP Z,2EF7H             ;2EDD   CA F7 2E      Ê÷.
LD B,A                 ;2EE0   47            G
LD A,(2D49H)           ;2EE1   3A 49 2D      :I-
ADD A,B                ;2EE4   80            
LD (2D49H),A           ;2EE5   32 49 2D      2I-
SCF                    ;2EE8   37            7
RR H                   ;2EE9   CB 1C         Ë
RR L                   ;2EEB   CB 1D         Ë
EXX                    ;2EED   D9            Ù
RR H                   ;2EEE   CB 1C         Ë
RR L                   ;2EF0   CB 1D         Ë
RR C                   ;2EF2   CB 19         Ë
EXX                    ;2EF4   D9            Ù
DJNZ 2EE8H             ;2EF5   10 F1         ñ
EXX                    ;2EF7   D9            Ù
LD A,C                 ;2EF8   79            y
OR A                   ;2EF9   B7            ·
JP P,2F1CH             ;2EFA   F2 1C 2F      ò/
LD DE,0001H            ;2EFD   11 01 00      
ADD HL,DE              ;2F00   19            
EXX                    ;2F01   D9            Ù
LD DE,0000H            ;2F02   11 00 00      
ADC HL,DE              ;2F05   ED 5A         íZ
JP NC,2F1BH            ;2F07   D2 1B 2F      Ò/
RR H                   ;2F0A   CB 1C         Ë
RR L                   ;2F0C   CB 1D         Ë
EXX                    ;2F0E   D9            Ù
RR H                   ;2F0F   CB 1C         Ë
RR L                   ;2F11   CB 1D         Ë
EXX                    ;2F13   D9            Ù
LD A,(2D49H)           ;2F14   3A 49 2D      :I-
INC A                  ;2F17   3C            <
LD (2D49H),A           ;2F18   32 49 2D      2I-
EXX                    ;2F1B   D9            Ù
PUSH HL                ;2F1C   E5            å
EXX                    ;2F1D   D9            Ù
LD B,H                 ;2F1E   44            D
LD C,L                 ;2F1F   4D            M
POP DE                 ;2F20   D1            Ñ
JP 2E0BH               ;2F21   C3 0B 2E      Ã.
LD A,E                 ;2F24   7B            {
LD E,D                 ;2F25   5A            Z
LD D,00H               ;2F26   16 00         
EXX                    ;2F28   D9            Ù
LD B,E                 ;2F29   43            C
LD E,D                 ;2F2A   5A            Z
LD D,A                 ;2F2B   57            W
EXX                    ;2F2C   D9            Ù
JP 2ED3H               ;2F2D   C3 D3 2E      ÃÓ.
PUSH DE                ;2F30   D5            Õ
LD A,(DE)              ;2F31   1A            
XOR (HL)               ;2F32   AE            ®
CPL                    ;2F33   2F            /
AND 80H                ;2F34   E6 80         æ
LD (2D48H),A           ;2F36   32 48 2D      2H-
LD B,(HL)              ;2F39   46            F
RES 7,B                ;2F3A   CB B8         Ë¸
LD A,(DE)              ;2F3C   1A            
AND 7FH                ;2F3D   E6 7F         æ
SUB B                  ;2F3F   90            
ADD A,81H              ;2F40   C6 81         Æ
CP 30H                 ;2F42   FE 30         þ0
JP C,2DE0H             ;2F44   DA E0 2D      Úà-
CP E0H                 ;2F47   FE E0         þà
JP NC,1398H            ;2F49   D2 98 13      Ò
LD (2D49H),A           ;2F4C   32 49 2D      2I-
INC HL                 ;2F4F   23            #
INC DE                 ;2F50   13            
EX DE,HL               ;2F51   EB            ë
LD C,(HL)              ;2F52   4E            N
INC HL                 ;2F53   23            #
LD B,(HL)              ;2F54   46            F
INC HL                 ;2F55   23            #
PUSH HL                ;2F56   E5            å
EX DE,HL               ;2F57   EB            ë
LD E,(HL)              ;2F58   5E            ^
INC HL                 ;2F59   23            #
LD D,(HL)              ;2F5A   56            V
INC HL                 ;2F5B   23            #
LD A,L                 ;2F5C   7D            }
EX AF,AF'              ;2F5D   08            
LD A,H                 ;2F5E   7C            |
LD H,B                 ;2F5F   60            `
LD L,C                 ;2F60   69            i
EXX                    ;2F61   D9            Ù
POP HL                 ;2F62   E1            á
LD C,(HL)              ;2F63   4E            N
INC HL                 ;2F64   23            #
LD B,(HL)              ;2F65   46            F
LD H,A                 ;2F66   67            g
EX AF,AF'              ;2F67   08            
LD L,A                 ;2F68   6F            o
LD E,(HL)              ;2F69   5E            ^
INC HL                 ;2F6A   23            #
LD D,(HL)              ;2F6B   56            V
LD H,B                 ;2F6C   60            `
LD L,C                 ;2F6D   69            i
LD A,D                 ;2F6E   7A            z
OR A                   ;2F6F   B7            ·
JP P,1398H             ;2F70   F2 98 13      ò
LD C,04H               ;2F73   0E 04         
LD B,08H               ;2F75   06 08         
BIT 7,H                ;2F77   CB 7C         Ë|
JP NZ,2F95H            ;2F79   C2 95 2F      Â/
OR A                   ;2F7C   B7            ·
RLA                    ;2F7D   17            
EXX                    ;2F7E   D9            Ù
ADD HL,HL              ;2F7F   29            )
EXX                    ;2F80   D9            Ù
ADC HL,HL              ;2F81   ED 6A         íj
DJNZ 2F77H             ;2F83   10 F2         ò
PUSH AF                ;2F85   F5            õ
DEC C                  ;2F86   0D            
JP NZ,2F75H            ;2F87   C2 75 2F      Âu/
POP AF                 ;2F8A   F1            ñ
LD E,A                 ;2F8B   5F            _
POP AF                 ;2F8C   F1            ñ
LD D,A                 ;2F8D   57            W
POP AF                 ;2F8E   F1            ñ
LD C,A                 ;2F8F   4F            O
POP AF                 ;2F90   F1            ñ
LD B,A                 ;2F91   47            G
JP 2E0BH               ;2F92   C3 0B 2E      Ã.
EXX                    ;2F95   D9            Ù
OR A                   ;2F96   B7            ·
SBC HL,DE              ;2F97   ED 52         íR
EXX                    ;2F99   D9            Ù
SBC HL,DE              ;2F9A   ED 52         íR
CCF                    ;2F9C   3F            ?
JP C,2F7DH             ;2F9D   DA 7D 2F      Ú}/
EXX                    ;2FA0   D9            Ù
ADD HL,DE              ;2FA1   19            
EXX                    ;2FA2   D9            Ù
ADC HL,DE              ;2FA3   ED 5A         íZ
OR A                   ;2FA5   B7            ·
RLA                    ;2FA6   17            
EXX                    ;2FA7   D9            Ù
ADD HL,HL              ;2FA8   29            )
EXX                    ;2FA9   D9            Ù
ADC HL,HL              ;2FAA   ED 6A         íj
DEC B                  ;2FAC   05            
JP NZ,2FB7H            ;2FAD   C2 B7 2F      Â·/
PUSH AF                ;2FB0   F5            õ
LD B,08H               ;2FB1   06 08         
DEC C                  ;2FB3   0D            
JP Z,2F8AH             ;2FB4   CA 8A 2F      Ê/
EXX                    ;2FB7   D9            Ù
OR A                   ;2FB8   B7            ·
SBC HL,DE              ;2FB9   ED 52         íR
EXX                    ;2FBB   D9            Ù
SBC HL,DE              ;2FBC   ED 52         íR
SCF                    ;2FBE   37            7
RLA                    ;2FBF   17            
DEC B                  ;2FC0   05            
JP NZ,2FCBH            ;2FC1   C2 CB 2F      ÂË/
PUSH AF                ;2FC4   F5            õ
LD B,08H               ;2FC5   06 08         
DEC C                  ;2FC7   0D            
JP Z,2F8AH             ;2FC8   CA 8A 2F      Ê/
EXX                    ;2FCB   D9            Ù
ADD HL,HL              ;2FCC   29            )
EXX                    ;2FCD   D9            Ù
ADC HL,HL              ;2FCE   ED 6A         íj
JP NC,2F77H            ;2FD0   D2 77 2F      Òw/
JP 2FB7H               ;2FD3   C3 B7 2F      Ã·/
EXX                    ;2FD6   D9            Ù
INC (HL)               ;2FD7   34            4
CALL E57EH             ;2FD8   CD 7E E5      Í~å
POP IX                 ;2FDB   DD E1         Ýá
EX DE,HL               ;2FDD   EB            ë
LD (2FD7H),HL          ;2FDE   22 D7 2F      "×/
EX AF,AF'              ;2FE1   08            
XOR A                  ;2FE2   AF            ¯
LD (2FD6H),A           ;2FE3   32 D6 2F      2Ö/
LD H,A                 ;2FE6   67            g
LD L,A                 ;2FE7   6F            o
EXX                    ;2FE8   D9            Ù
LD H,A                 ;2FE9   67            g
LD L,A                 ;2FEA   6F            o
LD B,A                 ;2FEB   47            G
LD C,A                 ;2FEC   4F            O
EX AF,AF'              ;2FED   08            
CP 2EH                 ;2FEE   FE 2E         þ.
JP Z,3008H             ;2FF0   CA 08 30      Ê0
SUB 30H                ;2FF3   D6 30         Ö0
CALL 30E3H             ;2FF5   CD E3 30      Íã0
CALL 30D9H             ;2FF8   CD D9 30      ÍÙ0
SUB 30H                ;2FFB   D6 30         Ö0
CP 0AH                 ;2FFD   FE 0A         þ

JR C,2FF5H             ;2FFF   38 F4         8ô
ADD A,30H              ;3001   C6 30         Æ0
CP 2EH                 ;3003   FE 2E         þ.
JP NZ,3019H            ;3005   C2 19 30      Â0
CALL 30D9H             ;3008   CD D9 30      ÍÙ0
SUB 30H                ;300B   D6 30         Ö0
CP 0AH                 ;300D   FE 0A         þ

JP NC,3017H            ;300F   D2 17 30      Ò0
CALL 30F2H             ;3012   CD F2 30      Íò0
JR 3008H               ;3015   18 F1         ñ
ADD A,30H              ;3017   C6 30         Æ0
CP 45H                 ;3019   FE 45         þE
JP NZ,3064H            ;301B   C2 64 30      Âd0
EXX                    ;301E   D9            Ù
CALL 30D9H             ;301F   CD D9 30      ÍÙ0
LD B,01H               ;3022   06 01         
CP BCH                 ;3024   FE BC         þ¼
JR Z,302EH             ;3026   28 06         (
CP BDH                 ;3028   FE BD         þ½
JP NZ,138EH            ;302A   C2 8E 13      Â
DEC B                  ;302D   05            
LD A,B                 ;302E   78            x
OR A                   ;302F   B7            ·
EX AF,AF'              ;3030   08            
CALL 30D9H             ;3031   CD D9 30      ÍÙ0
SUB 30H                ;3034   D6 30         Ö0
JR Z,3031H             ;3036   28 F9         (ù
CP 0AH                 ;3038   FE 0A         þ

JP NC,305AH            ;303A   D2 5A 30      ÒZ0
LD B,A                 ;303D   47            G
CALL 30D9H             ;303E   CD D9 30      ÍÙ0
SUB 30H                ;3041   D6 30         Ö0
CP 0AH                 ;3043   FE 0A         þ

JP NC,305AH            ;3045   D2 5A 30      ÒZ0
LD C,A                 ;3048   4F            O
CALL 30D9H             ;3049   CD D9 30      ÍÙ0
SUB 30H                ;304C   D6 30         Ö0
CP 0AH                 ;304E   FE 0A         þ

JP C,1398H             ;3050   DA 98 13      Ú
LD A,B                 ;3053   78            x
ADD A,A                ;3054   87            
ADD A,A                ;3055   87            
ADD A,B                ;3056   80            
ADD A,A                ;3057   87            
ADD A,C                ;3058   81            
LD B,A                 ;3059   47            G
EX AF,AF'              ;305A   08            
LD A,B                 ;305B   78            x
JR NZ,3060H            ;305C   20 02          
CPL                    ;305E   2F            /
INC A                  ;305F   3C            <
LD (2FD6H),A           ;3060   32 D6 2F      2Ö/
EXX                    ;3063   D9            Ù
PUSH IX                ;3064   DD E5         Ýå
LD A,(2FD6H)           ;3066   3A D6 2F      :Ö/
ADD A,1DH              ;3069   C6 1D         Æ
ADD A,C                ;306B   81            
LD (2FD6H),A           ;306C   32 D6 2F      2Ö/
CP 30H                 ;306F   FE 30         þ0
JP C,307CH             ;3071   DA 7C 30      Ú|0
CP 80H                 ;3074   FE 80         þ
JP C,1398H             ;3076   DA 98 13      Ú
JP 30CEH               ;3079   C3 CE 30      ÃÎ0
LD A,80H               ;307C   3E 80         >
LD (2D48H),A           ;307E   32 48 2D      2H-
LD A,A0H               ;3081   3E A0         > 
LD (2D49H),A           ;3083   32 49 2D      2I-
PUSH HL                ;3086   E5            å
EXX                    ;3087   D9            Ù
POP BC                 ;3088   C1            Á
LD D,H                 ;3089   54            T
LD E,L                 ;308A   5D            ]
LD HL,3096H            ;308B   21 96 30      !0
PUSH HL                ;308E   E5            å
LD HL,(2FD7H)          ;308F   2A D7 2F      *×/
PUSH HL                ;3092   E5            å
JP 2E0BH               ;3093   C3 0B 2E      Ã.
LD A,(2FD6H)           ;3096   3A D6 2F      :Ö/
LD L,A                 ;3099   6F            o
LD C,A                 ;309A   4F            O
LD H,00H               ;309B   26 00         &
LD B,H                 ;309D   44            D
ADD HL,HL              ;309E   29            )
ADD HL,HL              ;309F   29            )
ADD HL,BC              ;30A0   09            	
LD BC,3120H            ;30A1   01 20 31       1
ADD HL,BC              ;30A4   09            	
LD DE,(2FD7H)          ;30A5   ED 5B D7 2F   í[×/
LD A,80H               ;30A9   3E 80         >
LD (2D48H),A           ;30AB   32 48 2D      2H-
LD A,20H               ;30AE   3E 20         > 
ADD A,(HL)             ;30B0   86            
LD B,A                 ;30B1   47            G
LD A,(DE)              ;30B2   1A            
AND 7FH                ;30B3   E6 7F         æ
ADD A,B                ;30B5   80            
JP C,1398H             ;30B6   DA 98 13      Ú
SUB 21H                ;30B9   D6 21         Ö!
JR NC,30BEH            ;30BB   30 01         0
XOR A                  ;30BD   AF            ¯
LD BC,30C6H            ;30BE   01 C6 30      Æ0
PUSH BC                ;30C1   C5            Å
PUSH DE                ;30C2   D5            Õ
JP 2E6DH               ;30C3   C3 6D 2E      Ãm.
POP HL                 ;30C6   E1            á
LD BC,0005H            ;30C7   01 05 00      
LD D,B                 ;30CA   50            P
LD E,B                 ;30CB   58            X
LD A,(HL)              ;30CC   7E            ~
RET                    ;30CD   C9            É
LD HL,30C6H            ;30CE   21 C6 30      !Æ0
PUSH HL                ;30D1   E5            å
LD HL,(2FD7H)          ;30D2   2A D7 2F      *×/
PUSH HL                ;30D5   E5            å
JP 2DE0H               ;30D6   C3 E0 2D      Ãà-
INC IX                 ;30D9   DD 23         Ý#
LD A,(IX+0H)           ;30DB   DD 7E 00      Ý~
CP 20H                 ;30DE   FE 20         þ 
RET NZ                 ;30E0   C0            À
JR 30D9H               ;30E1   18 F6         ö
OR A                   ;30E3   B7            ·
JR NZ,30E9H            ;30E4   20 03          
OR B                   ;30E6   B0            °
RET Z                  ;30E7   C8            È
XOR A                  ;30E8   AF            ¯
EX AF,AF'              ;30E9   08            
LD A,B                 ;30EA   78            x
CP 09H                 ;30EB   FE 09         þ	
JP NZ,3100H            ;30ED   C2 00 31      Â1
INC C                  ;30F0   0C            
RET                    ;30F1   C9            É
OR A                   ;30F2   B7            ·
JR NZ,30FAH            ;30F3   20 05          
DEC C                  ;30F5   0D            
OR B                   ;30F6   B0            °
RET Z                  ;30F7   C8            È
INC C                  ;30F8   0C            
XOR A                  ;30F9   AF            ¯
EX AF,AF'              ;30FA   08            
LD A,B                 ;30FB   78            x
CP 09H                 ;30FC   FE 09         þ	
RET Z                  ;30FE   C8            È
DEC C                  ;30FF   0D            
INC B                  ;3100   04            
LD D,H                 ;3101   54            T
LD E,L                 ;3102   5D            ]
EXX                    ;3103   D9            Ù
LD D,H                 ;3104   54            T
LD E,L                 ;3105   5D            ]
XOR A                  ;3106   AF            ¯
ADD HL,HL              ;3107   29            )
RLA                    ;3108   17            
ADD HL,HL              ;3109   29            )
RLA                    ;310A   17            
ADD HL,DE              ;310B   19            
LD D,00H               ;310C   16 00         
ADC A,D                ;310E   8A            
ADD HL,HL              ;310F   29            )
RLA                    ;3110   17            
EX AF,AF'              ;3111   08            
LD E,A                 ;3112   5F            _
EX AF,AF'              ;3113   08            
ADD HL,DE              ;3114   19            
ADC A,D                ;3115   8A            
EXX                    ;3116   D9            Ù
ADD HL,HL              ;3117   29            )
ADD HL,HL              ;3118   29            )
ADD HL,DE              ;3119   19            
ADD HL,HL              ;311A   29            )
LD D,00H               ;311B   16 00         
LD E,A                 ;311D   5F            _
ADD HL,DE              ;311E   19            
RET                    ;311F   C9            É
RET PO                 ;3120   E0            à
PUSH AF                ;3121   F5            õ
RST 30H                ;3122   F7            ÷
JP NC,E3CAH            ;3123   D2 CA E3      ÒÊã
DI                     ;3126   F3            ó
OR L                   ;3127   B5            µ
ADD A,A                ;3128   87            
DB $E7                 ;3129   FD E7         ýç
CP B                   ;312B   B8            ¸
POP DE                 ;312C   D1            Ñ
LD (HL),H              ;312D   74            t
SBC A,(HL)             ;312E   9E            
JP PE,0625H            ;312F   EA 25 06      ê%
LD (DE),A              ;3132   12            
ADD A,EDH              ;3133   C6 ED         Æí
XOR A                  ;3135   AF            ¯
ADD A,A                ;3136   87            
SUB (HL)               ;3137   96            
RST 30H                ;3138   F7            ÷
POP AF                 ;3139   F1            ñ
CALL BE14H             ;313A   CD 14 BE      Í¾
SBC A,D                ;313D   9A            
CALL P,9A01H           ;313E   F4 01 9A      ô
LD L,L                 ;3141   6D            m
POP BC                 ;3142   C1            Á
RST 30H                ;3143   F7            ÷
ADD A,C                ;3144   81            
NOP                    ;3145   00            
RET                    ;3146   C9            É
POP AF                 ;3147   F1            ñ
EI                     ;3148   FB            û
LD D,B                 ;3149   50            P
AND B                  ;314A   A0             
DEC E                  ;314B   1D            
SUB A                  ;314C   97            
CP 65H                 ;314D   FE 65         þe
EX AF,AF'              ;314F   08            
PUSH HL                ;3150   E5            å
CP H                   ;3151   BC            ¼
LD BC,4A7EH            ;3152   01 7E 4A      ~J
LD E,ECH               ;3155   1E EC         ì
DEC B                  ;3157   05            
ADC A,A                ;3158   8F            
XOR 92H                ;3159   EE 92         î
SUB E                  ;315B   93            
EX AF,AF'              ;315C   08            
LD (77AAH),A           ;315D   32 AA 77      2ªw
CP B                   ;3160   B8            ¸
DEC BC                 ;3161   0B            
CP A                   ;3162   BF            ¿
SUB H                  ;3163   94            
SUB L                  ;3164   95            
AND 0FH                ;3165   E6 0F         æ
RST 30H                ;3167   F7            ÷
LD A,H                 ;3168   7C            |
DEC E                  ;3169   1D            
SUB B                  ;316A   90            
LD (DE),A              ;316B   12            
DEC (HL)               ;316C   35            5
CALL C,B424H           ;316D   DC 24 B4      Ü$´
DEC D                  ;3170   15            
LD B,D                 ;3171   42            B
INC DE                 ;3172   13            
LD L,E1H               ;3173   2E E1         .á
ADD HL,DE              ;3175   19            
ADD HL,BC              ;3176   09            	
CALL Z,8CBCH           ;3177   CC BC 8C      Ì¼
INC E                  ;317A   1C            
INC C                  ;317B   0C            
RST 38H                ;317C   FF            ÿ
EX DE,HL               ;317D   EB            ë
XOR A                  ;317E   AF            ¯
RRA                    ;317F   1F            
RST 08H                ;3180   CF            Ï
CP E6H                 ;3181   FE E6         þæ
IN A,(23H)             ;3183   DB 23         Û#
LD B,C                 ;3185   41            A
LD E,A                 ;3186   5F            _
LD (HL),B              ;3187   70            p
ADC A,C                ;3188   89            
LD H,12H               ;3189   26 12         &
LD (HL),A              ;318B   77            w
CALL Z,29ABH           ;318C   CC AB 29      Ì«)
SUB 94H                ;318F   D6 94         Ö
CP A                   ;3191   BF            ¿
SUB 2DH                ;3192   D6 2D         Ö-
LD B,BDH               ;3194   06 BD         ½
SCF                    ;3196   37            7
ADD A,(HL)             ;3197   86            
JR NC,31E1H            ;3198   30 47         0G
XOR H                  ;319A   AC            ¬
PUSH BC                ;319B   C5            Å
AND A                  ;319C   A7            
INC SP                 ;319D   33            3
LD E,C                 ;319E   59            Y
RLA                    ;319F   17            
OR A                   ;31A0   B7            ·
POP DE                 ;31A1   D1            Ñ
SCF                    ;31A2   37            7
SBC A,B                ;31A3   98            
LD L,(HL)              ;31A4   6E            n
LD (DE),A              ;31A5   12            
ADD A,E                ;31A6   83            
LD A,(0A3DH)           ;31A7   3A 3D 0A      :=

RST 10H                ;31AA   D7            ×
AND E                  ;31AB   A3            £
DEC A                  ;31AC   3D            =
CALL CCCCH             ;31AD   CD CC CC      ÍÌÌ
CALL Z,0041H           ;31B0   CC 41 00      ÌA
NOP                    ;31B3   00            
NOP                    ;31B4   00            
ADD A,B                ;31B5   80            
LD B,H                 ;31B6   44            D
NOP                    ;31B7   00            
NOP                    ;31B8   00            
NOP                    ;31B9   00            
AND B                  ;31BA   A0             
LD B,A                 ;31BB   47            G
NOP                    ;31BC   00            
NOP                    ;31BD   00            
NOP                    ;31BE   00            
RET Z                  ;31BF   C8            È
LD C,D                 ;31C0   4A            J
NOP                    ;31C1   00            
NOP                    ;31C2   00            
NOP                    ;31C3   00            
JP M,004EH             ;31C4   FA 4E 00      úN
NOP                    ;31C7   00            
LD B,B                 ;31C8   40            @
SBC A,H                ;31C9   9C            
LD D,C                 ;31CA   51            Q
NOP                    ;31CB   00            
NOP                    ;31CC   00            
LD D,B                 ;31CD   50            P
JP 0054H               ;31CE   C3 54 00      ÃT
NOP                    ;31D1   00            
INC H                  ;31D2   24            $
CALL P,0058H           ;31D3   F4 58 00      ôX
ADD A,B                ;31D6   80            
SUB (HL)               ;31D7   96            
SBC A,B                ;31D8   98            
LD E,E                 ;31D9   5B            [
NOP                    ;31DA   00            
JR NZ,3199H            ;31DB   20 BC          ¼
CP (HL)                ;31DD   BE            ¾
LD E,(HL)              ;31DE   5E            ^
NOP                    ;31DF   00            
JR Z,324DH             ;31E0   28 6B         (k
XOR 62H                ;31E2   EE 62         îb
NOP                    ;31E4   00            
LD SP,HL               ;31E5   F9            ù
LD (BC),A              ;31E6   02            
SUB L                  ;31E7   95            
LD H,L                 ;31E8   65            e
LD B,B                 ;31E9   40            @
OR A                   ;31EA   B7            ·
LD B,E                 ;31EB   43            C
CP D                   ;31EC   BA            º
LD L,B                 ;31ED   68            h
DJNZ 3195H             ;31EE   10 A5         ¥
CALL NC,6CE8H          ;31F0   D4 E8 6C      Ôèl
LD HL,(84E7H)          ;31F3   2A E7 84      *ç
SUB C                  ;31F6   91            
LD L,A                 ;31F7   6F            o
PUSH AF                ;31F8   F5            õ
JR NZ,31E1H            ;31F9   20 E6          æ
OR L                   ;31FB   B5            µ
LD (HL),D              ;31FC   72            r
LD (5FA9H),A           ;31FD   32 A9 5F      2©_
EX (SP),HL             ;3200   E3            ã
HALT                   ;3201   76            v
CP A                   ;3202   BF            ¿
RET                    ;3203   C9            É
DEC DE                 ;3204   1B            
ADC A,(HL)             ;3205   8E            
LD A,C                 ;3206   79            y
CPL                    ;3207   2F            /
CP H                   ;3208   BC            ¼
AND D                  ;3209   A2            ¢
OR C                   ;320A   B1            ±
LD A,H                 ;320B   7C            |
LD A,(0B6BH)           ;320C   3A 6B 0B      :k
SBC A,80H              ;320F   DE 80         Þ
DEC B                  ;3211   05            
INC HL                 ;3212   23            #
RST 00H                ;3213   C7            Ç
ADC A,D                ;3214   8A            
LD (HL),E              ;3215   73            s
POP HL                 ;3216   E1            á
JP 2A3CH               ;3217   C3 3C 2A      Ã<*
PUSH HL                ;321A   E5            å
CALL 28DEH             ;321B   CD DE 28      ÍÞ(
CALL 28F9H             ;321E   CD F9 28      Íù(
POP HL                 ;3221   E1            á
JP 2A3CH               ;3222   C3 3C 2A      Ã<*
CALL 32FBH             ;3225   CD FB 32      Íû2
CALL 289BH             ;3228   CD 9B 28      Í(
LD IX,(CDD5H)          ;322B   DD 2A D5 CD   Ý*ÕÍ
LD D,33H               ;322F   16 33         3
LD A,(3217H)           ;3231   3A 17 32      :2
OR A                   ;3234   B7            ·
JP Z,32DCH             ;3235   CA DC 32      ÊÜ2
JP M,3242H             ;3238   FA 42 32      úB2
CP 09H                 ;323B   FE 09         þ	
JP C,32A1H             ;323D   DA A1 32      Ú¡2
JR 3247H               ;3240   18 05         
CP FFH                 ;3242   FE FF         þÿ
JP NC,32D6H            ;3244   D2 D6 32      ÒÖ2
LD A,2EH               ;3247   3E 2E         >.
LD (3219H),A           ;3249   32 19 32      22
LD HL,3222H            ;324C   21 22 32      !"2
XOR A                  ;324F   AF            ¯
DEC HL                 ;3250   2B            +
CP (HL)                ;3251   BE            ¾
JR Z,3250H             ;3252   28 FC         (ü
LD A,(HL)              ;3254   7E            ~
CP 2EH                 ;3255   FE 2E         þ.
JP Z,3309H             ;3257   CA 09 33      Ê	3
INC HL                 ;325A   23            #
LD (HL),45H            ;325B   36 45         6E
INC HL                 ;325D   23            #
LD A,(3217H)           ;325E   3A 17 32      :2
LD B,2BH               ;3261   06 2B         +
OR A                   ;3263   B7            ·
JP P,3270H             ;3264   F2 70 32      òp2
CP EDH                 ;3267   FE ED         þí
JP C,3309H             ;3269   DA 09 33      Ú	3
LD B,2DH               ;326C   06 2D         -
CPL                    ;326E   2F            /
INC A                  ;326F   3C            <
LD (HL),B              ;3270   70            p
INC HL                 ;3271   23            #
LD BC,FF0AH            ;3272   01 0A FF      
ÿ
INC B                  ;3275   04            
SUB C                  ;3276   91            
JR NC,3275H            ;3277   30 FC         0ü
ADD A,C                ;3279   81            
LD (HL),B              ;327A   70            p
INC HL                 ;327B   23            #
LD (HL),A              ;327C   77            w
INC HL                 ;327D   23            #
LD (HL),0DH            ;327E   36 0D         6
LD HL,3218H            ;3280   21 18 32      !2
INC HL                 ;3283   23            #
LD A,(HL)              ;3284   7E            ~
CP 0DH                 ;3285   FE 0D         þ
JP Z,3293H             ;3287   CA 93 32      Ê2
JP NC,3283H            ;328A   D2 83 32      Ò2
OR 30H                 ;328D   F6 30         ö0
LD (HL),A              ;328F   77            w
JP 3283H               ;3290   C3 83 32      Ã2
LD DE,3218H            ;3293   11 18 32      2
XOR A                  ;3296   AF            ¯
SBC HL,DE              ;3297   ED 52         íR
LD B,H                 ;3299   44            D
LD C,L                 ;329A   4D            M
POP HL                 ;329B   E1            á
EX DE,HL               ;329C   EB            ë
INC BC                 ;329D   03            
LDIR                   ;329E   ED B0         í°
RET                    ;32A0   C9            É
LD HL,321AH            ;32A1   21 1A 32      !2
LD DE,3219H            ;32A4   11 19 32      2
LD B,A                 ;32A7   47            G
INC B                  ;32A8   04            
DEC B                  ;32A9   05            
JP Z,32B4H             ;32AA   CA B4 32      Ê´2
LD A,(HL)              ;32AD   7E            ~
LD (DE),A              ;32AE   12            
INC HL                 ;32AF   23            #
INC DE                 ;32B0   13            
JP 32A9H               ;32B1   C3 A9 32      Ã©2
LD A,2EH               ;32B4   3E 2E         >.
LD (DE),A              ;32B6   12            
LD HL,3222H            ;32B7   21 22 32      !"2
LD (HL),0DH            ;32BA   36 0D         6
DEC HL                 ;32BC   2B            +
LD A,(HL)              ;32BD   7E            ~
OR A                   ;32BE   B7            ·
JR Z,32BAH             ;32BF   28 F9         (ù
CP 2EH                 ;32C1   FE 2E         þ.
JP NZ,32C8H            ;32C3   C2 C8 32      ÂÈ2
LD (HL),0DH            ;32C6   36 0D         6
LD HL,3219H            ;32C8   21 19 32      !2
LD A,(HL)              ;32CB   7E            ~
CP 0DH                 ;32CC   FE 0D         þ
JP NZ,3280H            ;32CE   C2 80 32      Â2
LD (HL),00H            ;32D1   36 00         6
JP 3280H               ;32D3   C3 80 32      Ã2
LD DE,3224H            ;32D6   11 24 32      $2
JP 32DFH               ;32D9   C3 DF 32      Ãß2
LD DE,3223H            ;32DC   11 23 32      #2
LD HL,3221H            ;32DF   21 21 32      !!2
LD A,0DH               ;32E2   3E 0D         >
LD (DE),A              ;32E4   12            
PUSH DE                ;32E5   D5            Õ
DEC DE                 ;32E6   1B            
LD BC,0008H            ;32E7   01 08 00      
LDDR                   ;32EA   ED B8         í¸
EX DE,HL               ;32EC   EB            ë
LD A,(3217H)           ;32ED   3A 17 32      :2
OR A                   ;32F0   B7            ·
JP Z,32F7H             ;32F1   CA F7 32      Ê÷2
LD (HL),00H            ;32F4   36 00         6
DEC HL                 ;32F6   2B            +
LD (HL),2EH            ;32F7   36 2E         6.
DEC HL                 ;32F9   2B            +
LD (HL),00H            ;32FA   36 00         6
POP HL                 ;32FC   E1            á
DEC HL                 ;32FD   2B            +
LD A,(HL)              ;32FE   7E            ~
CP 00H                 ;32FF   FE 00         þ
JP NZ,3280H            ;3301   C2 80 32      Â2
LD (HL),0DH            ;3304   36 0D         6
JP 32FDH               ;3306   C3 FD 32      Ãý2
LD HL,3313H            ;3309   21 13 33      !3
LD BC,0003H            ;330C   01 03 00      
POP DE                 ;330F   D1            Ñ
LDIR                   ;3310   ED B0         í°
RET                    ;3312   C9            É
JR NZ,3345H            ;3313   20 30          0
DEC C                  ;3315   0D            
LD (3215H),HL          ;3316   22 15 32      "2
LD A,(HL)              ;3319   7E            ~
LD B,20H               ;331A   06 20          
OR A                   ;331C   B7            ·
JP M,3322H             ;331D   FA 22 33      ú"3
LD B,2DH               ;3320   06 2D         -
AND 7FH                ;3322   E6 7F         æ
LD (HL),A              ;3324   77            w
LD A,B                 ;3325   78            x
LD (3218H),A           ;3326   32 18 32      22
EX DE,HL               ;3329   EB            ë
LD HL,314DH            ;332A   21 4D 31      !M1
LD A,ECH               ;332D   3E EC         >ì
EX AF,AF'              ;332F   08            
EX AF,AF'              ;3330   08            
INC A                  ;3331   3C            <
EX AF,AF'              ;3332   08            
LD BC,0005H            ;3333   01 05 00      
ADD HL,BC              ;3336   09            	
PUSH HL                ;3337   E5            å
PUSH DE                ;3338   D5            Õ
LD A,(DE)              ;3339   1A            
CALL 33FBH             ;333A   CD FB 33      Íû3
POP DE                 ;333D   D1            Ñ
POP HL                 ;333E   E1            á
JP NC,3330H            ;333F   D2 30 33      Ò03
EX AF,AF'              ;3342   08            
LD (3217H),A           ;3343   32 17 32      22
PUSH DE                ;3346   D5            Õ
LD BC,3358H            ;3347   01 58 33      X3
PUSH BC                ;334A   C5            Å
PUSH DE                ;334B   D5            Õ
LD A,80H               ;334C   3E 80         >
LD (2D48H),A           ;334E   32 48 2D      2H-
LD A,(DE)              ;3351   1A            
SUB (HL)               ;3352   96            
ADD A,81H              ;3353   C6 81         Æ
JP 2F42H               ;3355   C3 42 2F      ÃB/
LD HL,3219H            ;3358   21 19 32      !2
LD (HL),00H            ;335B   36 00         6
INC HL                 ;335D   23            #
EX (SP),HL             ;335E   E3            ã
LD A,(HL)              ;335F   7E            ~
INC HL                 ;3360   23            #
LD E,(HL)              ;3361   5E            ^
INC HL                 ;3362   23            #
LD D,(HL)              ;3363   56            V
INC HL                 ;3364   23            #
PUSH HL                ;3365   E5            å
EX DE,HL               ;3366   EB            ë
EXX                    ;3367   D9            Ù
POP HL                 ;3368   E1            á
LD E,(HL)              ;3369   5E            ^
INC HL                 ;336A   23            #
LD D,(HL)              ;336B   56            V
EX DE,HL               ;336C   EB            ë
SUB C0H                ;336D   D6 C0         ÖÀ
JP NC,3380H            ;336F   D2 80 33      Ò3
SRL H                  ;3372   CB 3C         Ë<
RR L                   ;3374   CB 1D         Ë
EXX                    ;3376   D9            Ù
RR H                   ;3377   CB 1C         Ë
RR L                   ;3379   CB 1D         Ë
EXX                    ;337B   D9            Ù
INC A                  ;337C   3C            <
JP NZ,3372H            ;337D   C2 72 33      Âr3
POP BC                 ;3380   C1            Á
LD A,09H               ;3381   3E 09         >	
EX AF,AF'              ;3383   08            
XOR A                  ;3384   AF            ¯
LD D,H                 ;3385   54            T
LD E,L                 ;3386   5D            ]
EXX                    ;3387   D9            Ù
LD D,H                 ;3388   54            T
LD E,L                 ;3389   5D            ]
ADD HL,HL              ;338A   29            )
EXX                    ;338B   D9            Ù
ADC HL,HL              ;338C   ED 6A         íj
RLA                    ;338E   17            
EXX                    ;338F   D9            Ù
ADD HL,HL              ;3390   29            )
EXX                    ;3391   D9            Ù
ADC HL,HL              ;3392   ED 6A         íj
RLA                    ;3394   17            
EXX                    ;3395   D9            Ù
ADD HL,DE              ;3396   19            
EXX                    ;3397   D9            Ù
ADC HL,DE              ;3398   ED 5A         íZ
LD D,00H               ;339A   16 00         
ADC A,D                ;339C   8A            
EXX                    ;339D   D9            Ù
ADD HL,HL              ;339E   29            )
EXX                    ;339F   D9            Ù
ADC HL,HL              ;33A0   ED 6A         íj
RLA                    ;33A2   17            
LD (BC),A              ;33A3   02            
INC BC                 ;33A4   03            
EX AF,AF'              ;33A5   08            
DEC A                  ;33A6   3D            =
JP NZ,3383H            ;33A7   C2 83 33      Â3
LD HL,3222H            ;33AA   21 22 32      !"2
LD A,(HL)              ;33AD   7E            ~
LD (HL),00H            ;33AE   36 00         6
CP 05H                 ;33B0   FE 05         þ
LD C,00H               ;33B2   0E 00         
JP C,33B8H             ;33B4   DA B8 33      Ú¸3
INC C                  ;33B7   0C            
LD B,0AH               ;33B8   06 0A         

DEC B                  ;33BA   05            
JP Z,33CEH             ;33BB   CA CE 33      ÊÎ3
DEC HL                 ;33BE   2B            +
LD A,(HL)              ;33BF   7E            ~
ADD A,C                ;33C0   81            
LD (HL),A              ;33C1   77            w
SUB 0AH                ;33C2   D6 0A         Ö

LD C,00H               ;33C4   0E 00         
JP C,33BAH             ;33C6   DA BA 33      Úº3
INC C                  ;33C9   0C            
LD (HL),A              ;33CA   77            w
JP 33BAH               ;33CB   C3 BA 33      Ãº3
LD A,(3219H)           ;33CE   3A 19 32      :2
OR A                   ;33D1   B7            ·
RET Z                  ;33D2   C8            È
LD HL,3221H            ;33D3   21 21 32      !!2
LD DE,3222H            ;33D6   11 22 32      "2
LD BC,0009H            ;33D9   01 09 00      	
LDDR                   ;33DC   ED B8         í¸
EX DE,HL               ;33DE   EB            ë
LD (HL),00H            ;33DF   36 00         6
LD A,(3217H)           ;33E1   3A 17 32      :2
INC A                  ;33E4   3C            <
LD (3217H),A           ;33E5   32 17 32      22
JP 33AAH               ;33E8   C3 AA 33      Ãª3
LD BC,0005H            ;33EB   01 05 00      
LD A,(DE)              ;33EE   1A            
OR A                   ;33EF   B7            ·
JP M,33FBH             ;33F0   FA FB 33      úû3
BIT 7,(HL)             ;33F3   CB 7E         Ë~
JR Z,33F9H             ;33F5   28 02         (
SCF                    ;33F7   37            7
RET                    ;33F8   C9            É
EX DE,HL               ;33F9   EB            ë
LD A,(DE)              ;33FA   1A            
CP (HL)                ;33FB   BE            ¾
RET NZ                 ;33FC   C0            À
DEC C                  ;33FD   0D            
ADD HL,BC              ;33FE   09            	
EX DE,HL               ;33FF   EB            ë
ADD HL,BC              ;3400   09            	
EX DE,HL               ;3401   EB            ë
LD B,03H               ;3402   06 03         
LD A,(DE)              ;3404   1A            
CP (HL)                ;3405   BE            ¾
RET NZ                 ;3406   C0            À
DEC HL                 ;3407   2B            +
DEC DE                 ;3408   1B            
DJNZ 3404H             ;3409   10 F9         ù
LD A,(DE)              ;340B   1A            
CP (HL)                ;340C   BE            ¾
RET                    ;340D   C9            É
EX DE,HL               ;340E   EB            ë
CALL 3316H             ;340F   CD 16 33      Í3
LD A,(3218H)           ;3412   3A 18 32      :2
LD B,80H               ;3415   06 80         
CP 20H                 ;3417   FE 20         þ 
JP Z,341EH             ;3419   CA 1E 34      Ê4
LD B,00H               ;341C   06 00         
LD A,B                 ;341E   78            x
LD (2D48H),A           ;341F   32 48 2D      2H-
OR A                   ;3422   B7            ·
JP Z,34A7H             ;3423   CA A7 34      Ê4
LD A,(3217H)           ;3426   3A 17 32      :2
DEC A                  ;3429   3D            =
JP M,34DFH             ;342A   FA DF 34      úß4
LD HL,3222H            ;342D   21 22 32      !"2
LD B,0DH               ;3430   06 0D         
LD (HL),B              ;3432   70            p
SUB 08H                ;3433   D6 08         Ö
JR NC,343DH            ;3435   30 06         0
LD (HL),B              ;3437   70            p
DEC HL                 ;3438   2B            +
INC A                  ;3439   3C            <
JR NZ,3437H            ;343A   20 FB          û
DEC A                  ;343C   3D            =
INC A                  ;343D   3C            <
LD (2FD6H),A           ;343E   32 D6 2F      2Ö/
LD IX,3219H            ;3441   DD 21 19 32   Ý!2
XOR A                  ;3445   AF            ¯
LD H,A                 ;3446   67            g
LD L,A                 ;3447   6F            o
EXX                    ;3448   D9            Ù
LD B,A                 ;3449   47            G
LD C,A                 ;344A   4F            O
LD H,A                 ;344B   67            g
LD L,A                 ;344C   6F            o
LD A,(IX+0H)           ;344D   DD 7E 00      Ý~
CP 0DH                 ;3450   FE 0D         þ
JP Z,345DH             ;3452   CA 5D 34      Ê]4
CALL 30E3H             ;3455   CD E3 30      Íã0
INC IX                 ;3458   DD 23         Ý#
JP 344DH               ;345A   C3 4D 34      ÃM4
LD A,(2FD6H)           ;345D   3A D6 2F      :Ö/
ADD A,1DH              ;3460   C6 1D         Æ
ADD A,C                ;3462   81            
LD (2FD6H),A           ;3463   32 D6 2F      2Ö/
LD A,A0H               ;3466   3E A0         > 
LD (2D49H),A           ;3468   32 49 2D      2I-
PUSH HL                ;346B   E5            å
EXX                    ;346C   D9            Ù
POP BC                 ;346D   C1            Á
LD D,H                 ;346E   54            T
LD E,L                 ;346F   5D            ]
LD HL,347BH            ;3470   21 7B 34      !{4
PUSH HL                ;3473   E5            å
LD HL,(3215H)          ;3474   2A 15 32      *2
PUSH HL                ;3477   E5            å
JP 2E0BH               ;3478   C3 0B 2E      Ã.
LD A,(2FD6H)           ;347B   3A D6 2F      :Ö/
LD C,A                 ;347E   4F            O
LD L,A                 ;347F   6F            o
LD H,00H               ;3480   26 00         &
LD B,H                 ;3482   44            D
ADD HL,HL              ;3483   29            )
ADD HL,HL              ;3484   29            )
ADD HL,BC              ;3485   09            	
LD BC,3120H            ;3486   01 20 31       1
ADD HL,BC              ;3489   09            	
LD DE,(3215H)          ;348A   ED 5B 15 32   í[2
XOR A                  ;348E   AF            ¯
LD (2D47H),A           ;348F   32 47 2D      2G-
LD A,20H               ;3492   3E 20         > 
ADD A,(HL)             ;3494   86            
LD B,A                 ;3495   47            G
LD A,(DE)              ;3496   1A            
AND 7FH                ;3497   E6 7F         æ
ADD A,B                ;3499   80            
JP C,1398H             ;349A   DA 98 13      Ú
SUB 21H                ;349D   D6 21         Ö!
JP NC,34A3H            ;349F   D2 A3 34      Ò£4
XOR A                  ;34A2   AF            ¯
PUSH DE                ;34A3   D5            Õ
JP 2E6DH               ;34A4   C3 6D 2E      Ãm.
LD A,(3217H)           ;34A7   3A 17 32      :2
DEC A                  ;34AA   3D            =
JP M,34E4H             ;34AB   FA E4 34      úä4
LD HL,3222H            ;34AE   21 22 32      !"2
LD BC,0D00H            ;34B1   01 00 0D      
LD (HL),B              ;34B4   70            p
SUB 08H                ;34B5   D6 08         Ö
JP NC,34CAH            ;34B7   D2 CA 34      ÒÊ4
JP 34C5H               ;34BA   C3 C5 34      ÃÅ4
EX AF,AF'              ;34BD   08            
LD A,(HL)              ;34BE   7E            ~
OR A                   ;34BF   B7            ·
JR Z,34C3H             ;34C0   28 01         (
INC C                  ;34C2   0C            
LD (HL),B              ;34C3   70            p
EX AF,AF'              ;34C4   08            
DEC HL                 ;34C5   2B            +
INC A                  ;34C6   3C            <
JR NZ,34BDH            ;34C7   20 F4          ô
DEC A                  ;34C9   3D            =
EX AF,AF'              ;34CA   08            
LD A,C                 ;34CB   79            y
OR A                   ;34CC   B7            ·
JR Z,34DBH             ;34CD   28 0C         (
LD A,(HL)              ;34CF   7E            ~
INC A                  ;34D0   3C            <
LD (HL),A              ;34D1   77            w
CP 0AH                 ;34D2   FE 0A         þ

JR NZ,34DBH            ;34D4   20 05          
LD (HL),00H            ;34D6   36 00         6
DEC HL                 ;34D8   2B            +
JR 34CFH               ;34D9   18 F4         ô
EX AF,AF'              ;34DB   08            
JP 343DH               ;34DC   C3 3D 34      Ã=4
LD DE,1619H            ;34DF   11 19 16      
JR 34E7H               ;34E2   18 03         
LD DE,161EH            ;34E4   11 1E 16      
LD HL,(3215H)          ;34E7   2A 15 32      *2
EX DE,HL               ;34EA   EB            ë
LD BC,0005H            ;34EB   01 05 00      
LDIR                   ;34EE   ED B0         í°
RET                    ;34F0   C9            É
PUSH DE                ;34F1   D5            Õ
CALL 33EBH             ;34F2   CD EB 33      Íë3
JP Z,34FDH             ;34F5   CA FD 34      Êý4
LD HL,161EH            ;34F8   21 1E 16      !
JR 3500H               ;34FB   18 03         
LD HL,1619H            ;34FD   21 19 16      !
POP DE                 ;3500   D1            Ñ
JP 34EBH               ;3501   C3 EB 34      Ãë4
PUSH DE                ;3504   D5            Õ
EX DE,HL               ;3505   EB            ë
JR 3509H               ;3506   18 01         
PUSH DE                ;3508   D5            Õ
CALL 33EBH             ;3509   CD EB 33      Íë3
JP C,34F8H             ;350C   DA F8 34      Úø4
JP 34FDH               ;350F   C3 FD 34      Ãý4
PUSH DE                ;3512   D5            Õ
CALL 33EBH             ;3513   CD EB 33      Íë3
JP Z,34F8H             ;3516   CA F8 34      Êø4
JP 34FDH               ;3519   C3 FD 34      Ãý4
PUSH DE                ;351C   D5            Õ
EX DE,HL               ;351D   EB            ë
JR 3521H               ;351E   18 01         
PUSH DE                ;3520   D5            Õ
CALL 33EBH             ;3521   CD EB 33      Íë3
JP C,34FDH             ;3524   DA FD 34      Úý4
JP 34F8H               ;3527   C3 F8 34      Ãø4
CP (HL)                ;352A   BE            ¾
DEC (HL)               ;352B   35            5
JR Z,350AH             ;352C   28 DC         (Ü
RST 08H                ;352E   CF            Ï
PUSH DE                ;352F   D5            Õ
EX DE,HL               ;3530   EB            ë
LD A,(HL)              ;3531   7E            ~
LD BC,0004H            ;3532   01 04 00      
ADD HL,BC              ;3535   09            	
XOR (HL)               ;3536   AE            ®
JP M,355CH             ;3537   FA 5C 35      ú\5
LD DE,352AH            ;353A   11 2A 35      *5
PUSH DE                ;353D   D5            Õ
LD HL,3583H            ;353E   21 83 35      !5
CALL 2E59H             ;3541   CD 59 2E      ÍY.
POP HL                 ;3544   E1            á
PUSH HL                ;3545   E5            å
LD A,(HL)              ;3546   7E            ~
INC HL                 ;3547   23            #
LD E,(HL)              ;3548   5E            ^
INC HL                 ;3549   23            #
LD D,(HL)              ;354A   56            V
INC HL                 ;354B   23            #
LD C,(HL)              ;354C   4E            N
INC HL                 ;354D   23            #
LD B,(HL)              ;354E   46            F
CP C1H                 ;354F   FE C1         þÁ
CALL NC,356BH          ;3551   D4 6B 35      Ôk5
POP HL                 ;3554   E1            á
PUSH HL                ;3555   E5            å
CALL 2DE4H             ;3556   CD E4 2D      Íä-
JP 3566H               ;3559   C3 66 35      Ãf5
LD DE,352AH            ;355C   11 2A 35      *5
LD HL,357EH            ;355F   21 7E 35      !~5
PUSH DE                ;3562   D5            Õ
CALL 34EBH             ;3563   CD EB 34      Íë4
POP HL                 ;3566   E1            á
POP DE                 ;3567   D1            Ñ
JP 34EBH               ;3568   C3 EB 34      Ãë4
SUB C0H                ;356B   D6 C0         ÖÀ
SLA E                  ;356D   CB 23         Ë#
RL D                   ;356F   CB 12         Ë
RL C                   ;3571   CB 11         Ë
RL B                   ;3573   CB 10         Ë
DEC A                  ;3575   3D            =
JP NZ,356DH            ;3576   C2 6D 35      Âm5
LD A,C0H               ;3579   3E C0         >À
JP 3661H               ;357B   C3 61 36      Ãa6
CP (HL)                ;357E   BE            ¾
DEC (HL)               ;357F   35            5
JR Z,355EH             ;3580   28 DC         (Ü
RST 08H                ;3582   CF            Ï
PUSH BC                ;3583   C5            Å
NOP                    ;3584   00            
NOP                    ;3585   00            
NOP                    ;3586   00            
CP B                   ;3587   B8            ¸
LD (HL),E              ;3588   73            s
LD E,(HL)              ;3589   5E            ^
INC HL                 ;358A   23            #
LD D,20H               ;358B   16 20          
CALL 34E4H             ;358D   CD E4 34      Íä4
CALL 2820H             ;3590   CD 20 28      Í (
ADD HL,BC              ;3593   09            	
LD (73C6H),HL          ;3594   22 C6 73      "Æs
JP 341DH               ;3597   C3 1D 34      Ã4
CALL 11B3H             ;359A   CD B3 11      Í³
ADC A,B                ;359D   88            
DEC (HL)               ;359E   35            5
JP 2D4DH               ;359F   C3 4D 2D      ÃM-
CALL 359CH             ;35A2   CD 9C 35      Í5
LD HL,358DH            ;35A5   21 8D 35      !5
LD DE,3588H            ;35A8   11 88 35      5
JP 2E59H               ;35AB   C3 59 2E      ÃY.
OR B                   ;35AE   B0            °
LD (HL),E              ;35AF   73            s
PUSH DE                ;35B0   D5            Õ
LD HL,3684H            ;35B1   21 84 36      !6
CALL 2F30H             ;35B4   CD 30 2F      Í0/
POP HL                 ;35B7   E1            á
PUSH HL                ;35B8   E5            å
LD A,(HL)              ;35B9   7E            ~
LD (35AFH),A           ;35BA   32 AF 35      2¯5
OR 80H                 ;35BD   F6 80         ö
INC HL                 ;35BF   23            #
LD E,(HL)              ;35C0   5E            ^
INC HL                 ;35C1   23            #
LD D,(HL)              ;35C2   56            V
INC HL                 ;35C3   23            #
LD C,(HL)              ;35C4   4E            N
INC HL                 ;35C5   23            #
LD B,(HL)              ;35C6   46            F
CP C3H                 ;35C7   FE C3         þÃ
JP C,35DFH             ;35C9   DA DF 35      Úß5
SUB C2H                ;35CC   D6 C2         ÖÂ
SLA E                  ;35CE   CB 23         Ë#
RL D                   ;35D0   CB 12         Ë
RL C                   ;35D2   CB 11         Ë
RL B                   ;35D4   CB 10         Ë
DEC A                  ;35D6   3D            =
JP NZ,35CEH            ;35D7   C2 CE 35      ÂÎ5
LD A,C2H               ;35DA   3E C2         >Â
CALL 3661H             ;35DC   CD 61 36      Ía6
LD HL,8000H            ;35DF   21 00 80      !
CP C2H                 ;35E2   FE C2         þÂ
JR C,35ECH             ;35E4   38 06         8
LD H,L                 ;35E6   65            e
RES 7,B                ;35E7   CB B8         Ë¸
CALL 3661H             ;35E9   CD 61 36      Ía6
CP C1H                 ;35EC   FE C1         þÁ
JR C,35F6H             ;35EE   38 06         8
INC L                  ;35F0   2C            ,
RES 7,B                ;35F1   CB B8         Ë¸
CALL 3661H             ;35F3   CD 61 36      Ía6
EX AF,AF'              ;35F6   08            
LD A,(35AFH)           ;35F7   3A AF 35      :¯5
XOR H                  ;35FA   AC            ¬
CPL                    ;35FB   2F            /
AND 80H                ;35FC   E6 80         æ
LD H,A                 ;35FE   67            g
LD (35AEH),HL          ;35FF   22 AE 35      "®5
EX AF,AF'              ;3602   08            
POP HL                 ;3603   E1            á
PUSH HL                ;3604   E5            å
CALL 2DE4H             ;3605   CD E4 2D      Íä-
LD A,(35AEH)           ;3608   3A AE 35      :®5
OR A                   ;360B   B7            ·
JR Z,3616H             ;360C   28 08         (
POP DE                 ;360E   D1            Ñ
PUSH DE                ;360F   D5            Õ
LD HL,1614H            ;3610   21 14 16      !
CALL 2D4AH             ;3613   CD 4A 2D      ÍJ-
POP HL                 ;3616   E1            á
PUSH HL                ;3617   E5            å
LD A,(HL)              ;3618   7E            ~
AND 7FH                ;3619   E6 7F         æ
LD B,A                 ;361B   47            G
LD A,(35AFH)           ;361C   3A AF 35      :¯5
OR B                   ;361F   B0            °
LD (HL),A              ;3620   77            w
LD DE,3588H            ;3621   11 88 35      5
CALL 34EBH             ;3624   CD EB 34      Íë4
LD DE,358DH            ;3627   11 8D 35      5
LD HL,3588H            ;362A   21 88 35      !5
CALL 34EBH             ;362D   CD EB 34      Íë4
CALL 35A5H             ;3630   CD A5 35      Í¥5
LD DE,358DH            ;3633   11 8D 35      5
LD HL,3588H            ;3636   21 88 35      !5
CALL 34EBH             ;3639   CD EB 34      Íë4
LD HL,3689H            ;363C   21 89 36      !6
CALL 35A8H             ;363F   CD A8 35      Í¨5
LD HL,368EH            ;3642   21 8E 36      !6
CALL 35A2H             ;3645   CD A2 35      Í¢5
LD HL,3693H            ;3648   21 93 36      !6
CALL 35A2H             ;364B   CD A2 35      Í¢5
LD HL,3698H            ;364E   21 98 36      !6
CALL 35A2H             ;3651   CD A2 35      Í¢5
LD HL,369DH            ;3654   21 9D 36      !6
CALL 359CH             ;3657   CD 9C 35      Í5
POP DE                 ;365A   D1            Ñ
LD HL,3588H            ;365B   21 88 35      !5
JP 2E59H               ;365E   C3 59 2E      ÃY.
BIT 7,B                ;3661   CB 78         Ëx
RET NZ                 ;3663   C0            À
EX AF,AF'              ;3664   08            
LD A,B                 ;3665   78            x
OR C                   ;3666   B1            ±
OR E                   ;3667   B3            ³
OR D                   ;3668   B2            ²
JP Z,367BH             ;3669   CA 7B 36      Ê{6
EX AF,AF'              ;366C   08            
BIT 7,B                ;366D   CB 78         Ëx
RET NZ                 ;366F   C0            À
SLA E                  ;3670   CB 23         Ë#
RL D                   ;3672   CB 12         Ë
RL C                   ;3674   CB 11         Ë
RL B                   ;3676   CB 10         Ë
DEC A                  ;3678   3D            =
JR NZ,366DH            ;3679   20 F2          ò
LD BC,0000H            ;367B   01 00 00      
LD DE,0000H            ;367E   11 00 00      
LD A,80H               ;3681   3E 80         >
RET                    ;3683   C9            É
POP BC                 ;3684   C1            Á
AND C                  ;3685   A1            ¡
JP C,C90FH             ;3686   DA 0F C9      ÚÉ
OR H                   ;3689   B4            ´
CALL C,0A0FH           ;368A   DC 0F 0A      Ü

SBC A,A                ;368D   9F            
ADD HL,SP              ;368E   39            9
LD H,C                 ;368F   61            a
ADC A,A                ;3690   8F            
ADD HL,HL              ;3691   29            )
SBC A,C                ;3692   99            
CP L                   ;3693   BD            ½
RET Z                  ;3694   C8            È
LD (HL),A              ;3695   77            w
INC (HL)               ;3696   34            4
AND E                  ;3697   A3            £
LD B,B                 ;3698   40            @
ADD A,L                ;3699   85            
POP HL                 ;369A   E1            á
LD E,L                 ;369B   5D            ]
AND L                  ;369C   A5            ¥
POP BC                 ;369D   C1            Á
SUB H                  ;369E   94            
JP C,C90FH             ;369F   DA 0F C9      ÚÉ
PUSH DE                ;36A2   D5            Õ
LD HL,3684H            ;36A3   21 84 36      !6
CALL 2D4AH             ;36A6   CD 4A 2D      ÍJ-
POP HL                 ;36A9   E1            á
CALL 3B45H             ;36AA   CD 45 3B      ÍE;
EX DE,HL               ;36AD   EB            ë
JP 35B0H               ;36AE   C3 B0 35      Ã°5
PUSH DE                ;36B1   D5            Õ
EX DE,HL               ;36B2   EB            ë
LD DE,3597H            ;36B3   11 97 35      5
CALL 34EBH             ;36B6   CD EB 34      Íë4
POP DE                 ;36B9   D1            Ñ
PUSH DE                ;36BA   D5            Õ
CALL 36A2H             ;36BB   CD A2 36      Í¢6
POP HL                 ;36BE   E1            á
PUSH HL                ;36BF   E5            å
LD DE,3592H            ;36C0   11 92 35      5
CALL 34EBH             ;36C3   CD EB 34      Íë4
POP DE                 ;36C6   D1            Ñ
PUSH DE                ;36C7   D5            Õ
LD HL,3597H            ;36C8   21 97 35      !5
CALL 34EBH             ;36CB   CD EB 34      Íë4
POP DE                 ;36CE   D1            Ñ
PUSH DE                ;36CF   D5            Õ
CALL 35B0H             ;36D0   CD B0 35      Í°5
POP DE                 ;36D3   D1            Ñ
LD HL,3592H            ;36D4   21 92 35      !5
JP 2F30H               ;36D7   C3 30 2F      Ã0/
LD B,L                 ;36DA   45            E
XOR E                  ;36DB   AB            «
LD A,03H               ;36DC   3E 03         >
LD (36DAH),A           ;36DE   32 DA 36      2Ú6
PUSH DE                ;36E1   D5            Õ
EX DE,HL               ;36E2   EB            ë
LD A,(HL)              ;36E3   7E            ~
ADD A,80H              ;36E4   C6 80         Æ
JP NC,1398H            ;36E6   D2 98 13      Ò
JP NZ,36F9H            ;36E9   C2 F9 36      Âù6
EX AF,AF'              ;36EC   08            
LD BC,0004H            ;36ED   01 04 00      
ADD HL,BC              ;36F0   09            	
LD A,(HL)              ;36F1   7E            ~
SBC HL,BC              ;36F2   ED 42         íB
OR A                   ;36F4   B7            ·
JP P,375CH             ;36F5   F2 5C 37      ò\7
EX AF,AF'              ;36F8   08            
BIT 0,A                ;36F9   CB 47         ËG
JP NZ,3778H            ;36FB   C2 78 37      Âx7
LD (36DBH),A           ;36FE   32 DB 36      2Û6
LD (HL),C0H            ;3701   36 C0         6À
LD DE,3588H            ;3703   11 88 35      5
CALL 34EBH             ;3706   CD EB 34      Íë4
LD HL,3790H            ;3709   21 90 37      !7
CALL 35A8H             ;370C   CD A8 35      Í¨5
LD HL,3795H            ;370F   21 95 37      !7
CALL 359CH             ;3712   CD 9C 35      Í5
LD DE,358DH            ;3715   11 8D 35      5
POP HL                 ;3718   E1            á
PUSH HL                ;3719   E5            å
CALL 34EBH             ;371A   CD EB 34      Íë4
LD DE,358DH            ;371D   11 8D 35      5
LD HL,3588H            ;3720   21 88 35      !5
CALL 2F30H             ;3723   CD 30 2F      Í0/
LD HL,358DH            ;3726   21 8D 35      !5
CALL 359CH             ;3729   CD 9C 35      Í5
LD HL,3588H            ;372C   21 88 35      !5
LD A,(HL)              ;372F   7E            ~
AND 7FH                ;3730   E6 7F         æ
DEC A                  ;3732   3D            =
JP C,375CH             ;3733   DA 5C 37      Ú\7
OR 80H                 ;3736   F6 80         ö
LD (HL),A              ;3738   77            w
LD A,(36DAH)           ;3739   3A DA 36      :Ú6
DEC A                  ;373C   3D            =
LD (36DAH),A           ;373D   32 DA 36      2Ú6
JP NZ,3715H            ;3740   C2 15 37      Â7
LD A,(36DBH)           ;3743   3A DB 36      :Û6
CP 40H                 ;3746   FE 40         þ@
CALL NZ,3763H          ;3748   C4 63 37      Äc7
LD B,(HL)              ;374B   46            F
RES 7,B                ;374C   CB B8         Ë¸
ADD A,B                ;374E   80            
SUB 40H                ;374F   D6 40         Ö@
JP C,375CH             ;3751   DA 5C 37      Ú\7
JP M,1398H             ;3754   FA 98 13      ú
OR 80H                 ;3757   F6 80         ö
LD (HL),A              ;3759   77            w
JR 375FH               ;375A   18 03         
LD HL,1619H            ;375C   21 19 16      !
POP DE                 ;375F   D1            Ñ
JP 34EBH               ;3760   C3 EB 34      Ãë4
JP C,376DH             ;3763   DA 6D 37      Úm7
SUB 40H                ;3766   D6 40         Ö@
SRL A                  ;3768   CB 3F         Ë?
ADD A,40H              ;376A   C6 40         Æ@
RET                    ;376C   C9            É
LD B,A                 ;376D   47            G
LD A,40H               ;376E   3E 40         >@
SUB B                  ;3770   90            
SRL A                  ;3771   CB 3F         Ë?
LD B,A                 ;3773   47            G
LD A,40H               ;3774   3E 40         >@
SUB B                  ;3776   90            
RET                    ;3777   C9            É
INC A                  ;3778   3C            <
LD (36DBH),A           ;3779   32 DB 36      2Û6
LD (HL),BFH            ;377C   36 BF         6¿
LD DE,3588H            ;377E   11 88 35      5
CALL 34EBH             ;3781   CD EB 34      Íë4
LD HL,379AH            ;3784   21 9A 37      !7
CALL 35A8H             ;3787   CD A8 35      Í¨5
LD HL,379FH            ;378A   21 9F 37      !7
JP 3712H               ;378D   C3 12 37      Ã7
RET NZ                 ;3790   C0            À
NOP                    ;3791   00            
NOP                    ;3792   00            
NOP                    ;3793   00            
SUB B                  ;3794   90            
CP A                   ;3795   BF            ¿
NOP                    ;3796   00            
NOP                    ;3797   00            
NOP                    ;3798   00            
RET PO                 ;3799   E0            à
RET NZ                 ;379A   C0            À
NOP                    ;379B   00            
NOP                    ;379C   00            
NOP                    ;379D   00            
RET PO                 ;379E   E0            à
CP A                   ;379F   BF            ¿
NOP                    ;37A0   00            
NOP                    ;37A1   00            
NOP                    ;37A2   00            
SUB B                  ;37A3   90            
INC HL                 ;37A4   23            #
ADD HL,HL              ;37A5   29            )
PUSH DE                ;37A6   D5            Õ
LD A,(DE)              ;37A7   1A            
AND 80H                ;37A8   E6 80         æ
LD (37A4H),A           ;37AA   32 A4 37      2¤7
LD A,(DE)              ;37AD   1A            
OR 80H                 ;37AE   F6 80         ö
LD (DE),A              ;37B0   12            
LD HL,38D7H            ;37B1   21 D7 38      !×8
CALL 2F30H             ;37B4   CD 30 2F      Í0/
POP HL                 ;37B7   E1            á
PUSH HL                ;37B8   E5            å
LD A,40H               ;37B9   3E 40         >@
LD (37A5H),A           ;37BB   32 A5 37      2¥7
LD A,(HL)              ;37BE   7E            ~
SUB C1H                ;37BF   D6 C1         ÖÁ
CALL NC,3861H          ;37C1   D4 61 38      Ôa8
POP DE                 ;37C4   D1            Ñ
PUSH DE                ;37C5   D5            Õ
LD HL,38D2H            ;37C6   21 D2 38      !Ò8
CALL 2D4AH             ;37C9   CD 4A 2D      ÍJ-
POP HL                 ;37CC   E1            á
PUSH HL                ;37CD   E5            å
LD DE,3588H            ;37CE   11 88 35      5
CALL 34EBH             ;37D1   CD EB 34      Íë4
LD HL,38AFH            ;37D4   21 AF 38      !¯8
CALL 35A8H             ;37D7   CD A8 35      Í¨5
LD HL,38B4H            ;37DA   21 B4 38      !´8
CALL 359CH             ;37DD   CD 9C 35      Í5
POP HL                 ;37E0   E1            á
PUSH HL                ;37E1   E5            å
CALL 35A8H             ;37E2   CD A8 35      Í¨5
LD HL,38B9H            ;37E5   21 B9 38      !¹8
CALL 359CH             ;37E8   CD 9C 35      Í5
POP HL                 ;37EB   E1            á
PUSH HL                ;37EC   E5            å
CALL 35A8H             ;37ED   CD A8 35      Í¨5
LD HL,38BEH            ;37F0   21 BE 38      !¾8
CALL 359CH             ;37F3   CD 9C 35      Í5
POP HL                 ;37F6   E1            á
PUSH HL                ;37F7   E5            å
CALL 35A8H             ;37F8   CD A8 35      Í¨5
LD HL,38C3H            ;37FB   21 C3 38      !Ã8
CALL 359CH             ;37FE   CD 9C 35      Í5
POP HL                 ;3801   E1            á
PUSH HL                ;3802   E5            å
CALL 35A8H             ;3803   CD A8 35      Í¨5
LD HL,38C8H            ;3806   21 C8 38      !È8
CALL 359CH             ;3809   CD 9C 35      Í5
POP HL                 ;380C   E1            á
PUSH HL                ;380D   E5            å
CALL 35A8H             ;380E   CD A8 35      Í¨5
LD HL,38CDH            ;3811   21 CD 38      !Í8
CALL 359CH             ;3814   CD 9C 35      Í5
LD HL,3588H            ;3817   21 88 35      !5
LD B,(HL)              ;381A   46            F
RES 7,B                ;381B   CB B8         Ë¸
LD A,(37A5H)           ;381D   3A A5 37      :¥7
ADD A,B                ;3820   80            
JP C,38A5H             ;3821   DA A5 38      Ú¥8
SUB 3FH                ;3824   D6 3F         Ö?
JP C,3895H             ;3826   DA 95 38      Ú8
JP M,38A5H             ;3829   FA A5 38      ú¥8
OR 80H                 ;382C   F6 80         ö
LD (HL),A              ;382E   77            w
LD A,(37A4H)           ;382F   3A A4 37      :¤7
OR A                   ;3832   B7            ·
JP Z,383DH             ;3833   CA 3D 38      Ê=8
LD HL,3588H            ;3836   21 88 35      !5
POP DE                 ;3839   D1            Ñ
JP 34EBH               ;383A   C3 EB 34      Ãë4
POP DE                 ;383D   D1            Ñ
PUSH DE                ;383E   D5            Õ
LD HL,1614H            ;383F   21 14 16      !
CALL 34EBH             ;3842   CD EB 34      Íë4
POP DE                 ;3845   D1            Ñ
PUSH DE                ;3846   D5            Õ
LD A,(DE)              ;3847   1A            
CP FCH                 ;3848   FE FC         þü
PUSH AF                ;384A   F5            õ
JP C,3850H             ;384B   DA 50 38      ÚP8
DEC A                  ;384E   3D            =
LD (DE),A              ;384F   12            
LD HL,3588H            ;3850   21 88 35      !5
CALL 2F30H             ;3853   CD 30 2F      Í0/
POP AF                 ;3856   F1            ñ
POP HL                 ;3857   E1            á
RET C                  ;3858   D8            Ø
LD A,(HL)              ;3859   7E            ~
DEC A                  ;385A   3D            =
LD (HL),A              ;385B   77            w
RET M                  ;385C   F8            ø
PUSH HL                ;385D   E5            å
JP 2DE0H               ;385E   C3 E0 2D      Ãà-
INC HL                 ;3861   23            #
LD E,(HL)              ;3862   5E            ^
INC HL                 ;3863   23            #
LD D,(HL)              ;3864   56            V
INC HL                 ;3865   23            #
LD C,(HL)              ;3866   4E            N
INC HL                 ;3867   23            #
LD B,(HL)              ;3868   46            F
PUSH HL                ;3869   E5            å
INC A                  ;386A   3C            <
LD H,A                 ;386B   67            g
XOR A                  ;386C   AF            ¯
SLA E                  ;386D   CB 23         Ë#
RL D                   ;386F   CB 12         Ë
RL C                   ;3871   CB 11         Ë
RL B                   ;3873   CB 10         Ë
RLA                    ;3875   17            
JP C,38A3H             ;3876   DA A3 38      Ú£8
DEC H                  ;3879   25            %
JP NZ,386DH            ;387A   C2 6D 38      Âm8
ADD A,40H              ;387D   C6 40         Æ@
JP C,38A3H             ;387F   DA A3 38      Ú£8
LD (37A5H),A           ;3882   32 A5 37      2¥7
LD A,C0H               ;3885   3E C0         >À
CALL 3661H             ;3887   CD 61 36      Ía6
POP HL                 ;388A   E1            á
LD (HL),B              ;388B   70            p
DEC HL                 ;388C   2B            +
LD (HL),C              ;388D   71            q
DEC HL                 ;388E   2B            +
LD (HL),D              ;388F   72            r
DEC HL                 ;3890   2B            +
LD (HL),E              ;3891   73            s
DEC HL                 ;3892   2B            +
LD (HL),A              ;3893   77            w
RET                    ;3894   C9            É
LD A,(37A4H)           ;3895   3A A4 37      :¤7
OR A                   ;3898   B7            ·
JP Z,1398H             ;3899   CA 98 13      Ê
LD HL,1619H            ;389C   21 19 16      !
POP DE                 ;389F   D1            Ñ
JP 34EBH               ;38A0   C3 EB 34      Ãë4
POP AF                 ;38A3   F1            ñ
POP AF                 ;38A4   F1            ñ
LD A,(37A4H)           ;38A5   3A A4 37      :¤7
OR A                   ;38A8   B7            ·
JP NZ,1398H            ;38A9   C2 98 13      Â
JP 389CH               ;38AC   C3 9C 38      Ã8
OR E                   ;38AF   B3            ³
LD A,H                 ;38B0   7C            |
ADC A,H                ;38B1   8C            
SUB B                  ;38B2   90            
EX (SP),HL             ;38B3   E3            ã
OR (HL)                ;38B4   B6            ¶
RRA                    ;38B5   1F            
RST 18H                ;38B6   DF            ß
LD H,D                 ;38B7   62            b
RET M                  ;38B8   F8            ø
CP C                   ;38B9   B9            ¹
JP PO,DD6DH            ;38BA   E2 6D DD      âmÝ
SBC A,BCH              ;38BD   DE BC         Þ¼
ADC A,E                ;38BF   8B            
INC SP                 ;38C0   33            3
POP BC                 ;38C1   C1            Á
AND B                  ;38C2   A0             
CP (HL)                ;38C3   BE            ¾
ADC A,C                ;38C4   89            
LD C,D                 ;38C5   4A            J
POP AF                 ;38C6   F1            ñ
XOR L                  ;38C7   AD            ­
CP A                   ;38C8   BF            ¿
INC (HL)               ;38C9   34            4
INC SP                 ;38CA   33            3
JP P,C0FAH             ;38CB   F2 FA C0      òúÀ
LD (HL),F3H            ;38CE   36 F3         6ó
INC B                  ;38D0   04            
OR L                   ;38D1   B5            µ
RET NZ                 ;38D2   C0            À
NOP                    ;38D3   00            
NOP                    ;38D4   00            
NOP                    ;38D5   00            
ADD A,B                ;38D6   80            
RET NZ                 ;38D7   C0            À
RET M                  ;38D8   F8            ø
RLA                    ;38D9   17            
LD (HL),D              ;38DA   72            r
OR C                   ;38DB   B1            ±
LD A,(DE)              ;38DC   1A            
OR 80H                 ;38DD   F6 80         ö
PUSH DE                ;38DF   D5            Õ
LD A,80H               ;38E0   3E 80         >
LD (38DDH),A           ;38E2   32 DD 38      2Ý8
LD (38DCH),A           ;38E5   32 DC 38      2Ü8
EX DE,HL               ;38E8   EB            ë
LD A,(HL)              ;38E9   7E            ~
OR A                   ;38EA   B7            ·
JP P,1398H             ;38EB   F2 98 13      ò
CP 8AH                 ;38EE   FE 8A         þ
JP NC,38FEH            ;38F0   D2 FE 38      Òþ8
XOR A                  ;38F3   AF            ¯
LD (38DCH),A           ;38F4   32 DC 38      2Ü8
EX DE,HL               ;38F7   EB            ë
CALL 36DCH             ;38F8   CD DC 36      ÍÜ6
POP HL                 ;38FB   E1            á
PUSH HL                ;38FC   E5            å
LD A,(HL)              ;38FD   7E            ~
CP C1H                 ;38FE   FE C1         þÁ
CALL C,39BFH           ;3900   DC BF 39      Ü¿9
LD B,00H               ;3903   06 00         
CP C1H                 ;3905   FE C1         þÁ
JP Z,3910H             ;3907   CA 10 39      Ê9
SUB C1H                ;390A   D6 C1         ÖÁ
LD B,A                 ;390C   47            G
LD A,C1H               ;390D   3E C1         >Á
LD (HL),A              ;390F   77            w
LD A,B                 ;3910   78            x
LD (38DEH),A           ;3911   32 DE 38      2Þ8
LD DE,3588H            ;3914   11 88 35      5
CALL 34EBH             ;3917   CD EB 34      Íë4
POP DE                 ;391A   D1            Ñ
PUSH DE                ;391B   D5            Õ
LD HL,3A04H            ;391C   21 04 3A      !:
CALL 2D4AH             ;391F   CD 4A 2D      ÍJ-
LD HL,3A04H            ;3922   21 04 3A      !:
CALL 359CH             ;3925   CD 9C 35      Í5
POP DE                 ;3928   D1            Ñ
PUSH DE                ;3929   D5            Õ
LD HL,3588H            ;392A   21 88 35      !5
CALL 2F30H             ;392D   CD 30 2F      Í0/
POP DE                 ;3930   D1            Ñ
PUSH DE                ;3931   D5            Õ
LD HL,3A09H            ;3932   21 09 3A      !	:
CALL 2E59H             ;3935   CD 59 2E      ÍY.
POP HL                 ;3938   E1            á
PUSH HL                ;3939   E5            å
LD DE,358DH            ;393A   11 8D 35      5
CALL 34EBH             ;393D   CD EB 34      Íë4
POP HL                 ;3940   E1            á
PUSH HL                ;3941   E5            å
LD DE,358DH            ;3942   11 8D 35      5
CALL 2E59H             ;3945   CD 59 2E      ÍY.
LD DE,3588H            ;3948   11 88 35      5
LD HL,358DH            ;394B   21 8D 35      !5
CALL 34EBH             ;394E   CD EB 34      Íë4
LD HL,39F0H            ;3951   21 F0 39      !ð9
CALL 35A8H             ;3954   CD A8 35      Í¨5
LD HL,39F5H            ;3957   21 F5 39      !õ9
CALL 35A2H             ;395A   CD A2 35      Í¢5
LD HL,39FAH            ;395D   21 FA 39      !ú9
CALL 35A2H             ;3960   CD A2 35      Í¢5
LD HL,39FFH            ;3963   21 FF 39      !ÿ9
CALL 359CH             ;3966   CD 9C 35      Í5
POP HL                 ;3969   E1            á
PUSH HL                ;396A   E5            å
CALL 35A8H             ;396B   CD A8 35      Í¨5
LD DE,358DH            ;396E   11 8D 35      5
LD HL,3588H            ;3971   21 88 35      !5
CALL 34EBH             ;3974   CD EB 34      Íë4
LD A,(38DEH)           ;3977   3A DE 38      :Þ8
ADD A,A                ;397A   87            
INC A                  ;397B   3C            <
LD B,A                 ;397C   47            G
LD A,08H               ;397D   3E 08         >
BIT 7,B                ;397F   CB 78         Ëx
JP NZ,398AH            ;3981   C2 8A 39      Â9
SLA B                  ;3984   CB 20         Ë 
DEC A                  ;3986   3D            =
JP NZ,397FH            ;3987   C2 7F 39      Â9
ADD A,C0H              ;398A   C6 C0         ÆÀ
LD HL,3588H            ;398C   21 88 35      !5
LD (HL),A              ;398F   77            w
INC HL                 ;3990   23            #
XOR A                  ;3991   AF            ¯
LD (HL),A              ;3992   77            w
INC HL                 ;3993   23            #
LD (HL),A              ;3994   77            w
INC HL                 ;3995   23            #
LD (HL),A              ;3996   77            w
INC HL                 ;3997   23            #
LD (HL),B              ;3998   70            p
LD HL,3A0EH            ;3999   21 0E 3A      !:
CALL 35A8H             ;399C   CD A8 35      Í¨5
LD HL,358DH            ;399F   21 8D 35      !5
CALL 359CH             ;39A2   CD 9C 35      Í5
LD HL,3588H            ;39A5   21 88 35      !5
LD A,(38DDH)           ;39A8   3A DD 38      :Ý8
CALL 3B43H             ;39AB   CD 43 3B      ÍC;
POP DE                 ;39AE   D1            Ñ
PUSH DE                ;39AF   D5            Õ
CALL 34EBH             ;39B0   CD EB 34      Íë4
POP DE                 ;39B3   D1            Ñ
LD A,(38DCH)           ;39B4   3A DC 38      :Ü8
OR A                   ;39B7   B7            ·
RET NZ                 ;39B8   C0            À
LD HL,3588H            ;39B9   21 88 35      !5
JP 2D4DH               ;39BC   C3 4D 2D      ÃM-
PUSH HL                ;39BF   E5            å
LD DE,3588H            ;39C0   11 88 35      5
CALL 34EBH             ;39C3   CD EB 34      Íë4
POP DE                 ;39C6   D1            Ñ
PUSH DE                ;39C7   D5            Õ
LD HL,1614H            ;39C8   21 14 16      !
CALL 34EBH             ;39CB   CD EB 34      Íë4
POP DE                 ;39CE   D1            Ñ
PUSH DE                ;39CF   D5            Õ
LD HL,3588H            ;39D0   21 88 35      !5
CALL 2F30H             ;39D3   CD 30 2F      Í0/
POP HL                 ;39D6   E1            á
LD A,(HL)              ;39D7   7E            ~
CP C1H                 ;39D8   FE C1         þÁ
JP NC,39E8H            ;39DA   D2 E8 39      Òè9
PUSH HL                ;39DD   E5            å
EX DE,HL               ;39DE   EB            ë
LD HL,1614H            ;39DF   21 14 16      !
CALL 34EBH             ;39E2   CD EB 34      Íë4
POP HL                 ;39E5   E1            á
LD A,C1H               ;39E6   3E C1         >Á
EX AF,AF'              ;39E8   08            
LD A,00H               ;39E9   3E 00         >
LD (38DDH),A           ;39EB   32 DD 38      2Ý8
EX AF,AF'              ;39EE   08            
RET                    ;39EF   C9            É
XOR L                  ;39F0   AD            ­
AND H                  ;39F1   A4            ¤
LD H,D                 ;39F2   62            b
CALL Z,B2AFH           ;39F3   CC AF B2      Ì¯²
SBC A,A                ;39F6   9F            
JP (HL)                ;39F7   E9            é
LD B,A                 ;39F8   47            G
LD SP,HL               ;39F9   F9            ù
CP B                   ;39FA   B8            ¸
AND H                  ;39FB   A4            ¤
ADD A,D                ;39FC   82            
XOR D                  ;39FD   AA            ª
CALL C,BFBFH           ;39FE   DC BF BF      Ü¿¿
CALL Z,AFB0H           ;3A01   CC B0 AF      Ì°¯
POP BC                 ;3A04   C1            Á
INC SP                 ;3A05   33            3
DI                     ;3A06   F3            ó
INC B                  ;3A07   04            
OR L                   ;3A08   B5            µ
JP 7999H               ;3A09   C3 99 79      Ãy
ADD A,D                ;3A0C   82            
CP D                   ;3A0D   BA            º
CP A                   ;3A0E   BF            ¿
RET M                  ;3A0F   F8            ø
RLA                    ;3A10   17            
LD (HL),D              ;3A11   72            r
OR C                   ;3A12   B1            ±
PUSH DE                ;3A13   D5            Õ
CALL 38DFH             ;3A14   CD DF 38      Íß8
POP DE                 ;3A17   D1            Ñ
LD HL,3A1EH            ;3A18   21 1E 3A      !:
JP 2E59H               ;3A1B   C3 59 2E      ÃY.
CP A                   ;3A1E   BF            ¿
XOR C                  ;3A1F   A9            ©
RET C                  ;3A20   D8            Ø
LD E,E                 ;3A21   5B            [
SBC A,03H              ;3A22   DE 03         Þ
OR C                   ;3A24   B1            ±
PUSH DE                ;3A25   D5            Õ
EX DE,HL               ;3A26   EB            ë
LD A,(HL)              ;3A27   7E            ~
AND 80H                ;3A28   E6 80         æ
LD (3A23H),A           ;3A2A   32 23 3A      2#:
SET 7,(HL)             ;3A2D   CB FE         Ëþ
LD DE,1614H            ;3A2F   11 14 16      
CALL 33EBH             ;3A32   CD EB 33      Íë3
LD A,80H               ;3A35   3E 80         >
JP NC,3A53H            ;3A37   D2 53 3A      ÒS:
LD DE,3588H            ;3A3A   11 88 35      5
POP HL                 ;3A3D   E1            á
PUSH HL                ;3A3E   E5            å
CALL 34EBH             ;3A3F   CD EB 34      Íë4
POP DE                 ;3A42   D1            Ñ
PUSH DE                ;3A43   D5            Õ
LD HL,1614H            ;3A44   21 14 16      !
CALL 34EBH             ;3A47   CD EB 34      Íë4
POP DE                 ;3A4A   D1            Ñ
PUSH DE                ;3A4B   D5            Õ
LD HL,3588H            ;3A4C   21 88 35      !5
CALL 2F30H             ;3A4F   CD 30 2F      Í0/
XOR A                  ;3A52   AF            ¯
LD (3A24H),A           ;3A53   32 24 3A      2$:
POP HL                 ;3A56   E1            á
PUSH HL                ;3A57   E5            å
LD DE,3588H            ;3A58   11 88 35      5
CALL 34EBH             ;3A5B   CD EB 34      Íë4
POP HL                 ;3A5E   E1            á
PUSH HL                ;3A5F   E5            å
CALL 35A8H             ;3A60   CD A8 35      Í¨5
LD HL,3588H            ;3A63   21 88 35      !5
LD DE,358DH            ;3A66   11 8D 35      5
CALL 34EBH             ;3A69   CD EB 34      Íë4
LD HL,3AD3H            ;3A6C   21 D3 3A      !Ó:
CALL 35A8H             ;3A6F   CD A8 35      Í¨5
LD HL,3AD8H            ;3A72   21 D8 3A      !Ø:
CALL 35A2H             ;3A75   CD A2 35      Í¢5
LD HL,3ADDH            ;3A78   21 DD 3A      !Ý:
CALL 35A2H             ;3A7B   CD A2 35      Í¢5
LD HL,3AE2H            ;3A7E   21 E2 3A      !â:
CALL 35A2H             ;3A81   CD A2 35      Í¢5
LD HL,3AE7H            ;3A84   21 E7 3A      !ç:
CALL 35A2H             ;3A87   CD A2 35      Í¢5
LD HL,3AECH            ;3A8A   21 EC 3A      !ì:
CALL 35A2H             ;3A8D   CD A2 35      Í¢5
LD HL,3AF1H            ;3A90   21 F1 3A      !ñ:
CALL 35A2H             ;3A93   CD A2 35      Í¢5
LD HL,3AF6H            ;3A96   21 F6 3A      !ö:
CALL 35A2H             ;3A99   CD A2 35      Í¢5
LD HL,3AFBH            ;3A9C   21 FB 3A      !û:
CALL 35A2H             ;3A9F   CD A2 35      Í¢5
LD HL,1614H            ;3AA2   21 14 16      !
CALL 359CH             ;3AA5   CD 9C 35      Í5
POP HL                 ;3AA8   E1            á
PUSH HL                ;3AA9   E5            å
CALL 35A8H             ;3AAA   CD A8 35      Í¨5
POP DE                 ;3AAD   D1            Ñ
PUSH DE                ;3AAE   D5            Õ
LD HL,3588H            ;3AAF   21 88 35      !5
CALL 34EBH             ;3AB2   CD EB 34      Íë4
LD A,(3A24H)           ;3AB5   3A 24 3A      :$:
OR A                   ;3AB8   B7            ·
JP NZ,3ACCH            ;3AB9   C2 CC 3A      ÂÌ:
POP DE                 ;3ABC   D1            Ñ
PUSH DE                ;3ABD   D5            Õ
LD HL,3684H            ;3ABE   21 84 36      !6
CALL 34EBH             ;3AC1   CD EB 34      Íë4
POP DE                 ;3AC4   D1            Ñ
PUSH DE                ;3AC5   D5            Õ
LD HL,3588H            ;3AC6   21 88 35      !5
CALL 2D4AH             ;3AC9   CD 4A 2D      ÍJ-
POP HL                 ;3ACC   E1            á
LD A,(3A23H)           ;3ACD   3A 23 3A      :#:
JP 3B43H               ;3AD0   C3 43 3B      ÃC;
SCF                    ;3AD3   37            7
JP Z,569AH             ;3AD4   CA 9A 56      ÊV
RST 18H                ;3AD7   DF            ß
CP D                   ;3AD8   BA            º
LD (DE),A              ;3AD9   12            
LD (HL),A              ;3ADA   77            w
CALL Z,3BABH           ;3ADB   CC AB 3B      Ì«;
INC HL                 ;3ADE   23            #
OR D                   ;3ADF   B2            ²
LD E,(HL)              ;3AE0   5E            ^
RET M                  ;3AE1   F8            ø
CP H                   ;3AE2   BC            ¼
JR NZ,3B48H            ;3AE3   20 63          c
SUB B                  ;3AE5   90            
JP (HL)                ;3AE6   E9            é
DEC A                  ;3AE7   3D            =
XOR 3DH                ;3AE8   EE 3D         î=
RET PO                 ;3AEA   E0            à
XOR D                  ;3AEB   AA            ª
CP L                   ;3AEC   BD            ½
LD C,A                 ;3AED   4F            O
LD A,(DE)              ;3AEE   1A            
PUSH DE                ;3AEF   D5            Õ
RST 18H                ;3AF0   DF            ß
LD A,E3H               ;3AF1   3E E3         >ã
XOR A                  ;3AF3   AF            ¯
INC BC                 ;3AF4   03            
SUB D                  ;3AF5   92            
CP (HL)                ;3AF6   BE            ¾
LD HL,(C77BH)          ;3AF7   2A 7B C7      *{Ç
CALL Z,173FH           ;3AFA   CC 3F 17      Ì?
SUB (HL)               ;3AFD   96            
XOR D                  ;3AFE   AA            ª
XOR D                  ;3AFF   AA            ª
LD C,73H               ;3B00   0E 73         s
LD (730FH),DE          ;3B02   ED 53 0F 73   íSs
LD (7581H),HL          ;3B06   22 81 75      "u
CALL D527H             ;3B09   CD 27 D5      Í'Õ
LD DE,3B06H            ;3B0C   11 06 3B      ;
CALL 34EBH             ;3B0F   CD EB 34      Íë4
POP HL                 ;3B12   E1            á
PUSH HL                ;3B13   E5            å
LD BC,0004H            ;3B14   01 04 00      
ADD HL,BC              ;3B17   09            	
LD A,(HL)              ;3B18   7E            ~
OR A                   ;3B19   B7            ·
POP HL                 ;3B1A   E1            á
PUSH HL                ;3B1B   E5            å
JP P,2DE0H             ;3B1C   F2 E0 2D      òà-
LD A,(HL)              ;3B1F   7E            ~
AND 80H                ;3B20   E6 80         æ
LD (3B05H),A           ;3B22   32 05 3B      2;
SET 7,(HL)             ;3B25   CB FE         Ëþ
EX DE,HL               ;3B27   EB            ë
CALL 38DFH             ;3B28   CD DF 38      Íß8
LD A,(3B05H)           ;3B2B   3A 05 3B      :;
OR A                   ;3B2E   B7            ·
CALL Z,3B56H           ;3B2F   CC 56 3B      ÌV;
POP DE                 ;3B32   D1            Ñ
PUSH DE                ;3B33   D5            Õ
LD HL,3B06H            ;3B34   21 06 3B      !;
CALL 2E59H             ;3B37   CD 59 2E      ÍY.
POP DE                 ;3B3A   D1            Ñ
PUSH DE                ;3B3B   D5            Õ
CALL 37A6H             ;3B3C   CD A6 37      Í¦7
POP HL                 ;3B3F   E1            á
LD A,(3B05H)           ;3B40   3A 05 3B      :;
OR A                   ;3B43   B7            ·
RET NZ                 ;3B44   C0            À
LD BC,0004H            ;3B45   01 04 00      
ADD HL,BC              ;3B48   09            	
BIT 7,(HL)             ;3B49   CB 7E         Ë~
PUSH AF                ;3B4B   F5            õ
XOR A                  ;3B4C   AF            ¯
SBC HL,BC              ;3B4D   ED 42         íB
POP AF                 ;3B4F   F1            ñ
RET Z                  ;3B50   C8            È
LD A,(HL)              ;3B51   7E            ~
ADD A,80H              ;3B52   C6 80         Æ
LD (HL),A              ;3B54   77            w
RET                    ;3B55   C9            É
LD HL,3B06H            ;3B56   21 06 3B      !;
LD DE,3B00H            ;3B59   11 00 3B      ;
CALL 34EBH             ;3B5C   CD EB 34      Íë4
LD DE,3B06H            ;3B5F   11 06 3B      ;
CALL 340EH             ;3B62   CD 0E 34      Í4
LD DE,3B00H            ;3B65   11 00 3B      ;
LD HL,3B06H            ;3B68   21 06 3B      !;
CALL 2D4AH             ;3B6B   CD 4A 2D      ÍJ-
LD HL,3B04H            ;3B6E   21 04 3B      !;
LD A,(HL)              ;3B71   7E            ~
OR A                   ;3B72   B7            ·
JP M,1398H             ;3B73   FA 98 13      ú
LD HL,3B06H            ;3B76   21 06 3B      !;
LD A,(HL)              ;3B79   7E            ~
INC HL                 ;3B7A   23            #
LD E,(HL)              ;3B7B   5E            ^
INC HL                 ;3B7C   23            #
LD D,(HL)              ;3B7D   56            V
INC HL                 ;3B7E   23            #
LD C,(HL)              ;3B7F   4E            N
INC HL                 ;3B80   23            #
LD B,(HL)              ;3B81   46            F
AND 7FH                ;3B82   E6 7F         æ
SUB 41H                ;3B84   D6 41         ÖA
JP C,3B9BH             ;3B86   DA 9B 3B      Ú;
JP Z,3B98H             ;3B89   CA 98 3B      Ê;
SLA E                  ;3B8C   CB 23         Ë#
RL D                   ;3B8E   CB 12         Ë
RL C                   ;3B90   CB 11         Ë
RL B                   ;3B92   CB 10         Ë
DEC A                  ;3B94   3D            =
JP NZ,3B8CH            ;3B95   C2 8C 3B      Â;
RL B                   ;3B98   CB 10         Ë
RET C                  ;3B9A   D8            Ø
LD A,80H               ;3B9B   3E 80         >
LD (3B05H),A           ;3B9D   32 05 3B      2;
RET                    ;3BA0   C9            É
LD A,(3D16H)           ;3BA1   3A 16 3D      :=
OR A                   ;3BA4   B7            ·
RET Z                  ;3BA5   C8            È
CALL 3C66H             ;3BA6   CD 66 3C      Íf<
RET C                  ;3BA9   D8            Ø
LD A,0DH               ;3BAA   3E 0D         >
CALL 3C77H             ;3BAC   CD 77 3C      Íw<
XOR A                  ;3BAF   AF            ¯
LD (3D16H),A           ;3BB0   32 16 3D      2=
JP 3CB6H               ;3BB3   C3 B6 3C      Ã¶<
CALL 3C66H             ;3BB6   CD 66 3C      Íf<
RET C                  ;3BB9   D8            Ø
PUSH BC                ;3BBA   C5            Å
PUSH DE                ;3BBB   D5            Õ
LD A,(3D16H)           ;3BBC   3A 16 3D      :=
LD B,A                 ;3BBF   47            G
LD A,(DE)              ;3BC0   1A            
CP 0DH                 ;3BC1   FE 0D         þ
JP Z,3C1DH             ;3BC3   CA 1D 3C      Ê<
CP 20H                 ;3BC6   FE 20         þ 
CALL C,3BD3H           ;3BC8   DC D3 3B      ÜÓ;
CALL 3C77H             ;3BCB   CD 77 3C      Íw<
INC B                  ;3BCE   04            
INC DE                 ;3BCF   13            
JP 3BC0H               ;3BD0   C3 C0 3B      ÃÀ;
CP 15H                 ;3BD3   FE 15         þ
JP Z,3BECH             ;3BD5   CA EC 3B      Êì;
CP 12H                 ;3BD8   FE 12         þ
JP Z,3BF1H             ;3BDA   CA F1 3B      Êñ;
CP 11H                 ;3BDD   FE 11         þ
JP Z,3BF6H             ;3BDF   CA F6 3B      Êö;
CP 16H                 ;3BE2   FE 16         þ
JP Z,3BFBH             ;3BE4   CA FB 3B      Êû;
POP AF                 ;3BE7   F1            ñ
INC DE                 ;3BE8   13            
JP 3BC0H               ;3BE9   C3 C0 3B      ÃÀ;
LD A,0FH               ;3BEC   3E 0F         >
LD B,FFH               ;3BEE   06 FF         ÿ
RET                    ;3BF0   C9            É
LD A,0BH               ;3BF1   3E 0B         >
LD B,FFH               ;3BF3   06 FF         ÿ
RET                    ;3BF5   C9            É
LD A,09H               ;3BF6   3E 09         >	
LD B,FFH               ;3BF8   06 FF         ÿ
RET                    ;3BFA   C9            É
LD A,0CH               ;3BFB   3E 0C         >
CALL 3C77H             ;3BFD   CD 77 3C      Íw<
LD A,0AH               ;3C00   3E 0A         >

LD B,FFH               ;3C02   06 FF         ÿ
RET                    ;3C04   C9            É
CALL 3C66H             ;3C05   CD 66 3C      Íf<
RET C                  ;3C08   D8            Ø
PUSH BC                ;3C09   C5            Å
PUSH DE                ;3C0A   D5            Õ
LD A,(3D16H)           ;3C0B   3A 16 3D      :=
LD B,A                 ;3C0E   47            G
LD A,(DE)              ;3C0F   1A            
CP 0DH                 ;3C10   FE 0D         þ
JP Z,3C1DH             ;3C12   CA 1D 3C      Ê<
CALL 3C77H             ;3C15   CD 77 3C      Íw<
INC B                  ;3C18   04            
INC DE                 ;3C19   13            
JP 3C0FH               ;3C1A   C3 0F 3C      Ã<
LD A,B                 ;3C1D   78            x
CP 50H                 ;3C1E   FE 50         þP
JP C,3C25H             ;3C20   DA 25 3C      Ú%<
SUB 50H                ;3C23   D6 50         ÖP
LD (3D16H),A           ;3C25   32 16 3D      2=
POP DE                 ;3C28   D1            Ñ
POP BC                 ;3C29   C1            Á
JP 3CB6H               ;3C2A   C3 B6 3C      Ã¶<
CP 0DH                 ;3C2D   FE 0D         þ
JP Z,3BA6H             ;3C2F   CA A6 3B      Ê¦;
PUSH BC                ;3C32   C5            Å
PUSH DE                ;3C33   D5            Õ
LD C,A                 ;3C34   4F            O
LD A,(3D16H)           ;3C35   3A 16 3D      :=
LD B,A                 ;3C38   47            G
CALL 3C66H             ;3C39   CD 66 3C      Íf<
JP NC,3C42H            ;3C3C   D2 42 3C      ÒB<
POP DE                 ;3C3F   D1            Ñ
POP BC                 ;3C40   C1            Á
RET                    ;3C41   C9            É
LD A,C                 ;3C42   79            y
CALL 3C77H             ;3C43   CD 77 3C      Íw<
INC B                  ;3C46   04            
JP 3C1DH               ;3C47   C3 1D 3C      Ã<
CALL 3C66H             ;3C4A   CD 66 3C      Íf<
RET C                  ;3C4D   D8            Ø
PUSH BC                ;3C4E   C5            Å
PUSH DE                ;3C4F   D5            Õ
LD A,(3D16H)           ;3C50   3A 16 3D      :=
LD B,A                 ;3C53   47            G
LD A,20H               ;3C54   3E 20         > 
CALL 3C77H             ;3C56   CD 77 3C      Íw<
INC B                  ;3C59   04            
LD A,B                 ;3C5A   78            x
SUB 0AH                ;3C5B   D6 0A         Ö

JP C,3C54H             ;3C5D   DA 54 3C      ÚT<
JP NZ,3C5BH            ;3C60   C2 5B 3C      Â[<
JP 3C1DH               ;3C63   C3 1D 3C      Ã<
OR A                   ;3C66   B7            ·
RET                    ;3C67   C9            É
CALL 3C77H             ;3C68   CD 77 3C      Íw<
LD A,00H               ;3C6B   3E 00         >
CALL 3C8DH             ;3C6D   CD 8D 3C      Í<
IN A,(FEH)             ;3C70   DB FE         Ûþ
RRCA                   ;3C72   0F            
RRCA                   ;3C73   0F            
RET                    ;3C74   C9            É
LD A,0FH               ;3C75   3E 0F         >
PUSH AF                ;3C77   F5            õ
LD A,00H               ;3C78   3E 00         >
CALL 3C8DH             ;3C7A   CD 8D 3C      Í<
POP AF                 ;3C7D   F1            ñ
OUT (FFH),A            ;3C7E   D3 FF         Óÿ
LD A,80H               ;3C80   3E 80         >
OUT (FEH),A            ;3C82   D3 FE         Óþ
LD A,01H               ;3C84   3E 01         >
CALL 3C8DH             ;3C86   CD 8D 3C      Í<
XOR A                  ;3C89   AF            ¯
OUT (FEH),A            ;3C8A   D3 FE         Óþ
RET                    ;3C8C   C9            É
PUSH BC                ;3C8D   C5            Å
PUSH DE                ;3C8E   D5            Õ
LD D,A                 ;3C8F   57            W
LD E,06H               ;3C90   1E 06         
LD BC,0000H            ;3C92   01 00 00      
IN A,(FEH)             ;3C95   DB FE         Ûþ
AND 0DH                ;3C97   E6 0D         æ
CP D                   ;3C99   BA            º
JP NZ,3CA0H            ;3C9A   C2 A0 3C      Â <
POP DE                 ;3C9D   D1            Ñ
POP BC                 ;3C9E   C1            Á
RET                    ;3C9F   C9            É
DEC BC                 ;3CA0   0B            
LD A,B                 ;3CA1   78            x
OR C                   ;3CA2   B1            ±
JP NZ,3C95H            ;3CA3   C2 95 3C      Â<
DEC E                  ;3CA6   1D            
JP NZ,3C95H            ;3CA7   C2 95 3C      Â<
CALL 0009H             ;3CAA   CD 09 00      Í	
LD DE,3CE0H            ;3CAD   11 E0 3C      à<
CALL 0015H             ;3CB0   CD 15 00      Í
JP 124BH               ;3CB3   C3 4B 12      ÃK
LD A,07H               ;3CB6   3E 07         >
CALL 3C68H             ;3CB8   CD 68 3C      Íh<
JP NC,3CCAH            ;3CBB   D2 CA 3C      ÒÊ<
LD A,08H               ;3CBE   3E 08         >
CALL 3C68H             ;3CC0   CD 68 3C      Íh<
RET C                  ;3CC3   D8            Ø
LD DE,3D04H            ;3CC4   11 04 3D      =
JP 3CCDH               ;3CC7   C3 CD 3C      ÃÍ<
LD DE,3D0AH            ;3CCA   11 0A 3D      
=
CALL 0009H             ;3CCD   CD 09 00      Í	
CALL 0015H             ;3CD0   CD 15 00      Í
LD DE,3CF9H            ;3CD3   11 F9 3C      ù<
CALL 0015H             ;3CD6   CD 15 00      Í
XOR A                  ;3CD9   AF            ¯
LD (3D16H),A           ;3CDA   32 16 3D      2=
JP 124BH               ;3CDD   C3 4B 12      ÃK
LD C,(HL)              ;3CE0   4E            N
LD C,A                 ;3CE1   4F            O
JR NZ,3D34H            ;3CE2   20 50          P
LD C,A                 ;3CE4   4F            O
LD D,A                 ;3CE5   57            W
LD B,L                 ;3CE6   45            E
LD D,D                 ;3CE7   52            R
JR NZ,3D39H            ;3CE8   20 4F          O
LD D,D                 ;3CEA   52            R
JR NZ,3D3BH            ;3CEB   20 4E          N
LD C,A                 ;3CED   4F            O
JR NZ,3D33H            ;3CEE   20 43          C
LD C,A                 ;3CF0   4F            O
LD C,(HL)              ;3CF1   4E            N
LD C,(HL)              ;3CF2   4E            N
LD B,L                 ;3CF3   45            E
LD B,E                 ;3CF4   43            C
LD D,H                 ;3CF5   54            T
LD C,C                 ;3CF6   49            I
LD C,A                 ;3CF7   4F            O
LD C,(HL)              ;3CF8   4E            N
JR NZ,3D23H            ;3CF9   20 28          (
LD D,B                 ;3CFB   50            P
LD D,D                 ;3CFC   52            R
LD C,C                 ;3CFD   49            I
LD C,(HL)              ;3CFE   4E            N
LD D,H                 ;3CFF   54            T
LD B,L                 ;3D00   45            E
LD D,D                 ;3D01   52            R
ADD HL,HL              ;3D02   29            )
DEC C                  ;3D03   0D            
LD B,C                 ;3D04   41            A
LD C,H                 ;3D05   4C            L
LD B,C                 ;3D06   41            A
LD D,D                 ;3D07   52            R
LD C,L                 ;3D08   4D            M
DEC C                  ;3D09   0D            
LD D,B                 ;3D0A   50            P
LD B,C                 ;3D0B   41            A
LD D,B                 ;3D0C   50            P
LD B,L                 ;3D0D   45            E
LD D,D                 ;3D0E   52            R
JR NZ,3D56H            ;3D0F   20 45          E
LD C,L                 ;3D11   4D            M
LD D,B                 ;3D12   50            P
LD D,H                 ;3D13   54            T
LD E,C                 ;3D14   59            Y
DEC C                  ;3D15   0D            
NOP                    ;3D16   00            
PUSH AF                ;3D17   F5            õ
PUSH BC                ;3D18   C5            Å
PUSH DE                ;3D19   D5            Õ
PUSH HL                ;3D1A   E5            å
LD BC,0000H            ;3D1B   01 00 00      
LD HL,(1171H)          ;3D1E   2A 71 11      *q
LD A,28H               ;3D21   3E 28         >(
SUB L                  ;3D23   95            
LD B,A                 ;3D24   47            G
LD HL,3DB4H            ;3D25   21 B4 3D      !´=
LD A,(DE)              ;3D28   1A            
CP 0DH                 ;3D29   FE 0D         þ
JP NZ,3D36H            ;3D2B   C2 36 3D      Â6=
CALL 3D59H             ;3D2E   CD 59 3D      ÍY=
POP HL                 ;3D31   E1            á
POP DE                 ;3D32   D1            Ñ
POP BC                 ;3D33   C1            Á
POP AF                 ;3D34   F1            ñ
RET                    ;3D35   C9            É
CP 20H                 ;3D36   FE 20         þ 
JP NC,3D47H            ;3D38   D2 47 3D      ÒG=
CALL 3D59H             ;3D3B   CD 59 3D      ÍY=
LD A,(DE)              ;3D3E   1A            
INC DE                 ;3D3F   13            
LD C,A                 ;3D40   4F            O
CALL 0946H             ;3D41   CD 46 09      ÍF	
JP 3D1BH               ;3D44   C3 1B 3D      Ã=
LD A,(DE)              ;3D47   1A            
INC DE                 ;3D48   13            
CALL 0BB9H             ;3D49   CD B9 0B      Í¹
LD (HL),A              ;3D4C   77            w
INC HL                 ;3D4D   23            #
INC C                  ;3D4E   0C            
DEC B                  ;3D4F   05            
JP NZ,3D28H            ;3D50   C2 28 3D      Â(=
CALL 3D59H             ;3D53   CD 59 3D      ÍY=
JP 3D1BH               ;3D56   C3 1B 3D      Ã=
LD A,C                 ;3D59   79            y
OR A                   ;3D5A   B7            ·
RET Z                  ;3D5B   C8            È
PUSH DE                ;3D5C   D5            Õ
LD B,00H               ;3D5D   06 00         
LD A,(1194H)           ;3D5F   3A 94 11      :
ADD A,C                ;3D62   81            
CP 50H                 ;3D63   FE 50         þP
JP C,3D6AH             ;3D65   DA 6A 3D      Új=
SUB 50H                ;3D68   D6 50         ÖP
LD (1194H),A           ;3D6A   32 94 11      2
CALL 0FB1H             ;3D6D   CD B1 0F      Í±
LD A,(1171H)           ;3D70   3A 71 11      :q
ADD A,C                ;3D73   81            
LD (1171H),A           ;3D74   32 71 11      2q
EX DE,HL               ;3D77   EB            ë
LD HL,3DB4H            ;3D78   21 B4 3D      !´=
CALL 0DA6H             ;3D7B   CD A6 0D      Í¦
LDIR                   ;3D7E   ED B0         í°
POP DE                 ;3D80   D1            Ñ
LD HL,(1171H)          ;3D81   2A 71 11      *q
LD A,L                 ;3D84   7D            }
CP 28H                 ;3D85   FE 28         þ(
RET NZ                 ;3D87   C0            À
PUSH DE                ;3D88   D5            Õ
LD E,H                 ;3D89   5C            \
LD D,00H               ;3D8A   16 00         
LD HL,1173H            ;3D8C   21 73 11      !s
ADD HL,DE              ;3D8F   19            
LD A,(HL)              ;3D90   7E            ~
OR A                   ;3D91   B7            ·
JP NZ,3D9BH            ;3D92   C2 9B 3D      Â=
INC HL                 ;3D95   23            #
LD (HL),01H            ;3D96   36 01         6
INC HL                 ;3D98   23            #
LD (HL),00H            ;3D99   36 00         6
LD HL,(1171H)          ;3D9B   2A 71 11      *q
LD L,00H               ;3D9E   2E 00         .
INC H                  ;3DA0   24            $
LD (1171H),HL          ;3DA1   22 71 11      "q
POP DE                 ;3DA4   D1            Ñ
LD A,H                 ;3DA5   7C            |
CP 19H                 ;3DA6   FE 19         þ
RET NZ                 ;3DA8   C0            À
LD H,18H               ;3DA9   26 18         &
LD (1171H),HL          ;3DAB   22 71 11      "q
LD A,C0H               ;3DAE   3E C0         >À
CALL 0DDCH             ;3DB0   CD DC 0D      ÍÜ
RET                    ;3DB3   C9            É
LD HL,(73C4H)          ;3DB4   2A C4 73      *Äs
LD (HL),A              ;3DB7   77            w
INC HL                 ;3DB8   23            #
XOR A                  ;3DB9   AF            ¯
LD (HL),A              ;3DBA   77            w
INC HL                 ;3DBB   23            #
LD (HL),A              ;3DBC   77            w
INC HL                 ;3DBD   23            #
LD (HL),A              ;3DBE   77            w
INC HL                 ;3DBF   23            #
LD (HL),B              ;3DC0   70            p
LD D,A                 ;3DC1   57            W
LD E,A                 ;3DC2   5F            _
LD B,A                 ;3DC3   47            G
LD C,05H               ;3DC4   0E 05         
CALL 29FDH             ;3DC6   CD FD 29      Íý)
CALL 2C1BH             ;3DC9   CD 1B 2C      Í,
RST 08H                ;3DCC   CF            Ï
INC HL                 ;3DCD   23            #
JP 2A39H               ;3DCE   C3 39 2A      Ã9*
CALL 2A30H             ;3DD1   CD 30 2A      Í0*
LD A,E                 ;3DD4   7B            {
CP F0H                 ;3DD5   FE F0         þð
JP NC,23CAH            ;3DD7   D2 CA 23      ÒÊ#
LD (3DE6H),A           ;3DDA   32 E6 3D      2æ=
CALL 2721H             ;3DDD   CD 21 27      Í!'
INC L                  ;3DE0   2C            ,
CALL 2A30H             ;3DE1   CD 30 2A      Í0*
LD A,E                 ;3DE4   7B            {
OUT (FFH),A            ;3DE5   D3 FF         Óÿ
JP 2A3CH               ;3DE7   C3 3C 2A      Ã<*
RET Z                  ;3DEA   C8            È
RST 20H                ;3DEB   E7            ç
SUB H                  ;3DEC   94            
XOR A                  ;3DED   AF            ¯
JR 3DF2H               ;3DEE   18 02         
LD A,80H               ;3DF0   3E 80         >
PUSH DE                ;3DF2   D5            Õ
XOR (HL)               ;3DF3   AE            ®
CPL                    ;3DF4   2F            /
LD C,A                 ;3DF5   4F            O
LD A,(DE)              ;3DF6   1A            
AND 80H                ;3DF7   E6 80         æ
LD B,A                 ;3DF9   47            G
XOR C                  ;3DFA   A9            ©
CPL                    ;3DFB   2F            /
AND 80H                ;3DFC   E6 80         æ
LD C,A                 ;3DFE   4F            O
PUSH BC                ;3DFF   C5            Å
LD B,(HL)              ;3E00   46            F
RES 7,B                ;3E01   CB B8         Ë¸
LD A,(DE)              ;3E03   1A            
AND 7FH                ;3E04   E6 7F         æ
CP B                   ;3E06   B8            ¸
JP NC,3E15H            ;3E07   D2 15 3E      Ò>
POP BC                 ;3E0A   C1            Á
EX DE,HL               ;3E0B   EB            ë
LD A,B                 ;3E0C   78            x
XOR C                  ;3E0D   A9            ©
CPL                    ;3E0E   2F            /
AND 80H                ;3E0F   E6 80         æ
LD B,A                 ;3E11   47            G
JP 3DFFH               ;3E12   C3 FF 3D      Ãÿ=
LD C,A                 ;3E15   4F            O
ADD A,40H              ;3E16   C6 40         Æ@
LD (3DECH),A           ;3E18   32 EC 3D      2ì=
LD A,C                 ;3E1B   79            y
SUB B                  ;3E1C   90            
POP BC                 ;3E1D   C1            Á
LD (3DEAH),BC          ;3E1E   ED 43 EA 3D   íCê=
PUSH DE                ;3E22   D5            Õ
INC HL                 ;3E23   23            #
LD E,(HL)              ;3E24   5E            ^
INC HL                 ;3E25   23            #
LD D,(HL)              ;3E26   56            V
INC HL                 ;3E27   23            #
LD C,(HL)              ;3E28   4E            N
INC HL                 ;3E29   23            #
LD B,(HL)              ;3E2A   46            F
POP HL                 ;3E2B   E1            á
INC HL                 ;3E2C   23            #
JP Z,3E4EH             ;3E2D   CA 4E 3E      ÊN>
CP 08H                 ;3E30   FE 08         þ
JP NC,3E44H            ;3E32   D2 44 3E      ÒD>
SRL B                  ;3E35   CB 38         Ë8
RR C                   ;3E37   CB 19         Ë
RR D                   ;3E39   CB 1A         Ë
RR E                   ;3E3B   CB 1B         Ë
DEC A                  ;3E3D   3D            =
JP NZ,3E35H            ;3E3E   C2 35 3E      Â5>
JP 3E4EH               ;3E41   C3 4E 3E      ÃN>
LD E,D                 ;3E44   5A            Z
LD D,C                 ;3E45   51            Q
LD C,B                 ;3E46   48            H
LD B,00H               ;3E47   06 00         
SUB 08H                ;3E49   D6 08         Ö
JP NZ,3E30H            ;3E4B   C2 30 3E      Â0>
LD A,(3DEAH)           ;3E4E   3A EA 3D      :ê=
OR A                   ;3E51   B7            ·
JP Z,3E91H             ;3E52   CA 91 3E      Ê>
LD A,(HL)              ;3E55   7E            ~
INC HL                 ;3E56   23            #
ADD A,E                ;3E57   83            
LD E,A                 ;3E58   5F            _
LD A,(HL)              ;3E59   7E            ~
INC HL                 ;3E5A   23            #
ADC A,D                ;3E5B   8A            
LD D,A                 ;3E5C   57            W
LD A,(HL)              ;3E5D   7E            ~
INC HL                 ;3E5E   23            #
ADC A,C                ;3E5F   89            
LD C,A                 ;3E60   4F            O
LD A,(HL)              ;3E61   7E            ~
ADC A,B                ;3E62   88            
LD B,A                 ;3E63   47            G
JP NC,3E73H            ;3E64   D2 73 3E      Òs>
RR B                   ;3E67   CB 18         Ë
RR C                   ;3E69   CB 19         Ë
RR D                   ;3E6B   CB 1A         Ë
RR E                   ;3E6D   CB 1B         Ë
LD HL,3DECH            ;3E6F   21 EC 3D      !ì=
INC (HL)               ;3E72   34            4
LD HL,3DECH            ;3E73   21 EC 3D      !ì=
LD A,(HL)              ;3E76   7E            ~
SUB 40H                ;3E77   D6 40         Ö@
JP C,3E83H             ;3E79   DA 83 3E      Ú>
JP M,23CAH             ;3E7C   FA CA 23      úÊ#
DEC HL                 ;3E7F   2B            +
OR (HL)                ;3E80   B6            ¶
JR 3E86H               ;3E81   18 03         
CALL 471EH             ;3E83   CD 1E 47      ÍG
POP HL                 ;3E86   E1            á
LD (HL),A              ;3E87   77            w
INC HL                 ;3E88   23            #
LD (HL),E              ;3E89   73            s
INC HL                 ;3E8A   23            #
LD (HL),D              ;3E8B   72            r
INC HL                 ;3E8C   23            #
LD (HL),C              ;3E8D   71            q
INC HL                 ;3E8E   23            #
LD (HL),B              ;3E8F   70            p
RET                    ;3E90   C9            É
LD A,(HL)              ;3E91   7E            ~
INC HL                 ;3E92   23            #
SUB E                  ;3E93   93            
LD E,A                 ;3E94   5F            _
LD A,(HL)              ;3E95   7E            ~
INC HL                 ;3E96   23            #
SBC A,D                ;3E97   9A            
LD D,A                 ;3E98   57            W
LD A,(HL)              ;3E99   7E            ~
INC HL                 ;3E9A   23            #
SBC A,C                ;3E9B   99            
LD C,A                 ;3E9C   4F            O
LD A,(HL)              ;3E9D   7E            ~
SBC A,B                ;3E9E   98            
LD B,A                 ;3E9F   47            G
CALL C,3EE0H           ;3EA0   DC E0 3E      Üà>
OR C                   ;3EA3   B1            ±
OR D                   ;3EA4   B2            ²
JP NZ,3EAEH            ;3EA5   C2 AE 3E      Â®>
LD A,E                 ;3EA8   7B            {
CP 3FH                 ;3EA9   FE 3F         þ?
JP C,3E83H             ;3EAB   DA 83 3E      Ú>
LD HL,3DECH            ;3EAE   21 EC 3D      !ì=
LD A,B                 ;3EB1   78            x
OR A                   ;3EB2   B7            ·
JP M,3E73H             ;3EB3   FA 73 3E      ús>
JP NZ,3ECEH            ;3EB6   C2 CE 3E      ÂÎ>
LD A,(HL)              ;3EB9   7E            ~
SUB 08H                ;3EBA   D6 08         Ö
JP C,3E83H             ;3EBC   DA 83 3E      Ú>
LD (HL),A              ;3EBF   77            w
LD A,C                 ;3EC0   79            y
OR D                   ;3EC1   B2            ²
OR E                   ;3EC2   B3            ³
JP Z,3E83H             ;3EC3   CA 83 3E      Ê>
LD B,C                 ;3EC6   41            A
LD C,D                 ;3EC7   4A            J
LD D,E                 ;3EC8   53            S
LD E,00H               ;3EC9   1E 00         
JP 3EB1H               ;3ECB   C3 B1 3E      Ã±>
DEC (HL)               ;3ECE   35            5
JP C,3E83H             ;3ECF   DA 83 3E      Ú>
SLA E                  ;3ED2   CB 23         Ë#
RL D                   ;3ED4   CB 12         Ë
RL C                   ;3ED6   CB 11         Ë
RL B                   ;3ED8   CB 10         Ë
JP P,3ECEH             ;3EDA   F2 CE 3E      òÎ>
JP 3E73H               ;3EDD   C3 73 3E      Ãs>
LD HL,3DEBH            ;3EE0   21 EB 3D      !ë=
LD A,(HL)              ;3EE3   7E            ~
ADD A,80H              ;3EE4   C6 80         Æ
LD (HL),A              ;3EE6   77            w
LD A,E                 ;3EE7   7B            {
CPL                    ;3EE8   2F            /
ADD A,01H              ;3EE9   C6 01         Æ
LD E,A                 ;3EEB   5F            _
LD A,D                 ;3EEC   7A            z
CPL                    ;3EED   2F            /
ADC A,00H              ;3EEE   CE 00         Î
LD D,A                 ;3EF0   57            W
LD A,C                 ;3EF1   79            y
CPL                    ;3EF2   2F            /
ADC A,00H              ;3EF3   CE 00         Î
LD C,A                 ;3EF5   4F            O
LD A,B                 ;3EF6   78            x
CPL                    ;3EF7   2F            /
ADC A,00H              ;3EF8   CE 00         Î
LD B,A                 ;3EFA   47            G
RET                    ;3EFB   C9            É
PUSH DE                ;3EFC   D5            Õ
LD A,(DE)              ;3EFD   1A            
XOR (HL)               ;3EFE   AE            ®
CPL                    ;3EFF   2F            /
AND 80H                ;3F00   E6 80         æ
LD (3DEBH),A           ;3F02   32 EB 3D      2ë=
LD B,(HL)              ;3F05   46            F
RES 7,B                ;3F06   CB B8         Ë¸
LD A,(DE)              ;3F08   1A            
AND 7FH                ;3F09   E6 7F         æ
ADD A,B                ;3F0B   80            
JP Z,3E83H             ;3F0C   CA 83 3E      Ê>
DEC A                  ;3F0F   3D            =
CP 30H                 ;3F10   FE 30         þ0
JP C,3E83H             ;3F12   DA 83 3E      Ú>
CP E0H                 ;3F15   FE E0         þà
JP NC,23CAH            ;3F17   D2 CA 23      ÒÊ#
LD (3DECH),A           ;3F1A   32 EC 3D      2ì=
XOR A                  ;3F1D   AF            ¯
LD (3DEAH),A           ;3F1E   32 EA 3D      2ê=
LD BC,0004H            ;3F21   01 04 00      
ADD HL,BC              ;3F24   09            	
LD A,(HL)              ;3F25   7E            ~
OR A                   ;3F26   B7            ·
JP P,3E83H             ;3F27   F2 83 3E      ò>
PUSH HL                ;3F2A   E5            å
POP IY                 ;3F2B   FD E1         ýá
LD C,B                 ;3F2D   48            H
EX DE,HL               ;3F2E   EB            ë
INC HL                 ;3F2F   23            #
LD E,(HL)              ;3F30   5E            ^
INC HL                 ;3F31   23            #
LD D,(HL)              ;3F32   56            V
INC HL                 ;3F33   23            #
PUSH HL                ;3F34   E5            å
LD H,B                 ;3F35   60            `
LD L,B                 ;3F36   68            h
EXX                    ;3F37   D9            Ù
POP HL                 ;3F38   E1            á
LD E,(HL)              ;3F39   5E            ^
INC HL                 ;3F3A   23            #
LD D,(HL)              ;3F3B   56            V
LD HL,0000H            ;3F3C   21 00 00      !
LD A,D                 ;3F3F   7A            z
OR A                   ;3F40   B7            ·
JP P,3E83H             ;3F41   F2 83 3E      ò>
LD C,04H               ;3F44   0E 04         
LD A,(IY+0H)           ;3F46   FD 7E 00      ý~
LD B,08H               ;3F49   06 08         
OR A                   ;3F4B   B7            ·
JP Z,3FC7H             ;3F4C   CA C7 3F      ÊÇ?
RLA                    ;3F4F   17            
JP NC,3F68H            ;3F50   D2 68 3F      Òh?
EX AF,AF'              ;3F53   08            
EXX                    ;3F54   D9            Ù
LD A,B                 ;3F55   78            x
ADD A,C                ;3F56   81            
LD C,A                 ;3F57   4F            O
ADC HL,DE              ;3F58   ED 5A         íZ
EXX                    ;3F5A   D9            Ù
ADC HL,DE              ;3F5B   ED 5A         íZ
JP NC,3F67H            ;3F5D   D2 67 3F      Òg?
LD A,(3DEAH)           ;3F60   3A EA 3D      :ê=
INC A                  ;3F63   3C            <
LD (3DEAH),A           ;3F64   32 EA 3D      2ê=
EX AF,AF'              ;3F67   08            
SRL D                  ;3F68   CB 3A         Ë:
RR E                   ;3F6A   CB 1B         Ë
EXX                    ;3F6C   D9            Ù
RR D                   ;3F6D   CB 1A         Ë
RR E                   ;3F6F   CB 1B         Ë
RR B                   ;3F71   CB 18         Ë
EXX                    ;3F73   D9            Ù
DJNZ 3F4FH             ;3F74   10 D9         Ù
DEC IY                 ;3F76   FD 2B         ý+
DEC C                  ;3F78   0D            
JP NZ,3F46H            ;3F79   C2 46 3F      ÂF?
LD A,(3DEAH)           ;3F7C   3A EA 3D      :ê=
OR A                   ;3F7F   B7            ·
JP Z,3F9AH             ;3F80   CA 9A 3F      Ê?
LD B,A                 ;3F83   47            G
LD A,(3DECH)           ;3F84   3A EC 3D      :ì=
ADD A,B                ;3F87   80            
LD (3DECH),A           ;3F88   32 EC 3D      2ì=
SCF                    ;3F8B   37            7
RR H                   ;3F8C   CB 1C         Ë
RR L                   ;3F8E   CB 1D         Ë
EXX                    ;3F90   D9            Ù
RR H                   ;3F91   CB 1C         Ë
RR L                   ;3F93   CB 1D         Ë
RR C                   ;3F95   CB 19         Ë
EXX                    ;3F97   D9            Ù
DJNZ 3F8BH             ;3F98   10 F1         ñ
EXX                    ;3F9A   D9            Ù
LD A,C                 ;3F9B   79            y
OR A                   ;3F9C   B7            ·
JP P,3FBFH             ;3F9D   F2 BF 3F      ò¿?
LD DE,0001H            ;3FA0   11 01 00      
ADD HL,DE              ;3FA3   19            
EXX                    ;3FA4   D9            Ù
LD DE,0000H            ;3FA5   11 00 00      
ADC HL,DE              ;3FA8   ED 5A         íZ
JP NC,3FBEH            ;3FAA   D2 BE 3F      Ò¾?
RR H                   ;3FAD   CB 1C         Ë
RR L                   ;3FAF   CB 1D         Ë
EXX                    ;3FB1   D9            Ù
RR H                   ;3FB2   CB 1C         Ë
RR L                   ;3FB4   CB 1D         Ë
EXX                    ;3FB6   D9            Ù
LD A,(3DECH)           ;3FB7   3A EC 3D      :ì=
INC A                  ;3FBA   3C            <
LD (3DECH),A           ;3FBB   32 EC 3D      2ì=
EXX                    ;3FBE   D9            Ù
PUSH HL                ;3FBF   E5            å
EXX                    ;3FC0   D9            Ù
LD B,H                 ;3FC1   44            D
LD C,L                 ;3FC2   4D            M
POP DE                 ;3FC3   D1            Ñ
JP 3EAEH               ;3FC4   C3 AE 3E      Ã®>
LD A,E                 ;3FC7   7B            {
LD E,D                 ;3FC8   5A            Z
LD D,00H               ;3FC9   16 00         
EXX                    ;3FCB   D9            Ù
LD B,E                 ;3FCC   43            C
LD E,D                 ;3FCD   5A            Z
LD D,A                 ;3FCE   57            W
EXX                    ;3FCF   D9            Ù
JP 3F76H               ;3FD0   C3 76 3F      Ãv?
PUSH DE                ;3FD3   D5            Õ
LD A,(DE)              ;3FD4   1A            
XOR (HL)               ;3FD5   AE            ®
CPL                    ;3FD6   2F            /
AND 80H                ;3FD7   E6 80         æ
LD (3DEBH),A           ;3FD9   32 EB 3D      2ë=
LD B,(HL)              ;3FDC   46            F
RES 7,B                ;3FDD   CB B8         Ë¸
LD A,(DE)              ;3FDF   1A            
AND 7FH                ;3FE0   E6 7F         æ
SUB B                  ;3FE2   90            
ADD A,81H              ;3FE3   C6 81         Æ
CP 30H                 ;3FE5   FE 30         þ0
JP C,3E83H             ;3FE7   DA 83 3E      Ú>
CP E0H                 ;3FEA   FE E0         þà
JP NC,23CAH            ;3FEC   D2 CA 23      ÒÊ#
LD (3DECH),A           ;3FEF   32 EC 3D      2ì=
INC HL                 ;3FF2   23            #
INC DE                 ;3FF3   13            
EX DE,HL               ;3FF4   EB            ë
LD C,(HL)              ;3FF5   4E            N
INC HL                 ;3FF6   23            #
LD B,(HL)              ;3FF7   46            F
INC HL                 ;3FF8   23            #
PUSH HL                ;3FF9   E5            å
EX DE,HL               ;3FFA   EB            ë
LD E,(HL)              ;3FFB   5E            ^
INC HL                 ;3FFC   23            #
LD D,(HL)              ;3FFD   56            V
INC HL                 ;3FFE   23            #
LD A,L                 ;3FFF   7D            }
EX AF,AF'              ;4000   08            
LD A,H                 ;4001   7C            |
LD H,B                 ;4002   60            `
LD L,C                 ;4003   69            i
EXX                    ;4004   D9            Ù
POP HL                 ;4005   E1            á
LD C,(HL)              ;4006   4E            N
INC HL                 ;4007   23            #
LD B,(HL)              ;4008   46            F
LD H,A                 ;4009   67            g
EX AF,AF'              ;400A   08            
LD L,A                 ;400B   6F            o
LD E,(HL)              ;400C   5E            ^
INC HL                 ;400D   23            #
LD D,(HL)              ;400E   56            V
LD H,B                 ;400F   60            `
LD L,C                 ;4010   69            i
LD A,D                 ;4011   7A            z
OR A                   ;4012   B7            ·
JP P,23CAH             ;4013   F2 CA 23      òÊ#
LD C,04H               ;4016   0E 04         
LD B,08H               ;4018   06 08         
BIT 7,H                ;401A   CB 7C         Ë|
JP NZ,4038H            ;401C   C2 38 40      Â8@
OR A                   ;401F   B7            ·
RLA                    ;4020   17            
EXX                    ;4021   D9            Ù
ADD HL,HL              ;4022   29            )
EXX                    ;4023   D9            Ù
ADC HL,HL              ;4024   ED 6A         íj
DJNZ 401AH             ;4026   10 F2         ò
PUSH AF                ;4028   F5            õ
DEC C                  ;4029   0D            
JP NZ,4018H            ;402A   C2 18 40      Â@
POP AF                 ;402D   F1            ñ
LD E,A                 ;402E   5F            _
POP AF                 ;402F   F1            ñ
LD D,A                 ;4030   57            W
POP AF                 ;4031   F1            ñ
LD C,A                 ;4032   4F            O
POP AF                 ;4033   F1            ñ
LD B,A                 ;4034   47            G
JP 3EAEH               ;4035   C3 AE 3E      Ã®>
EXX                    ;4038   D9            Ù
OR A                   ;4039   B7            ·
SBC HL,DE              ;403A   ED 52         íR
EXX                    ;403C   D9            Ù
SBC HL,DE              ;403D   ED 52         íR
CCF                    ;403F   3F            ?
JP C,4020H             ;4040   DA 20 40      Ú @
EXX                    ;4043   D9            Ù
ADD HL,DE              ;4044   19            
EXX                    ;4045   D9            Ù
ADC HL,DE              ;4046   ED 5A         íZ
OR A                   ;4048   B7            ·
RLA                    ;4049   17            
EXX                    ;404A   D9            Ù
ADD HL,HL              ;404B   29            )
EXX                    ;404C   D9            Ù
ADC HL,HL              ;404D   ED 6A         íj
DEC B                  ;404F   05            
JP NZ,405AH            ;4050   C2 5A 40      ÂZ@
PUSH AF                ;4053   F5            õ
LD B,08H               ;4054   06 08         
DEC C                  ;4056   0D            
JP Z,402DH             ;4057   CA 2D 40      Ê-@
EXX                    ;405A   D9            Ù
OR A                   ;405B   B7            ·
SBC HL,DE              ;405C   ED 52         íR
EXX                    ;405E   D9            Ù
SBC HL,DE              ;405F   ED 52         íR
SCF                    ;4061   37            7
RLA                    ;4062   17            
DEC B                  ;4063   05            
JP NZ,406EH            ;4064   C2 6E 40      Ân@
PUSH AF                ;4067   F5            õ
LD B,08H               ;4068   06 08         
DEC C                  ;406A   0D            
JP Z,402DH             ;406B   CA 2D 40      Ê-@
EXX                    ;406E   D9            Ù
ADD HL,HL              ;406F   29            )
EXX                    ;4070   D9            Ù
ADC HL,HL              ;4071   ED 6A         íj
JP NC,401AH            ;4073   D2 1A 40      Ò@
JP 405AH               ;4076   C3 5A 40      ÃZ@
EX AF,AF'              ;4079   08            
NOP                    ;407A   00            
CPL                    ;407B   2F            /
LD A,(HL)              ;407C   7E            ~
PUSH HL                ;407D   E5            å
POP IX                 ;407E   DD E1         Ýá
EX DE,HL               ;4080   EB            ë
LD (407AH),HL          ;4081   22 7A 40      "z@
EX AF,AF'              ;4084   08            
XOR A                  ;4085   AF            ¯
LD (4079H),A           ;4086   32 79 40      2y@
LD H,A                 ;4089   67            g
LD L,A                 ;408A   6F            o
EXX                    ;408B   D9            Ù
LD H,A                 ;408C   67            g
LD L,A                 ;408D   6F            o
LD B,A                 ;408E   47            G
LD C,A                 ;408F   4F            O
EX AF,AF'              ;4090   08            
CP 2EH                 ;4091   FE 2E         þ.
JP Z,40ABH             ;4093   CA AB 40      Ê«@
SUB 30H                ;4096   D6 30         Ö0
CALL 4186H             ;4098   CD 86 41      ÍA
CALL 417CH             ;409B   CD 7C 41      Í|A
SUB 30H                ;409E   D6 30         Ö0
CP 0AH                 ;40A0   FE 0A         þ

JR C,4098H             ;40A2   38 F4         8ô
ADD A,30H              ;40A4   C6 30         Æ0
CP 2EH                 ;40A6   FE 2E         þ.
JP NZ,40BCH            ;40A8   C2 BC 40      Â¼@
CALL 417CH             ;40AB   CD 7C 41      Í|A
SUB 30H                ;40AE   D6 30         Ö0
CP 0AH                 ;40B0   FE 0A         þ

JP NC,40BAH            ;40B2   D2 BA 40      Òº@
CALL 4195H             ;40B5   CD 95 41      ÍA
JR 40ABH               ;40B8   18 F1         ñ
ADD A,30H              ;40BA   C6 30         Æ0
CP 45H                 ;40BC   FE 45         þE
JP NZ,4107H            ;40BE   C2 07 41      ÂA
EXX                    ;40C1   D9            Ù
CALL 417CH             ;40C2   CD 7C 41      Í|A
LD B,01H               ;40C5   06 01         
CP BCH                 ;40C7   FE BC         þ¼
JR Z,40D1H             ;40C9   28 06         (
CP BDH                 ;40CB   FE BD         þ½
JP NZ,23C0H            ;40CD   C2 C0 23      ÂÀ#
DEC B                  ;40D0   05            
LD A,B                 ;40D1   78            x
OR A                   ;40D2   B7            ·
EX AF,AF'              ;40D3   08            
CALL 417CH             ;40D4   CD 7C 41      Í|A
SUB 30H                ;40D7   D6 30         Ö0
JR Z,40D4H             ;40D9   28 F9         (ù
CP 0AH                 ;40DB   FE 0A         þ

JP NC,40FDH            ;40DD   D2 FD 40      Òý@
LD B,A                 ;40E0   47            G
CALL 417CH             ;40E1   CD 7C 41      Í|A
SUB 30H                ;40E4   D6 30         Ö0
CP 0AH                 ;40E6   FE 0A         þ

JP NC,40FDH            ;40E8   D2 FD 40      Òý@
LD C,A                 ;40EB   4F            O
CALL 417CH             ;40EC   CD 7C 41      Í|A
SUB 30H                ;40EF   D6 30         Ö0
CP 0AH                 ;40F1   FE 0A         þ

JP C,23CAH             ;40F3   DA CA 23      ÚÊ#
LD A,B                 ;40F6   78            x
ADD A,A                ;40F7   87            
ADD A,A                ;40F8   87            
ADD A,B                ;40F9   80            
ADD A,A                ;40FA   87            
ADD A,C                ;40FB   81            
LD B,A                 ;40FC   47            G
EX AF,AF'              ;40FD   08            
LD A,B                 ;40FE   78            x
JR NZ,4103H            ;40FF   20 02          
CPL                    ;4101   2F            /
INC A                  ;4102   3C            <
LD (4079H),A           ;4103   32 79 40      2y@
EXX                    ;4106   D9            Ù
PUSH IX                ;4107   DD E5         Ýå
LD A,(4079H)           ;4109   3A 79 40      :y@
ADD A,1DH              ;410C   C6 1D         Æ
ADD A,C                ;410E   81            
LD (4079H),A           ;410F   32 79 40      2y@
CP 30H                 ;4112   FE 30         þ0
JP C,411FH             ;4114   DA 1F 41      ÚA
CP 80H                 ;4117   FE 80         þ
JP C,23CAH             ;4119   DA CA 23      ÚÊ#
JP 4171H               ;411C   C3 71 41      ÃqA
LD A,80H               ;411F   3E 80         >
LD (3DEBH),A           ;4121   32 EB 3D      2ë=
LD A,A0H               ;4124   3E A0         > 
LD (3DECH),A           ;4126   32 EC 3D      2ì=
PUSH HL                ;4129   E5            å
EXX                    ;412A   D9            Ù
POP BC                 ;412B   C1            Á
LD D,H                 ;412C   54            T
LD E,L                 ;412D   5D            ]
LD HL,4139H            ;412E   21 39 41      !9A
PUSH HL                ;4131   E5            å
LD HL,(407AH)          ;4132   2A 7A 40      *z@
PUSH HL                ;4135   E5            å
JP 3EAEH               ;4136   C3 AE 3E      Ã®>
LD A,(4079H)           ;4139   3A 79 40      :y@
LD L,A                 ;413C   6F            o
LD C,A                 ;413D   4F            O
LD H,00H               ;413E   26 00         &
LD B,H                 ;4140   44            D
ADD HL,HL              ;4141   29            )
ADD HL,HL              ;4142   29            )
ADD HL,BC              ;4143   09            	
LD BC,41C3H            ;4144   01 C3 41      ÃA
ADD HL,BC              ;4147   09            	
LD DE,(407AH)          ;4148   ED 5B 7A 40   í[z@
LD A,80H               ;414C   3E 80         >
LD (3DEBH),A           ;414E   32 EB 3D      2ë=
LD A,20H               ;4151   3E 20         > 
ADD A,(HL)             ;4153   86            
LD B,A                 ;4154   47            G
LD A,(DE)              ;4155   1A            
AND 7FH                ;4156   E6 7F         æ
ADD A,B                ;4158   80            
JP C,23CAH             ;4159   DA CA 23      ÚÊ#
SUB 21H                ;415C   D6 21         Ö!
JR NC,4161H            ;415E   30 01         0
XOR A                  ;4160   AF            ¯
LD BC,4169H            ;4161   01 69 41      iA
PUSH BC                ;4164   C5            Å
PUSH DE                ;4165   D5            Õ
JP 3F10H               ;4166   C3 10 3F      Ã?
POP HL                 ;4169   E1            á
LD BC,0005H            ;416A   01 05 00      
LD D,B                 ;416D   50            P
LD E,B                 ;416E   58            X
LD A,(HL)              ;416F   7E            ~
RET                    ;4170   C9            É
LD HL,4169H            ;4171   21 69 41      !iA
PUSH HL                ;4174   E5            å
LD HL,(407AH)          ;4175   2A 7A 40      *z@
PUSH HL                ;4178   E5            å
JP 3E83H               ;4179   C3 83 3E      Ã>
INC IX                 ;417C   DD 23         Ý#
LD A,(IX+0H)           ;417E   DD 7E 00      Ý~
CP 20H                 ;4181   FE 20         þ 
RET NZ                 ;4183   C0            À
JR 417CH               ;4184   18 F6         ö
OR A                   ;4186   B7            ·
JR NZ,418CH            ;4187   20 03          
OR B                   ;4189   B0            °
RET Z                  ;418A   C8            È
XOR A                  ;418B   AF            ¯
EX AF,AF'              ;418C   08            
LD A,B                 ;418D   78            x
CP 09H                 ;418E   FE 09         þ	
JP NZ,41A3H            ;4190   C2 A3 41      Â£A
INC C                  ;4193   0C            
RET                    ;4194   C9            É
OR A                   ;4195   B7            ·
JR NZ,419DH            ;4196   20 05          
DEC C                  ;4198   0D            
OR B                   ;4199   B0            °
RET Z                  ;419A   C8            È
INC C                  ;419B   0C            
XOR A                  ;419C   AF            ¯
EX AF,AF'              ;419D   08            
LD A,B                 ;419E   78            x
CP 09H                 ;419F   FE 09         þ	
RET Z                  ;41A1   C8            È
DEC C                  ;41A2   0D            
INC B                  ;41A3   04            
LD D,H                 ;41A4   54            T
LD E,L                 ;41A5   5D            ]
EXX                    ;41A6   D9            Ù
LD D,H                 ;41A7   54            T
LD E,L                 ;41A8   5D            ]
XOR A                  ;41A9   AF            ¯
ADD HL,HL              ;41AA   29            )
RLA                    ;41AB   17            
ADD HL,HL              ;41AC   29            )
RLA                    ;41AD   17            
ADD HL,DE              ;41AE   19            
LD D,00H               ;41AF   16 00         
ADC A,D                ;41B1   8A            
ADD HL,HL              ;41B2   29            )
RLA                    ;41B3   17            
EX AF,AF'              ;41B4   08            
LD E,A                 ;41B5   5F            _
EX AF,AF'              ;41B6   08            
ADD HL,DE              ;41B7   19            
ADC A,D                ;41B8   8A            
EXX                    ;41B9   D9            Ù
ADD HL,HL              ;41BA   29            )
ADD HL,HL              ;41BB   29            )
ADD HL,DE              ;41BC   19            
ADD HL,HL              ;41BD   29            )
LD D,00H               ;41BE   16 00         
LD E,A                 ;41C0   5F            _
ADD HL,DE              ;41C1   19            
RET                    ;41C2   C9            É
RET PO                 ;41C3   E0            à
PUSH AF                ;41C4   F5            õ
RST 30H                ;41C5   F7            ÷
JP NC,E3CAH            ;41C6   D2 CA E3      ÒÊã
DI                     ;41C9   F3            ó
OR L                   ;41CA   B5            µ
ADD A,A                ;41CB   87            
DB $E7                 ;41CC   FD E7         ýç
CP B                   ;41CE   B8            ¸
POP DE                 ;41CF   D1            Ñ
LD (HL),H              ;41D0   74            t
SBC A,(HL)             ;41D1   9E            
JP PE,0625H            ;41D2   EA 25 06      ê%
LD (DE),A              ;41D5   12            
ADD A,EDH              ;41D6   C6 ED         Æí
XOR A                  ;41D8   AF            ¯
ADD A,A                ;41D9   87            
SUB (HL)               ;41DA   96            
RST 30H                ;41DB   F7            ÷
POP AF                 ;41DC   F1            ñ
CALL BE14H             ;41DD   CD 14 BE      Í¾
SBC A,D                ;41E0   9A            
CALL P,9A01H           ;41E1   F4 01 9A      ô
LD L,L                 ;41E4   6D            m
POP BC                 ;41E5   C1            Á
RST 30H                ;41E6   F7            ÷
ADD A,C                ;41E7   81            
NOP                    ;41E8   00            
RET                    ;41E9   C9            É
POP AF                 ;41EA   F1            ñ
EI                     ;41EB   FB            û
LD D,B                 ;41EC   50            P
AND B                  ;41ED   A0             
DEC E                  ;41EE   1D            
SUB A                  ;41EF   97            
CP 65H                 ;41F0   FE 65         þe
EX AF,AF'              ;41F2   08            
PUSH HL                ;41F3   E5            å
CP H                   ;41F4   BC            ¼
LD BC,4A7EH            ;41F5   01 7E 4A      ~J
LD E,ECH               ;41F8   1E EC         ì
DEC B                  ;41FA   05            
ADC A,A                ;41FB   8F            
XOR 92H                ;41FC   EE 92         î
SUB E                  ;41FE   93            
EX AF,AF'              ;41FF   08            