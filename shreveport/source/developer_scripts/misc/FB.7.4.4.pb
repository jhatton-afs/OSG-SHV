
*  AUTHOR: Owen Holman
*    DATE: April 03, 2002 - Allow user to Delete TS Bills
*  REVISIONS:
* Instructions to create file
*  Get an Excel file save as U:\-USER-\00000-DELETE.txt
*    where 00000 is the client number
*    '-DELETE' is a literal
*    and .txt is the Formatted Text TAB Delmited option
*    Keywords to search on: DELETE TS; DELETE TRAFFIC SURVEY BILLS
********************************************************************
*
$INCLUDE PROG.ADMIN INC_OPTIONS
* INITIALIZE VARIABLES
*
    SEQ=0
    PROMPT''
    CALL GET.USER(USER)
*
********************************************************************
*
*  TABLE TO CHANGE FIELD NUMBERS (VALUES) OF DATA
*
********************************************************************
*
* ASK FOR CLIENT
*
      PROG.NAME='FB.7.4.4.PB'
      PROG.DESC="Delete Traffic Survey Bills from SS Spec 1"
      PACK.NAME="Freight Billing"

       UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'FB.7.4.4' ; UPL.VOUT = ''                    ;* NPR_UPL 04/23/2010
       CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010
      CALL AFS.SCR.HEAD(CO.ID, FILE.ID, '', PROG.NAME, PROG.DESC, PACK.NAME, CO.NAME, TIME.DATE, 1)
      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         CALL OPEN.ABORT("CLIENTS",PROG.NAME)
      END
      OPEN '','VOC' TO F.VOC ELSE
         CALL OPEN.ABORT("VOC",PROG.NAME)
      END


100   HELP='Enter the Traffic Survery Client Number or [EX]it'
      CRT @(0,03):@(-3):
      CRT @(0,05):'Instructions for use BEFORE Continuing:'
      CRT @(0,06):'Step  1 Create a Spreadsheet of bills using Spec 1'
      CRT @(0,07):'Step  2 Open Excel THEN Open the Spreadsheet (its located in your U:\':USER:'\ Drive)'
      CRT @(0,08):'Step  3 On the Excel Text Import Wizard CLICK [Next] then [Next] again'
      CRT @(0,09):'Step  4 Scroll to the right and click (Highlight) the Pro # Column'
      CRT @(0,10):"Step  5 CLICK the 'Text' Button at the top right of the screen"
      CRT @(0,11):'Step  6 Select Finish'
      CRT @(0,12):'Step  7 Remove the bills from this spreadsheet that you want to KEEP'
      CRT @(0,13):'Step  8 When finished you have a list of the bills to DELETE'
      CRT @(0,14):"Step  9 CLICK File, CLICK Save As, 'Change Save as type:' to:"
      CRT @(0,15):'        Text (Tab Delimited)(*.txt)'
      CRT @(0,16):'Step 10 Name the file CLIENT#-delete.txt (Example: 99999-delete.txt)'
      CRT @(0,17):"        Ignore the 'Not Compatible' messages you receive and click OK, then YES"
 
      CALL GEN.IN(0,3,'Enter Client Number #####','',Q,0,20,'','',1,-5,3,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
        CASE QI='' ! QI='EX' ! QI='X'
          GOTO EXIT.PROGRAM
        CASE NOT(NUM(QI))
          CALL ELINE('CLIENT MUST BE NUMERIC')
          GOTO 100
      END CASE
      CLIENT=Q'R%5'
      READV CLIENT.NAME FROM F.CLIENTS,CLIENT,2 ELSE
        CALL ELINE('Client#: ':CLIENT:' is not on file!')
        GO 100
      END
      CRT @(26,3):"- ":CLIENT.NAME:@(-4):
      IF CLIENT[1,2]#'99' THEN
        CALL ELINE('NOT ALLOWED!  This client is NOT A Traffic Survey Client!')
        GO 100
      END
      OPEN '','FB.BILLS.HIST,':CLIENT TO F.HIST ELSE
        CALL OPEN.ABORT("FB.BILLS.HIST,":CLIENT,PROG.NAME)
        GO 100
      END
      OPEN '','FB.BILLS,':CLIENT TO F.BILLS ELSE
        CALL OPEN.ABORT("FB.BILLS,":CLIENT,PROG.NAME)
        GO 100
      END
*
* OPEN FILE
*
      READ BILLDATA.REC FROM F.VOC,"BILLDATA" ELSE
         GOSUB CALL.NET.ADMIN
         CALL ELINE('UNABLE TO OPEN "VOC BILLDATA"')
         STOP
      END

      BILLDATA.REC<2>:='\':USER
      WRITE BILLDATA.REC ON F.VOC,"BILLDATA.":USER ELSE
        CALL ELINE('UNABLE TO WRITE VOC "BILLDATA.":USER')
        GOSUB CALL.NET.ADMIN
        STOP
      END
      OPEN '','BILLDATA.':USER TO F.BILLDATA ELSE
        CALL ELINE(USER:" is not a folder in U:\Billdata. Add the folder and try again")
        GOSUB CALL.NET.ADMIN
        STOP
      END

*
* READ RAW.DATA
*
    RAW.ID=CLIENT:"-delete.txt"
    READ RAW.DATA FROM F.BILLDATA,RAW.ID ELSE
      CALL ELINE('U:\':USER:'\':RAW.ID:' is not on file.  Must be present to delete bills')
      GOTO 100
    END
    RAW.DATA=CHANGE(RAW.DATA,CHAR(9),@VM); * Replace Tabs with Values

  SAVE.RAW.DATA = RAW.DATA
  
*
* GET INFO AND WRITE TO FILE
*
    NUM.LINES=DCOUNT(RAW.DATA,@AM)

*
* Verify selection criteria is correct.
*
VERIFY.SELECTION:***
    CRT @(0,19):"By typing [I-UNDERSTAND] I agree to PERMANENTLY deleting ":NUM.LINES-3:" Freight Bills"
    CRT @(0,20):"from the Traffic Survey account ":CLIENT:"-":CLIENT.NAME
    HELP="X=Change. EX=Exit. [I-UNDERSTAND]=Continue."
    CALL GEN.IN(0,22,'Enter selection please. ------------','',Q,0,12,'','',0,-12,22,1,QI,HELP,0,23)
    QI=OCONV(QI,'MCU')
    BEGIN CASE
       CASE QI='X'
          CRT @(0,19):@(-3):
          GOTO 100
       CASE QI='EX'
          STOP
       CASE QI='I-UNDERSTAND'
          NULL
       CASE 1
          CALL ELINE('Invalid entry. Must be [X], [EX], or [I-UNDERSTAND].')
          GOTO VERIFY.SELECTION
    END CASE
    CRT @(0,22)
*
*  Read file, check that bills can be found (PKB 06172011)
*
    MISSING.PRO = 0

    FOR X = 1 TO NUM.LINES
      IF X < 4 THEN GO SKIP.LINE.READ
      LINE=RAW.DATA<1>
      IF TRIM(LINE)='' THEN GO SKIP.LINE.READ
      CARRIER=LINE<1,1>'R%5'
      PRO=LINE<1,5>
      PRO.ID=CARRIER:"*":PRO:"*0"
      READV DHIST FROM F.HIST,PRO.ID,1 ELSE
        MISSING.PRO = MISSING.PRO + 1
      END

SKIP.LINE.READ:* 
      DEL RAW.DATA<1>

    NEXT X
    IF MISSING.PRO > 0 THEN
    CRT @(0,03):@(-3):
    CALL FB.PRINT.CENT(1,78,7,'Your file contains ':MISSING.PRO:' missing pro numbers. Nothing was deleted.')
    CALL FB.PRINT.CENT(1,78,8,'Verify the freight bill numbers in your spreadsheet file')  
    CALL FB.PRINT.CENT(1,78,9,'and follow the import wizard instructions.') 
    CRT
    CRT 'Press [ENTER] to Continue':
    INPUT NUL
    GO EXIT.PROGRAM
    END    


*
   RAW.DATA = SAVE.RAW.DATA

*
*  
    FOR X = 1 TO NUM.LINES
      IF X < 4 THEN GO SKIP.LINE
      LINE=RAW.DATA<1>
      IF TRIM(LINE)='' THEN GO SKIP.LINE
      CARRIER=LINE<1,1>'R%5'
      PRO=LINE<1,5>
      PRO.ID=CARRIER:"*":PRO:"*0"
      READ DHIST FROM F.HIST,PRO.ID ELSE
        CALL ELINE('On Line ':X:' PRO.ID ':PRO.ID:' is missing from FB.BILLS.HIST File!')
      END
      DELETE F.HIST,PRO.ID
      DELETE F.BILLS,PRO.ID
      CRT PRO.ID:' deleted'
SKIP.LINE:* 
      DEL RAW.DATA<1>
    NEXT X
    CRT
    CRT 'Press [ENTER] to Continue':
    INPUT NUL
    GO EXIT.PROGRAM
CALL.NET.ADMIN:***
    CALL ELINE("CALL NETWORK ADMINISTRATOR!")
    CALL ELINE("CALL NETWORK ADMINISTRATOR!!!!!")
    RETURN
*
EXIT.PROGRAM:*
*
    STOP
