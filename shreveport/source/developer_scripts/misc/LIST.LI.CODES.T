***      SUBROUTINE LIST.LI.CODES(VIN,VOUT)
*****************************************************************************
*
* SUBROUTINE LIST.LI.CODES
* CALLED BY TRAFFIC SURVEY (FB.2.1.TS)
* ADDS ABILITY TO DO A LISTING OF CODES I.E. FRT, SIT, ETC.
*
* WRITTEN BY KD 4/99
*
*****************************************************************************

$OPTIONS HEADER.EJECT
$OPTIONS EXEC.EQ.PREF
$OPTIONS INFO.ABORT

* NPR01 101510 - Increased the limit on the number of lines to display - Not sure why we need one.

VIN=''
VIN<1> = '02427'

      PROMPT=''
      PROG.NAME='LIST.LI.CODES'
      PROG.DESC='LINE ITEM CODE LISTING (TS)'
      PACK.NAME='TRAFFIC SURVEY'
      CALL AFS.SCR.HEAD(CO.ID,FILE.ID,'',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'LIST.LI.CODES' ; UPL.VOUT = ''  ; * NPR_UPL 04/23/2010
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/23/2010
      VOUT=''
      OPEN '','FB.TABLES' TO F.TABLES ELSE CALL OPEN.ABORT('FB.TABLES',PROG.NAME)
      IF VIN<1> # '' THEN
         OPEN '','TEMPO.CLIENTS.ACC' TO F.TEMPOCACC ELSE
            CALL OPEN.ABORT('TEMPO.CLIENTS.ACC',PROG.NAME)
         END
         READ CODES FROM F.TEMPOCACC,VIN<1> ELSE CODES =''
      END ELSE
         READ CODES FROM F.TABLES,'LI.CODES' ELSE CODES=''
      END

      PAGE=1
      GO 9000

100:*
*
*ENTER CODE OR PAGE
*
      HELP='Enter number --- [ENTER] for next page --- [B]ack a page'
      CALL GEN.IN(0,22,'Enter line number. ###','',Q,0,3,'','',1,-3,22,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI=''
            PAGE=PAGE+1
            GO 9000
         CASE QI='B'
            IF PAGE=1 THEN
               CALL ELINE("Can't go back a page from first page")
               GO 9000
            END ELSE
               PAGE=PAGE-1
               GO 9000
            END
         CASE QI='EX'
            STOP
         CASE QI='X'
            VOUT<1>=CODES<1,1>
            VOUT<2>=CODES<2,1>
            VOUT<3>=CODES<3,1>
            VOUT<4>=CODES<4,1>
            RETURN
         CASE NUM(QI)
            SEL=QI
            IF SEL LT START ! SEL GT STOP THEN
               CALL ELINE("INVALID SELECTION")
*      GO 9000
            END
         CASE 1
            CALL ELINE("INVALID SELECTION")
            GO 9000
      END CASE
      VOUT<1>=CODES<1,Q>
      VOUT<2>=CODES<2,Q>
      VOUT<3>=CODES<3,Q>
      VOUT<4>=CODES<4,Q>
      RETURN

9000:*
*
*DISPLAY ARRAY
*
      CRT @(0,3):@(-3):"  #":@(5,3):"Code Description"
      START=(PAGE*18)-17
*NPR01IF START GT 126 THEN
      IF START GT 250 THEN               ; * NPR01
         START=1
         PAGE=1
      END
      STOP=START+17
      FOR I=START TO STOP STEP 1
         ROW=3+REM(I,18)
         IF ROW=3 THEN ROW=21
         CODE=CODES<1,I>
         DESC=CODES<2,I>
         TYPE=CODES<3,I>
         PRINT@(0,ROW):I'R#3':'  ':CODE'L#4':'  ':DESC'L#30':'  ':TYPE'L#1'
      NEXT I
      GO 100
