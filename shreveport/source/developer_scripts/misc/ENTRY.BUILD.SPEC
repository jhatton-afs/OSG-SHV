* Program to enter records format for spreadsheet
*
* Freight Payments
*
* AUTHOR: David R. Friend
* DATE: 08/07/97
* 090903 - JMK01 - ALLOW FOR CREATION OF MISROUTE FORMATS
* 120903 - JMK02 - ADD FOR MV TABLE LOOKUP REFERENCE
* 121703 - JMK03 - ADD FOR SUMMATION FEATURE
* 020304 - JMK04 - ALLOW FOR EXCLUSION IN SUMMARY (JMK04)
* 061704 - JMK05 - ADD COUNT FEATURE
* 012605 - JMK06 - EXPAND REF FIELD FOR EXCLUSIONS
* 021909 - JMK07 - ADD CONVERSION DEFINITION FOR SLSMAN NAME
* 070909 - JMK08 - C090893 - Image Projections West: Add customer information
* 032410 - JMK09 - ADD INTL.CODES TO FIELD OPTIONS
* 100512 - JMK10 - SysAid#4429 - Tracking the BD resolution process
* 050613 - JMK11 - FREIGHT DATA EXPORT FILE
* 091213 - JMK12 - Add Shipper and Consignee setup for Rexel B460 Report
* 012215 - DRF01 - SysAid 14856 Gave Ken access
* 031615 - DRF02 - SysAid 15959 Gave April the same access as Cynthia
* 082117 - NKH01 - Replaced Tom Gorton with Nicole Meddaugh
      PROMPT ''                          ; * JMK01
      INPUT PRFX                         ; * JMK01
      PROG.NAME='ENTRY.BUILD.SPEC'
*
* Open files.
*
      OPEN '','FB.BUILD.SPEC' TO F.BUILD.SPEC ELSE
         CALL OPEN.ABORT("FB.BUILD.SPEC",PROG.NAME)
      END
      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         CALL OPEN.ABORT("CLIENTS",PROG.NAME)
      END
*
* CHECK FOR PROPER USER
*
      OK=0
      CALL GET.USER(USER)

      IF USER='DAVID' THEN OK=1
      IF USER='NMEDDAUGH' THEN OK=1    ;* NKH01
      IF USER='CYNTHIA' THEN OK=1
      IF USER='GBINO' THEN OK=1        ; * JMK01
      IF USER='PBASS' THEN OK=1          ; *  PKB temporary access
      IF USER='KHOSKINS' THEN OK=1     ; * DRF01
      IF USER='ARSEXTONAUDIT' THEN OK=1     ; * DRF02
*
      IF OK=1 ELSE
         CALL ELINE('Unauthorized user. ACCESS DENIED. Call the IS Help Desk for help.')
         GOTO 9999
      END
*
* Initialize variables.
*
20:   PROG.DESC='PROGRAMMER SPREADSHEET SPEC RECORD'
      IF PRFX='MRS' THEN                 ; * JMK01
         PROG.DESC='MISROUTE EMAIL SPREADSHEET SPEC RECORD'  ; * JMK01
      END                                ; * JMK01
      PACK.NAME='FP'
      CALL AFS.SCR.HEAD(CO.ID,FILE.ID,'',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'ENTRY.BUILD.SPEC' ; UPL.VOUT = ''         ; * NPR_UPL 04/23/2010
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/23/2010
      PROMPT''
      FORMULA=''
      PAGE.LEN=18
      MODE=''
      FIND.LOCKED.NAME=''
      CLIENT=''
      INSERT='OFF'
25:   HELP="Enter client number. Word of name for search. ENTER for Default. X=Exit."
      IF CLIENT='' THEN MASK='#####' ELSE MASK=CLIENT'R%5'
      IF CLIENT='' THEN
         MASK='#####'
      END ELSE
         IF CLIENT='DEFAULT' THEN
            MASK='DEFAULT'
         END ELSE
            MASK=CLIENT'R%5'
         END
      END
      CALL GEN.IN(0,4,'Enter Client Number ':MASK,'',Q,0,20,'','',2,20,4,1,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=CLIENT ; Q=CLIENT
      BEGIN CASE
         CASE QI='EX' ! QI='X'
            STOP
         CASE QI='' ! QI='DEFAULT'
            Q='DEFAULT'
         CASE NOT(QI MATCHES "0N")
            CALL SOUNDEX.DISPLAY(QI,'BCUST','SDX.CLIENTS,NAME',2,ITEM.LIST)
            CALL AFS.SCR.HEAD(CO.ID,FILE.ID,'',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
            BEGIN CASE
               CASE ITEM.LIST=''
                  GOTO 25
               CASE DCOUNT(ITEM.LIST<1>,@VM) GT 1
                  GOTO 25
               CASE ITEM.LIST NE ''
                  IF NUM(ITEM.LIST<1,1>) THEN DATA ITEM.LIST<1,1>
                  GOTO 25
            END CASE
         CASE NUM(QI)
            Q=QI'R%5'
         CASE 1
            GOTO 25
      END CASE
*
      CLIENT=Q
      IF CLIENT#'DEFAULT' THEN
         READ CLIENT.REC FROM F.CLIENTS,Q ELSE
            CALL ELINE('ERROR - Client ':CLIENT:' not on file.')
            GOTO 25
         END
         CLIENT.NAME=CLIENT.REC<2>
         CRT @(0,4):'Enter Client Number ':CLIENT'R%5':
         CRT ' ':CLIENT.NAME:@(-4):
      END ELSE
         CRT @(0,4):'Enter Client Number DEFAULT':@(-4):
      END

50:   HELP='Enter The Version To Update, "L" to list.'
      CALL GEN.IN(0,6,'Enter Version Number ###','',Q,0,3,'','',0,-3,6,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='EX' OR QI=''
            STOP
         CASE QI='X'
            GOTO 25
         CASE QI='L'
            IF CLIENT='DEFAULT' THEN     ; * JMK01
               STMT = 'SORT FB.BUILD.SPEC BY FMT WITH REC.TYPE = "':PRFX:'" AND WITH CLIENT.ID = "" BY CLIENT.ID CLIENT.ID FMT 1 (I '        ; * JMK01
            END ELSE                     ; * JMK01
               STMT = 'SORT FB.BUILD.SPEC BY FMT WITH REC.TYPE = "':PRFX:'" AND WITH CLIENT.ID = "':CLIENT:'" BY CLIENT.ID CLIENT.ID FMT 1 (I '        ; * JMK01
            END                          ; * JMK01
            EXECUTE STMT
            CALL ELINE('')
            CALL AFS.SCR.HEAD(CO.ID,FILE.ID,'',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
            IF CLIENT#'DEFAULT' THEN
               CRT @(0,4):'Enter Client Number ':CLIENT'R%5':
               CRT ' ':CLIENT.NAME:@(-4):
            END ELSE
               CRT @(0,4):'Enter Client Number DEFAULT':@(-4):
            END
            GOTO 50
         CASE NUM(QI)
         CASE 1
            CALL ELINE('Record: ':QI:' Must be numeric')
            GOTO 50
      END CASE
      VER.NUM=QI
      IF CLIENT='DEFAULT' THEN CLIENT=''
*
* GET RECORD
*
      IF USER='SCOTT' AND VER.NUM#'88' THEN
         CALL ELINE('Only Version 88 for Scott!')
         GO 50
      END
      READU SPEC.REC FROM F.BUILD.SPEC,PRFX:'*':CLIENT:'*':VER.NUM LOCKED        ; * JMK01
         FIND.LOCKED.NAME = 'FB.BUILD.SPEC,':PRFX:'*':CLIENT:'*':VER.NUM         ; * JMK01
         GOSUB FIND.LOCKED
         CALL ELINE(FL.USER:' has ':FIND.LOCKED.NAME:' locked. Press enter to exit program.')
         GOTO 9999
      END ELSE
         SPEC.REC=''
         IF PRFX='MRS' THEN              ; * JMK01
            READ FMT.SPEC.REC FROM F.BUILD.SPEC,'FMT*':CLIENT:'*':VER.NUM THEN   ; * JMK01
55:            HELP="New item. Do you wish to copy the Report Format? [Y]es [N]o"
               CALL GEN.IN(0,22,"Copy Report format. (Y/N)",'',Q,0,1,'','',0,-4,22,0,QI,HELP,0,23)
               QI=OCONV(QI,'MCU')
               IF QI='' THEN QI='Y'      ; * JMK01
               CRT @(0,22):@(-4):        ; * JMK01
               BEGIN CASE                ; * JMK01
                  CASE QI='Y'            ; * JMK01
                     SPEC.REC=FMT.SPEC.REC         ; * JMK01
                  CASE QI='N'            ; * JMK01
                  CASE 1                 ; * JMK01
                     GO 55               ; * JMK01
               END CASE                  ; * JMK01
            END                          ; * JMK01
         END                             ; * JMK01
      END
      OLD.SPEC.REC=SPEC.REC

75:   HELP='Enter The Description of Version'
      IF SPEC.REC<1>='' THEN
         MASK=STR('-',25)
      END ELSE
         MASK=SPEC.REC<1>'L#25'
      END
      CALL GEN.IN(0,8,'Enter Version Description ':MASK,'',Q,0,25,'','',0,-25,8,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      IF QI='' THEN Q=SPEC.REC<1>
      BEGIN CASE
         CASE QI='EX'
            STOP
         CASE QI='X'
            GOTO 50
         CASE Q=''
            CALL ELINE('Entry is required')
            GOTO 75
         CASE 1
      END CASE
      SPEC.REC<1>=Q
      PROG.DESC=PROG.DESC:' - ':PRFX:'*':CLIENT:'*':VER.NUM  ; * JMK01
      CALL AFS.SCR.HEAD(CO.ID,FILE.ID,'',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
*
* First page of codes.
*
      PAGE=1
      GOSUB 9000
*
* Enter selection code.
*
100:  HELP="Enter line number [A]dd [B]ack [T]op ''=Page [E]nd [I]ns [M]ove [EX]it [D]el."
      INSERT='OFF'
      CALL GEN.IN(0,22,"Enter line number please. ###",'',Q,0,3,'','',0,-3,22,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='' OR QI='+'
            IF SPEC.REC<2,PAGE*PAGE.LEN>='' THEN
               CALL ELINE('Error! You are on the last page!')
               GO 100
            END
            PAGE=PAGE+1
            GOSUB 9000
         CASE QI='A'
            MODE='ADD'
            ADDING=1
            OLD.PAGE=0
            LOOP
            WHILE ADDING
               NUM.ITEM=DCOUNT(SPEC.REC<2>,@VM)
               SEL=NUM.ITEM+1
               IF MOD(SEL,PAGE.LEN) > 0 AND MOD(SEL,PAGE.LEN) < PAGE.LEN/2 THEN
                  PAGE=OCONV(SEL/PAGE.LEN,'MR0')+1
               END ELSE
                  PAGE=OCONV(SEL/PAGE.LEN,'MR0')
               END
               IF OLD.PAGE#PAGE THEN
                  GOSUB 9000
                  OLD.PAGE=PAGE
               END
               GOSUB 8000
            REPEAT
            MODE=''
         CASE QI='I'
            INSERT='ON'
            GOSUB 8000
         CASE QI='M'
            NUM.ITEMS=DCOUNT(SPEC.REC<2>,@VM)
**************************************************************************
GET.LINE.NUM.MOVE.FROM:
**************************************************************************
            HELP='Enter line number to move from'
            MASK='Line number ##'
            CALL GEN.IN(0,23,MASK,'',Q,1,3,'','',0,LEN(MASK)-2,23,1,QI,HELP,0,22)
            QI=OCONV(QI,'MCU')
            BEGIN CASE
               CASE QI='X'
                  GOTO 100
               CASE QI='EX'
                  STOP
               CASE NOT(NUM(QI))
                  CALL ELINE("Invalid Entry - must be numeric")
                  GO GET.LINE.NUM.MOVE.FROM
               CASE 1
                  IF Q<0 OR Q>NUM.ITEMS THEN
                     CALL ELINE("Number is beyond range of data - please pick another number")
                     GO GET.LINE.NUM.MOVE.FROM
                  END
            END CASE
            NUM.MV.FROM=Q
**************************************************************************
GET.LINE.NUM.MOVE.TO:
**************************************************************************
            HELP='Enter line number to insert before'
            MASK='Line number ##'
            CALL GEN.IN(0,23,MASK,'',Q,1,3,'','',0,LEN(MASK)-2,23,1,QI,HELP,0,22)
            QI=OCONV(QI,'MCU')
            BEGIN CASE
               CASE QI='X'
                  GOTO GET.LINE.NUM.MOVE.FROM
               CASE QI='EX'
                  STOP
               CASE NOT(NUM(QI))
                  CALL ELINE("Invalid Entry - must be numeric")
                  GO GET.LINE.NUM.MOVE.TO
               CASE 1
                  IF Q<0 OR Q>NUM.ITEMS THEN
                     CALL ELINE("Number is beyond range of data - please pick another number")
                     GO GET.LINE.NUM.MOVE.TO
                  END
            END CASE
            NUM.MV.TO=Q
            IF NUM.MV.TO=NUM.ITEMS THEN
               SPEC.REC<2,NUM.MV.TO+1>=SPEC.REC<2,NUM.MV.FROM>
               SPEC.REC<3,NUM.MV.TO+1>=SPEC.REC<3,NUM.MV.FROM>
               SPEC.REC<4,NUM.MV.TO+1>=SPEC.REC<4,NUM.MV.FROM>
               SPEC.REC<5,NUM.MV.TO+1>=SPEC.REC<5,NUM.MV.FROM>
               SPEC.REC<6,NUM.MV.TO+1>=SPEC.REC<6,NUM.MV.FROM>
               SPEC.REC<7,NUM.MV.TO+1>=SPEC.REC<7,NUM.MV.FROM>
               SPEC.REC<8,NUM.MV.TO+1>=SPEC.REC<8,NUM.MV.FROM>
               SPEC.REC<9,NUM.MV.TO+1>=SPEC.REC<9,NUM.MV.FROM>
               SPEC.REC<10,NUM.MV.TO+1>=SPEC.REC<10,NUM.MV.FROM>
               SPEC.REC<11,NUM.MV.TO+1>=SPEC.REC<11,NUM.MV.FROM>
               SPEC.REC<12,NUM.MV.TO+1>=SPEC.REC<12,NUM.MV.FROM>
               SPEC.REC<13,NUM.MV.TO+1>=SPEC.REC<13,NUM.MV.FROM>       ; * JMK02
               SPEC.REC<14,NUM.MV.TO+1>=SPEC.REC<14,NUM.MV.FROM>       ; * JMK02
            END ELSE
               IF NUM.MV.FROM>NUM.MV.TO THEN
                  FOR X=NUM.ITEMS TO NUM.MV.TO STEP-1
                     SPEC.REC<2,X+1>=SPEC.REC<2,X>
                     SPEC.REC<3,X+1>=SPEC.REC<3,X>
                     SPEC.REC<4,X+1>=SPEC.REC<4,X>
                     SPEC.REC<5,X+1>=SPEC.REC<5,X>
                     SPEC.REC<6,X+1>=SPEC.REC<6,X>
                     SPEC.REC<7,X+1>=SPEC.REC<7,X>
                     SPEC.REC<8,X+1>=SPEC.REC<8,X>
                     SPEC.REC<9,X+1>=SPEC.REC<9,X>
                     SPEC.REC<10,X+1>=SPEC.REC<10,X>
                     SPEC.REC<11,X+1>=SPEC.REC<11,X>
                     SPEC.REC<12,X+1>=SPEC.REC<12,X>
                     SPEC.REC<13,X+1>=SPEC.REC<13,X>         ; * JMK02
                     SPEC.REC<14,X+1>=SPEC.REC<14,X>         ; * JMK02
                  NEXT X
                  NUM.MV.FROM+=1
                  SPEC.REC<2,NUM.MV.TO>=SPEC.REC<2,NUM.MV.FROM>
                  SPEC.REC<3,NUM.MV.TO>=SPEC.REC<3,NUM.MV.FROM>
                  SPEC.REC<4,NUM.MV.TO>=SPEC.REC<4,NUM.MV.FROM>
                  SPEC.REC<5,NUM.MV.TO>=SPEC.REC<5,NUM.MV.FROM>
                  SPEC.REC<6,NUM.MV.TO>=SPEC.REC<6,NUM.MV.FROM>
                  SPEC.REC<7,NUM.MV.TO>=SPEC.REC<7,NUM.MV.FROM>
                  SPEC.REC<8,NUM.MV.TO>=SPEC.REC<8,NUM.MV.FROM>
                  SPEC.REC<9,NUM.MV.TO>=SPEC.REC<9,NUM.MV.FROM>
                  SPEC.REC<10,NUM.MV.TO>=SPEC.REC<10,NUM.MV.FROM>
                  SPEC.REC<11,NUM.MV.TO>=SPEC.REC<11,NUM.MV.FROM>
                  SPEC.REC<12,NUM.MV.TO>=SPEC.REC<12,NUM.MV.FROM>
                  SPEC.REC<13,NUM.MV.TO>=SPEC.REC<13,NUM.MV.FROM>      ; * JMK02
                  SPEC.REC<14,NUM.MV.TO>=SPEC.REC<14,NUM.MV.FROM>      ; * JMK02
               END ELSE
                  INS SPEC.REC<2,NUM.MV.FROM> BEFORE SPEC.REC<2,NUM.MV.TO+1>
                  INS SPEC.REC<3,NUM.MV.FROM> BEFORE SPEC.REC<3,NUM.MV.TO+1>
                  INS SPEC.REC<4,NUM.MV.FROM> BEFORE SPEC.REC<4,NUM.MV.TO+1>
                  INS SPEC.REC<5,NUM.MV.FROM> BEFORE SPEC.REC<5,NUM.MV.TO+1>
                  INS SPEC.REC<6,NUM.MV.FROM> BEFORE SPEC.REC<6,NUM.MV.TO+1>
                  INS SPEC.REC<7,NUM.MV.FROM> BEFORE SPEC.REC<7,NUM.MV.TO+1>
                  INS SPEC.REC<8,NUM.MV.FROM> BEFORE SPEC.REC<8,NUM.MV.TO+1>
                  INS SPEC.REC<9,NUM.MV.FROM> BEFORE SPEC.REC<9,NUM.MV.TO+1>
                  INS SPEC.REC<10,NUM.MV.FROM> BEFORE SPEC.REC<10,NUM.MV.TO+1>
                  INS SPEC.REC<11,NUM.MV.FROM> BEFORE SPEC.REC<11,NUM.MV.TO+1>
                  INS SPEC.REC<12,NUM.MV.FROM> BEFORE SPEC.REC<12,NUM.MV.TO+1>
                  INS SPEC.REC<13,NUM.MV.FROM> BEFORE SPEC.REC<13,NUM.MV.TO+1>   ; * JMK02
                  INS SPEC.REC<14,NUM.MV.FROM> BEFORE SPEC.REC<14,NUM.MV.TO+1>   ; * JMK02
               END
            END
            SPEC.REC=DELETE(SPEC.REC,2,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,3,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,4,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,5,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,6,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,7,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,8,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,9,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,10,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,11,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,12,NUM.MV.FROM)
            SPEC.REC=DELETE(SPEC.REC,13,NUM.MV.FROM)         ; * JMK02
            SPEC.REC=DELETE(SPEC.REC,14,NUM.MV.FROM)         ; * JMK02
            GOSUB DO.FORMULA.COUNT
            GOSUB 9000
         CASE QI='B' OR QI='-'
            PAGE=PAGE-1
            IF PAGE=0 THEN PAGE=1
            GOSUB 9000
         CASE QI='T'
            PAGE=1
            GOSUB 9000
         CASE QI='P'
            GOSUB 9100
            GOSUB 9000
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 100
            END
            GOTO 9999
         CASE NUM(QI)
            SEL=QI
            IF SEL LT START ! SEL GT STOP THEN
               CALL ELINE('Invalid selection.')
               GOTO 100
            END
            IF SEL = 1 ELSE
               IF SPEC.REC<2,SEL> = '' THEN
                  CALL ELINE('Invalid Entry - use "A" to add "M" to move or "I" to insert')
                  GOTO 100
               END
            END
            GOSUB 8000
         CASE QI='E'
            X=DCOUNT(SPEC.REC<2>,CHAR(253))
            FOR I=X TO 1 STEP -1
               IF SPEC.REC<12,I>='' THEN
                  SPEC.REC<12,I>='NULL'
                  SPEC.REC<12,I>=''
               END
               IF SPEC.REC<2,I>='' THEN
                  SPEC.REC=DELETE(SPEC.REC,2,I)
                  SPEC.REC=DELETE(SPEC.REC,3,I)
                  SPEC.REC=DELETE(SPEC.REC,4,I)
                  SPEC.REC=DELETE(SPEC.REC,5,I)
                  SPEC.REC=DELETE(SPEC.REC,6,I)
                  SPEC.REC=DELETE(SPEC.REC,7,I)
                  SPEC.REC=DELETE(SPEC.REC,8,I)
                  SPEC.REC=DELETE(SPEC.REC,9,I)
                  SPEC.REC=DELETE(SPEC.REC,10,I)
                  SPEC.REC=DELETE(SPEC.REC,11,I)
                  SPEC.REC=DELETE(SPEC.REC,12,I)
                  SPEC.REC=DELETE(SPEC.REC,13,I)   ; * JMK02
                  SPEC.REC=DELETE(SPEC.REC,14,I)   ; * JMK02
               END
            NEXT I
            WRITE SPEC.REC ON F.BUILD.SPEC,PRFX:'*':CLIENT:'*':VER.NUM           ; * JMK01
            GOTO 20
         CASE QI='D'                     ; * JMK01
            HELP="Are you sure? [N]o [Y]es"
            CRT @(0,22):@(-4):           ; * JMK01
            CALL GEN.IN(0,22,"Delete? (Y/N)",'',Q,0,1,'','',0,-2,22,0,QI,HELP,0,23)
            QI=OCONV(QI,'MCU')
            IF QI='' THEN QI='N'         ; * JMK01
            BEGIN CASE                   ; * JMK01
               CASE QI='Y'               ; * JMK01
                  DELETE F.BUILD.SPEC,PRFX:'*':CLIENT:'*':VER.NUM      ; * JMK01
                  GOTO 20
               CASE 1
                  GOTO 100
            END CASE                     ; * JMK01
      END CASE
      GOTO 100
*
*-----------------------------------------------------------------------
* INTERNAL SUBROUTINES
*-----------------------------------------------------------------------
*
* EDIT REC
*
8000:
      IF INSERT='ON' THEN
         GOSUB GET.INSERT.POINT
         IF INSERT='OFF' THEN
            RETURN
         END
         GOSUB DO.FORMULA.COUNT
      END
      IF MODE='ADD' THEN
         IF INSERT#'ON' THEN
            GOSUB DO.FORMULA.COUNT
         END
      END
      ROW=3+REM(SEL,PAGE.LEN)
      IF ROW=3 THEN ROW=21
      COL=SPEC.REC<11,SEL>
      COL.HEAD=SPEC.REC<2,SEL>
      FILE.NAME=SPEC.REC<3,SEL>
      ATTR=SPEC.REC<4,SEL>
      VAL=SPEC.REC<5,SEL>
      CONVERSION=SPEC.REC<6,SEL>
      T.FILE=SPEC.REC<7,SEL>
      T.ATTR=SPEC.REC<8,SEL>
      T.VAL=SPEC.REC<9,SEL>
      SUBTOTAL=SPEC.REC<10,SEL>
      FORMULA=SPEC.REC<12,SEL>
      R.ATTR=SPEC.REC<13,SEL>            ; * JMK02
      R.VAL=SPEC.REC<14,SEL>             ; * JMK02
*
**************************************************************************
EDIT.RECORD.DISPLAY:
*************************************************************************
      IF SPEC.REC<12,SEL>='' THEN
         CRT @(0,2):@(-3):               ; * JMK02
         CRT @(0,4):STR('-',80):
         CRT @(0,6):'Excel Column':@(15,6):'- ':COL:
         CRT @(0,7):'Column Heading':@(15,7):'- ':COL.HEAD:
         CRT @(0,8):'File Name':@(15,8):'- ':FILE.NAME:
         CRT @(0,9):'Attribute':@(15,9):'- ':SPEC.REC<4,SEL>:
         CRT @(0,10):'Attr Val':@(15,10):'- ':SPEC.REC<5,SEL>:
         CRT @(0,11):'Ref Attr':@(15,11):'- ':SPEC.REC<13,SEL>:        ; * JMK02
         CRT @(0,12):'Ref Value':@(15,12):'- ':SPEC.REC<14,SEL>:       ; * JMK02
*        CRT @(0,11):'Conversion':@(15,11):'- ':SPEC.REC<6,SEL>: ; * JMK02
*        CRT @(0,12):'T File':@(15,12):'- ':SPEC.REC<7,SEL>:     ; * JMK02
*        CRT @(0,13):'T File Attr':@(15,13):'- ':SPEC.REC<8,SEL>: ; * JMK02
*        CRT @(0,14):'T File Val':@(15,14):'- ':SPEC.REC<9,SEL>:  ; * JMK02
*        CRT @(0,15):'Subtotal':@(15,15):'- ':SPEC.REC<10,SEL>:   ; * JMK02
         CRT @(0,13):'Conversion':@(15,13):'- ':SPEC.REC<6,SEL>:       ; * JMK02
         CRT @(0,14):'T File':@(15,14):'- ':SPEC.REC<7,SEL>:           ; * JMK02
         CRT @(0,15):'T File AttR':@(15,15):'- ':SPEC.REC<8,SEL>:      ; * JMK02
         CRT @(0,16):'T File Val':@(15,16):'- ':SPEC.REC<9,SEL>:       ; * JMK02
         CRT @(0,17):'Subtotal':@(15,17):'- ':SPEC.REC<10,SEL>:        ; * JMK02
      END ELSE
         CRT @(0,3):@(-3):
         CRT @(0,4):STR('-',80):
         CRT @(0,6):'This entry is a formula!':
         CRT @(0,8):'Formula':@(15,8):': ':SPEC.REC<12,SEL>:
         HELP='Do you wish to convert this formula or edit existing formula?'
         MASK='[C]onvert - [E]dit - [X]-Back [EX]it ##'
         CALL GEN.IN(0,23,MASK,'',Q,0,1,'','',0,LEN(MASK)-2,23,1,QI,HELP,0,22)
         QI=OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI='' OR QI='X'
               GOSUB 9000
               GOTO 100
            CASE QI='EX'
               STOP
            CASE QI='C'
               SPEC.REC<12,SEL>=''
               GO EDIT.RECORD.DISPLAY
            CASE QI='E'
               GO EDIT.FORMULA
         END CASE
      END

8015: IF MODE='ADD' THEN
         HELP="Enter the Column Heading Guide. 'D'=Delete. 'EX'=Exit 'F'=Formula. 'X'=Exit Add"
      END ELSE
         HELP="Enter the Column Heading Guide. 'D'=Delete. 'EX'=Exit 'F'=Formula."
      END
      IF COL.HEAD='' THEN MASK=STR('-',20) ELSE MASK=COL.HEAD'L#20'
      CALL GEN.IN(17,7,MASK,'',Q,0,20,'','',2,17,7,0,QI,HELP,0,23)
      IF QI='' THEN QI=COL.HEAD
      IF MODE='ADD' THEN
         IF QI='' AND SEL#1 THEN
            CALL ELINE("Must enter a description")
            GO 8015
            RETURN
         END
      END
      BEGIN CASE
         CASE QI='X'
            IF INSERT='ON' THEN
               INSERT='OFF'
               SPEC.REC=T.OLD.SPEC.REC
            END
            IF MODE='ADD' THEN
               ADDING=0
               MODE=''
               SPEC.REC=DELETE(SPEC.REC,2,SEL)
               SPEC.REC=DELETE(SPEC.REC,3,SEL)
               SPEC.REC=DELETE(SPEC.REC,4,SEL)
               SPEC.REC=DELETE(SPEC.REC,5,SEL)
               SPEC.REC=DELETE(SPEC.REC,6,SEL)
               SPEC.REC=DELETE(SPEC.REC,7,SEL)
               SPEC.REC=DELETE(SPEC.REC,8,SEL)
               SPEC.REC=DELETE(SPEC.REC,9,SEL)
               SPEC.REC=DELETE(SPEC.REC,10,SEL)
               SPEC.REC=DELETE(SPEC.REC,11,SEL)
               SPEC.REC=DELETE(SPEC.REC,12,SEL)
               SPEC.REC=DELETE(SPEC.REC,13,SEL)    ; * JMK02
               SPEC.REC=DELETE(SPEC.REC,14,SEL)    ; * JMK02
            END
            GOSUB 9000
            RETURN
         CASE OCONV(QI,'MCU')='F'
            GO EDIT.FORMULA
         CASE OCONV(QI,'MCU')='D'
            SPEC.REC=DELETE(SPEC.REC,1,SEL)
            SPEC.REC=DELETE(SPEC.REC,2,SEL)
            SPEC.REC=DELETE(SPEC.REC,3,SEL)
            SPEC.REC=DELETE(SPEC.REC,4,SEL)
            SPEC.REC=DELETE(SPEC.REC,5,SEL)
            SPEC.REC=DELETE(SPEC.REC,6,SEL)
            SPEC.REC=DELETE(SPEC.REC,7,SEL)
            SPEC.REC=DELETE(SPEC.REC,8,SEL)
            SPEC.REC=DELETE(SPEC.REC,9,SEL)
            SPEC.REC=DELETE(SPEC.REC,10,SEL)
            SPEC.REC=DELETE(SPEC.REC,11,SEL)
            SPEC.REC=DELETE(SPEC.REC,12,SEL)
            SPEC.REC=DELETE(SPEC.REC,13,SEL)       ; * JMK02
            SPEC.REC=DELETE(SPEC.REC,14,SEL)       ; * JMK02
            GOSUB 9000
            GOTO 100
         CASE OCONV(QI,'MCU')='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8015
            END
            GOTO 9999
         CASE QI=''
            CALL ELINE('Invalid entry. Data required in this field.')
            GOTO 8015
      END CASE
      COL.HEAD=QI
      CRT @(17,7):COL.HEAD'L#20'
*
8030: HELP="Enter file to use FB - FB.BILLS.HIST/EDI - EDI.BILLS.HIST/TR - FB.TRANSPORT."
      IF FILE.NAME='' THEN MASK=STR('-',5) ELSE MASK=FILE.NAME'L#5'
      CALL GEN.IN(17,8,MASK,'',Q,0,5,'','',2,17,8,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=FILE.NAME
      BEGIN CASE
         CASE QI='X'
            CRT @(17,8):FILE.NAME'L#5'
            GOTO 8015
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8030
            END
            GOTO 9999
         CASE QI='FB' OR QI='EDI' OR QI='TR' OR QI = 'VC' OR QI = 'FBP' ; * JMK10
         CASE 1
            CALL ELINE('Entry must be FB, EDI, TR or BOL for file name')
            GOTO 8030
      END CASE
      FILE.NAME=QI
      CRT @(17,8):FILE.NAME'L#5'
*
8050: HELP="Enter the Attribute. [EX]-Exit."
      IF ATTR='' THEN MASK=STR('#',3) ELSE MASK=ATTR'R#3'
      CALL GEN.IN(17,9,MASK,'',Q,0,3,'','',2,17,9,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=ATTR
      BEGIN CASE
         CASE QI='X'
            CRT @(17,9):ATTR'R#3'
            GOTO 8030
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8050
            END
            GOTO 9999
         CASE QI=''
            CALL ELINE('Entry is required ')
            GOTO 8050
         CASE NUM(QI)
         CASE 1
            CALL ELINE('Invalid Entry - Must be Numeric')
            GOTO 8050
      END CASE
      ATTR=QI
      CRT @(17,9):ATTR'R#3'
*
8100: HELP="Enter the Value. [L]ocate [E]xclude [S]um [EX]-Exit."      ; * JMK05
      IF VAL='' THEN MASK=STR('#',2) ELSE MASK=VAL'R#2'
      CALL GEN.IN(17,10,MASK,'',Q,0,2,'','',2,17,10,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=VAL
      BEGIN CASE
         CASE QI='X'
            CRT @(17,10):VAL'R#2'
            GOTO 8050
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8100
            END
            GOTO 9999
         CASE QI=''
         CASE NUM(QI)
         CASE QI='L'                     ; * JMK02
         CASE QI='E'                     ; * JMK05
         CASE QI='S'                     ; * JMK03
            R.ATTR=''                    ; * JMK03
            R.VAL=''                     ; * JMK03
            CRT @(17,11):R.ATTR'R#3'     ; * JMK03
            CRT @(17,12):R.VAL'L#40'     ; * JMK03
         CASE 1
            CALL ELINE('Entry must be numeric or blank.')
            GOTO 8100
      END CASE
      VAL=QI
      CRT @(17,10):VAL'R#2'
*
      IF VAL='L' OR VAL='E' THEN         ; * JMK02; * JMK04
8120:    HELP="Enter the Reference Attribute. [EX]-Exit."
         IF R.ATTR='' THEN MASK=STR('#',3) ELSE MASK=R.ATTR'R#3'
         CALL GEN.IN(17,11,MASK,'',Q,0,3,'','',2,17,11,0,QI,HELP,0,23)
         QI=OCONV(QI,'MCU')
         IF QI='' THEN QI=R.ATTR
         BEGIN CASE
            CASE QI='X'
               CRT @(17,11):R.ATTR'R#3'
               GOTO 8030
            CASE QI='EX'
               IF OLD.SPEC.REC#SPEC.REC THEN
                  GOSUB ASK.FOR.CONFIRMATION
                  IF NOT(CONFIRMATION) THEN GOTO 8120
               END
               GOTO 9999
            CASE QI=''
               CALL ELINE('Entry is required ')
               GOTO 8120
            CASE NUM(QI)
            CASE 1
               CALL ELINE('Invalid Entry - Must be Numeric')
               GOTO 8120
         END CASE
         R.ATTR=QI
         CRT @(17,11):R.ATTR'R#3'
*
8140:    HELP="Enter the Reference Literal Value(s). [EX]-Exit."       ; * JMK05
         IF R.VAL='' THEN MASK=STR('#',60) ELSE MASK=R.VAL'L#60'       ; * JMK05; * JMK06
         CALL GEN.IN(17,12,MASK,'',Q,0,63,'','',2,17,12,0,QI,HELP,0,23)          ; * JMK05; * JMK06
         QI=OCONV(QI,'MCU')
         IF QI='' THEN QI=R.VAL
         BEGIN CASE
            CASE QI='X'
               CRT @(17,12):R.VAL'L#60'  ; * JMK05; * JMK06
               GOTO 8030
            CASE QI='EX'
               IF OLD.SPEC.REC#SPEC.REC THEN
                  GOSUB ASK.FOR.CONFIRMATION
                  IF NOT(CONFIRMATION) THEN GOTO 8140
               END
               GOTO 9999
            CASE QI=''
               CALL ELINE('Entry is required ')
               GOTO 8140
         END CASE
         R.VAL=QI
         CRT @(17,12):R.VAL'L#60'        ; * JMK05; * JMK06
*
      END                                ; * JMK02
8200: HELP="Enter the Conversion. [EX]-Exit."
      IF CONVERSION='' THEN MASK=STR('-',5) ELSE MASK=CONVERSION'L#5'
      CALL GEN.IN(17,13,MASK,'',Q,0,5,'','',2,17,13,0,QI,HELP,0,23)    ; * JMK02
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=CONVERSION
      BEGIN CASE
         CASE QI='X'
            CRT @(17,13):CONVERSION'L#5'           ; * JMK02
            GOTO 8100
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8200
            END
            GOTO 9999
      END CASE
      CONVERSION=QI
      CRT @(17,13):CONVERSION'L#5'       ; * JMK02
*
8300: HELP='Enter T-File Name "CL"ient "CA"rrier [LI.CODES]-TS Codes "DV" Div "DVZ" Div zip'
      IF T.FILE='' THEN MASK=STR('-',20) ELSE MASK=T.FILE'L#20'
      CALL GEN.IN(17,14,MASK,'',Q,0,20,'','',2,17,14,0,QI,HELP,0,23)   ; * JMK02
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=T.FILE
      BEGIN CASE
         CASE QI='X'
            CRT @(17,14):T.FILE'L#20'    ; * JMK02
            GOTO 8200
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8300
            END
            GOTO 9999

         CASE QI=''                      ; * JMK08
         CASE QI='CL'                    ; * JMK08
         CASE QI='CA'                    ; * JMK08
         CASE QI='LI.CODES'              ; * JMK08
         CASE QI='CHG.CODES'             ; * JMK11
         CASE QI='CHG.DESC'              ; * JMK11
         CASE QI='OVRCHG.CODES'          ; * JMK11
         CASE QI='INTL.CODES'            ; * JMK09
         CASE QI='SERV.LEV'              ; * JMK08
         CASE QI='AFS.SERV.LEV'          ; * JMK08
         CASE QI='REJ.CODES'             ; * JMK08
         CASE QI='CS'                    ; * JMK08
         CASE QI='DV'                    ; * JMK08
         CASE QI='DVZ'                   ; * JMK08
         CASE QI='VC'                    ; * JMK08
         CASE QI='FB.COUNTRIES'          ; * JMK08
         CASE QI='FB.TRANSPORT'
         CASE QI='SHIPPER'               ; * JMK12
         CASE QI='CONSIGNEE'             ; * JMK12
         CASE QI ='BOL'                  ; * GRB01
         CASE QI=' '                     ; * JMK02
            QI=''                        ; * JMK02
         CASE 1
            CALL ELINE(QI:' Is Not a Valid File Name')
            GOTO 8300
      END CASE
      IF QI='' AND T.FILE='' THEN GO 8505
      T.FILE=QI
      CRT @(17,14):T.FILE'L#20'          ; * JMK02
*
8400: HELP="Enter the T-File Attribute. [EX]-Exit."
      IF T.ATTR='' THEN MASK=STR('#',3) ELSE MASK=T.ATTR'R#3'
      CALL GEN.IN(17,15,MASK,'',Q,0,3,'','',2,17,15,0,QI,HELP,0,23)    ; * JMK02
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=T.ATTR
      BEGIN CASE
         CASE QI='X'
            CRT @(17,15):T.ATTR'R#3'     ; * JMK02
            GOTO 8300
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8400
            END
            GOTO 9999
         CASE QI=''
            IF SPEC.REC<7,SEL>#'' THEN
               CALL ELINE('Entry is required since T-File exists')
               GOTO 8400
            END
         CASE QI=' ' AND T.FILE=''       ; * JMK02
            QI=''                        ; * JMK02
         CASE NUM(QI)
         CASE 1
            CALL ELINE('Invalid entry - Entry must be numeric')
            GOTO 8400
      END CASE
      T.ATTR=QI
      CRT @(17,15):T.ATTR'R#3'           ; * JMK02
*
8500: HELP="Enter the T-File Value. [EX]-Exit."
      IF T.VAL='' THEN MASK=STR('#',2) ELSE MASK=T.VAL'R#2'
      CALL GEN.IN(17,16,MASK,'',Q,0,2,'','',2,17,16,0,QI,HELP,0,23)    ; * JMK02
      QI=OCONV(QI,'MCU')
      IF QI='' THEN QI=T.VAL
      BEGIN CASE
         CASE QI='X'
*           CRT @(17,14):T.VAL'R#2' ; * JMK02
            CRT @(17,16):T.VAL'R#2'      ; * JMK02
            GOTO 8400
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8500
            END
            GOTO 9999
         CASE QI=''
         CASE NUM(QI)
         CASE 1
            IF QI=' ' THEN
               QI=''
            END ELSE
               CALL ELINE('T.File Value must be blank or numeric')
               GOTO 8500
            END
      END CASE
      T.VAL=QI
      CRT @(17,16):T.VAL'R#2'            ; * JMK02

8505: HELP="Enter 1 If subtotal needed. [EX]-Exit."
      IF SUBTOTAL='' THEN MASK=STR('#',2) ELSE MASK=SUBTOTAL'R#2'
*     CALL GEN.IN(17,15,MASK,'',Q,0,2,'','',2,17,15,0,QI,HELP,0,23) ; * JMK02
      CALL GEN.IN(17,17,MASK,'',Q,0,2,'','',2,17,17,0,QI,HELP,0,23)    ; * JMK02
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI=''
            QI=SUBTOTAL
         CASE QI='X'
            CRT @(17,17):SUBTOTAL'R#2'   ; * JMK02
            GOTO 8500
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8500
            END
            GOTO 9999
         CASE NUM(QI)
            IF Q NE '1' THEN
               CALL ELINE('Must be blank or "1"')
               GOTO 8505
            END
         CASE 1
            IF SUBTOTAL='' THEN
               CALL ELINE('Must be blank or "1"')
               GOTO 8505
            END
      END CASE
      SUBTOTAL=QI
      CRT @(17,17):SUBTOTAL'R#2'         ; * JMK02

8506: HELP="Is the above information correct?"
      MASK='Information correct? (Y/N)'
      CALL GEN.IN(0,23,MASK,'',Q,0,2,'','',2,-4,23,0,QI,HELP,0,22)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='' OR QI='Y'
         CASE QI='X'
            GOTO 8505
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8506
            END
            GOTO 9999
         CASE NUM(QI)
            CALL ELINE("Invalid Entry")
            GO 8506
         CASE QI='N'
            CRT @(0,22):@(-3):
            GO 8505
      END CASE
*
**************************************************************************
UPDATE.LINE:***
*************************************************************************
      SPEC.REC<2,SEL>=COL.HEAD
      SPEC.REC<3,SEL>=FILE.NAME
      SPEC.REC<4,SEL>=ATTR
      SPEC.REC<5,SEL>=VAL
      SPEC.REC<6,SEL>=CONVERSION
      SPEC.REC<7,SEL>=T.FILE
      SPEC.REC<8,SEL>=T.ATTR
      SPEC.REC<9,SEL>=T.VAL
      SPEC.REC<10,SEL>=SUBTOTAL
      GOSUB DO.FORMULA.COUNT
      SPEC.REC<12>=FORMULA
      SPEC.REC<13,SEL>=R.ATTR            ; * JMK02
      SPEC.REC<14,SEL>=R.VAL             ; * JMK02
      GOSUB 9000
      RETURN
*

**************************************************************************
9000:* DISPLAY ARRAY
*************************************************************************
*CRT @(00,3):@(-3):"Ln":            ; * JMK02
      CRT @(00,2):@(-3):                 ; * JMK02
      CRT @(43,2):"|- Ref --|":          ; * JMK02
      CRT @(60,2):"|- Lookup --|":       ; * JMK02
      CRT @(00,3):"Ln":                  ; * JMK02
      CRT @(04,3):'COL':
*     CRT @(09,3):"Col Heading":         ; * JMK02
*     CRT @(30,3):"File":                ; * JMK02
*     CRT @(36,3):"Attr":                ; * JMK02
*     CRT @(41,3):"Val":                 ; * JMK02
*     CRT @(45,3):"Cnvr":                ; * JMK02
*     CRT @(51,3):"T File":              ; * JMK02
*     CRT @(60,3):"T Attr":              ; * JMK02
*     CRT @(67,3):"Subtotal":            ; * JMK02
      CRT @(08,3):"Col Heading":         ; * JMK02
      CRT @(29,3):"File":                ; * JMK02
      CRT @(35,3):"Att":                 ; * JMK02
      CRT @(39,3):"Val":                 ; * JMK02
      CRT @(43,3):"Att":                 ; * JMK02
      CRT @(47,3):"Val":                 ; * JMK02
      CRT @(54,3):"Cnvr":                ; * JMK02
      CRT @(60,3):"File":                ; * JMK02
      CRT @(70,3):"Att":                 ; * JMK02
      CRT @(74,3):"Subtot":              ; * JMK02

      START=(PAGE*PAGE.LEN)-17

      STOP=START+17
      FOR I=START TO STOP STEP 1
         ROW=3+REM(I,PAGE.LEN)
         IF ROW=3 THEN ROW=21
         COL=SPEC.REC<11,I>
         COL.HEAD=SPEC.REC<2,I>
         FILE.NAME=SPEC.REC<3,I>
         ATTR=SPEC.REC<4,I>
         VAL=SPEC.REC<5,I>
         CONVERSION=SPEC.REC<6,I>
         T.FILE=SPEC.REC<7,I>
         T.ATTR=SPEC.REC<8,I>
         T.VAL=SPEC.REC<9,I>
         SUBTOTAL=SPEC.REC<10,I>
         R.ATTR=SPEC.REC<13,I>           ; * JMK02
         R.VAL=SPEC.REC<14,I>            ; * JMK02
         CRT @(00,ROW):I"R#3":
         CRT @(04,ROW):COL:
*        CRT @(09,ROW):COL.HEAD'L#20':   ; * JMK02
*        CRT @(30,ROW):FILE.NAME'L#5':   ; * JMK02
*        CRT @(36,ROW):ATTR'R#3':        ; * JMK02
*        CRT @(41,ROW):VAL'R#2':         ; * JMK02
*        CRT @(45,ROW):CONVERSION'L#5':  ; * JMK02
*        CRT @(51,ROW):T.FILE'L#20':     ; * JMK02
*        CRT @(60,ROW):T.ATTR'R#3':      ; * JMK02
*        CRT @(67,ROW):SUBTOTAL:         ; * JMK02
         CRT @(08,ROW):COL.HEAD'L#20':   ; * JMK02
         CRT @(29,ROW):FILE.NAME'L#5':   ; * JMK02
         CRT @(35,ROW):ATTR'R#3':        ; * JMK02
         CRT @(39,ROW):VAL'R#2':         ; * JMK02
         CRT @(43,ROW):R.ATTR'R#3':      ; * JMK02
         CRT @(47,ROW):R.VAL'L#6':       ; * JMK02
         CRT @(54,ROW):CONVERSION'L#5':  ; * JMK02
         CRT @(60,ROW):T.FILE'L#9':      ; * JMK02
         CRT @(70,ROW):T.ATTR'R#3':      ; * JMK02
         CRT @(74,ROW):SUBTOTAL:         ; * JMK02
      NEXT I
      RETURN
* 
*************************************************************************
9100:* PRINT ARRAY
************************************************************************
      PRINTER ON
      HED1=PRFX:'*':CLIENT:'*':VER.NUM:' - ':SPEC.REC<1>'L#50'
      HED2=SPACE(43):"|- Ref --|":SPACE(7):"|- Lookup --|"
      HED3="Ln ":"COL ":"Col Heading":SPACE(10):"File  ":"Att ":"Val":"Att ":"Val   ":"Cnvr ":"File     ":"Att":"Subtot"
      HEADING HED1:"'L'":HED2:"'L'":HED3:"'LL'"

      NVAL=DCOUNT(SPEC.REC<11>,@VM)
      FOR I=1 TO NVAL
         COL=SPEC.REC<11,I>
         COL.HEAD=SPEC.REC<2,I>
         FILE.NAME=SPEC.REC<3,I>
         ATTR=SPEC.REC<4,I>
         VAL=SPEC.REC<5,I>
         CONVERSION=SPEC.REC<6,I>
         T.FILE=SPEC.REC<7,I>
         T.ATTR=SPEC.REC<8,I>
         T.VAL=SPEC.REC<9,I>
         SUBTOTAL=SPEC.REC<10,I>
         R.ATTR=SPEC.REC<13,I>
         R.VAL=SPEC.REC<14,I>
         PRINT I"R#3 ":COL"R#4 ":COL.HEAD'L#20 ':FILE.NAME'L#5 ':ATTR'R#3 ':VAL'R#2 ':R.ATTR'R#3 ':R.VAL'L#6 ':CONVERSION'L#5 ':T.FILE'L#9 ':T.ATTR'R#3 ':SUBTOTAL
      NEXT I
      PRINTER OFF
      PRINTER CLOSE
      RETURN

*************************************************************************
EDIT.FORMULA:
*************************************************************************

      CRT @(0,4):@(-3):
      OSR=''
      OSR<3>=SPEC.REC<3,SEL>
      OSR<4>=SPEC.REC<4,SEL>
      OSR<5>=SPEC.REC<5,SEL>
      OSR<6>=SPEC.REC<6,SEL>
      OSR<7>=SPEC.REC<7,SEL>
      OSR<8>=SPEC.REC<8,SEL>
      OSR<9>=SPEC.REC<9,SEL>
      SPEC.REC<3,SEL>=''
      SPEC.REC<4,SEL>=''
      SPEC.REC<5,SEL>=''
      SPEC.REC<6,SEL>=''
      SPEC.REC<7,SEL>=''
      SPEC.REC<8,SEL>=''
      SPEC.REC<9,SEL>=''
      CRT @(0,5):'Column Heading':@(15,5):'- ':SPEC.REC<2,SEL>:@(-4):
      CRT @(0,6):'Formula':@(15,6):'- ':SPEC.REC<12,SEL>:@(-4):
      CRT @(0,8):STR('-',80):

*************************************************************************
GET.COL.HED.FORMULA:
*************************************************************************

      HELP="Enter the Column Heading Guide. 'D'=Delete. 'EX'=Exit."
      IF COL.HEAD='' THEN MASK=STR('-',20) ELSE MASK=COL.HEAD'L#20'
      CALL GEN.IN(17,5,MASK,'',Q,0,20,'','',2,17,5,0,QI,HELP,0,23)
      IF QI='' THEN QI=COL.HEAD
      BEGIN CASE
         CASE QI='X'
            SPEC.REC<3,SEL>=OSR<3>
            SPEC.REC<4,SEL>=OSR<4>
            SPEC.REC<5,SEL>=OSR<5>
            SPEC.REC<6,SEL>=OSR<6>
            SPEC.REC<7,SEL>=OSR<7>
            SPEC.REC<8,SEL>=OSR<8>
            SPEC.REC<9,SEL>=OSR<9>
            GO 9000
         CASE OCONV(QI,'MCU')='D'
            SPEC.REC=DELETE(SPEC.REC,1,SEL)
            SPEC.REC=DELETE(SPEC.REC,2,SEL)
            SPEC.REC=DELETE(SPEC.REC,3,SEL)
            SPEC.REC=DELETE(SPEC.REC,4,SEL)
            SPEC.REC=DELETE(SPEC.REC,5,SEL)
            SPEC.REC=DELETE(SPEC.REC,6,SEL)
            SPEC.REC=DELETE(SPEC.REC,7,SEL)
            SPEC.REC=DELETE(SPEC.REC,8,SEL)
            SPEC.REC=DELETE(SPEC.REC,9,SEL)
            SPEC.REC=DELETE(SPEC.REC,10,SEL)
            SPEC.REC=DELETE(SPEC.REC,11,SEL)
            SPEC.REC=DELETE(SPEC.REC,12,SEL)
            SPEC.REC=DELETE(SPEC.REC,13,SEL)       ; * JMK02
            SPEC.REC=DELETE(SPEC.REC,14,SEL)       ; * JMK02
            GOSUB 9000
            GOTO 100
         CASE OCONV(QI,'MCU')='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO 8015
            END
            GOTO 9999
         CASE QI=''
            CALL ELINE('Invalid entry. Data required in this field.')
            GOTO 8015
      END CASE
      SPEC.REC<2,SEL>=QI
      COL.HEAD=SPEC.REC<2,SEL>
      CRT @(17,5):COL.HEAD'L#20'


      HELP='Enter formula - "+" or "-" to page through the list'
      MASK=SPEC.REC<12,SEL>
      START=0
      F.PAGE=1
      F.PAGE.LEN=30

*************************************************************************
DISPLAY.COL.LIST:
*************************************************************************

      LINE.COUNT=START
      FOR OUTER.LOOP=1 TO 3
         FOR INNER.LOOP=1 TO 10
            LINE.COUNT+=1
            IF OUTER.LOOP=1 THEN
               COL.IDX=0
            END
            IF OUTER.LOOP=2 THEN
               COL.IDX=25
            END
            IF OUTER.LOOP=3 THEN
               COL.IDX=50
            END
            CRT @(COL.IDX,INNER.LOOP+8):SPEC.REC<11,LINE.COUNT>:' - ':SPEC.REC<2,LINE.COUNT>:@(-4):
         NEXT INNER.LOOP
      NEXT OUTER.LOOP

*************************************************************************
GET.FORMULA.CHOICE:
*************************************************************************

      CALL GEN.IN(17,6,MASK,'',Q,0,40,'','',0,17,6,2,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='X'
            CRT @(17,6):SPEC.REC<12,SEL>:
            GO GET.COL.HED.FORMULA
         CASE QI='EX'
            IF OLD.SPEC.REC#SPEC.REC THEN
               GOSUB ASK.FOR.CONFIRMATION
               IF NOT(CONFIRMATION) THEN GOTO GET.FORMULA.CHOICE
            END
            GOTO 9999
         CASE QI='+'
            IF SPEC.REC<2,F.PAGE*F.PAGE.LEN>='' THEN
               CALL ELINE("Error - you are on the last page!")
               GO GET.FORMULA.CHOICE
            END
            F.PAGE+=1
            START=START+30
            GO DISPLAY.COL.LIST
         CASE QI='-'
            F.PAGE=F.PAGE-1
            START=START-30
            IF F.PAGE=0 THEN
               F.PAGE=1
               START=0
            END
            GO DISPLAY.COL.LIST
         CASE 1
            IF QI='' ELSE
               SPEC.REC<12,SEL>=QI
            END
            GO 9000
      END CASE

      RETURN
*
*************************************************************************
FIND.LOCKED:
************************************************************************
      STMT = 'LIST.READU EVERY'
      EXECUTE STMT CAPTURING OUTPUT
      FL.LEN = DCOUNT(OUTPUT,@AM)
      FL.USER = 'Someone'
      FOUND = 0

      FOR X = 1 TO FL.LEN UNTIL FOUND
         T.USER = OCONV(TRIM(OUTPUT<X>[44,9]),'MCU')
         T.FILE = TRIM(OUTPUT<X>[53,17])
         IF T.FILE = FIND.LOCKED.NAME THEN
            FL.USER = T.USER
            FOUND = 1
         END
      NEXT


      RETURN
*************************************************************************
ASK.FOR.CONFIRMATION:***
************************************************************************
      HELP='Enter <Y>es to exit without saving or <N>o to return to program'
      CALL GEN.IN(0,22,'Are You Sure You Want To Exit: N','',Q,0,1,'','',2,-1,22,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='N' OR QI=''
            CONFIRMATION=0
         CASE QI='Y'
            CONFIRMATION=1
         CASE 1
            CALL ELINE('Invalid Entry')
            GOTO ASK.FOR.CONFIRMATION
      END CASE
      CRT @(0,22):@(-3):
      RETURN
*************************************************************************
9999:* EXIT PROGRAM
************************************************************************
      STOP

*************************************************************************
DO.FORMULA.COUNT:
*************************************************************************

      COUNT.1=0
      COUNT.SET=0
      COUNT.2=0
      MAIN.COUNT=0
START.AGAIN:
      RECORDS=DCOUNT(SPEC.REC<2>,@VM)
      IF MODE='ADD' THEN
         RECORDS+=1
      END
      MAIN.COUNT+=1
      IF COUNT.SET THEN
         DATA=CHAR(65+COUNT.1):CHAR(65+COUNT.2)
      END ELSE
         DATA=CHAR(65+COUNT.1)
      END
      SPEC.REC<11,MAIN.COUNT>=DATA
      IF COUNT.SET THEN
         COUNT.2+=1
         IF COUNT.2>=26 THEN
            COUNT.1+=1
            COUNT.2=0
         END
      END ELSE
         COUNT.1+=1
         IF COUNT.1 >=26 THEN
            COUNT.1=0
            COUNT.SET=1
         END
      END
      IF MAIN.COUNT>=RECORDS ELSE GO START.AGAIN
      RETURN


************************************************************************
GET.INSERT.POINT:
*************************************************************************
      T.OLD.SPEC.REC=SPEC.REC
      NUM.ITEMS=DCOUNT(SPEC.REC<2>,@VM)
      HELP='Enter Line to insert before'
      MASK='Line number ##'
      CALL GEN.IN(0,23,MASK,'',Q,1,3,'','',0,LEN(MASK)-2,23,0,QI,HELP,0,22)
      BEGIN CASE
         CASE NOT(NUM(QI))
            IF QI='X' THEN
               INSERT='OFF'
               GO 9000
            END
            IF QI='EX' THEN
               STOP
            END
            CALL ELINE("Invalid Entry!")
            GO GET.INSERT.POINT
         CASE 1
            IF QI>NUM.ITEMS THEN
               CALL ELINE("Must be inserted before last line")
               GO GET.INSERT.POINT
            END
            IF QI<1 THEN
               CALL ELINE("Can not be zero or a negative number")
               GO GET.INSERT.POINT
            END
      END CASE
      INSERT.POINT=Q
      SEL=INSERT.POINT
      FOR X=NUM.ITEMS TO INSERT.POINT STEP -1
         SPEC.REC<2,X+1>=SPEC.REC<2,X>
         SPEC.REC<3,X+1>=SPEC.REC<3,X>
         SPEC.REC<4,X+1>=SPEC.REC<4,X>
         SPEC.REC<5,X+1>=SPEC.REC<5,X>
         SPEC.REC<6,X+1>=SPEC.REC<6,X>
         SPEC.REC<7,X+1>=SPEC.REC<7,X>
         SPEC.REC<8,X+1>=SPEC.REC<8,X>
         SPEC.REC<9,X+1>=SPEC.REC<9,X>
         SPEC.REC<10,X+1>=SPEC.REC<10,X>
         SPEC.REC<11,X+1>=SPEC.REC<11,X>
         SPEC.REC<12,X+1>=SPEC.REC<12,X>
         SPEC.REC<13,X+1>=SPEC.REC<13,X>           ; * JMK02
         SPEC.REC<14,X+1>=SPEC.REC<14,X>           ; * JMK02
      NEXT X
      SPEC.REC<2,INSERT.POINT>=''
      CALL ELINE('STOP')
      SPEC.REC<3,INSERT.POINT>=''
      SPEC.REC<4,INSERT.POINT>=''
      SPEC.REC<5,INSERT.POINT>=''
      SPEC.REC<6,INSERT.POINT>=''
      SPEC.REC<7,INSERT.POINT>=''
      SPEC.REC<8,INSERT.POINT>=''
      SPEC.REC<9,INSERT.POINT>=''
      SPEC.REC<10,INSERT.POINT>=''
      SPEC.REC<11,INSERT.POINT>=''
      SPEC.REC<12,INSERT.POINT>=''
      SPEC.REC<13,INSERT.POINT>=''       ; * JMK02
      SPEC.REC<14,INSERT.POINT>=''       ; * JMK02
      RETURN
