****************************************
* Program name : CLEAN.EDI
* Author       : Greg Bino
* Date written : Jan 28, 2016
* Library      : FBBP
* COPYRIGHT (C) 1998 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
*
* This program clears out files used to send emails
*
* Last updated by DEV (gregbino) at 08:37:09 on 10/01/2001.
*
* Start modification history
* Mod nn  mm/dd/yy, init, req #, description
* End modification history
*
****************************************
      COMMON PROGPARAMS(24)
      EQU PROGFROM TO PROGPARAMS(1)
      EQU USER TO PROGPARAMS(2)
      EQU PROCDATE TO PROGPARAMS(3)
      EQU CHNUM TO PROGPARAMS(4)
********      CALL CHANNEL(CH.NUM)
****      CALL GET.USER(USER)
      PROG.NAME = "EDI.XREF"
      * Begin GRB01
      VIN1=""
      VIN1<1> = PROG.NAME
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "S"
      ****    CALL PROGTRACK(VIN1,VOUT1)
      * End GRB01
      CYCLE = 496
      EDI.H = 0
      OPEN '','UPS.FILE.XREF' TO F.UPS ELSE CALL OPEN.ABORT('EDI.RAW.DATA', PROG.NAME)
      OPEN '','EDI.CAR.ACNT.XREF' TO F.XREF ELSE CALL OPEN.ABORT('EDI.ARCHIVE.2016', PROG.NAME)
      TODAY = DATE()
      WINDOW = 60
      DIM EDI.CAR(20)
      MAT EDI.CAR = ""
      FOUND = 0
      NOT.FOUND = 0
      NEW.FOUND = NOT.FOUND + 1
      PREFIX = "Invoice_"

      DT.MARK = DATE()
      DOW = OCONV(DT.MARK,"DOW")
      BEGIN CASE
         CASE DOW = 6
            ADJ = 1
         CASE DOW = 1
            ADJ = 2
         CASE DOW = 2
            ADJ = 3
         CASE DOW = 3
            ADJ = 4
         CASE DOW = 4
            ADJ = 5
         CASE DOW = 5
            ADJ = 6
      END CASE
      DT.MARK = DT.MARK - ADJ
      DT.MARK2 = OCONV(DT.MARK,"D2-")
      CONVERT "-" TO "" IN DT.MARK2
      SUFFIX = "_":DT.MARK2:".csv"


      EXECUTE "GET-LIST DD"
****      EXECUTE "GET-LIST UI"
      UPDT.DT = DT.MARK
      OUPDT.DT = OCONV(UPDT.DT,"D2-")
      EOJ = 0
      LOOP
         UPDT = 0
         READNEXT ID ELSE EOJ = 1
      UNTIL EOJ DO
         READ REC FROM F.UPS,ID THEN
            FILE.CNT = DCOUNT(REC<1>,@VM)
            FOR I = 1 TO FILE.CNT
               FILE = REC<1,I>
               NEW.ID = PREFIX:FILE:SUFFIX
               OPENSEQ 'BILLDATA.EBILL.DATA',NEW.ID TO INSEQ.FILE THEN
                  FOUND = FOUND + 1
                  UPDT = 1
                  ***  READ XREF FROM F.UPS,ID THEN
                  TARGET = FIELD(NEW.ID,"_",2)"R#10"
                  LOCATE(TARGET,REC<1>,1;QQ) THEN
                     REC<9,QQ> = UPDT.DT
                  END
                  WRITE REC ON F.UPS,ID ELSE NULL
                  ***    END
               END ELSE
                  ****    	DEBUG
                  FILE = FILE:CYCLE
                  FILE = FILE"R%15"
                  NEW.ID = PREFIX:FILE:SUFFIX
                  OPENSEQ 'BILLDATA.EBILL.DATA',NEW.ID TO INSEQ.FILE THEN
                     **** WRITEV FILE ON F.UPS,ID,9
                     NEW.FOUND = NEW.FOUND + 1

                     UPDT = 1
                  END ELSE

                     NOT.FOUND = NOT.FOUND + 1
****                     CRT NEW.ID
                  END
               END
               CLOSESEQ INSEQ.FILE
            NEXT I
            IF UPDT THEN

               WRITEV UPDT.DT ON F.UPS,ID,9 ELSE NULL
            END
         END

      REPEAT
      *
      DISPLAY "FOUND ":FOUND:SPACE(5):"NOT FOUND ":NOT.FOUND:SPACE(5):"CYCLE INCLUDED ":NEW.FOUND
      EXECUTE "GET-LIST DE" RTNLIST N1
      CMD = 'SORT UPS.FILE.XREF WITH 9 AND WITH 9 # "' : OUPDT.DT : '" 1 9 PROC.DAY'
      EXECUTE CMD PASSLIST N1
