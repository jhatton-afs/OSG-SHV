****************************************
* Program name : UPD.SQL.QFBHIST
* Author       : Owen Holman
* Date written : January 2002
* Library      : FBBP
* COPYRIGHT (c) : AFS, LLC 2016, All Rights Reserved.
*
* FB BILLS HIST sql push
* Last updated by afs (gbino) at 08:48:26 on 09/28/2018.
* Last updated by afs (AFSLOGISTICS\gbino) at 08:38:09 on 10/12/2018.
* Start modification history
* Mod nn  mm/dd/yy, init, req #, description

* End modification history
*
*******************************************
$INCLUDE UNIVERSE.INCLUDE ODBC.H
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'UPD.SQL.QFBHIST' ; UPL.VOUT = ''
      CALL GET.USER.NEW(USER,CH.NUM)
      UPL.VIN<3> = USER
      UPL.VIN<4> = CH.NUM
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)
      CALL GET.SERVER.INFO(SVR.VIN,SVR.VOUT)
      SVR.NAME=SVR.VOUT<1>
      BEGIN CASE
         CASE USER='DAVID'
         CASE USER = "GBINO"
         CASE USER = "NMEDDAUGH"         ; * NKH01
         CASE USER='SV.UVAUTO'
         CASE USER='UVTASKS'
         CASE 1
            CRT "YOU ARE NOT AUTHORIZED TO USE THIS PROGRAM"
            STOP
      END CASE

      VIN1=""
      VIN1<1> = "UPD.SQL.QFBHIST"
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "S"
      CALL PROGTRACK(VIN1,VOUT1)
      GET (ARG.,1) OBEG.DATE THEN
         BEG.DATE=ICONV(OBEG.DATE,'D')
      END ELSE
         BEG.DATE=DATE()
      END
      GET (ARG.,2) OEND.DATE THEN
         END.DATE=ICONV(OEND.DATE,'D')
      END ELSE
         END.DATE=DATE()
      END
      CRT @(0,0):@(-1):@(0,3):'UPD.SQL.QFBHIST.T - Processing Clients from ':BEG.DATE'D2/':' to ':END.DATE'D2/':'...'
      GOSUB OPEN.FILES


      GET (ARG.,3) CLIENT.LIST.NAME ELSE CLIENT.LIST.NAME=''
      GET (ARG.,4) OPT.LIST ELSE OPT.LIST=''
      GET (ARG.,5) START.TIME ELSE START.TIME=''
      IF START.TIME#'' THEN
         CRT "Waiting until ":START.TIME
         STMT="SLEEP ":START.TIME
         EXECUTE STMT CAPTURING TIME.RESULTS
      END
      GOSUB SETUP.SQL
      GOSUB SETUP.PARAMETERS
      IF CLIENT.LIST.NAME#'' AND CLIENT.LIST.NAME#'ALL' THEN
         STMT='GET-LIST ':CLIENT.LIST.NAME
      END ELSE
         STMT='SSELECT CLIENTS WITH @ID # "9]" AND WITH STATUS # "I"'
      END
      EXECUTE STMT RTNLIST CLIENT.LIST CAPTURING RESULTS
      NUM.CLIENTS=@SELECTED

      UPD.SHIP=1
      UPD.CINV=1
      UPD.CIDTL=1
      UPD.EXP=1
      UPD.STOP=1                         ; * JMK12
      UPD.PYMT=1
      IF UPD.FLAGS#'' THEN
         UPD.SHIP=UPD.FLAGS[1,1]
         UPD.CINV=UPD.FLAGS[2,1]
         UPD.CIDTL=UPD.FLAGS[3,1]
         UPD.EXP=UPD.FLAGS[4,1]
         UPD.STOP=UPD.FLAGS[5,1]
         UPD.PYMT=UPD.FLAGS[6,1]
      END

      FORM = "T##########"
      DASH = "----------"
      EXPECT = ""
      NULL=""
      TOT.NUM.BILLS=0
      ERROR.CNT=0
10:   ERRORS=''

*************************** CLIENT LOOP
      CLIENT.EOF=0
      CLIENT.CNT=0
      CLIENT.PER=0
      LOOP
         READNEXT CLIENT.ID FROM CLIENT.LIST ELSE CLIENT.EOF=1
      UNTIL CLIENT.EOF DO
         CLIENT.CNT+=1
         CLIENT.PCT=ICONV(CLIENT.CNT/NUM.CLIENTS*100,'MR2')
         READ CLIENT.REC FROM F.CLIENT,CLIENT.ID THEN
            CRT @(0,5):@(-4):CLIENT.CNT'R#4':' - ':CLIENT.PCT'R26#6':'% ':CLIENT.ID:' - ':CLIENT.REC<2>
*****            CALL PROG.BAR(8,CLIENT.CNT,NUM.CLIENTS,CLIENT.PER)
            OPEN '','FB.BILLS.HIST,':CLIENT.ID TO F.BILL THEN

               EDI.FOUND=0
               VC.FOUND=0
               DIV.FOUND=0

               OPEN '','EDI.BILLS.HIST,':CLIENT.ID TO F.EDI THEN EDI.FOUND=1
               OPEN '','VEND.CUST,':CLIENT.ID TO F.VC THEN VC.FOUND=1
               OPEN '','DIVISION.CODE,':CLIENT.ID TO F.DIV THEN DIV.FOUND=1

               STMT = 'SELECT FB.PROC.DATE.XREF,':CLIENT.ID
               STMT:=' WITH DATE GE "':OCONV(BEG.DATE,'D2/'):'"'
               STMT:=' AND WITH DATE LE "':OCONV(END.DATE,'D2/'):'"'
               EXECUTE STMT RTNLIST DT.LIST CAPTURING OUTPUT

               IF @SELECTED < 1 AND CLIENT.ID # "00000" THEN GOTO SKIP.CLIENT    ; * JMK01
               STMT = 'QSELECT FB.PROC.DATE.XREF,':CLIENT.ID
               EXECUTE STMT PASSLIST DT.LIST RTNLIST NDX.LIST CAPTURING OUTPUT

               IF @SELECTED < 1 AND CLIENT.ID # "00000" THEN GOTO SKIP.CLIENT    ; * JMK01
               IF CLIENT.ID="00000" THEN           ; * JMK01
                  STMT='SELECT FB.BILLS.HIST,':CLIENT.ID
                  STMT:=' WITH VERSION = "0"'
                  STMT:=' AND WITH 39 # "R"'
                  STMT:=' AND WITH 39 # "P"'
                  STMT:=' AND WITH 30 GE "':OCONV(BEG.DATE,'D2/'):'"'
                  STMT:=' AND WITH 30 LE "':OCONV(END.DATE,'D2/'):'"'
                  EXECUTE STMT RTNLIST BILL.LIST CAPTURING OUTPUT      ; * JMK01
               END ELSE                  ; * JMK01
                  STMT='SELECT FB.BILLS.HIST,':CLIENT.ID
                  STMT:=' WITH VERSION = "0"'
                  STMT:=' AND WITH 39 # "R"'
                  STMT:=' AND WITH 39 # "P"'
                  STMT:=' AND WITH 37 GE "':OCONV(BEG.DATE,'D2/'):'"'
                  STMT:=' AND WITH 37 LE "':OCONV(END.DATE,'D2/'):'"'
                  EXECUTE STMT PASSLIST NDX.LIST RTNLIST BILL.LIST CAPTURING OUTPUT
               END                       ; * JMK01
               NUM.BILLS=@SELECTED
               TOT.NUM.BILLS+=NUM.BILLS
               CRT @(0,10):@(-3):' #Bills - ':NUM.BILLS'R#12':' - ':TOT.NUM.BILLS'R#15'
               BILL.EOF=0
               BILL.CNT=0
               BILL.PER=0
               LOOP
                  READNEXT BILL.ID FROM BILL.LIST ELSE BILL.EOF=1
               UNTIL BILL.EOF DO
                  BILL.CNT+=1
                  BILL.PCT=ICONV(BILL.CNT/NUM.BILLS*100,'MR2')
                  *
                  IF NOT(REM(BILL.CNT,100)) THEN
                     CRT @(0,10):@(-3):' #Bills - ':NUM.BILLS'R#12':' - ':BILL.CNT'R#15'
                  END
                  READ BILL.REC FROM F.BILL,BILL.ID THEN
                     EDI.REC=''
                     IF EDI.FOUND THEN
                        READ EDI.REC FROM F.EDI,BILL.ID ELSE EDI.REC=''
                     END
* DEFINE FIELDS TO UPDATE FROM CLIENT.REC HERE
                     CARRIER.ID=FIELD(BILL.ID,'*',1)
                     PRO=FIELD(BILL.ID,'*',2)
                     SEQ=FIELD(BILL.ID,'*',3)
                     DUPLICATE=FIELD(BILL.ID,'*',3)
                     LPRO=LEN(PRO)
                     IF SEQ#0 THEN CONTINUE
                     DIV.REC=''
                     IF DIV.FOUND THEN
                        DIV.ID=BILL.REC<9>
                        READ DIV.REC FROM F.DIV,DIV.ID ELSE DIV.REC=''
                     END
                     VC.REC=''
                     IF VC.FOUND THEN
                        VC.ID=BILL.REC<17>
                        READ VC.REC FROM F.VC,VC.ID ELSE VC.REC=''
                     END
                     IF BILL.REC<37>='' THEN
                        ERRORS<-1>='Missing Process Date for ':BILL.ID
                        ****       RETURN TO THE.END
                        CONTINUE
                     END
                     ****************************8
                     * DEFINE FIELDS TO UPDATE FROM CLIENT.REC HERE
                     UPS.EBILL=0
                     PRO=FIELD(BILL.ID,'*',2)
                     UPS.FDATE=ICONV(PRO[8,2]:'/':PRO[10,2]:'/':PRO[12,2],'D')
                     BEGIN CASE
                        CASE CLIENT.ID='00244' AND UPS.FDATE < ICONV('01/26/08','D')
                        CASE CLIENT.ID='00841' AND UPS.FDATE < ICONV('01/26/08','D')
                        CASE CLIENT.ID='00857' AND UPS.FDATE < ICONV('01/26/08','D')
                        CASE CLIENT.ID='00962' AND UPS.FDATE < ICONV('02/02/08','D')
                        CASE CLIENT.ID='01292' AND UPS.FDATE < ICONV('01/26/08','D')
                        CASE CLIENT.ID='01310' AND UPS.FDATE < ICONV('02/02/08','D')
                        CASE CLIENT.ID='01352' AND UPS.FDATE < ICONV('02/02/08','D')
                        CASE CLIENT.ID='01393' AND UPS.FDATE < ICONV('01/26/08','D')
                        CASE CLIENT.ID='01640' AND UPS.FDATE < ICONV('03/24/08','D')
                        CASE 1
                           UPS.EBILL=(BILL.REC<53>="EBILL.IMPORT.NEW")
                     END CASE

                     IF UPS.EBILL THEN
                        UPD.SHIP=0
                        UPD.CINV=0
                        UPD.CIDTL=0
                        UPD.EXP=1
                        UPD.STOP=0
                        UPD.PYMT=0
                        ****    GOSUB THE.END
                        ****   GOSUB SETUP.SQL
                        CONTINUE
                     END ELSE
                        IF UPD.FLAGS#'' THEN
                           UPD.SHIP=UPD.FLAGS[1,1]
                           UPD.CINV=UPD.FLAGS[2,1]
                           UPD.CIDTL=UPD.FLAGS[3,1]
                           UPD.EXP=UPD.FLAGS[4,1]
                           UPD.STOP=UPD.FLAGS[5,1]
                           UPD.PYMT=UPD.FLAGS[6,1]
                        END
                     END


                     ********************************

                     ******                CALL UPD.SQL.FBHIST.SUB(SQLVIN,SQLVOUT,CLIENT.REC,DIV.REC,VC.REC,BILL.REC,EDI.REC)
                     GOSUB DO.IT
                     IF MOD(BILL.CNT,10)=0 THEN
                        **        CRT @(0,22):'Sleeping...zzz...zzz...':
                        ******        CRT @(0,22):@(-4):
                     END
                  END
SKIP.BILL:        *
               REPEAT
               WKENDLOAD=0
               IF CLIENT.LIST.NAME='CLIENTFBHIST1' THEN WKENDLOAD=1
               IF CLIENT.LIST.NAME='CLIENTFBHIST2' THEN WKENDLOAD=1
               IF CLIENT.LIST.NAME='CLIENTFBHIST3' THEN WKENDLOAD=1
               IF CLIENT.LIST.NAME='CLIENTFBHIST4' THEN WKENDLOAD=1
               IF WKENDLOAD THEN
                  MVIN=''
                  MVIN<1,-1>='nmeddaugh@afs.net'
                  MVIN<4>='AFS_UPD.SQL.FBHIST.SUB'
                  MVIN<5>='SQL Shipment Update by Client'
                  TEXT='On ':DATE()'D2/':' ':OCONV(TIME(),'MTHS'):', ':USER:' updated '
                  TEXT<1,-1>='Client ':CLIENT.ID:' ':CLIENT.REC<2>:' completed the SQL update for the processing period from ':OCONV(BEG.DATE,'D4/'):' to ':OCONV(END.DATE,'D4/'):' with ':NUM.BILLS:' shipments loaded.'
                  TEXT<1,-1>=' '
                  MVIN<6>=TEXT
                  MVIN<7>=1
                  CALL SENDMAIL(MVIN,MVOUT)
               END
               IF TOT.NUM.BILLS+0#0 THEN
                  ******             CRT @(0,22):@(-3):
               END
            END
         END
SKIP.CLIENT:*
      REPEAT
*****************************************************************
THE.END:***
****************************************************************

* NOW JUST CLEAN UP THE ENVIRONMENT AND LEAVE
*
      FN = "SQLFreeStmt"
      STATUS = SQLFREESTMT(STMTENV, SQL.DROP)
      GOSUB CKSTMTENV

      FN = "SQLDisconnect"
      STATUS = SQLDISCONNECT(CONENV)
      GOSUB CKCONENV

      FN = "SQLFreeConnect"
      STATUS = SQLFREECONNECT(CONENV)
      GOSUB CKCONENV

      FN = "SQLFreeEnv"
      STATUS = SQLFREEENV(DBCENV)
      IF STATUS <> SQL.SUCCESS THEN
         ERRORS<1,-1>="Failed to release ODBC environment"
      END

      IF ERRORS#'' THEN
         ERROR.CNT+=1
         IF ERROR.CNT>3 THEN
            MVIN=''
            MVIN<1>='UPD.SQL.Group@afs.net'
            MVIN<4>='AFS_UPD.SQL.FBHIST.SUB'
            MVIN<5>='SQL Client Update Errors'
            TEXT='On ':DATE()'D2/':' ':OCONV(TIME(),'MTHS'):', ':USER:' updated '
            TEXT<1,-1>='Client ':CLIENT.ID:', Bill ':BILL.ID:', but did not succeed in updating SQL due to:'
            TEXT<1,-1>=' '
            TEXT<1,-1>=ERRORS
            MVIN<6>=TEXT
            MVIN<7>=1
            CALL SENDMAIL(MVIN,MVOUT)
         END ELSE
            GO 10
         END
      END


      VIN1=''
      VIN1<1> = "UPD.SQL.FBHIST.T"
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "E"
      CALL PROGTRACK(VIN1,VOUT1)

      STOP
*********************************************************************
DO.IT:
*******************************************************************8
      BD=0
      AD=0
      IF PRO[LPRO-1,2]='BD' THEN BD=1
      IF PRO[LPRO-1,2]='AD' THEN AD=1
      IF BILL.REC<37>='' THEN
         ERRORS<-1>='Missing Process Date for ':BILL.ID
****         RETURN TO THE.END
         RETURN
      END

      PROC.DT=BILL.REC<37>'D4/'
      SQL.UNIQUEKEY=CLIENT.ID:CARRIER.ID:PRO:PROC.DT[7,4]:PROC.DT[1,2]:PROC.DT[4,2]
      SQL.FB.ACT.SVC=TRIM(BILL.REC<219,1>)
      SQL.FB.FINAL.STACK=TRIM(BILL.REC<68>)
      SQL.FB.HAND.UNIT=TRIM(BILL.REC<235>)
      AUDITED.BY = BILL.REC<89>
      SQL.FB.LAST.AUDIT.DT = ""
      AUDIT.DATE=''
      NVAL = DCOUNT(BILL.REC<84>,@VM)
      FOR VAL = NVAL TO 1 STEP -1
         W.USER = BILL.REC<84,VAL>
         IF W.USER = AUDITED.BY THEN
            AUDIT.TIME = BILL.REC<85,VAL>
            AUDIT.DATE = BILL.REC<86,VAL>
            EXIT
         END
      NEXT VAL
      IF AUDIT.DATE NE "" THEN SQL.FB.LAST.AUDIT.DT = OCONV(AUDIT.DATE,"D2/")
      SQL.FB.LCC=BILL.REC<143>'R26'
      SQL.FB.LCC.SVC=TRIM(BILL.REC<221,1>)
      SQL.FB.ORIG.STACK=TRIM(BILL.REC<96>)
      SQL.FB.WI=''
      LOCATE 'WI' IN BILL.REC<151> SETTING WPOS THEN
         SQL.FB.WI='Y'
      END
      SQL.FB.BD.NOTE=TRIM(BILL.REC<213>)[1,200]
      SQL.EDI.BT.ACCOUNT=TRIM(EDI.REC<18>)
      BOL.SRC.TEST=BILL.REC<244,1>
      IF BOL.SRC.TEST='' THEN            ; * SWB01
         BOL.SRC.DESC='UNKNOWN'          ; * SWB01
      END ELSE                           ; * SWB01
         BOL.SRC.ID='BOL.SRC*':BOL.SRC.TEST        ; * SWB01
         READV BOL.SRC.DESC FROM F.TABLES, BOL.SRC.ID,1 ELSE BOL.SRC.DESC='UNKNOWN'        ; * SWB01
      END                                ; * SWB01
      SQL.FB.BOL.SRC=BOL.SRC.DESC
      SQL.FB.EST.SVC=TRIM(BILL.REC<220,1>)
      SQL.FB.UPS.ADD.CORR=TRIM(BILL.REC<123>)'R26'
      SQL.FB.UPS.LATE.PYMT=TRIM(BILL.REC<148>)'R26'
      SQL.EDI.ZONE=TRIM(EDI.REC<93>)
      SQL.FB.ACTUAL.CHG=0
      SQL.FB.ADBD=""
      IF AD OR BD THEN
         SQL.FB.ACTUAL.CHG=BILL.REC<8>'R26'
         IF AD THEN SQL.FB.ADBD:='AD'
         IF BD THEN SQL.FB.ADBD:='BD'
      END
      SQL.FB.OLA.AMT=BILL.REC<99>'R26'
      SQL.FB.DUP=DUPLICATE

      SQL.TRANS.REC=''
      SQL.TRANS.REC< 1>=SQL.UNIQUEKEY
      SQL.TRANS.REC< 2>=SQL.FB.ACT.SVC
      SQL.TRANS.REC< 3>=SQL.FB.ACTUAL.CHG
      SQL.TRANS.REC< 4>=SQL.FB.FINAL.STACK
      SQL.TRANS.REC< 5>=SQL.FB.HAND.UNIT
      SQL.TRANS.REC< 6>=SQL.FB.LAST.AUDIT.DT
      SQL.TRANS.REC< 7>=SQL.FB.LCC
      SQL.TRANS.REC< 8>=SQL.FB.LCC.SVC
      SQL.TRANS.REC< 9>=SQL.FB.ORIG.STACK
      SQL.TRANS.REC<10>=SQL.FB.WI
      SQL.TRANS.REC<11>=SQL.FB.BD.NOTE
      SQL.TRANS.REC<12>=SQL.EDI.BT.ACCOUNT
      SQL.TRANS.REC<13>=SQL.FB.BOL.SRC
      SQL.TRANS.REC<14>=SQL.FB.EST.SVC
      SQL.TRANS.REC<15>=SQL.FB.UPS.ADD.CORR
      SQL.TRANS.REC<16>=SQL.FB.UPS.LATE.PYMT
      SQL.TRANS.REC<17>=SQL.EDI.ZONE
      SQL.TRANS.REC<18>=SQL.FB.ADBD
      SQL.TRANS.REC<19>=SQL.FB.OLA.AMT
      SQL.TRANS.REC<20>=SQL.FB.DUP

      FN = "SQLExecute"
      STATUS = SQLEXECUTE(UPDSHIPENV)
      STMTENV=UPDSHIPENV
      GOSUB CKSTMTENV

      RETURN
*********************************************
SETUP.PARAMETERS:*
*********************************************
*******************************************
UPDATE.SQL.SHIPMENT:*
*******************************************
*
* NOW ALLOCATE AN SQL STATEMENT ENVIRONMENT
* TO BE USED FOR EXECUTING SQL STATEMENTS
*
      FN = "SQLAllocStmt"
      STATUS = SQLALLOCSTMT(CONENV,UPDSHIPENV)
      GOSUB CKCONENV

*
* NOTE THAT WE ARE USING PARAMETER MARKERS IN THE SQL STATEMENT TO FACILITATE
* LOADING MULTIPLE ROWS OF DATA EFFICIENTLY
*
      OPT.STR = STR(' ?,',20)            ; * JMK03 ; * JMK04 ; * JMK06 ;  JMK07
      OPT.STR = OPT.STR[2,LEN(OPT.STR)-2]
      INST1 = "{CALL PX_UpdShipmentXref (":OPT.STR:")}"      ; * 17 PLACEHOLDERS

      ROWNUM = 0
      FN = "SQLSetParam"
*
* DEFINE THE FIELD UPDATE PARAMETERS USING THE FOLLOWING FORMAT
*
      STATUS = SQLSETPARAM(UPDSHIPENV, 1, SQL.B.BASIC, SQL.VARCHAR, 50, 0, SQL.UNIQUEKEY) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 2, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.ACT.SVC) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 3, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.ACTUAL.CHG) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 4, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.FINAL.STACK) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 5, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.HAND.UNIT) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 6, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.LAST.AUDIT.DT) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 7, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.LCC) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 8, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.LCC.SVC) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 9, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.ORIG.STACK) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 10, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.WI) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 11, SQL.B.BASIC, SQL.VARCHAR, 200, 0, SQL.FB.BD.NOTE) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 12, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.EDI.BT.ACCOUNT) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 13, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.BOL.SRC) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 14, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.EST.SVC) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 15, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.UPS.ADD.CORR) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 16, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.UPS.LATE.PYMT) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 17, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.EDI.ZONE) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 18, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.ADBD) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 19, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.OLA.AMT) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDSHIPENV, 20, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.FB.DUP) ; STMTENV=UPDSHIPENV ; GOSUB CKSTMTENV

      FN = "SQLPrepare"
      STATUS = SQLPREPARE(UPDSHIPENV, INST1)
      STMTENV=UPDSHIPENV
      ENVSRC='UPDSHIP'
      GOSUB CKSTMTENV
      RETURN
*********************************************
CKCONENV:
*********************************************
      COUNT = -1
      IF STATUS EQ -2 THEN
         ERRORS<1,-1>="INVALID CONNECTION HANDLE"
         STMT='BBSEND MIKE UPD.SQL.FBHIST.SUB INVALID CONNECTION HANDLE ABORT'
         EXECUTE STMT CAPTURING RESULTS
         ABORT
      END
      IF STATUS NE 0 THEN
201:     *
         ST = SQLERROR(-1,CONENV,-1,STATE,NATCODE,ERRTXT)
         IF ST <> SQL.NO.DATA.FOUND
         THEN
            COUNT = 1
            IF EXPECT NE 0 AND STATE = EXPECT AND ST <> SQL.NO.DATA.FOUND THEN
               ERRORS<1,-1>="Allowed error of ":STATE:" returned for func ":FN
               GOTO 299
            END ELSE
               ERRORS<1,-1>="Status for ":FN:" call is: ":STATUS
               ERRORS<1,-1>="SQLSTATE,NATCOD are:" : STATE:"  ":NATCODE
               ERRORS<1,-1>="Error text is"
               ERRORS<1,-1>="    " : ERRTXT
            END
            IF ST = SQL.SUCCESS THEN GOTO 201
         END
         IF STATUS = -1 AND COUNT = 1 THEN
            ERRORS<1,-1>="EXITING CKCONENV"
            RETURN TO THE.END
         END
      END
299:  *
      RETURN
*********************************************
CKSTMTENV:
*********************************************
      IF STATUS EQ -2 THEN
         ERRORS<1,-1>="INVALID STATEMENT HANDLE"
         STMT='BBSEND GREGB UPD.SQL.FBHIST.SUB INVALID STATEMENT HANDLE ABORT'
         EXECUTE STMT CAPTURING RESULTS
         ABORT
      END

      IF STATUS EQ 100 THEN RETURN
      IF STATUS NE 0 THEN
301:     *
         ST = SQLERROR(-1,-1,STMTENV,STATE,NATCODE,ERRTXT)
         IF ST <> SQL.NO.DATA.FOUND
         THEN
            COUNT = 1
            IF EXPECT NE 0 AND STATE = EXPECT AND ST <> SQL.NO.DATA.FOUND THEN
               ERRORS<1,-1>="Allowed error of ":STATE:" returned for func ":FN
               GOTO 399
            END ELSE
               ERRORS<1,-1>="Status for ":FN:" call is: ":STATUS
               ERRORS<1,-1>="SQLSTATE,NATCOD are:" : STATE:"  ":NATCODE
               ERRORS<1,-1>="Error text is"
               ERRORS<1,-1>="    " : ERRTXT
            END
            IF ST = 0 THEN GOTO 301
         END
         IF STATUS = -1 AND COUNT = 1 THEN
            ERRORS<1,-1>="EXITING CKSTMTENV"
            RETURN TO THE.END
         END
      END
399:  *
      RETURN
*********************************************
CHECK.SQL.WEIGHT:*
*********************************************
      LI.CODE.TYPE=''
      IF SQL.RATINGCODE='' THEN SQL.RATINGCODE='FRT'
      IF LI.CODES<1>#'' THEN
         LOCATE SQL.RATINGCODE IN LI.CODES<1> SETTING RPOS THEN
            LI.CODE.TYPE=LI.CODES<2,RPOS>
            IF LI.CODE.TYPE#'F' THEN
               SQL.WEIGHT=0
            END
         END
      END
      RETURN
*********************************************
SETUP.SQL:*
*********************************************
* CREATE AN ODBC ENVIRONMENT & A CONNECTION ENVIRONMENT. USE THE
* SSQLSETCONNECTOPTION TO SPECIFY THE OPERATING SYSTEM USER ID AND
* PASSWORD.

      STATUS = SQLALLOCENV(DBCENV)
      IF STATUS <> SQL.SUCCESS THEN
         ERRORS<1,-1>="Failed to allocate an ODBC environment"
         RETURN TO THE.END
      END

      STATUS = SQLALLOCCONNECT(DBCENV,CONENV)
      IF STATUS <> SQL.SUCCESS THEN
         ERRORS<1,-1>="Failed to allocate a CONNECT environment"
         RETURN TO THE.END
      END
*
* GATHER THE DATA SOURCE NAME, USERID AND PASSWORD FOR THE SERVER O/S AND
* INFORMATION FOR THE DBMS AT THE SERVER.
*
      BEGIN CASE                         ; * JMK10
         CASE SVR.NAME='AFS'             ; * JMK10
            SOURCE='PRODQV'              ; * JMK10
            UID="uv_sql"                 ; * JMK10
            PWD="4@gAbreg"               ; * JMK10
         CASE 1                          ; * JMK10
            SOURCE='DEVDW'               ; * JMK10
            UID="uv_sql"                 ; * JMK10
            PWD="4@gAbreg"               ; * JMK10
      END CASE                           ; * JMK10
*
* ESTABLISH A SESSION TO THE SPECIFIED DATA SOURCE
*
*     PRINT "Connecting to data source: ": SOURCE
      FN = "SQLConnect"
      STATUS = SQLCONNECT(CONENV,SOURCE,UID,PWD)
      GOSUB CKCONENV
      RETURN
******************************************************
OPEN.FILES:
********************************************************
      OPEN '','FB.TL.FSC' TO F.TL.FSC ELSE         ; * JMK01
         CALL OPEN.ABORT("FB.TL.FSC",PROG.NAME)    ; * JMK01
      END                                ; * JMK01
      OPEN '','PCIN' TO F.PCIN ELSE      ; * JMK01
         CALL OPEN.ABORT("PCIN",PROG.NAME)         ; * JMK01
      END                                ; * JMK01
      OPEN '','PCOUT' TO F.PCOUT ELSE    ; * JMK01
         CALL OPEN.ABORT("PCOUT",PROG.NAME)        ; * JMK01
      END                                ; * JMK01
      OPEN '','FB.MILEAGE' TO F.MILEAGE ELSE       ; * JMK01
         CALL OPEN.ABORT("FB.MILEAGE",PROG.NAME)   ; * JMK01
      END                                ; * JMK01
      OPEN '','FB.BC.FSC' TO F.NFSC ELSE           ; * JMK01
         CALL OPEN.ABORT("FB.BC.FSC",PROG.NAME)    ; * JMK01
      END                                ; * JMK01
      OPEN '','FB.TABLES' TO F.TABLES ELSE         ; * JMK01
         CALL OPEN.ABORT("FB.TABLES",PROG.NAME)    ; * JMK01
      END                                ; * JMK01
      OPEN '','FB.CHECKS.HDR' TO F.CK.HDR ELSE
         CALL OPEN.ABORT("FB.CHECKS.HDR",PROG.NAME)
      END
      OPEN '','ZIPS.CODES' TO F.ZIPS ELSE          ; * JMK01
         CALL OPEN.ABORT("ZIPS.CODES",PROG.NAME)   ; *JMK01
      END                                ; * JMK01
      OPEN '','CAN.ZIP.CODES' TO F.CAN.ZIPS ELSE   ; * JMK01
         CALL OPEN.ABORT("CAN.ZIP.CODES",PROG.NAME)          ; *JMK01
      END                                ; * JMK01
      OPEN '','CLIENTS' TO F.CLIENT ELSE ABORT 201,'CLIENTS'
      OPEN '','FB.TABLES' TO F.TABLES ELSE ABORT 201,'FB.TABLES'
      READ LI.CODE.REC FROM F.TABLES,'LI.CODES' ELSE LI.CODE.REC=''
      LI.CODES =''
      LI.CODES<1>=LI.CODE.REC<1>
      LI.CODES<2>=LI.CODE.REC<3>
      UPD.FLAGS='111111'
      SQL.DESC.REC=''
      SQL.DESC.REC< 1>='p_UniqueKey (50)'
      SQL.DESC.REC< 2>='p_ActTrans (10)'
      SQL.DESC.REC< 3>='p_ActualCharge (10)'
      SQL.DESC.REC< 4>='p_FinalStack (10)'
      SQL.DESC.REC< 5>='p_HandlingUnits (10)'
      SQL.DESC.REC< 6>='p_LastAuditDate (10)'
      SQL.DESC.REC< 7>='p_LCC (10)'
      SQL.DESC.REC< 8>='p_LCCMisrouteTrans (10)'
      SQL.DESC.REC< 9>='p_OriginalStack (10)'
      SQL.DESC.REC<10>='p_WI (10)'
      SQL.DESC.REC<11>='p_BalanceDueNote (200)'
      SQL.DESC.REC<12>='p_BillToAccount (10)'
      SQL.DESC.REC<13>='p_BOLSource (10)'
      SQL.DESC.REC<14>='p_EstTrans (10)'
      SQL.DESC.REC<15>='p_UPSAddrCorrCharge (10)'
      SQL.DESC.REC<16>='p_UPSLatePayment (10)'
      SQL.DESC.REC<17>='p_Zone (10)'
      SQL.DESC.REC<18>='p_DueType (10)'
      SQL.DESC.REC<19>='p_OLAAmount (10)'
      SQL.DESC.REC<20>='p_Duplicate (10)'
      RETURN
   END
