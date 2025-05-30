***************************************************************   
*
* PROGRAM FB.2.7.S
* PROGRAM TO GENERATE SPREADSHEET OF  FEDEX INVOICES
* modified version of invoice inquiry FB.2.7
* FREIGHT BILLING PACKAGE
*
* AUTHOR: Greg Bino
* DATE: June 21, 2016
*
***************************************************************
* Initialize variables
*
$OPTIONS HEADER.EJECT
$OPTIONS EXEC.EQ.PERF
$OPTIONS INFO.ABORT
      ERRMSG=''
      PROMPT''
      PROG.NAME='FB.2.7.S'
      PROG.DESC='INVOICE SPREADSHEET'
      PACK.NAME='FREIGHT BILLING'
      CO.NAME='AFS Logistics, LLC'
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'FB.2.7.S' ; UPL.VOUT = ''
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)
      CLIENT.ID='' ; CLIENT.NAME='' ; CARRIER.ID=''
      CARRIER.NAME=''
      HLA = '' ; HLB = ''
      TAB=CHAR(9)
*
* Open general files
*
      OPEN '','CLIENTS' TO F.CLIENTS ELSE CALL OPEN.ABORT("CLIENTS",PROG.NAME)
      OPEN '','CARRIERS' TO F.CARRIERS ELSE CALL OPEN.ABORT("CARRIERS",PROG.NAME)
      OPEN '','FB.BILLS.CRX' TO F.CRX ELSE
         EXECUTE 'CREATE-FILE FB.BILLS.CRX 1 103' PASSLIST CAPTURING OUTPUT
         OPEN '','FB.BILLS.CRX' TO F.CRX ELSE CALL OPEN.ABORT("FB.BILLS.CRX",PROG.NAME)
      END
      OPEN '','FB.TABLES' TO F.TABLES ELSE CALL OPEN.ABORT("FB.TABLES",PROG.NAME)
      OPEN '','FED.INV.XREF' TO F.INV.XREF ELSE CALL OPEN.ABORT("FED.INV.XREF",PROG.NAME)
      OPEN '','BCTRL' TO F.BCTRL ELSE
         CALL OPEN.ABORT('BCTRL',PROG.NAME)
      END
      CALL GET.USER(USER)
      READ DBCTRL FROM F.BCTRL,USER ELSE DBCTRL=''
      OPEN '','BILLDATA.':USER TO F.BILLDATA ELSE
         CALL ELINE('Unable to open BILLDATA.':USER:'.')
         STOP
      END
***********************************************************************
* Enter invoice number
***********************************************************************
      EOJ = 0
      LOOP
      UNTIL EOJ DO
         GOSUB DISP.SCRN                 ; * Display screen
         HELP="Enter invoice number. [cr]=Exit."
         CALL GEN.IN(8,3,'#-###-#####  ','',Q,0,13,'','',0,-13,3,0,QI,HELP,0,23)
         QI=OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI='X' ! QI='EX' ! QI=''
               EOJ = 1
               CONTINUE
            CASE Q MATCH "1N'-'3N'-'5N"
               NULL
            CASE 1
               CALL ELINE(' Invalid invoice format')
               CONTINUE
         END CASE
         INV.NUM=Q
         CRT @(8,3):INV.NUM
         DARRAY=''
         INV.AMT=0
         AMT.TO.PAY=0
         GOSUB GET.RECORD.NAME
         CALL ELINE(INV.NUM:' Building file')
         GOSUB BUILD.HEADER
         GOSUB GET.REC
      REPEAT
      STOP
*
**********************************************************************
GET.REC:* Get invoice item
***********************************************************************
      READ DINV.XREF FROM F.INV.XREF,INV.NUM ELSE
         W.ID.PRO = "01075*":INV.NUM:"*0"
         DINV.XREF = W.ID.PRO            ; * NPR01
         READ PRO.REC FROM F.CRX, W.ID.PRO ELSE
            CALL ELINE(INV.NUM:' Is not on file')
            RETURN
         END
      END
      NUM.PROS=DCOUNT(DINV.XREF,CHAR(254))
      OLD.CLIENT.ID=''
      FOR I = 1 TO NUM.PROS
         READ PRO.REC FROM F.CRX,DINV.XREF<I> ELSE
            CALL ELINE(DINV.XREF<I>:' Is not on file - Skipping')
            DARRAY<I,1>=FIELD(DINV.XREF<I>,'*',2)
            CONTINUE
         END
         INV.AMT=INV.AMT+PRO.REC<8>-PRO.REC<10>-PRO.REC<11>
         AMT.TO.PAY=AMT.TO.PAY+PRO.REC<8>
         DARRAY<I,1>=FIELD(DINV.XREF<I>,'*',2)
         DARRAY<I,2>=PRO.REC<2>
         DARRAY<I,3>=PRO.REC<8>-PRO.REC<10>-PRO.REC<11>
         DARRAY<I,4>=PRO.REC<8>
         DARRAY<I,5>=PRO.REC<41,2>:' ':PRO.REC<41,1>
         DARRAY<I,5>=TRIM(DARRAY<I,5>)
         DARRAY<I,6>=PRO.REC<37>
         DARRAY<I,7>=PRO.REC<15>
         DARRAY<I,8>=PRO.REC<14>
         DARRAY<I,9>=PRO.REC<1>
         DARRAY<I,10>=FIELD(DINV.XREF<I>,'*',1)
         IF PRO.REC<39>='R' THEN
            DARRAY<I,5>='REJECTED BILL'
            DARRAY<I,4>=0
            AMT.TO.PAY=AMT.TO.PAY-PRO.REC<8>
         END
         CLIENT.ID=PRO.REC<1>
         IF OLD.CLIENT.ID='' THEN OLD.CLIENT.ID=CLIENT.ID
         IF CLIENT.ID#OLD.CLIENT.ID THEN
            CALL ELINE('More than one client for this invoice - Using the first one')
         END
      NEXT I
      READ DCLIENT FROM F.CLIENTS,CLIENT.ID THEN
         HIN = DCLIENT<240> ; HOUT = ""
         CALL CLIENT.HL(HIN,HOUT) ; HLB = HOUT<1,1> ; HLA = HOUT<1,2>
         CLIENT.LINE=CLIENT.ID:' ':DCLIENT<2>
      END ELSE
         CALL ELINE(CLIENT.ID:' Is not on file')
         CLIENT.LINE=CLIENT.ID:' *** Unknown ***'
      END
      CRT @(42,3):INV.AMT'R26,#10'
      CRT @(69,3):AMT.TO.PAY'R26,#10'
      CRT @(8,4):HLB:CLIENT.LINE[1,30]:HLA
      CRT @(75,4):NUM.PROS'R#4'
      GOSUB BUILD.ARRAY
      RETURN
*
**********************************************************************
DISP.SCRN:* Display screen
***********************************************************************
      CALL AFS.SCR.HEAD('','','',PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,'',1)
      CRT @(0,3):'Invoice #':@(25,3):'Invoice Amount':@(55,3):'Amount To Pay'
      CRT @(0,4):'Client'
      CRT @(55,4):'Number of Airbills'
      CRT @(0,5):STR('-',79)
      RETURN
*
***********************************************************************
BUILD.ARRAY:*
***********************************************************************
      ***   CRT @(0,6):@(-3):' Ln Airbills....... Shp Date Inv Amt  Amt Pd Cut Back/Prc Date  Ck Date  Check #'
      FOR I=1 TO NUM.PROS
         GOSUB BUILD.DATA.LINE
      NEXT I
      CLOSESEQ OUTSEQ.FILE
      CALL ELINE(' File ':RECORD.NAME:' completed')
      RETURN
*************************************************************************
WRITE.LINE:
*************************************************************************
      LINED=CHANGE(LINED,@VM,TAB)
      WRITESEQ LINED ON OUTSEQ.FILE ELSE NULL

      RETURN
*************************************************************************
GET.RECORD.NAME:
*************************************************************************
      RECORD.NAME=INV.NUM
      RECORD.NAME:='-'
      D=DATE()'D2/'
      RECORD.NAME:=D[1,2]:D[4,2]:D[7,4]
      RECORD.NAME:='.XLS'
      OPENSEQ 'BILLDATA.':USER, RECORD.NAME TO OUTSEQ.FILE ELSE
         CREATE OUTSEQ.FILE ELSE
         END
      END
      RETURN
************************************************************************
BUILD.DATA.LINE:
************************************************************************
      LINED = I'R#3':TAB:DARRAY<I,1>'L#15':TAB:DARRAY<I,2>'D2/':TAB:DARRAY<I,3>'R26#8':TAB:DARRAY<I,4>'R26#8'
      IF DARRAY<I,5>#'' THEN
         LINED = LINED:TAB:DARRAY<I,5>'L#17'
      END ELSE
         LINED = LINED:TAB:DARRAY<I,6>'D2/'
      END
      LINED = LINED:TAB:DARRAY<I,7>'D2/':TAB:DARRAY<I,8>'L#8':TAB:DARRAY<I,10>
      GOSUB WRITE.LINE

      RETURN
************************************************************************
BUILD.HEADER:
************************************************************************
      HDR = "INVOICE # ":INV.NUM
      LINED = HDR
      GOSUB WRITE.LINE
      HDR = "LN":TAB:"Airbills":TAB:"Shp Date":TAB:"Inv Amt":TAB:"Amt Pd":TAB:"Cut Back/Prc Date":TAB:"Ck Date":TAB:"Check #":TAB:"Carrier"
      LINED = HDR
      GOSUB WRITE.LINE

      RETURN
   END
