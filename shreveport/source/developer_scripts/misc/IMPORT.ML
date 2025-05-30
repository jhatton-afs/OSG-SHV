$OPTIONS HEADER.EJECT
      ERRMSG=''
*
$OPTIONS EXEC.EQ.PERF
$OPTIONS INFO.ABORT
*
* PROGRAM: IMPORT.ML
* Program to Import Checks from ML Bank Statement
*
* GENERAL LEDGER PACKAGE
*
* AUTHOR: OWEN HOLMAN
* DATE: MARCH 29, 2001
*
* 102505 - JMK01 - CHANGES TO USE DOWNLOAD FILE WITHOUT EXCEL INTERVENTION
* 110305 - JMK02 - WRITE PROCESSING FILE TO HISTORY AND DELETE TO AVOID RE-PROCESSING AGAIN
* 110305 - JMK03 - ADD EMAIL NOTIFICATION WHEN ATTEMPT WITH WRONG FILE NAME
* 111005 - JMK04 - ADD USER.EMAIL AS FROM FOR EMAIL NOTIFICATIONS
* 020706 - JMK05 - UPDATE ERROR MESSAGES AND ADD MYSELF TO EMAILS
* 021306 - JMK06 - MAKE SURE THE CLEARED DATE IS NOT NULL
* 050306 - JMK07 - KEEP COPY FOR RESEARCH
* 050306 - JMK08 - USE THE ML CLEARED DATE INSTEAD OF STATEMENT DATE
* 070506 - JMK09 - REMOVE OWEN FROM NORMAL EMAILS
* 091106 - JCW01 - USE NEW FB.CHECKS FILES
* 022007 - JTW01 - ALLOW FOR ACH TRANSACTIONS
* 061107 - JMK10 - DO NOT CLEAR ACH TRANSACTIONS IF NOT COMPLETE.
* 080428 - DRF01 - ADDED STACY RITTENBACH (SRITTENBACH) TO HAVE ACCESS
* 081809 - JMK11 - CHANGE SANDRA TO STACEY
* 051810 - NPR01 - ADD ABILITY TO CLEAR OUT UPS.SCHED TRACKING FILE FOR UPS CHECKS CLEARED
* 120310 - NPR02 - ADD ABILITY TO CLEAR OUT BANK "I" CHECKS IN TRUCKLOAD (AFS Advantage)
* 053111 - NPR03 - Change to cater for new format.
* 010912 - JMK12 - SysAid#1299 - Check recon process not working
* 012314 - DRF02 - SysAid 8388 - Added Sarah Lynch
* 061714 - DRF03 - SysAid 10243 - Gave PMOSLEY the same access as JATTAWAY
* 031815 - DRF04 - SysAid 16105 - Gave AMPARKER the same access as SLYNCH
* 021116 - GRB01 - SysAid 22719 - Gave user CBULGER access
*
*
* AND MAY NOT BE USED, COPIED OR MODIFIED WITHOUT THE
* EXPRESS WRITTEN CONSENT OF SAME.
*
* Initialize variables
*
      PROMPT ''
      PROG.NAME='IMPORT.ML'
      PROG.DESC='Import Cleared Checks from ML Tab Delimited File'
      PACK.NAME='FREIGHT BILLING'
      CALL GET.USER(USER)
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'IMPORT.ML' ; UPL.VOUT = ''      ; * NPR_UPL 04/23/2010
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/23/2010
*
* Open files
*
*     OPEN '','FB.CHECKS' TO F.CHECKS ELSE CALL OPEN.ABORT("FB.CHECKS",PROG.NAME)         ; * JCW01
      OPEN '','FB.CHECKS.HDR' TO F.CHECKS ELSE CALL OPEN.ABORT("FB.CHECKS.HDR",PROG.NAME)  ; * JCW01
      OPEN '','BCTRL' TO F.BCTRL ELSE CALL OPEN.ABORT("BCTRL",PROG.NAME)
      OPEN '','ALL.CHECKS.1000.1' TO F.ALL.CHECKS ELSE CALL OPEN.ABORT("ALL.CHECKS.1000.1",PROG.NAME)
      OPEN '','BR.BANKS.1000.1' TO F.BR.BANKS ELSE CALL OPEN.ABORT("BR.BANKS.1000.1",PROG.NAME)      ; * NPR02
      OPEN '','BILLDATA.':USER TO F.BILLDATA ELSE CALL OPEN.ABORT("BILLDATA.":USER,PROG.NAME)
*     OPEN '','BILLDATA.MKERBOW' TO F.BILLDATA.MKERBOW ELSE CALL OPEN.ABORT("BILLDATA.MKERBOW",PROG.NAME) ; * JMK07
      OPEN '','FB.BANKS' TO F.BANK ELSE CALL OPEN.ABORT("FB.BANKS",PROG.NAME)
      OPEN '','FB.ACH.XREF' TO F.ACH.XREF ELSE CALL OPEN.ABORT('FB.ACH.XREF',PROG.NAME)

*NPR01 Start changes

      OPEN '','FBWORK.UPS.CKC' TO F.WORK ELSE      ; * Need file that the Phantom process can open
         EXECUTE 'CREATE-FILE FBWORK.UPS.CKC 1 103' CAPTURING OUTPUT
         OPEN '','FBWORK.UPS.CKC' TO F.WORK ELSE
            CALL ELINE("Cant open file FBWORK.UPS.CKC",PROG.NAME)
            STOP
         END
      END

*NPR01 Start changes

      READ DBCTRL FROM F.BCTRL,USER ELSE DBCTRL=''
      USER.EMAIL=DBCTRL<20>
*
* Display screen heading
*
      CALL AFS.SCR.HEAD(CO.ID,FILE.ID,'',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
      CLEARED.DATE=DATE()
      BANK.ID=''
      ML.ERRORS=''
      SERIOUS.ERRORS=''
      BEGIN CASE
         CASE USER='DEBBIE'
*        CASE USER='SANDRA'              ; * JMK11
*        CASE USER='CGOSS'               ; * JMK11
*        CASE USER='AMY'                 ; * JMK07
*        CASE USER='MISSY'               ; * JMK07
         CASE USER='DAVID'
         CASE USER='OWEN'
         CASE USER='KAREN'
*        CASE USER='RCASON'              ; * JMK11
*        CASE USER='KCHAUVIN'            ; * JMK11
         CASE USER='MKERBOW'             ; * JMK01
*        CASE USER='NPRATT'              ; * NPR02
*        CASE USER='JWEBERT'             ; * JCW01 ; * JMK11
*        CASE USER='SRITTENBACH'         ; * DRF01
         CASE USER='CBEASLEY'
         CASE USER='JATTAWAY'   ; * Ticket 6928 - DRF 09/05/13
         CASE USER='CSATER'     ; * Ticket 6928 - DRF 09/05/13
         CASE USER='PMOSLEY'   ; * DRF03
         CASE USER='SLYNCH'     ; * DRF02
         CASE USER='AMPARKER'     ; * DRF04
            CASE USER = 'CBULGER'       ; * GRB01
         CASE 1
            CALL ELINE("You are not setup to use this program.  See Programming")
            STOP
      END CASE
*
* Select bank account
*
100:  HELP="Enter bank account ID. ''=Exit."
      CALL GEN.IN(0,3,'Enter bank ID -','',Q,0,1,'','',0,-1,3,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      IF QI='' THEN STOP
      IF QI='X' THEN STOP
      IF QI='EX' THEN STOP
      READ BANK.REC FROM F.BANK,'BANK*':QI ELSE
         READ BANK.REC FROM F.BR.BANKS, QI ELSE
            CALL ELINE('Invalid bank ID ':QI)
            GOTO 100
         END
      END
      BANK.ID=QI
*
* Get statement date
*
200:  HELP="Enter date of bank statement. ''=Accept. 'X'=Back to bank ID. 'EX'=Exit."
      IF CLEARED.DATE='' THEN ODATE='MM/DD/YY' ELSE ODATE=CLEARED.DATE'D2/'
      CALL GEN.IN(40,3,'Enter statement date ':ODATE,'DATE',Q,0,8,'','',0,-8,3,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='X'
            CRT @(40,3):@(-4)
            GOTO 100
         CASE QI='EX'
            STOP
         CASE QI=''
            Q=CLEARED.DATE
            QI=CLEARED.DATE
      END CASE
      CRT @(61,3):Q'D2/'
      IF Q > DATE() THEN
         CALL ELINE("Error! Date CANNOT be Greater than Today!")
         GO 200
      END
*     IF DATE() - Q > 30 AND DATE() > 12136 THEN
      IF DATE() - Q > 30 THEN
         CALL ELINE("Error! Date CANNOT be more than 30 days ago")
         GO 200
      END
      TEST.DATE=Q+1
      OTEST.DATE=OCONV(TEST.DATE,'D2')
      TEST.DAY=FIELD(OTEST.DATE,'-',2)
*     IF TEST.DAY#1 THEN
*       CALL ELINE("Error! Date MUST be the Last Day of the Month!")
*       GO 200
*     END
      TEST.DATE=OCONV(Q,'D/')            ; * JMK06
      IF TEST.DATE='' THEN               ; * JMK06
         CALL ELINE("Error! Invalid Date - reenter!!")       ; * JMK06
         GO 200                          ; * JMK06
      END                                ; * JMK06
      CLEARED.DATE=Q
      CRT @(61,3):CLEARED.DATE'D2/'

*
      ODATE=OCONV(CLEARED.DATE,'D4-')
      MONTH=FIELD(ODATE,'-',1)'R%2'
      DAY =FIELD(ODATE,'-',2)'R%2'       ; * JMK01
      YEAR =FIELD(ODATE,'-',3)
*     ML.ID='ML':YEAR:'-':MONTH:'.TXT'   ; * JMK01
      ML.ID='FPACTIVITY.DNL'             ; * JMK01
      ML.ID=BANK.ID:'ACTIVITY.DNL'       ; * JMKXXX  ; * NPR03
**********************************************************************
*
* Verify selection criteria is correct.
*
**********************************************************************
VERIFY.SELECTION:***
      CRT @(0,05):"Instructions for Creating Importable File:"
*     CRT @(0,06):" 1) Open Recon file in Excel" ; * JMK01
*     CRT @(0,07):" 2) Click on File, then Click on Save As" ; * JMK01
*     CRT @(0,08):" 3) Change the Save in Location to your Billdata Drive" ; * JMK01
*     CRT @(0,09):" 4) Change the Save as type: to Text (Tab delimited) (*.txt)" ; * JMK01
*     CRT @(0,10):" 5) Name the file MLyyyy-mm (yyyy=four digit year, mm=two digit month" ; * JMK01
*     CRT @(0,11):"    Example: March of 2001 would be named, ML2001-03 (Excel will add the .txt)" ; * JMK01
*     CRT @(0,12):" 6) Click Save." ; * JMK01
      CRT @(0,06):' 1) Start download from ML Web Site'      ; * JMK01
      CRT @(0,07):' 2) Choose Save from the Download options'          ; * JMK01
      CRT @(0,08):' 3) Save to your Billdata Drive as "':ML.ID:'"'     ; * JMK01
      HELP="Going to Look for BILLDATA.":USER:" ":ML.ID:" Press [Enter] to Continue:"
      CALL GEN.IN(0,22,'Enter selection please. --','',Q,0,2,'','',0,-2,22,1,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='X'
            CRT @(0,22):@(-3):
            GOTO 200
         CASE QI='EX'
            STOP
         CASE QI=''
            NULL
         CASE 1
            CALL ELINE('Invalid entry. Must be X, EX, or RETURN.')
            GOTO VERIFY.SELECTION
      END CASE

      READ DML FROM F.BILLDATA,ML.ID ELSE
         ML.ID = OCONV(ML.ID,"MCL")      ; * NPR03  - Check for lower case file name
         READ DML FROM F.BILLDATA,ML.ID ELSE       ; * NPR03
            CALL ELINE('Unable to read/find BILLDATA.':USER:' ':ML.ID)
            MVIN=''                      ; * JMK03
*NPR99         MVIN<1>='OHolman@afs.net'       ; * JMK03
            MVIN<1>='oweninfo@afs.net'   ; * JMK03    ;*NPR99 as per Owen's request 11/15/10
            MVIN<2>='MKerbow@afs.net'    ; * JMK03
            MVIN<4>='FBBP_IMPORT.ML@afs.net'       ; * JMK03
            MVIN<5>= "Missing ":ML.ID:" File for ML FP Upload!"        ; * JMK03
            MVIN<6>= "User ":USER:" attempted to perform the Freight Payables Import with ":ML.ID:" missing!"  ; * JMK03
            MVIN<7>=1
            CALL SENDMAIL(MVIN,MVOUT)
            GO 200
         END                             ; * NPR03
      END
      HIST.ML.ID='MLFP-':ODATE:'.XLS'    ; * JMK02
      HIST.ML.ID='ML':BANK.ID:'-':ODATE:'.XLS'     ; * JMKXXX
      WRITE DML ON F.BILLDATA,HIST.ML.ID           ; * JMK02
*     WRITE DML ON F.BILLDATA.MKERBOW,HIST.ML.ID           ; * JMK07
      DELETE F.BILLDATA,ML.ID            ; * JMK02
      DML=CHANGE(DML,CHAR(9),@VM)
      DML=CHANGE(DML,'"','')             ; * JMK01
      TIMES=DCOUNT(DML,@AM)
      CALL PROG.BAR(20,1,TIMES,PER)
      HEADLINE=DML<1>
      DEL DML<1>
      FOR X = 2 TO TIMES
         CALL PROG.BAR(20,X,TIMES,PER)
         LINE=DML<1>
         DEL DML<1>                      ; * Always work with Line 1 for speed
*NPR03         OTEST.DATE=LINE<1,1>
         OTEST.DATE=LINE<1,2>            ; *NPR03
         ITEST.DATE=ICONV(OTEST.DATE,'D')
         IF ITEST.DATE='' THEN
            ERROR='Line ':X:' is not in the proper format: "':LINE:'"'
            ML.ERRORS<-1>=ERROR
            GO NEXT.X
         END
*NPR03         ML.AMOUNT=ICONV(-LINE<1,10>,'MR2')
*NPR03         ML.CLEARED.DATE=ICONV(LINE<1,4>,'D')

*        ML.AMOUNT = LINE<1,11>          ; * JMK12
         ML.AMOUNT = LINE<1,13>          ; * JMK12
         ML.AMOUNT = CHANGE(ML.AMOUNT,',','')      ; * NPR03
         ML.AMOUNT = CHANGE(ML.AMOUNT,'(','')      ; * NPR03
         ML.AMOUNT = CHANGE(ML.AMOUNT,')','')      ; * NPR03
         IF ML.AMOUNT GT "0" THEN        ; * NPR03
            ML.AMOUNT = ICONV(ML.AMOUNT,'MR2')     ; * NPR03
         END ELSE                        ; * NPR03
            ML.AMOUNT = ICONV(ML.AMOUNT,'MR2') * (-1)        ; * NPR03
         END                             ; * NPR03

         ML.CLEARED.DATE=ICONV(LINE<1,2>,'D')      ; * NPR03
         IF ML.CLEARED.DATE='' THEN
* NPR03            ERROR="Line ":X:" references a date of ":LINE<1,4>:" which cannot be converted.  Skipping Line"
            ERROR="Line ":X:" references a date of ":LINE<1,2>:" which cannot be converted.  Skipping Line"    ; * NPR03
            ML.ERRORS<-1>=LINE
            GO NEXT.X
         END
*NPR03         TYPE=TRIM(LINE<1,7>)            ; * JTW01
*        TYPE=OCONV(FIELD(TRIM(LINE<1,6>),' ',1),"MCU")                  ; * JTW01 ;* NPR03 ; * JMK12
         TYPE=OCONV(FIELD(TRIM(LINE<1,7>),' ',1),"MCU")      ; * JTW01 ;* NPR03 ; * JMK12
!        IF TRIM(LINE<1,7>)#'CHECK' THEN           ; * JTW01
*NPR03         IF TYPE#'CHECK' AND TYPE#'WCM' THEN       ; * JTW01
*        IF TYPE # 'CHECK' THEN       ; * JTW01                    ;* NPR03 ; * JMK12
         IF TYPE # 'CHECKING' THEN       ; * JTW01                    ;* NPR03 ; * JMK12
            ERROR="Line ":X:" is not a CHECK .... Line skipped"
            ML.ERRORS<-1>=ERROR
            GO NEXT.X
         END

         STATUS=OCONV(TRIM(LINE<1,3>),"MCU")       ; * NPR03
         IF STATUS # 'SETTLED' THEN      ; * NPR03
            ERROR="Line ":X:" status is 'pending' .... Line skipped"   ; * NPR03
            ML.ERRORS<-1>=ERROR          ; * NPR03
            GO NEXT.X                    ; * NPR03
         END                             ; * NPR03

         BEGIN CASE                      ; * JTW01
*           CASE TYPE='CHECK' ; * JMK12
            CASE TYPE='CHECKING'         ; * JMK12
*NPR03               CHECK.NUM=LINE<1,13>[17,8]          ; * This is the FULL Check# from ML
*NPR03               CHECK.NUM=CHECK.NUM[3,6]
*              CHECK.NUM = FIELD(TRIM(LINE<1,6>),' ',2)  ;* NPR03 ; * JMK12
               CHECK.NUM = FIELD(TRIM(LINE<1,8>),' ',2)      ; * NPR03 ; * JMK12
               CHECK.NUM = CHECK.NUM "R%6"         ; * NPR03
*DFIF USER='DAVID' THEN
*DF  IF CHECK.NUM='657338' OR CHECK.NUM='657339' THEN
*DF    CALL ELINE('PRESS BREAK')
*DF  END
*DFEND

*NPR03               CHECK.PAYEE=LINE<1,13>[1,16]        ; * Payee Name from ML File
*              CHECK.PAYEE = ""                          ; * NPR03 Unavailable on new file ; * JMK12
               CHECK.PAYEE = LINE<1,9>[1,16]       ; * JMK12

**** Make sure all is OK before you reconcile it

               ERROR.FLAG=0

               FP.CHECK=0
               CHECK.ID=CHECK.NUM:'*':BANK.ID
               READ CHECK.REC FROM F.ALL.CHECKS,CHECK.ID THEN
                  IF CHECK.REC<2> < DATE()-150 THEN
                     FP.CHECK=0
                  END ELSE
                     FP.CHECK=1
                     IF CHECK.REC<7>='Void' THEN
                        ERROR.FLAG=1
                        ERROR="Line ":X:" Refers to check number ":CHECK.NUM:" which has been voided in FP!"
                        ML.ERRORS<-1>=ERROR
                        GOSUB BUILD.SERIOUS.ERROR.LINE
                        SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
                        ERROR="Line above Refers to check number ":CHECK.NUM:" in the amount of ":ML.AMOUNT'R26,':" which HAS BEEN VOIDED in FP!"
                        SERIOUS.ERRORS<-1>=ERROR
                        SERIOUS.ERRORS<-1>=' '        ; * Skip a line in Email
                     END
                  END
              END

               BR.CHECK=0

               CHECK.ID=CHECK.NUM:'*':'B'

               READ CHECK.REC FROM F.ALL.CHECKS,CHECK.ID THEN
                  IF CHECK.REC<2> < DATE()-150 THEN
                     BR.CHECK=0
                  END ELSE
                     BR.CHECK=1
                     IF CHECK.REC<7>='Void' THEN
                        ERROR.FLAG=1
                        ERROR="Line ":X:" Refers to check number ":CHECK.NUM:" which has been voided in BR!"
                        ML.ERRORS<-1>=ERROR
                        GOSUB BUILD.SERIOUS.ERROR.LINE
                        SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
                        ERROR="Line above Refers to check number ":CHECK.NUM:" in the amount of ":ML.AMOUNT'R26,':" which HAS BEEN VOIDED in BR!"
                        SERIOUS.ERRORS<-1>=ERROR
                        SERIOUS.ERRORS<-1>=' '        ; * Skip a line in Email
                     END
                  END
               END

               IF FP.CHECK & BR.CHECK THEN
                  ERROR.FLAG=1
                  ERROR="Line ":X:" Refers to check number ":CHECK.NUM:" which is in BOTH FP & BR!"
                  ML.ERRORS<-1>=ERROR
                  GOSUB BUILD.SERIOUS.ERROR.LINE
                  SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
                  ERROR="Line above Refers to check number ":CHECK.NUM:" in the amount of ":ML.AMOUNT'R26,':" which is in BOTH FP & BR!"
                  SERIOUS.ERRORS<-1>=ERROR
                  SERIOUS.ERRORS<-1>=' '           ; * Skip a line in Email
               END

               IF ERROR.FLAG THEN
                  ERROR="Line ":X:" check number ":CHECK.NUM:" was SKIPPED because of the above errors"
                  ML.ERRORS<-1>=ERROR
                  GO NEXT.X              ; * Skip this one
               END


**** Do the reconcile here
               CHECK.ID=CHECK.NUM:'*':BANK.ID
               READ CHECK.REC FROM F.CHECKS,CHECK.ID THEN
                  GOSUB UPDATE.CHECK.REC
                  WRITE CHECK.REC ON F.CHECKS,CHECK.ID
               END ELSE
*NPR02                  CHECK.ID=CHECK.NUM:'*':'B'
                  IF BANK.ID = "I" THEN  ; *NPR02
                     CHECK.ID=CHECK.NUM:'*':'I'    ; *NPR02
                  END ELSE               ; *NPR02
                      CHECK.ID=CHECK.NUM:'*':'B'
                  END                    ; *NPR02
                  READ CHECK.REC FROM F.ALL.CHECKS,CHECK.ID ELSE
                     ERROR="Line ":X:" Refers to check number ":CHECK.NUM:" which is not on file!"
                     ML.ERRORS<-1>=ERROR

                     GOSUB BUILD.SERIOUS.ERROR.LINE
                     SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
                     ERROR="Line above Refers to check number ":CHECK.NUM:" in the amount of ":ML.AMOUNT'R26,':" which is not in the system!"
                     SERIOUS.ERRORS<-1>=ERROR
                     SERIOUS.ERRORS<-1>=' '        ; * Skip a line in Email

                     GO NEXT.X
                  END
                  GOSUB UPDATE.CHECK.REC
                  WRITE CHECK.REC ON F.ALL.CHECKS,CHECK.ID
               END
            CASE TYPE='WCM'              ; * JTW01                          ;* NPR03 Type WCM not on New file
               REF=LINE<1,13>[7,7]       ; * JTW01
               READ XREC FROM F.ACH.XREF,REF ELSE  ; * JTW01
                  IF REF[1,1]='0' THEN REF=REF[2,99]         ; * JTW01
                  READ XREC FROM F.ACH.XREF,REF ELSE XREC=''           ; * JTW01
               END                       ; * JTW01
               IF XREC='' THEN           ; * JTW01
                  ERROR="Line ":X:" Refers to batch ":REF:" which is not on file!"         ; * JTW01
                  ML.ERRORS<-1>=ERROR    ; * JTW01
               END ELSE                  ; * JTW01
                  MAX=DCOUNT(XREC<1>,@VM)          ; * JTW01
                  TOT.AMT=0              ; * JTW01
                  FOR M=1 TO MAX         ; * JTW01
                     CHECK.ID=XREC<1,M>  ; * JTW01
                     READ CHECK.REC FROM F.CHECKS,CHECK.ID THEN        ; * JTW01
                        IF CHECK.REC<7>='Void' THEN NULL ELSE
                           TOT.AMT+=CHECK.REC<4>
                        END
                     END                 ; * JTW01
                  NEXT M                 ; * JTW01
                  IF ML.AMOUNT#TOT.AMT THEN        ; * JTW01
                     ERROR="Line ":X:" original Batch# ":REF:" amount was ":TOT.AMT'R26':" but was cleared for an amount of ":ML.AMOUNT'R26,'
                     ML.ERRORS<-1>=ERROR
                     GOSUB BUILD.SERIOUS.ERROR.LINE
                     SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
                     SERIOUS.ERRORS<-1>=ERROR      ; * JMK10
                     SERIOUS.ERRORS<-1>=' '
                  END ELSE               ; * JMK10
                     FOR M=1 TO MAX      ; * JMK10
                        CHECK.ID=XREC<1,M>         ; * JMK10
                        READ CHECK.REC FROM F.CHECKS,CHECK.ID THEN     ; * JMK10
                           IF CHECK.REC<7>='Void' THEN NULL ELSE       ; * JMK10
                              GOSUB UPDATE.WCM     ; * JMK10
                              WRITE CHECK.REC ON F.CHECKS,CHECK.ID     ; * JMK10
                           END           ; * JMK10
                        END              ; * JMK10
                     NEXT M              ; * JMK10
                  END                    ; * JMK10
               END                       ; * JTW01
         END CASE                        ; * JTW01
NEXT.X:***
      NEXT X

*NPR03      EXECUTE \PHANTOM FB.UPD.UPS.CK.CLR.DT\ CAPTURING PH.OUTPUT    ;* NPR01

      IF SERIOUS.ERRORS='' THEN
         MVIN=''
*        MVIN<1> ='slong@afs.net'        ; * JMK11
*        MVIN<1> ='srittenbach@afs.net'  ; * JMK11 ; * JMK12
         MVIN<1> ='cbeasley@afs.net'
         MVIN<2> ='kgilbert@afs.net'
         IF USER#"SRITTENBACH" AND USER#"CBEASLEY" THEN MVIN<2,-1>=USER.EMAIL
*        MVIN<2,-1>='oholman@afs.net'    ; * JMK09
         MVIN<3>='mkerbow@afs.net'       ; * JMK06
         MVIN<4>=USER.EMAIL              ; * JMK04
         MVIN<5>= "FP Cleared Checks Process Complete"       ; *SUBJ
         MVIN<6>= "The Freight Payables Import Cleared Checks from Merrill Lynch process has been sucessfully completed with no serious errors"
         MVIN<7>=1
         CALL SENDMAIL(MVIN,MVOUT)
      END ELSE
         MVIN=''
*        MVIN<1> ='SLong@afs.net'        ; * JMK11
*        MVIN<1> ='srittenbach@afs.net'  ; * JMK11 ; * JMK12
         MVIN<1> ='cbeasley@afs.net'
         MVIN<2> ='kgilbert@afs.net'
         IF USER#"SRITTENBACH" AND USER#"CBEASLEY" THEN MVIN<2,-1>=USER.EMAIL
         MVIN<2,-1>='oholman@afs.net'
         MVIN<3>='mkerbow@afs.net'       ; * JMK06
*        MVIN<3,-1>='npratt@afs.net'     ; * NPR01
         MVIN<4>=USER.EMAIL              ; * JMK04
         MVIN<5>= "FP Serious Errors-Cleared Checks Process!"          ; *SUBJ
         MVIN<6>= "The Freight Payables Import Cleared Checks from Merrill Lynch process has been successfully completed with the following serious error/s that needs to be ADDRESSED IMMEDIATELY!"
         MVIN<6,-1>=' '
         MVIN<6,-1>=CHANGE(SERIOUS.ERRORS,@AM,@VM)
         MVIN<7>=1
         CALL SENDMAIL(MVIN,MVOUT)
      END

      IF ML.ERRORS#'' THEN
*        ML.ERROR.ID='MLERRORS':YEAR:'-':MONTH:'.XLS'                  ; * JMK01
         ML.ERROR.ID='MLFPERRORS-':YEAR:'-':MONTH:DAY:'.XLS'           ; * JMK01
         ML.ERROR.ID='ML':BANK.ID:'ERRORS-':YEAR:'-':MONTH:DAY:'.XLS'  ; * JMKXXX
         WRITE ML.ERRORS ON F.BILLDATA,ML.ERROR.ID
*        WRITE ML.ERRORS ON F.BILLDATA.MKERBOW,ML.ERROR.ID             ; * JMK07
         CRT @(0,23):"Errors Found! Refer to: BILLDATA.":USER:" ":ML.ERROR.ID:" Press [Enter]":
         INPUT NUL:
      END
      STOP

BUILD.SERIOUS.ERROR.LINE:***
      SERIOUS.ERROR.LINE=LINE
      SERIOUS.ERROR.LINE=CHANGE(SERIOUS.ERROR.LINE,@VM,'_')
      SERIOUS.ERROR.LINE=TRIM(SERIOUS.ERROR.LINE)
      RETURN


UPDATE.CHECK.REC:***
      CHECK.DATE=CHECK.REC<2>
      CHECK.AMT=CHECK.REC<4>
*     CLEARED.DATE=CHECK.REC<21>         ; * JMK06
      CLR.DATE=CHECK.REC<21>             ; * JMK06
      IF CHECK.REC<6> #'' THEN           ; * Already Cleared
*        IF CLEARED.DATE#ML.CLEARED.DATE OR CHECK.AMT#ML.AMOUNT THEN   ; * Don't notify if you "re-clear" the same check ; * JMK06
         IF CLR.DATE#ML.CLEARED.DATE OR CHECK.AMT#ML.AMOUNT THEN       ; * Don't notify if you "re-clear" the same check ; * JMK06
            ERROR="Line ":X:" refers to check ":CHECK.NUM:" which HAS ALREADY cleared on ":CHECK.REC<5>'D2/':" for ":CHECK.REC<6>'R26,'
            ML.ERRORS<-1>=ERROR
            GOSUB BUILD.SERIOUS.ERROR.LINE
            SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
            ERROR="Line above refers to check ":CHECK.NUM:" in the amount of ":ML.AMOUNT'R26,':" which HAS ALREADY cleared on ":CHECK.REC<5>'D2/':" for ":CHECK.REC<6>'R26,':" printed on ":CHECK.REC<2>'D2/'
            SERIOUS.ERRORS<-1>=ERROR
            SERIOUS.ERRORS<-1>=' '       ; * Skip a line in Email
            RETURN TO NEXT.X
         END
      END
      IF CHECK.AMT#ML.AMOUNT THEN
         ERROR="Line ":X:" original check amount was ":CHECK.AMT'R26':" but was cleared for an amount of ":ML.AMOUNT'R26,'
         ML.ERRORS<-1>=ERROR
         GOSUB BUILD.SERIOUS.ERROR.LINE
         SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
         ERROR="Line above the original check amount was ":CHECK.AMT'R26':" but was cleared for A DIFFERENT amount of ":ML.AMOUNT'R26,':" printed on ":CHECK.REC<2>'D2/'
         SERIOUS.ERRORS<-1>=ERROR
         SERIOUS.ERRORS<-1>=' '          ; * Skip a line in Email
      END
*     CHECK.REC<5>=CLEARED.DATE          ; * JMK08
      CHECK.REC<5>=ML.CLEARED.DATE       ; * JMK08
      CHECK.REC<6>=ML.AMOUNT
      CHECK.REC<21>=ML.CLEARED.DATE
      IF CHECK.REC<5>='' AND CHECK.REC<21>#'' THEN           ; * JMK06
         CHECK.REC<5>=CHECK.REC<21>      ; * JMK06
      END                                ; * JMK06

      IF CHECK.REC<3> = "00041" THEN     ; * NPR01
         WRITE CHECK.REC ON F.WORK,CHECK.ID        ; * NPR01
      END                                ; * NPR01

      RETURN

UPDATE.WCM:****
      CHECK.DATE=CHECK.REC<2>
      CHECK.AMT=CHECK.REC<4>
      CLR.DATE=CHECK.REC<21>             ; * JMK06
      IF CHECK.REC<6> #'' THEN           ; * Already Cleared
         IF CLR.DATE#ML.CLEARED.DATE THEN          ; * Don't notify if you "re-clear" the same check ; * JMK06
            ERROR="Line ":X:" refers to check ":CHECK.NUM:" which HAS ALREADY cleared on ":CHECK.REC<5>'D2/':" for ":CHECK.REC<6>'R26,'
            ML.ERRORS<-1>=ERROR
            GOSUB BUILD.SERIOUS.ERROR.LINE
            SERIOUS.ERRORS<-1>=SERIOUS.ERROR.LINE
            ERROR="Line above refers to check ":CHECK.NUM:" in the amount of ":ML.AMOUNT'R26,':" which HAS ALREADY cleared on ":CHECK.REC<5>'D2/':" for ":CHECK.REC<6>'R26,':" printed on ":CHECK.REC<2>'D2/'
            SERIOUS.ERRORS<-1>=ERROR
         END
      END
      CHECK.REC<5>=ML.CLEARED.DATE       ; * JMK08
      CHECK.REC<6>=CHECK.AMT
      CHECK.REC<21>=ML.CLEARED.DATE
      IF CHECK.REC<5>='' AND CHECK.REC<21>#'' THEN           ; * JMK06
         CHECK.REC<5>=CHECK.REC<21>      ; * JMK06
      END                                ; * JMK06

      IF CHECK.REC<3> = "00041" THEN     ; * NPR01
         WRITE CHECK.REC ON F.WORK,CHECK.ID        ; * NPR01
      END                                ; * NPR01


      RETURN
      STOP
