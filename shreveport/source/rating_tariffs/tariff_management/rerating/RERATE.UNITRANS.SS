
*  AUTHOR: Owen Holman
*    DATE: April 03, 2002 - Allow user to Rerate External SS
*  REVISIONS:
* Instructions to create file
*  Get an Excel file save as U:\-USER-\00000-DELETE.txt
*    where 00000 is the client number
*    '-DELETE' is a literal
*    and .txt is the Formatted Text TAB Delmited option
********************************************************************
* NPR01 Add option to select tarrif.
*
      $INCLUDE PROG.ADMIN INC_OPTIONS
*
* Pass mode to the old TARIFF.DATE.XREF routine to allow for selection of a Tariff.   ;* NPR01
*
MODE = "S"                  ;* NPR01
DATA MODE                   ;* NPR01
EXECUTE "TARIFF.DATE.XREF"  ;* NPR01
INPUT TARIFF.SELECTED       ;* NPR01

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
      PROG.NAME='RERATE.UNITRANS'
      PROG.DESC="Submit Freight Information for Charges"
      PACK.NAME="Logistics"

      UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'RERATE.UNITRANS' ; UPL.VOUT = ''                               ;* NPR_UPL 04/23/2010
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010
      CALL AFS.SCR.HEAD(CO.ID, FILE.ID, '', PROG.NAME, PROG.DESC, PACK.NAME, CO.NAME, TIME.DATE, 1)
      BEGIN CASE
         CASE USER='BRIAN'
         CASE USER='KAREN'
         CASE USER='OWEN'

         CASE USER='MKERBOW'
         CASE USER='DAVID'
         CASE USER='NPRATT'
         CASE USER='PBASS'
         CASE USER='TWOODRUFF'
         CASE USER='GSHAFER'

         CASE USER='BJEPPSON'
         CASE USER='SWINSTEAD'
         CASE USER='SSELMAN'
         CASE USER='DOURSLER'
         CASE USER='GCASSADA'
         CASE USER='DONNA'
         CASE USER='AMY'
         CASE USER='KRISTY'
         CASE USER='SSHAFER'  ; * TICKET 3091 - DRF 07/09/12
         CASE USER='RBOEHNLEIN' ; * Ticket 5457 - DRF 03/18/13

         CASE 1
            CALL ELINE('Authorized Access is Required.')
            GO EXIT.PROGRAM
      END CASE

      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         CALL OPEN.ABORT("CLIENTS",PROG.NAME)
      END
      OPEN '','VOC' TO F.VOC ELSE
         CALL OPEN.ABORT("VOC",PROG.NAME)
      END
      CLIENT='79999'
      READV CLIENT.NAME FROM F.CLIENTS,CLIENT,2 ELSE
         CALL ELINE('Client#: ':CLIENT:' is not on file!')
         GO EXIT.PROGRAM
      END
      CRT @(26,3):"- ":CLIENT.NAME:@(-4):
      OPEN '','FB.BILLS.HIST,':CLIENT TO F.HIST ELSE
         CALL OPEN.ABORT("FB.BILLS.HIST,":CLIENT,PROG.NAME)
         GO EXIT.PROGRAM
      END
      OPEN '','FB.BILLS,':CLIENT TO F.BILLS ELSE
         CALL OPEN.ABORT("FB.BILLS,":CLIENT,PROG.NAME)
         GO EXIT.PROGRAM
      END


10: *
      CRT @(0,03):@(-3):
      CRT @(0,04):'Instructions for use BEFORE Continuing:'
      CRT @(0,05):'Step  1 Using Excel, Open your Spreadsheet;'
      CRT @(0,06):'Step  2 Adjust the columns and headings so that:'
      CRT @(0,07):'        Column 1 is blank and is labeled -                  "Error",'
      CRT @(0,08):'        Column 2 is blank and is labeled -                  "Charges",'
      CRT @(0,09):'        Include an Origin Zip column labeled -              "Origin Zip",'
      CRT @(0,10):'        Include a  Destination Zip column labeled -         "Dest Zip",'
      CRT @(0,11):'        Include pairs of Class & Weight columns labeled -   "Class" & "Weight",'
      CRT @(0,12):'        For fuel surcharge calculations include the following columns : '
      CRT @(0,13):'           Carrier Number labeled             -      "Carrier #",'
      CRT @(0,14):'           Bill Date (MM/DD/YYYY) labeled     -      "Bill Date",'
      CRT @(0,15):'           FSC Percentage labeled             -      "FSC %",'
      CRT @(0,16):'           FSC Percentage labeled             -      "FSC Amount",'
      CRT @(0,17):"Step  3 In the Excel Menu Bar, CLICK File, CLICK Save As, 'Change Save as type:' to:"
      CRT @(0,18):'        Text (Tab Delimited)(*.txt).'
      CRT @(0,19):'Step  4 Name the file "U:\':USER:'\{FileName}.XLS" (Ex."U:\':USER:'\RATE_SS.XLS").'
      CRT @(0,20):"        Ignore the 'Not Compatible' messages you receive and click OK, then YES."

100   HELP='Enter the File Name to process or [EX]it'
      CALL GEN.IN(0,3,'Enter File Name #########################','',Q,0,25,'','',1,-25,3,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='' ! QI='EX' ! QI='X'
            GOTO EXIT.PROGRAM
         CASE 1
            RAW.ID=QI
      END CASE

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
      READ RAW.DATA FROM F.BILLDATA,RAW.ID ELSE
         CALL ELINE('U:\':USER:'\':RAW.ID:' is not on file.  Please re-enter.')
         GOTO 100
      END
      RAW.DATA=CHANGE(RAW.DATA,CHAR(9),@VM); * Replace Tabs with Values
*
* GET INFO AND WRITE TO FILE
*
      NUM.LINES=DCOUNT(RAW.DATA,@AM)

*
* Verify selection criteria is correct.
*
VERIFY.SELECTION: ***
      HELP="X=Change. EX=Exit. ''=Continue."
      CALL GEN.IN(0,22,'Enter selection please. ------------','',Q,0,12,'','',0,-12,22,1,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='X'
            CRT @(0,19):@(-3):
            GOTO 100
         CASE QI='EX'
            STOP
         CASE QI=''
            NULL
         CASE 1
            CALL ELINE('Invalid entry. Must be [X], [EX], or <RTN>.')
            GOTO VERIFY.SELECTION
      END CASE
      CRT @(0,22)

      RVIN=''
      RVOUT=''
      RVIN<1>=USER                       ; * BILLDATA USER FILE NAME
      RVIN<2>=RAW.ID                     ; * BILLDATA FILE NAME
      RVIN<3>='79999'                    ; * CLIENT ID
      RVIN<4>='99990'                    ; * CARRIER ID TO USE OR "SAME"
      RVIN<5>=TARIFF.SELECTED
      CALL RERATE.UNITRANS.SUB(RVIN,RVOUT)
      NEWFILENAME=RVOUT<1>
      ERRORX=RVOUT<2>

      IF ERRORX = "" THEN
         CRT @(0,22):@(-4)                                                     ;* NPR01
         HELP="Do you wish to calculate FSC. 'Y'=Yes or 'N'o."                 ;* NPR01
         CALL GEN.IN(0,22,'','',Q,0,2,'','',0,LEN(HELP) + 1,22,0,QI,HELP,0,22) ;* NPR01
         QI=OCONV(QI,'MCU')                                                    ;* NPR01
         IF QI = "Y" THEN
            DATA NEWFILENAME
            EXECUTE "UNITRANS.FSC.CALC"
         END
         CRT @(0,22):@(-3):'Your rated file is located at "U:\':USER:'\':NEWFILENAME:'".'
      END ELSE
         CRT @(0,22):@(-3):'Error -- ':ERRORX
      END
      CRT @(0,23):'Press [ENTER] to Continue':
      INPUT NUL
      GO EXIT.PROGRAM
CALL.NET.ADMIN: ***
      CALL ELINE("CALL NETWORK ADMINISTRATOR!")
      CALL ELINE("CALL NETWORK ADMINISTRATOR!!!!!")
      RETURN
*
EXIT.PROGRAM: *
*
      STOP
