****************************************
* Program name : CHECK.CPP
* Author       : Unknown
* Date written : Unknown
* Library      : FBBP
* COPYRIGHT (C) 1998 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
*
* Last updated by afs (AFSLOGISTICS\nmeddaugh) at 14:28:46 on 01/06/2022.
*
* Start modification history
* Mod nn  mm/dd/yy, init, req #, description
* 010622 - NKH01 - ACCU-1299 Added file for compare
* End modification history
*
****************************************

      PROG.NAME = 'CHECK.CPP'
      OPEN 'BILLDATA.EBILL.HIST' TO F.BILLDATA.HIST ELSE
         CALL OPEN.ABORT('BILLDATA.EBILL.HIST',PROG.NAME)
      END
      OPEN 'EDI.CAR.ACNT.XREF' TO F.XREF ELSE
         CALL OPEN.ABORT('EDI.CAR.ACNT.XREF',PROG.NAME)
      END
      OPEN "CLIENTS" TO F.CLI ELSE
         CALL OPEN.ABORT('CLIENTS',PROG.NAME)
      END
      OPEN "UPS.TEMP" TO UPS.TEMP ELSE          ; * NKH01
         CALL OPEN.ABORT('UPS.TEMP',PROG.NAME)  ; * NKH01
      END                                       ; * NKH01
      
      OK = 0
      PROMPT""
      LOOP
      UNTIL OK DO
         CRT @(-1)
         CRT @(5,2):"UPS CPP weekly UPS report"
         CRT @(10,10):"Enter UPS file date ": ; INPUT UPSDATE
         FILE.DATE = ICONV(UPSDATE,"D")
         FILE.DATE = OCONV(FILE.DATE,"D4-")
         FILE.DATE = FILE.DATE[1,2]:"_":FILE.DATE[4,2]:"_":FILE.DATE[7,4]
         CRT @(30,10):FILE.DATE
         CRT @(5,20):"Is file date name correct ": ; INPUT RESPON
         IF RESPON = "Y" THEN
            OK = 1
         END
      REPEAT
      PT2 = FILE.DATE
      PT3 = '.XLS'
      PRE = "00041*"
   **   EXECUTE "GET-LIST CPP1"
       EXECUTE "GET-LIST CPP" 
      EOJ = 0
      LOOP
         READNEXT ID ELSE EOJ = 1
         FILE.ID = FIELD(ID,"*",1)
         XREF.ID = FILE.ID"R%6"
         XREF.ID = PRE:XREF.ID
       
****         READV CLIENT.ID FROM F.XREF,XREF.ID,1 ELSE CLIENT.ID = "NOF"
         CLIENT.ID = FIELD(ID,"*",2)
         READV NAME FROM F.CLI,CLIENT.ID,2 ELSE NAME = "NOF"
      UNTIL EOJ DO
         PT1 = FILE.ID"R%10"
         FILE.ID = PT1:"_":PT2:PT3
         READ TST FROM F.BILLDATA.HIST,FILE.ID THEN
            READ UPS.REC FROM UPS.TEMP, CLIENT.ID THEN       ; * NKH01
               DELETE UPS.TEMP,CLIENT.ID                     ; * NKH01
            END                                              ; * NKH01
*            CRT "FOUND IT      ":CLIENT.ID:" ":NAME:" ":PT1 ; * NKH01
*         END ELSE                                           ; * NKH01
*            CRT "NOT found     ":CLIENT.ID:" ":NAME:" ":PT1 ; * NKH01
         END
      REPEAT
      
      * Begin NKH01
      CMD = 'SSELECT UPS.TEMP'
      EXECUTE CMD
      EOF = 0
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         READ UPS.REC FROM UPS.TEMP, ID THEN
            ACCT.CNT = DCOUNT(UPS.REC<2>,@VM)
            FOR X = 1 TO ACCT.CNT
               CRT ID"R%5":SPACE(5):UPS.REC<1>"L#30":SPACE(5):UPS.REC<2,X>"R#10":SPACE(5):OCONV(UPS.REC<3>,"D2-")
            NEXT X
         END
      REPEAT
      * End NKH01
