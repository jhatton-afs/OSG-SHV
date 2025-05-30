****************************************
* Program name : UPD.SQL.FBDTL.SUB
* Author       : Owen Holman
* Date written : January 2002
* Library      : FBBP
* COPYRIGHT (c) : AFS, LLC 2016, All Rights Reserved.
*
* FB BILLS HIST sql push
* Last updated by afs (AFSLOGISTICS\gbino) at 07:12:15 on 10/05/2018.
*
* Start modification history
* Mod nn  mm/dd/yy, init, req #, description
* 022712 - JMK01 - SysAid#1841 - Set up AFS Brokerage in AFSi V2
* End modification history
*
*******************************************
$INCLUDE UNIVERSE.INCLUDE ODBC.H
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'UPD.SQL.FBDTL.T' ; UPL.VOUT = ''          ; * NPR_UPL 04/23/2010
      CALL GET.USER.NEW(USER,CH.NUM)
      UPL.VIN<3> = USER
      UPL.VIN<4> = CH.NUM
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/23/2010
      CALL GET.SERVER.INFO(SVR.VIN,SVR.VOUT)       ; * JMK10
      SVR.NAME=SVR.VOUT<1>               ; * JMK10
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
      OPEN 'GREG.AUDIT' TO F.GA ELSE STOP

      VIN1=""
      VIN1<1> = "UPD.SQL.FBDTL.T"
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
      CRT @(0,0):@(-1):@(0,3):'UPD.SQL.FBDTL.T - Processing Clients from ':BEG.DATE'D2/':' to ':END.DATE'D2/':'...'
      GOSUB OPEN.FILES
      ERRORS=''

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

      UPD.FBDTL=1

      FORM = "T##########"
      DASH = "----------"
      EXPECT = ""
      NULL=""
      TOT.NUM.BILLS=0
      ERROR.CNT=0
10:

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
            LOGISTICS=CLIENT.REC<93>='Y'
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
                  MVIN<4>='AFS_UPD.SQL.FBDTL.SUB'
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
            MVIN<4>='AFS_UPD.SQL.FBDTL.SUB'
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
      VIN1<1> = "UPD.SQL.FBDTL.T"
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "E"
      CALL PROGTRACK(VIN1,VOUT1)

      STOP
*********************************************************************
DO.IT:
*******************************************************************8
      IF BILL.REC<37>='' THEN
         ERRORS<-1>='Missing Process Date for ':BILL.ID
         RETURN TO THE.END
      END
      PROC.DT=BILL.REC<37>'D4/'
      SQL.UNIQUEKEY=CLIENT.ID:CARRIER.ID:PRO:PROC.DT[7,4]:PROC.DT[1,2]:PROC.DT[4,2]
      ***     FN = "SQLExecute"
      ***     STATUS = SQLEXECUTE(DELFBDTLENV)
***      STMTENV=DELFBDTLENV
***      GOSUB CKSTMTENV

      NVAL=DCOUNT(BILL.REC<252>,@VM)
      IF UPD.FBDTL THEN
         IF BILL.REC<252>='' THEN RETURN
         LOCATE 'AMIN' IN BILL.REC<252> SETTING AMIN.START ELSE AMIN.START=1
         LOCATE 'ABMIN' IN BILL.REC<252> SETTING ABMIN.START ELSE ABMIN.START=1
         LOCATE 'OMIN' IN BILL.REC<252> SETTING OMIN.START ELSE OMIN.START=1
         LOCATE 'TMIN' IN BILL.REC<252> SETTING TMIN.START ELSE TMIN.START=1
         IF AMIN.START>1 AND LOGISTICS THEN
            IF BILL.REC<265,AMIN.START>='' THEN
               IF TMIN.START>1 THEN
                  BILL.REC<265,AMIN.START>=BILL.REC<265,TMIN.START>
               END
               IF BILL.REC<265,AMIN.START>='' THEN
                  FOR VAL1=1 TO AMIN.START-1
                     BILL.REC<265,AMIN.START>+=BILL.REC<265,VAL1>
                  NEXT VAL1
               END
            END
         END
         COMM.START=1
         IF TMIN.START>COMM.START THEN COMM.START=TMIN.START
         IF ABMIN.START>COMM.START THEN COMM.START=ABMIN.START
         IF AMIN.START>COMM.START THEN COMM.START=AMIN.START
         IF OMIN.START>COMM.START THEN COMM.START=OMIN.START

         FOR VAL=1 TO NVAL
*
* INITIALIZE VARIABLES FIRST
*
            SQL.ACCLCODE=''
            SQL.ACCLDESC=''
            SQL.GROSSCLS=''
            SQL.GROSSWT=''
            SQL.GROSSRATE=''
            SQL.GROSSDISC=''
            SQL.GROSSCHG=''
            SQL.CONTRCLS=''
            SQL.CONTRWT=''
            SQL.CONTRRATE=''
            SQL.CONTRDISC=''
            SQL.CONTRCHG=''
            SQL.CMCOMM=''
            SQL.CMVAR=''
            SQL.CMPCT=''

            SQL.ACCLCODE=BILL.REC<252,VAL>
            LOCATE SQL.ACCLCODE IN LI.CODES<1> SETTING APOS THEN
               SQL.ACCLDESC=LI.CODES<2,APOS>
            END ELSE
               BEGIN CASE
                  CASE SQL.ACCLCODE='AMIN'
                     SQL.ACCLDESC='AFS Contract Minimum'
                  CASE SQL.ACCLCODE='ABMIN'
                     SQL.ACCLDESC='AFS Absolute Minimum'
                  CASE SQL.ACCLCODE='OMIN'
                     SQL.ACCLDESC='AFS Override Minimum'
                  CASE SQL.ACCLCODE='TMIN'
                     SQL.ACCLDESC='Tariff Minimum'
                  CASE 1
                     SQL.ACCLDESC='Unknown'
                     GID = DATE():"*":TIME():SQL.ACCLCODE
                     GB=""
                     WRITE GB ON F.GA,GID
               END CASE
            END
            IF BILL.REC<260,VAL>#'' THEN
               SQL.GROSSCLS=BILL.REC<260,VAL>
            END
            IF BILL.REC<261,VAL>#'' THEN
               SQL.GROSSWT=BILL.REC<261,VAL>
            END
            IF BILL.REC<262,VAL>#'' THEN
               SQL.GROSSRATE=BILL.REC<262,VAL>'R26'
            END
            IF BILL.REC<264,VAL>#'' THEN
               SQL.GROSSDISC=BILL.REC<264,VAL>'R26'
            END
            IF BILL.REC<265,VAL>#'' THEN
               SQL.GROSSCHG=BILL.REC<265,VAL>'R26'
            END
            IF BILL.REC<254,VAL>#'' THEN
               SQL.CONTRCLS=BILL.REC<254,VAL>
            END
            IF BILL.REC<255,VAL>#'' THEN
               SQL.CONTRWT=BILL.REC<255,VAL>
            END
            IF BILL.REC<256,VAL>#'' THEN
               SQL.CONTRRATE=BILL.REC<256,VAL>'R26'
            END
            IF BILL.REC<258,VAL>#'' THEN
               SQL.CONTRDISC=BILL.REC<258,VAL>'R26'
            END
            IF BILL.REC<259,VAL>#'' THEN
               SQL.CONTRCHG=BILL.REC<259,VAL>'R26'
            END
            IF VAL>=COMM.START THEN
               IF LOGISTICS=0 THEN
                  SQL.CMCOMM='0'
                  SQL.CMVAR='0'
               END ELSE
                  IF BILL.REC<267,VAL>#'' THEN
                     SQL.CMCOMM=BILL.REC<267,VAL>'R26'
                  END
                  IF SQL.GROSSCHG#'' OR SQL.CONTRCHG#'' THEN
                     SQL.CMVAR=SQL.GROSSCHG-SQL.CONTRCHG
                  END
               END
            END
            IF BILL.REC<266>#'' THEN
               SQL.CMPCT=BILL.REC<266>'R26'
            END
            FN = "SQLExecute"
            STATUS = SQLEXECUTE(UPDFBDTLENV)
            STMTENV=UPDFBDTLENV
            GOSUB CKSTMTENV
         NEXT VAL
      END
      RETURN
*********************************************
SETUP.PARAMETERS:*
*********************************************
****************************************************************
UPDATE.SQL.CARRIER.INV.DETAIL:*
***************************************************************

*
* NOW ALLOCATE AN SQL STATEMENT ENVIRONMENT
* TO BE USED FOR EXECUTING SQL STATEMENTS
*
      FN = "SQLAllocStmt"
      STATUS = SQLAllocStmt(CONENV,UPDFBDTLENV)
      GOSUB CKCONENV
*
* NOTE THAT WE ARE USING PARAMETER MARKERS IN THE SQL STATEMENT TO FACILITATE
* LOADING MULTIPLE ROWS OF DATA EFFICIENTLY
*
      OPT.STR = STR(' ?,',16)
      OPT.STR = OPT.STR[2,LEN(OPT.STR)-2]
      INST1 = "{CALL PX_UpdAcclCharges (":OPT.STR:")}"       ; * 16 PLACEHOLDERS

      ROWNUM = 0
      FN = "SQLSetParam"
*
* DEFINE THE FIELD UPDATE PARAMETERS USING THE FOLLOWING FORMAT
*     STATUS = SQLSETPARAM(STMTENV, COL, SQL.B.BASIC, SQL.DATA.TYPE, PREC, SCALE, VAR.NAME) ; GOSUB CKSTMTENV
*
      STATUS = SQLSETPARAM(UPDFBDTLENV, 1, SQL.B.BASIC, SQL.VARCHAR, 50, 0, SQL.UNIQUEKEY) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 2, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.ACCLCODE) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 3, SQL.B.BASIC, SQL.VARCHAR, 50, 0, SQL.ACCLDESC) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 4, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.GROSSCLS) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 5, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.GROSSWT) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 6, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.GROSSRATE) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 7, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.GROSSDISC) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 8, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.GROSSCHG) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV, 9, SQL.B.BASIC, SQL.VARCHAR, 10, 0, SQL.CONTRCLS) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV,10, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.CONTRWT) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV,11, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.CONTRRATE) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV,12, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.CONTRDISC) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV,13, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.CONTRCHG) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV,14, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.CMCOMM) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV,15, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.CMVAR) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV
      STATUS = SQLSETPARAM(UPDFBDTLENV,16, SQL.B.BASIC, SQL.VARCHAR, 20, 0, SQL.CMPCT) ; STMTENV=UPDFBDTLENV ; GOSUB CKSTMTENV

      FN = "SQLPrepare"
      STATUS = SQLPrepare(UPDFBDTLENV, INST1)
      STMTENV=UPDFBDTLENV
      ENVSRC='UPDFBDTL'
      GOSUB CKSTMTENV
***************************************************************
DELETE.SQL.CARRIER.INV.DETAIL:*
****************************************************************
* NOW ALLOCATE AN SQL STATEMENT ENVIRONMENT
* TO BE USED FOR EXECUTING SQL STATEMENTS
*
      FN = "SQLAllocStmt"
      STATUS = SQLAllocStmt(CONENV,DELFBDTLENV)
      GOSUB CKCONENV
*
* NOTE THAT WE ARE USING PARAMETER MARKERS IN THE SQL STATEMENT TO FACILITATE
* LOADING MULTIPLE ROWS OF DATA EFFICIENTLY
*
      OPT.STR = STR(' ?,',1)
      OPT.STR = OPT.STR[2,LEN(OPT.STR)-2]
      INST1 = "{CALL PX_DelAcclCharges (":OPT.STR:")}"       ; * 1 PLACEHOLDERS

      ROWNUM = 0
      FN = "SQLSetParam"
*
* DEFINE THE FIELD UPDATE PARAMETERS USING THE FOLLOWING FORMAT
*     STATUS = SQLSETPARAM(STMTENV, COL, SQL.B.BASIC, SQL.DATA.TYPE, PREC, SCALE, VAR.NAME) ; GOSUB CKSTMTENV
*
      STATUS = SQLSETPARAM(DELFBDTLENV, 1, SQL.B.BASIC, SQL.VARCHAR, 50, 0, SQL.UNIQUEKEY) ; STMTENV=DELFBDTLENV ; GOSUB CKSTMTENV
      FN = "SQLPrepare"
      STATUS = SQLPrepare(DELFBDTLENV, INST1)
      STMTENV=DELFBDTLENV
      ENVSRC='DELFBDTL'
      GOSUB CKSTMTENV

      RETURN
*********************************************
CKCONENV:
*********************************************
      COUNT = -1
      IF STATUS EQ -2 THEN
         ERRORS<1,-1>="INVALID CONNECTION HANDLE"
         STMT='BBSEND GREGB UPD.SQL.FBDTL.T INVALID CONNECTION HANDLE ABORT'
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
         STMT='BBSEND GREGB UPD.SQL.FBDTL.T INVALID STATEMENT HANDLE ABORT'
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
            SOURCE='DEVODS'              ; * JMK10
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

      RETURN
   END
