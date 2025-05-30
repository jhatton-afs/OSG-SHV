************************************************************************
* Program name : RERATE.SS
* Author       : Owen Holman
* Date written : April 03, 2002
* Library      : FBBP
* Copyright (c) 2002 by AFS Logistics, LLC. - All Rights Reserved
*
* submit freight info for charges
*
* Last updated by AFS (gbino) at 07:57:18 on 02/21/2017.
*
* Start modification history
* 12/02/14 : DRF01 : SysAid 13796 Added Alan Hicks to this program
* 07/01/15 : DRF02 : SysAid 18393 Added Robbie Jester to this program
* 08/11/15 : DRF03 : SysAid 19293 Gave Cynthia access
      * End modification history
*********************************************************************
** Instructions to create file
*  Get an Excel file save as U:\-USER-\00000-DELETE.txt
*    where 00000 is the client number
*    '-DELETE' is a literal
*    and .txt is the Formatted Text TAB Delmited option
$INCLUDE PROG.ADMIN INC_OPTIONS
* INITIALIZE VARIABLES
*
      SEQ=0
      PROMPT''
      CALL GET.USER.NEW(USER,CH.NUM)
      PROG.NAME='RERATE.SS'
      PROG.DESC="Submit Freight Information for Charges"
      PACK.NAME="Logistics"

      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'RERATE.SS' ; UPL.VOUT = ''      ; * NPR_UPL 04/23/2010
      UPL.VIN<3> = USER
      UPL.VIN<4> = CH.NUM
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/23/2010
      CALL AFS.SCR.HEAD(CO.ID, FILE.ID, '', PROG.NAME, PROG.DESC, PACK.NAME, CO.NAME, TIME.DATE, 1)
      OPEN '','OPERATOR' TO F.OP ELSE CALL OPEN.ABORT("OPERATOR",PROG.NAME)      ; * GRB01
      READV OP.FLG FROM F.OP,USER,46 ELSE
         OP.FLG = "N"
      END
      IF OP.FLG = "Y" THEN

         ****   BEGIN CASE
         **** CASE USER='BRIAN'
         **** CASE USER='BROSE'
         **** CASE USER='DAVID'
         **** CASE USER='GSHAFER'
         **** CASE USER='PBASS'
         **** CASE USER='AHICKS'      ; * DRF01
         **** CASE USER='AMY'
         **** CASE USER='BJEPPSON'
         **** CASE USER='CYNTHIA'     ; * DRF03
         **** CASE USER='DONNA'
         **** CASE USER='GCASSADA'
         **** CASE USER='KRISTY'
         **** CASE USER='RBOEHNLEIN' ; * Ticket 5457 - DRF 03/18/13
         **** CASE USER='RJESTER'      ; * DRF02
         **** CASE USER='SCHUTAI'
         **** CASE USER='SSELMAN'
         **** CASE USER='SWINSTEAD'
         **    CASE 1
      END ELSE
         CALL ELINE('Authorized Access is Required.')
         GO EXIT.PROGRAM
         **  END CASE
      END

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
10:   *
      CRT @(0,03):@(-3):
      CRT @(0,05):'Instructions for use BEFORE Continuing:'
      CRT @(0,06):'Step  1 Using Excel, Open your Spreadsheet;'
      CRT @(0,07):'Step  2 Adjust the columns and headings so that:'
      CRT @(0,08):'        Column 1 is blank and is labeled "Error",'
      CRT @(0,09):'        Column 2 is blank and is labeled "Charges",'
      CRT @(0,10):'        Column 3 contains the Origin Zip and is labeled "Origin Zip",'
      CRT @(0,11):'        Column 4 contains the Destination Zip and is labeled "Dest Zip",'
      CRT @(0,12):'        Column 5 contains the Freight Class and is labeled "Class",'
      CRT @(0,13):'        Column 6 contains the associated Weight and is labeled "Weight",'
      CRT @(0,14):'        Repeat the two columns above for all needed classes and weights.'
      CRT @(0,15):"Step  2 In the Excel Menu Bar, CLICK File, CLICK Save As, 'Change Save as type:' to:"
      CRT @(0,16):'        Text (Tab Delimited)(*.txt).'
      CRT @(0,17):'Step  3 Name the file "U:\':USER:'\{FileName}.XLS" (Ex."U:\':USER:'\RATE_SS.XLS").'
      CRT @(0,18):"        Ignore the 'Not Compatible' messages you receive and click OK, then YES."

100:  HELP='Enter the File Name to process or [EX]it'
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
      RAW.DATA=CHANGE(RAW.DATA,CHAR(9),@VM)        ; * Replace Tabs with Values
*
* GET INFO AND WRITE TO FILE
*
      NUM.LINES=DCOUNT(RAW.DATA,@AM)

*
* Verify selection criteria is correct.
*
VERIFY.SELECTION:***
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
      CALL RERATE.SUB(RVIN,RVOUT)
      NEWFILENAME=RVOUT<1>
      ERRORX=RVOUT<2>
      IF ERRORX NE "" THEN
         CRT @(0,22):@(-3):'Your rated file is located at "U:\':USER:'\':NEWFILENAME:'".'
      END ELSE
         CRT @(0,22):@(-3):'Error -- ':ERRORX
      END
      CRT @(0,23):'Press [ENTER] to Continue':
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
