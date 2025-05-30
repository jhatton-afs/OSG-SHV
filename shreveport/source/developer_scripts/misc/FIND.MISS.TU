****************************************************
* Program name : POST.APCHECK
* Author       : Greg Bino
* Date written : 06-06-2016
* Library      : FBBP
* COPYRIGHT (C) 1998 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
* Post brokerage transactions payments to FB.BILLS.HIST,00000
*
* Last updated by AFS (gbino) at 07:57:18 on 06/13/2016.
*
* Start modification history
* End modification history
*
*******************************************************
      CALL GET.USER(USER)
      * Begin GRB01
      VIN1=""
      VIN1<1> = 'POST.APCHECK'
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "S"
 **     CALL PROGTRACK(VIN1,VOUT1)
      * End GRB01
      *


      OPEN 'CHECK.WORK' TO FILE.GB ELSE STOP
      OPEN 'MISS.TU.SHIP' TO FILE.XREF ELSE STOP
      OPEN "FB.BILLS.HIST,00000" TO F.BILLS ELSE STOP
      OPEN "GRB" TO FILE.CRX ELSE STOP
      TAB = "|"
      TAB = CHAR(9)
      AM = CHAR(254)
      CNT = 0
      WRT.CNT = 0
      CHK.CNT = 0
      VER = 0

              *
         ID= "MISSING.TU.txt"
         READ DAT FROM FILE.CRX,ID THEN
            CNT = CNT + 1
            LINE.CNT = DCOUNT(DAT,AM)
            FOR I = 2 TO LINE.CNT
               DATA = DAT<I>
               IF DATA # "" THEN
                  DATA = CHANGE(DATA, TAB, @VM)

                  NEW.REC = DATA
                  CLIENT = NEW.REC<1,1>"R%5"
                  
                  CARRIER = NEW.REC<1,2>"R%5"
                  
                  PRO.NUM = NEW.REC<1,3>

                  WRITE "" ON FILE.XREF,CLIENT:"*":CARRIER:"*":PRO.NUM
WRT.CNT+=1
               END


   NEXT.LINE:         NEXT I
         END
      CRT @(10,10):CNT
      DEBUG
  
      * Begin GRB01
      VIN1=""
      VIN1<1> = 'POST.APCHECK'
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "E"
  **    CALL PROGTRACK(VIN1,VOUT1)
      * End GRB01
      *
      CRT "COUNT ":CNT
      CRT "CHECK CNT ":CHK.CNT
      CRT "WRITES ":WRT.CNT
      CRT "THAT'S ALL FOLKS"
      STOP
   

   END
