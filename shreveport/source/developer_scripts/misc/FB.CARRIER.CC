*
* PLEASE MAKE SURE YOU CHECK DN.SYNC.CARRIERS SO THAT ATTRIBUTE YOU 
* USE DO NOT GET CLEARED. 
*
* DN.SYNC.CARRIER DOES NOT CLEAR ATTRIBUTER 102 TO 129. SO IF YOU 
* USE AN ATTRIBUTE OUTSIDE OF THIS RANGE YOU WILL NEED TO MODIFY
* DN.SYNC.CARRIER
*
      PROGRAM FB.CARRIER.CC
************************************************************************
* PROGRAM: FB.CARRIER.CC - Program to allow entry/updating of Carrier
*                          related info for Credit Card payments.
*                          This program replaces FB.CARRIER.AMEX.
*
* PROGRAMMER: Steve Barbee
*
************************************************************************
*
* PARAMETERS - None
*
************************************************************************
*
* EDIT HISTORY:
*
*    NAME :   DATE:     : DESCRIPTION
*     SWB : 05/06/13    : Started new program
*   DRF01 : 04/07/14    : SysAid 9293 Added KSHELTON access as she is
*                         Dina's back up.
* 081314 - JMK01 - Mary Ann Rose access 
********************************************************************************
* Includes
$INCLUDE FILE.DEFS INC_ADDS60.CODES; * These require specific PROCOMM settings

      INPUT CC.TYPE
      BEGIN CASE
         CASE CC.TYPE = 'AMEX'
            CC = CC.TYPE
            CC.NAME = 'American Express'
            CC.STATUS.FLD = 124
            CC.ACCT.NAME.FLD = 125
            CC.REMIT.EMAIL.ADDR.FLD = 126
            OTHER.CC.STATUS.FLD = 127
            OTHER.CC.TYPE = 'MC'
            OTHER.CC.NAME = 'MasterCard'
         CASE CC.TYPE = 'MC'
            CC = CC.TYPE
            CC.NAME = 'MasterCard'
            CC.STATUS.FLD = 127
            CC.ACCT.NAME.FLD = 128
            CC.REMIT.EMAIL.ADDR.FLD = 129
            OTHER.CC.STATUS.FLD = 124
            OTHER.CC.TYPE = 'AMEX'
            OTHER.CC.NAME = 'American Express'
         CASE 1
            CALL ELINE('Unknown Credit Card Type. Notify Helpdesk.')
            STOP
      END CASE

      OPEN '','CARRIERS' TO F.CARRIERS ELSE
         CALL OPEN.ABORT('CARRIERS')
      END
* Equates
      EQU REVERSE.BLINK.ON TO TERM.ESC.SEQ:CHAR(TERM.REV+TERM.BLINK)   ; * Reverse Blinking text ON
      EQU REVERSE.ON TO TERM.ESC.SEQ:CHAR(TERM.REV)          ; * Reverse text ON
      EQU REVERSE.OFF TO TERM.ESC.SEQ:CHAR(TERM.NORMAL)      ; * Reverse text OFF
      EQU TRUE TO 1
      EQU FALSE TO 0
      CARRIER.REC=''
      OLD.CARRIER.REC=''
      CARRIER.ID=''

* Initialize general program variables
      PROMPT''
      PORT.NUM=SYSTEM(19)
      CALL GET.USER(USER.NAME)
      PROG.NAME='FB.CARRIER.CC'
      PROG.DESC='Carrier ':CC.NAME:' Setup'
      PACK.NAME='USER : ':USER.NAME
      CO.NAME='AFS Logistics, LLC'
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'FB.CARRIER.CC' ; UPL.VOUT = ''
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)
      EDIT.MASK.CHAR='-'
      PLACE.HOLDER='~~ PLACE*HOLDER ~~'
      AFN.MSG=''
      AFN.MIN=''
      AFN.MAX=''
      AFN.MASK=''

* Initialize operating variables
      PAGE.SIZE=11                       ; * Number of lines per page
      START.Y=9                          ; * Starting y-position on the screen minus one
      LAST.EDIT.MASK=1                   ; * Last item edited or deleted
      WIDTH=80                           ; * Print width for printing table of includes/excludes
      CTR=INT(WIDTH/2)                   ; * Center of the table width

      CARRIER.NAME=''
      CARRIER.CITY=''
      CARRIER.STATE=''
      BEGIN.DATE=''
      END.DATE=''
      CONTROL.REC=''
      OLD.CONTROL.REC=''

* Display initial screen
      GOSUB DISPLAY.SCREEN

* Restrict access
      BEGIN CASE
*Top level folks
         CASE USER.NAME='BRIAN'

*IT folks
         CASE USER.NAME='DAVID'
         CASE USER.NAME='MKERBOW'
         CASE USER.NAME='PBASS'
         CASE USER.NAME='SBARBEE'
*Business folks
         CASE USER.NAME='RWHITT'
         CASE USER.NAME='DGARRETT'
         CASE USER.NAME='KSHELTON'     ; * DRF01
         CASE USER.NAME='MROSE'        ; * JMK01

         CASE 1
            CALL FB.PRINT.CENT(1,80,12,'! Restricted Access Application !')
            CALL FB.PRINT.CENT(1,80,14,'Access Denied')
            CALL ELINE('')
            GOTO THE.END
      END CASE

      LOOP
1000:
         CARRIER.REC=''
         OLD.CARRIER.REC=''
         CARRIER.ID=''
         CARRIER.NAME=''
         CARRIER.CITY=''
         CARRIER.STATE=''
         BEGIN.DATE=''
         END.DATE=''
         GOSUB DISPLAY.SCREEN
         HELP="Enter carrier number, 'name' for search, [L]ist, [EX]it."
         CALL GEN.IN(20,3,'#####','',Q,0,20,'','',3,-5,3,0,QI,HELP,0,23)
         QI=OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI='X' OR QI='EX' OR QI=''
               EXIT.IT = TRUE

            CASE QI EQ 'L'
               EXECUTE 'SORT CARRIERS BY 1 1'
               CALL ELINE('')

            CASE NUM(QI)
               CARRIER.ID=Q'R%5'
               CRT @(20,2):CARRIER.ID
               READU CARRIER.REC FROM F.CARRIERS,CARRIER.ID LOCKED
                  FIND.LOCKED.NAME = CARRIER.ID
                  GOSUB FIND.LOCKED
                  GOTO 1000
               END THEN
                  OLD.CARRIER.REC=CARRIER.REC
                  GOSUB GET.STATUS
                  GOSUB PROCESS.SCREEN
                  RELEASE F.CARRIERS,CARRIER.ID
                  GOTO 1000
               END ELSE
                  CALL ELINE('Carrier not on file !!!')
                  GOTO 1000
               END

            CASE 1
               CALL SOUNDEX.DISPLAY(Q,'CARRIERS','SDX.CARRIER,NAME','1,3,4',QX)
               CT=DCOUNT(QX<1>,@VM)
               IF CT=1 THEN
                  DATA QX<1,1>
               END
         END CASE

      UNTIL (EXIT.IT = TRUE) DO
      REPEAT
      STOP

PROCESS.SCREEN:
      BACK.FLAG=FALSE
      CARRIER.NAME=CARRIER.REC<1>
      CARRIER.CITY=CARRIER.REC<3>
      CARRIER.STATE=CARRIER.REC<4>
      GOSUB DISPLAY.SCREEN
*      IF CARRIER.REC<CC.ACCT.NAME.FLD>='' THEN
      IF CURRENT.STATUS='' THEN
PROCESS.SCREEN.LINE.1:
         GOSUB CHG.STATUS
         IF BACK.FLAG THEN
            BACK.FLAG=FALSE
            GO 1000
         END
PROCESS.SCREEN.LINE.2:
         GOSUB GET.NAME
         IF BACK.FLAG THEN
            BACK.FLAG=FALSE
            GO PROCESS.SCREEN.LINE.1
         END
* TPROCESS.SCREEN.LINE.3:
         GOSUB GET.EMAIL
         IF BACK.FLAG THEN
            BACK.FLAG=FALSE
            GO PROCESS.SCREEN.LINE.2
         END
      END

MAIN.START:***

      HELP="Prompt #. [U]pdate. [X]=Back. [EX]it."
      CALL GEN.IN(0,22,'Enter selection please. --','',Q,0,2,'','',0,-2,22,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='EX'                    ; * Exit
            GOTO LAST.CHANCE.TO.SAVE
         CASE QI='X'                     ; * Back to client
            IF CARRIER.REC#OLD.CARRIER.REC THEN
               YN.MSG='You have unsaved changes. Save before entering new client?'
               YN.MASK=''
               GOSUB ASK.Y.OR.N
               IF YN.ANSWER='Y' THEN
                  GOSUB FAILSAFE.CHECK
                  IF FAILSAFE.OK THEN
                     GOSUB SAVE.CONTROL.REC
                     RETURN
                  END ELSE
                     RETURN
                  END
               END
            END
            RETURN
         CASE QI='U'                     ; * Update (and exit)
            IF CARRIER.REC#OLD.CARRIER.REC THEN
               GOSUB FAILSAFE.CHECK
               IF FAILSAFE.OK THEN
                  GOSUB SAVE.CONTROL.REC
                  RETURN
               END ELSE
                  RETURN
               END
            END ELSE
               CRT @(0,22):'No changes to save.':@(-3)
               SLEEP 1
            END
            RETURN
         CASE QI='1'
            GOSUB CHG.STATUS
            GOSUB DISPLAY.SCREEN
            GOTO MAIN.START
         CASE QI='2'
            GOSUB GET.NAME
            GOTO MAIN.START
         CASE QI='3'
            GOSUB GET.EMAIL
            GOTO MAIN.START
         CASE QI='*'                     ; * Show contents of CONTROL.REC for debugging purposes
            CRT @(-1)
            CRT @(0,0):CARRIER.REC
            CALL ELINE('Viewing DEBUG Screen.')
            GOSUB DISPLAY.SCREEN
            GOTO MAIN.START
         CASE 1
            GOTO MAIN.START
      END CASE

********************************************************************************
* Start of internal subroutines
********************************************************************************

DISPLAY.SCREEN:***
      CALL AFS.SCR.REFRESH(PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
      CRT @(0,2):STR('=',79):
      PADDING = 4 - LEN(CC.TYPE)
      CRT @(0,3):'Carrier#/Name  : '
      CRT @(0,4):'1. ':CC.TYPE:' Status':SPACE(PADDING):' : '
      CRT @(0,5):'2. ':CC.TYPE:' Name':SPACE(PADDING):'   : '
      CRT @(0,6):'3. ':CC.TYPE:' Email':SPACE(PADDING):'  : '
      IF CARRIER.ID='' THEN NULL ELSE
         CRT @(20,3):CARRIER.ID'R%5':', ':CARRIER.NAME:' (':CARRIER.CITY:', ':CARRIER.STATE:')'
         GOSUB GET.STATUS
         CRT @(20,4):STATUS.DESC
         CRT @(20,5):CARRIER.REC<CC.ACCT.NAME.FLD>
         EMAIL=CARRIER.REC<CC.REMIT.EMAIL.ADDR.FLD>
         CONVERT @VM TO ';' IN EMAIL
         IF EMAIL[60,99]='' THEN ETC='' ELSE ETC='...'
         CRT @(20,6):EMAIL[1,59]:ETC
      END
      RETURN

********************************************************************************
CHG.STATUS:***
      X.POS=20
      Y.POS=4
      CRT @(0,22):'Enter ':CC.TYPE:' Status Code.':@(-4)

      IF CARRIER.REC<CC.STATUS.FLD>='' THEN
         SAVE.STATUS=SPACE(2)
         EDIT.MASK=STR(EDIT.MASK.CHAR,2):SPACE(48)
      END ELSE
         SAVE.STATUS=CARRIER.REC<CC.STATUS.FLD>
         EDIT.MASK=SAVE.STATUS:SPACE(48)
      END
      BEGIN CASE
         CASE CARRIER.REC<CC.STATUS.FLD>='A'
            HELP='Enter [I]nactive or <Return> for unchanged'
            VALID.ENTRIES = 'I':@VM:CARRIER.REC<CC.STATUS.FLD>
         CASE CARRIER.REC<CC.STATUS.FLD>='I'
            HELP='Enter [A]ctive or <Return> for unchanged'
            VALID.ENTRIES = 'A':@VM:CARRIER.REC<CC.STATUS.FLD>
         CASE CARRIER.REC<CC.STATUS.FLD>=''
            HELP='Enter [A]ctive, [I]nactive or <Return> for unchanged'
            VALID.ENTRIES = 'A':@VM:'I':@VM:CARRIER.REC<CC.STATUS.FLD>
      END CASE
      CALL GEN.IN(X.POS,Y.POS,EDIT.MASK,'',Q,0,2,'','',2,X.POS,Y.POS,0,QI,HELP,0,23)
      IF QI='' AND CARRIER.REC<CC.STATUS.FLD>#'' THEN QI=CARRIER.REC<CC.STATUS.FLD>
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI=''
            CRT @(X.POS,4):STATUS.DESC 'L#50'
            RETURN
         CASE QI='EX'
            GOTO THE.END
         CASE QI='I' OR QI='A'
            LOCATE QI IN VALID.ENTRIES<1>,1 SETTING QQQ ELSE
               CALL ELINE('INVALID ENTRY')
               GOTO CHG.STATUS
            END
            IF QI='A' THEN
               IF CARRIER.REC<102>='A' THEN
                  CALL ELINE('This program is changing ACH to [I]nactive')
                  CARRIER.REC<102>='I'
               END
               IF CARRIER.REC<OTHER.CC.STATUS.FLD> = 'A' THEN
                  CALL ELINE('This program is changing ':OTHER.CC.NAME:' to [I]nactive')
                  CARRIER.REC<OTHER.CC.STATUS.FLD>='I'
               END
            END
            STATUS=QI
            CARRIER.REC<CC.STATUS.FLD>=STATUS
            GOSUB GET.STATUS
            CRT @(X.POS,4):STATUS.DESC 'L#50'
            RETURN
         CASE 1
            GOTO CHG.STATUS
      END CASE

***********************************************************************************

GET.NAME:***

      X.POS=20
      Y.POS=5
      CRT @(0,22):@(-3):'Enter ':CC.TYPE:' Name for this Carrier or [EX]it.':
      IF CARRIER.REC<CC.ACCT.NAME.FLD>='' THEN
         SAVE.NAME=''
         EDIT.MASK=STR(EDIT.MASK.CHAR,40)
      END ELSE
         SAVE.NAME=CARRIER.REC<CC.ACCT.NAME.FLD>
         EDIT.MASK=SAVE.NAME 'L#40'
      END
      HELP=''
      CALL GEN.IN(X.POS,Y.POS,EDIT.MASK,'',Q,0,40,'','',40,X.POS,Y.POS,0,QI,HELP,0,23)
      IF QI='' AND SAVE.NAME#'' THEN QI=SAVE.NAME
      BEGIN CASE
         CASE OCONV(QI,'MCU')='EX'
            STOP
         CASE OCONV(QI,'MCU')='X'
            BACK.FLAG=TRUE
            CRT @(X.POS,Y.POS):SAVE.NAME
            RETURN
         CASE QI=''
            GOTO GET.NAME
         CASE 1
            NAME=QI
            CARRIER.REC<CC.ACCT.NAME.FLD>=NAME
            CRT @(X.POS,Y.POS):NAME
            RETURN
      END CASE

***********************************************************************************

GET.EMAIL:***
      VIN='' ; VOUT=''
      HDG.TXT=CC.TYPE:' Remit Email Address'
      VOUT=CARRIER.REC<CC.REMIT.EMAIL.ADDR.FLD>
      VIN<1>=PROG.DESC
      VIN<2>=PACK.NAME
      VIN<3>=HDG.TXT
      VIN<4>=0                           ; * DISPLAY MODE
      VIN<5>=1                           ; * PROC LVL 1=TO 2=CC 3=BCC
      CALL FB.EMAIL(VIN,VOUT)
      CARRIER.REC<CC.REMIT.EMAIL.ADDR.FLD>=VOUT<1>
      GOSUB DISPLAY.SCREEN
      RETURN

***********************************************************************************
FAILSAFE.CHECK:***
* There are no failsafe conditions to check currently.
      FAILSAFE.OK=TRUE                   ; * Assume no problems and try to find problems
      RETURN

********************************************************************************

SAVE.CONTROL.REC:***

      WRITE CARRIER.REC ON F.CARRIERS,CARRIER.ID

      RETURN

********************************************************************************

FIND.LOCKED:

      STMT = 'LIST.READU EVERY'
      EXECUTE STMT CAPTURING OUTPUT
      FL.LEN = DCOUNT(OUTPUT,@AM)
      FL.USER = 'Someone'
      FOUND = FALSE

      FOR X = 1 TO FL.LEN UNTIL FOUND
         T.USER = OCONV(TRIM(OUTPUT<X>[44,9]),'MCU')
         T.FILE = TRIM(OUTPUT<X>[53,17])
         IF T.FILE = FIND.LOCKED.NAME THEN
            FL.USER = T.USER
            FOUND = TRUE
         END
      NEXT

      CALL ELINE(FL.USER:" is in Carrier ":FIND.LOCKED.NAME:". Find them and tell them to get out of that carrier!")

      RETURN

********************************************************************************

DISPLAY.CONTROL.RECORDS:***
      CRT @(0,0):@(-1)
      EXECUTE 'SORT FB.CAR.CTRL 1 2 3 4'
      CALL ELINE('')
      RETURN

********************************************************************************

ASK.FOR.NUM:***
* A general number prompt routine
* Inputs:
*    AFN.MSG  - message to display
*    AFN.MASK - default value
*    AFN.MIN  - min value allowed
*    AFN.MAX  - max value allowed
* Outputs:
*    AFN.ANSWER

      AFN.ANSWER=''

AFN.1:
      CRT @(0,22):AFN.MSG:@(-4)
      HELP='Entry Options: [':AFN.MIN:'-':AFN.MAX:'] [X]=Back'
      EDIT.MASK=AFN.MASK:' '
      CALL GEN.IN(LEN(AFN.MSG)+1,22,EDIT.MASK,'',Q,0,LEN(AFN.MAX),'','',2,LEN(AFN.MSG)+1,22,0,QI,HELP,0,23)
      QI=TRIM(OCONV(QI,'MCU'))
      IF QI='' THEN QI=TRIM(EDIT.MASK)
      BEGIN CASE
         CASE QI='X'
         CASE QI>=AFN.MIN AND QI<=AFN.MAX
         CASE 1
            CALL ELINE('Invalid entry. Try again.')
            GOTO AFN.1
      END CASE
      AFN.ANSWER=QI
      CRT @(0,22):@(-4):
      CRT @(0,23):@(-4):
      RETURN

********************************************************************************

ASK.Y.OR.N:***
* This is a general Yes/No prompt routine.
* Inputs:
*    YN.MSG, YN.MASK
* Outputs:
*    YN.ANSWER

      YN.ANSWER=''

Y.OR.N:
      CRT @(0,22):YN.MSG:@(-4)
      HELP='Entry Options: [Y]es [N]o'
      EDIT.MASK=YN.MASK'L#1'
      CALL GEN.IN(LEN(YN.MSG)+1,22,EDIT.MASK,'',Q,0,1,'','',2,LEN(YN.MSG)+1,22,0,QI,HELP,0,23)
      QI=TRIM(OCONV(QI,'MCU'))
      IF QI='' THEN QI=TRIM(EDIT.MASK)
      BEGIN CASE
         CASE QI='Y'
         CASE QI='N'
         CASE 1
            CALL ELINE('Invalid entry. Try again.')
            GOTO Y.OR.N
      END CASE
      CRT @(0,22):@(-4):
      CRT @(0,23):@(-4):
      YN.ANSWER=QI
      RETURN

********************************************************************************



LAST.CHANCE.TO.SAVE:***
      IF CARRIER.REC#OLD.CARRIER.REC THEN
         YN.MSG='You have unsaved changes. Save before exiting?'
         YN.MASK=''
         GOSUB ASK.Y.OR.N
         IF YN.ANSWER='Y' THEN
            GOSUB FAILSAFE.CHECK
            IF FAILSAFE.OK THEN
               GOSUB SAVE.CONTROL.REC
               RETURN
            END ELSE
               RETURN
            END
         END
         RETURN
      END

********************************************************************************

THE.END:***
      CRT @(0,22):@(-3):
      RETURN

GET.STATUS:

      CURRENT.STATUS=CARRIER.REC<CC.STATUS.FLD>
      BEGIN CASE
         CASE CURRENT.STATUS='' ; STATUS.DESC = ''
         CASE CURRENT.STATUS='A' ; STATUS.DESC = 'A - Active'
         CASE CURRENT.STATUS='I' ; STATUS.DESC = 'I - Inactive'
      END CASE

      RETURN
   END
