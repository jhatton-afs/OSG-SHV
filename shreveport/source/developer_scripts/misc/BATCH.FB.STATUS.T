*******************************************************************
* Program : BATCH.FB.STATUS
*           Import Carrier Service data from Non-SMC Carriers
* Author  : JMK
* Date    : October 2007
*
* Copyright (c) 2002 by AFS Logistics, LLC. - All Rights Reserved

* Last updated by afs (gbino) at 08:31:01 on 09/28/2016.

* 092816 - GRB001 - SysAid 27313 add client name and number
* 110416 - GRB002 - SysAid 27313 add client name and number
* 121719 - GRB01 - ACCU-707 Modify format of returned data
*********************************************************************
* Format of CARRIER.SVC Text file            Format of CARRIER.SVC
* Tab delimited with 6 possible fields       ITEM ID = CARRIER*CLIENT*ORIGIN ZIP (OR ALL)
*
* (1) AFS Carrier #                          REC< 1> Dest ZipCode (3 or 5/6) multivalued
* (2) Origin ZipCode (3 or 5/6)              REC< 2> Direct/Indirect (D/I) multivalued
* (3) Dest ZipCode   (3 or 5/6)              REC< 3> Service Days multivalued
* (4) Direct/Indirect (D/I)
* (5) Service Days


$INCLUDE PROG.ADMIN INC_OPTIONS

* Initialize general variables
      PROMPT''
      CALL GET.USER.NEW(USER.NAME,CH.NUM)

      PROG.NAME='BATCH.FB.STATUS'
      PROG.DESC='Batch FB Status Data'
      PACK.NAME='Freight Payment'
      MASK.CHAR='-'
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'BATCH.FB.STATUS' ; UPL.VOUT = ''          ; * NPR_UPL 04/22/2010
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/22/2010
      TAB=CHAR(9)
      ESC=CHAR(27)
      CLIENT.ID=''
      CARRIER.ID=''
      USER.PWD=''
      USER.TYPE='AFSCS'
      USER.ID=''

* Write screen header
      CALL AFS.SCR.HEAD(CO.ID,FILE.ID,'',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
      CRT @(0,2):STR('=',79)

* Open other files

      OPEN '','BILLDATA.':USER.NAME TO F.BILLDATA ELSE
         OPEN '','VOC' TO F.VOC ELSE
            CALL ELINE('Unable to open VOC file - Call IS Department.')
            GOTO THE.END
         END
         READ BILLDATA.REC FROM F.VOC,'BILLDATA' ELSE
            CALL ELINE('Unable to open VOC BILLDATA.')
            GOTO THE.END
         END
         BILLDATA.REC<2>:='\':USER.NAME
         WRITE BILLDATA.REC ON F.VOC,'BILLDATA.':USER.NAME ELSE
            CALL ELINE('Your user name ':USER.NAME:' is not in the BILLDATA folder - Call IS Department.')
            GOTO THE.END
         END
         OPEN '','BILLDATA.':USER.NAME TO F.BILLDATA ELSE
            CALL ELINE('Unable to open BILLDATA.':USER.NAME:'.')
            GOTO THE.END
         END
      END
      OPEN '','CARRIERS' TO F.CARRIERS ELSE
         CALL ELINE('Unable to open CARRIERS.')
      END
      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         CALL ELINE('Unable to open CLIENTS.')
      END
      OPEN '','FED.INV.XREF' TO F.FED.INV.XREF ELSE          ; * JMK
         CALL ELINE('Unable to open FED.INV.XREF.')          ; * JMK
      END                                ; * JMK
      OPEN '','FB.BILLS.CRX' TO F.FB.CRX ELSE      ; * JMK
         CALL ELINE('Unable to open FB.BILLS.CRX.')          ; * JMK
      END                                ; * JMK

      CRT @(0,03):@(-3):
      CRT @(0,05):'Instructions for use BEFORE Continuing:'
      CRT @(0,06):'Step  1 Locate the desired pro numbers to query and copy them to the Windows'
      CRT @(0,07):'        clipboard.  Make sure these are one pro number per line.'
      CRT @(0,08):'Step  2 Open a new Excel spreadsheet and paste the Windows clipboard to cell A1.'
      CRT @(0,09):'Step  3 Right Click (Highlight) column A and choose the "Format Cells" option.'
      CRT @(0,10):'Step  4 Choose the "Number" tab from the Format Cells pop-up box.'
      CRT @(0,11):'Step  5 CLICK the "Text" option on the left side.'
      CRT @(0,12):'Step  6 Select "OK"'
      CRT @(0,13):"Step  7 CLICK File, CLICK Save As, 'Change Save as type:' to:"
      CRT @(0,14):'        Text (Tab Delimited)(*.txt). Save the file in your "U:\" drive.'
      CRT @(0,15):'Step  8 Name the file FBSTATUS-00000n.TXT where "00000" is the AFS carrier id'
      CRT @(0,16):'        and "n" refers to a counter if you have multiple files for the same'
      CRT @(0,17):'        AFS carrier id.'
      CRT @(0,18):"        Ignore the 'Not Compatible' messages you receive and click OK, then YES"

100:  ***
      LN='Are you ready to process your FB status file? '
      MASK='N-'
      HELP='[Y]=Yes [N]=No [EX]=Exit'
      CALL GEN.IN(0,22,LN:MASK,'',Q,0,2,'','',2,-2,22,1,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='EX' OR QI='N' OR QI=''
            GOTO THE.END
         CASE QI='Y'
            NULL
         CASE 1
            GOTO 100
      END CASE

      IF USER.NAME='DAVID' THEN CALL ELINE('PRESS BREAK')

      STMT='SSELECT BILLDATA.':USER.NAME:' = "FBSTATUS-]"'
      EXECUTE STMT RTNLIST BILLDATA.LIST CAPTURING BILLDATA.RESULTS
      NUM.ITEMS=@SELECTED
      IF NUM.ITEMS < 1 THEN
         CALL ELINE('No Files To Process.')
         GOTO 100
      END

      BILLDATA.EOF=0
      BILLDATA.CNT=0
      LOOP
         READNEXT BILLDATA.IN.ID FROM BILLDATA.LIST ELSE BILLDATA.EOF=1
      UNTIL BILLDATA.EOF DO
         FSFX=OCONV(FIELD(BILLDATA.IN.ID,'.',2),'MCU')
         IF FSFX#"TXT" THEN GOTO NEXT.FILE
         CARRIER.ID=FIELD(BILLDATA.IN.ID,'-',2)[1,5]
         BILLDATA.OUT.ID=FIELD(BILLDATA.IN.ID,'.',1):'-UPD.XLS'
         READ TEST FROM F.BILLDATA,BILLDATA.OUT.ID THEN
            CONTINUE
            ***GOTO NEXT.FILE               ; * Don't process again.
         END

         READ CARRIER.REC FROM F.CARRIERS,CARRIER.ID ELSE
            CALL ELINE("ERROR - Carrier ":CARRIER.ID:" not on file.")
            GOTO NEXT.FILE               ; * ENTER CARRIER
         END

* Read in the existing Carrier Service text file
         READ FBS.IMPORT FROM F.BILLDATA,BILLDATA.IN.ID ELSE
            CALL ELINE(BILLDATA.IN.ID:' does not exist.')    ; * SWB CACHE SYNTAX FIXES
            GOTO NEXT.FILE
         END
         IF CARRIER.ID='00015' THEN      ; * JMK
            NEW.FBS.IMPORT=''
            NATT=DCOUNT(FBS.IMPORT,@AM)  ; * JMK
            FOR ATT=1 TO NATT            ; * JMK
               TEST.ID='00015*':FBS.IMPORT<ATT>:'*0'         ; * JMK
               READ TEST.REC FROM F.FB.CRX,FBS.IMPORT<ATT> THEN        ; * JMK
                  NEW.FBS.IMPORT<-1>=FBS.IMPORT<ATT>         ; * JMK
               END ELSE                  ; * JMK
                  READ TEST.REC FROM F.FED.INV.XREF,FBS.IMPORT<ATT> THEN         ; * JMK
                     TEST.NATT=DCOUNT(TEST.REC,@AM)          ; * JMK
                     FOR TEST.ATT=1 TO TEST.NATT   ; * JMK
                        NEW.FBS.IMPORT<-1>=FIELD(TEST.REC<TEST.ATT>,'*',2)       ; * JMK
                     NEXT TEST.ATT       ; * JMK
                  END ELSE               ; * JMK
                     NEW.FBS.IMPORT<-1>=FBS.IMPORT<ATT>      ; * JMK
                  END                    ; * JMK
               END                       ; * JMK
            NEXT ATT                     ; * JMK
            IF NEW.FBS.IMPORT#'' THEN    ; * JMK
               FBS.IMPORT=NEW.FBS.IMPORT           ; * JMK
            END                          ; * JMK
         END                             ; * JMK
         BILLDATA.OUT.ID=FIELD(BILLDATA.IN.ID,'.',1):'-UPD.XLS'
         DELETE F.BILLDATA,BILLDATA.OUT.ID
         READ TEST FROM F.BILLDATA,BILLDATA.OUT.ID THEN
            GOTO NEXT.FILE               ; * Don't process again.
         END
         FBS.LAST.IMPORT=FBS.IMPORT      ; * Save file for writing as "last"
         FBS.IMPORT=CHANGE(FBS.IMPORT,CHAR(12),'')
         FBS.IMPORT=CHANGE(FBS.IMPORT,TAB,@VM)
         FBS.EXPORT=''

* Status lines
         NATT=DCOUNT(FBS.IMPORT,@AM)
         CRT @(0,5):'Total items in import file ':BILLDATA.IN.ID:' = ':NATT:@(-3)
         CRT @(0,7):'Total Items processed'
         CRT @(0,8):'---------------------'

* Set counters for processing
         ALREADY.THERE=0
         ALREADY.THERE.BOTH.MATCH=0
         ALREADY.THERE.AMOUNTS.MATCH=0
         ALREADY.THERE.DATES.MATCH=0
         ALREADY.THERE.NEITHER.MATCH=0
         ALREADY.THERE.NULL=0
         NOT.THERE=0
         RESULTS.ARRAY=''
         ERROR.ARRAY=''
         PERC=0
         PREV.CLIENT.NUMBER=''

* Prepare the file for processing
         NUM.PROS=DCOUNT(FBS.IMPORT,@AM)
         FOR ATT=1 TO NATT
            IF NOT(REM(ATT,100)) THEN
               CRT @(0,9):ATT'R#21'
            END
***            CALL PROG.BAR(11,ATT,NATT,PERC)
            FBS.LINE=TRIM(FBS.IMPORT<1>)
            DEL FBS.IMPORT<1>
            IF DCOUNT(FBS.LINE,' ')>1 THEN
               FBS.LINE=TRIM(FIELD(FBS.LINE,' ',1))
            END
            FBS.PRO=FBS.LINE<1,1>        ; * AFS Carrier Number Pro
            DATA CARRIER.ID,FBS.PRO,USER.NAME,USER.PWD,USER.TYPE,USER.ID
            EXECUTE 'INET.FB.STATUS.T1' CAPTURING FBS.RESULTS
GO 888
            * Begin GRB001
            PRO.FORMAT = CARRIER.REC<47>
            PROS=''
            IF PRO.FORMAT<1,1>#'' THEN
               VIN = PRO.FORMAT
               VIN<2> = CARRIER.REC<51>
               VIN<3> = FBS.PRO:@VM:FBS.PRO
               CALL FORMAT.PROS(VIN,VOUT)
               PROS = VOUT<3>
               IF CARRIER.ID = "00018" THEN        ; * JMK16
                  IF FBS.PRO[LEN(FBS.PRO),1]='1' THEN        ; * JMK16
                     FBS.PRO=FBS.PRO[1,LEN(FBS.PRO)-1]:'0'   ; * JMK16
                  END                    ; * JMK16
               END                       ; * JMK16
               NUM.T.PROS = DCOUNT(PROS,@VM)
               IF NUM.T.PROS = 0 THEN
                  TEMP.PRO.ID = CARRIER.ID:'*':FBS.PRO:"*0"
                  PRO.NO = TEMP.PRO.ID
               END
               FOR YY = 1 TO NUM.T.PROS
                  TEMP.PRO.ID = CARRIER.ID:'*':PROS<1,YY>:"*0"
                  PRO.NO = ""
                  READ DUMMY FROM F.FB.CRX,TEMP.PRO.ID THEN
                     PRO.NO = TEMP.PRO.ID
                     CRT "FOUND"
                     EXIT
                  END
               NEXT YY
            END

            READV CLIENT.NO FROM F.FB.CRX,PRO.NO,1 ELSE CLIENT.NO = "NOF"
            READV CLIENT.NAME FROM F.CLIENTS,CLIENT.NO,2 ELSE CLIENT.NAME = "NOFN"
            READ CARRIER.REC FROM F.CARRIERS,CARRIER.ID ELSE
               CALL ELINE("ERROR - Carrier ":CARRIER.ID:" not on file.")
               GOTO NEXT.LINE            ; * ENTER CARRIER
            END
            CARRIER.NAME = CARRIER.REC<1>
            RESULTS.CNT = COUNT(FBS.RESULTS,@AM)
            FOR I = 1 TO RESULTS.CNT
               IF I =1 THEN
                  FBS.RESULTS = INSERT(FBS.RESULTS,1,1,0,"Client Name")
                  FBS.RESULTS = INSERT(FBS.RESULTS,1,1,0,"Client No.")
               END
               IF I GT 1 THEN
                  FBS.RESULTS = INSERT(FBS.RESULTS,I,1,0,CLIENT.NAME)
                  FBS.RESULTS = INSERT(FBS.RESULTS,I,1,0,CLIENT.NO)
               END
            NEXT I
            
    888:        
            
            * End GRB001
            IF ATT=1 THEN
               FBS.EXPORT<-1>=FBS.RESULTS
            END ELSE
               DEL FBS.RESULTS<1>
               FBS.EXPORT<-1>=FBS.RESULTS
            END

NEXT.LINE:NEXT ATT

* Update files

         FBS.EXPORT.NEW = ""
         LINE.CNT = DCOUNT(FBS.EXPORT,@AM)
         FOR I = 1 TO LINE.CNT
            IF I = 1 THEN
               NEW.FOR = FBS.EXPORT<I,1>:@VM:FBS.EXPORT<I,2>:@VM:FBS.EXPORT<I,3>:@VM:FBS.EXPORT<I,4>:@VM:FBS.EXPORT<I,5>:@VM:FBS.EXPORT<I,6>:@VM:FBS.EXPORT<I,7>:@VM:FBS.EXPORT<I,8>
               NEW.FOR = NEW.FOR:@VM:FBS.EXPORT<I,9>:@VM:FBS.EXPORT<I,10>:@VM:FBS.EXPORT<I,11>:@VM:FBS.EXPORT<I,12>:@VM:FBS.EXPORT<I,13>
               NEW.FOR = NEW.FOR:@VM:FBS.EXPORT<I,14>:@VM:FBS.EXPORT<I,15>:@VM:FBS.EXPORT<I,16>
               NEW.FOR = NEW.FOR:@VM:FBS.EXPORT<I,17>:@VM:FBS.EXPORT<I,18>:@VM:FBS.EXPORT<I,19>:@VM:FBS.EXPORT<I,20>:@VM:FBS.EXPORT<I,21>:@VM:FBS.EXPORT<I,22>

            END ELSE
               
               NEW.FOR = FBS.EXPORT<I,1>:@VM:FBS.EXPORT<I,2>:@VM:FBS.EXPORT<I,3>:@VM:FBS.EXPORT<I,4>:@VM:FBS.EXPORT<I,5>:@VM:FBS.EXPORT<I,6>:@VM:FBS.EXPORT<I,7>
               NEW.FOR = NEW.FOR:@VM:FBS.EXPORT<I,8>:@VM:FBS.EXPORT<I,9>
               NEW.FOR = NEW.FOR:@VM:FBS.EXPORT<I,10>:@VM:FBS.EXPORT<I,11>:@VM:FBS.EXPORT<I,12>:@VM:FBS.EXPORT<I,13>:@VM:FBS.EXPORT<I,14>:@VM:FBS.EXPORT<I,15>:@VM:FBS.EXPORT<I,16>:@VM:FBS.EXPORT<I,17>

               SEAR.IND = INDEX(FBS.EXPORT<I,22>,"Bill returned for the following reason",1)
               NEW.STRING = ""
               
              
               
               IF SEAR.IND THEN
                  START.POS = SEAR.IND
                  END.POS = LEN(FBS.EXPORT<I,22>)
                  NEW.STRING = FBS.EXPORT<I,22>[START.POS,(END.POS - START.POS)]
               END
               NEW.FOR = NEW.FOR:@VM:NEW.STRING:@VM:FBS.EXPORT<I,18>:@VM:FBS.EXPORT<I,19>:@VM:FBS.EXPORT<I,20>:@VM:FBS.EXPORT<I,21>

            END
            FBS.EXPORT.NEW<-1> = NEW.FOR
         NEXT I

         FBS.EXPORT=CHANGE(FBS.EXPORT.NEW,@VM,TAB)
         WRITE FBS.EXPORT ON F.BILLDATA,BILLDATA.OUT.ID ELSE
            CALL ELINE('Could not write ':BILLDATA.OUT.ID:'. Call Help Desk about program "FBBP BATCH.FB.STATUS".')
         END
NEXT.FILE:*
      REPEAT

*************************************************************************

THE.END:***
* End of program
      CRT @(0,23):
   END
