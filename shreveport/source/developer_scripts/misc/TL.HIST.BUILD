* PROGRAM: TL.HIST REPORT
*
*  THIS PROGRAM IS A PROPRIETARY PRODUCT OF AUTOMATED FREIGHT SYSTEMS.
*
* FREIGHT BILLING
*
*  AUTHOR       : Tami Seago
*  DATE CREATED : 06/15/99
*  DESCRIPTION  : Download TL Hist file for use in a spreadsheet for a given client
*
**********************************************************************************
$INCLUDE PROG.ADMIN INC_OPTIONS

**********************************************************************************
* Initialize variables.
**********************************************************************************
    CALL CHANNEL(CH.NUM)
    PROMPT''
    PROG.NAME='Truckload History Download'
    PROG.DESC="Download Truckload History"
    PACK.NAME="Freight Billing"
    CALL AFS.SCR.HEAD(CO.ID, FILE.ID, '', PROG.NAME, PROG.DESC, PACK.NAME, CO.NAME, TIME.DATE, 1)
     UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'TL.HIST.BUILD' ; UPL.VOUT = ''                    ;* NPR_UPL 04/23/2010
     CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010

    OPEN '','CARRIERS' TO F.CARRIERS ELSE
      CALL OPEN.ABORT("CARRIERS",PROG.NAME)
    END
    OPEN '','ZIPS.CODES' TO F.ZIPS ELSE CALL OPEN.ABORT('ZIPS.CODES',PROG.NAME)
    OPEN '','CLIENTS' TO F.CLIENTS ELSE
      CALL OPEN.ABORT("CLIENTS",PROG.NAME)
    END
    OPEN '','FB.TABLES' TO F.TABLES ELSE
      CALL OPEN.ABORT("FB.TABLES",PROG.NAME)
    END

    BILLDATA.REC = ''
    OPEN '','VOC' TO F.VOC ELSE
      GOSUB CALL.NET.ADMIN
      CALL ELINE('UNABLE TO OPEN VOC FILE')
      STOP
    END
    CALL GET.USER(USER)
    OPEN '','TL.HIST' TO F.TL.HIST ELSE
      CALL ELINE('TL.HIST file missing')
      STOP
    END

    READ BILLDATA.REC FROM F.VOC,"BILLDATA" ELSE
      GOSUB CALL.NET.ADMIN
      CALL ELINE('UNABLE TO OPEN "VOC BILLDATA"')
      STOP
    END

    BILLDATA.REC<2>:='\':USER
    WRITE BILLDATA.REC ON F.VOC,"BILLDATA.":USER ELSE
       GOSUB CALL.NET.ADMIN
       CALL ELINE("YOUR USER NAME '":USER:"' IS NOT IN THE BILLDATA FOLDER - PLEASE SEE OWEN/TAMI/DAVID")
       STOP
    END
    OPEN '','BILLDATA.':USER TO BILLDATA ELSE
       GOSUB CALL.NET.ADMIN
       CALL ELINE('UNABLE TO OPEN "BILLDATA.":USER')
       STOP
    END
    TAB=CHAR(9)

    BEG.DATE=''
    END.DATE=''


*****************************************************************************
* Enter Client Number
*****************************************************************************
ENTER.CLIENT.ID:
     CRT @(0,2):@(-3)
     HELP='Enter the client number - Name for Search - [EX]it'
     CALL GEN.IN(0,3,'Enter Client : #####','',Q,0,20,'','',0,-5,3,0,QI,HELP,0,23)
     QI=OCONV(QI,'MCU')
     CALL GET.USER(USER)
     BEGIN CASE
       CASE QI=''
         STOP
       CASE QI='EX' OR QI='X'
         STOP
       CASE NUM(QI)
         Q=QI'R%5'
       CASE 1
         CALL SOUNDEX.DISPLAY(QI,'BCUST','SDX.CLIENTS,NAME','2,1,3,4',ITEM.LIST)
         CALL AFS.SCR.REFRESH(PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)
         IF ITEM.LIST='' ! DCOUNT(ITEM.LIST<1>,@VM) > 1 THEN GOTO ENTER.CLIENT.ID
         IF NOT(NUM(ITEM.LIST<1,1>))THEN GOTO ENTER.CLIENT.ID
         Q=ITEM.LIST<1,1>'R%5'
     END CASE
     CLIENT.ID=Q'R%5'
     READ CLIENT.REC FROM F.CLIENTS,CLIENT.ID ELSE
       CALL ELINE('ERROR - Client ':CLIENT.ID:' not on file.')
       GOTO ENTER.CLIENT.ID
     END
     CLIENT.NAME=CLIENT.REC<2>

     CRT @(0,3):'Enter Client : ':CLIENT.ID'R%5':
     CRT ' ':CLIENT.NAME:@(-4):

******************************************************************************
* Enter beginning date.
******************************************************************************
ENTER.BEGIN.DATE:***
      HELP="Enter beginning date. nn=Day. nn/nn=Month & Day. X=Back to file. EX=Exit."
      IF BEG.DATE='' THEN BEG.DATE=DATE()
      LN='Enter the Beginning date  : ':BEG.DATE'D2/'
      CALL GEN.IN(0,5,LN,'DATE',Q,0,8,'','',0,-8,5,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='X'
            CRT @(0,5):@(-3):
            GO ENTER.CLIENT.ID
         CASE QI='EX'
            STOP
      END CASE
      BEG.DATE=Q
      CRT @(28,5):BEG.DATE'D2/'
******************************************************************************
* Enter ending date.
******************************************************************************
ENTER.END.DATE:***
      HELP="Enter ending date. nn=Day. nn/nn=Month & Day. X=Back to Beg Date. EX=Exit."
      IF END.DATE='' THEN END.DATE=DATE()
      LN='Enter the Ending Date     : ':END.DATE'D2/'
      CALL GEN.IN(0,7,LN,'DATE',Q,0,9,'','',0,-8,7,0,QI,HELP,0,23)
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='X'
            CRT @(0,7):@(-3):
            GOTO ENTER.BEGIN.DATE
         CASE QI='EX'
            STOP
      END CASE                  
      END.DATE=Q
      IF BEG.DATE GT END.DATE THEN
         CALL ELINE('Beginning date cannot exceed ending date.')
         GOTO ENTER.END.DATE
      END
      DAYS=END.DATE-BEG.DATE+1
      CRT @(28,7):END.DATE'D2/'



**********************************************************************************
* Verify selection criteria is correct.
**********************************************************************************
VERIFY.SELECTION:***
    HELP="X or EX=Exit. RETURN=Continue."
    CALL GEN.IN(0,22,'Enter selection please. --','',Q,0,2,'','',0,-2,22,1,QI,HELP,0,23)
    QI=OCONV(QI,'MCU')
    BEGIN CASE
      CASE QI='EX' 
        STOP
      CASE QI='X'
        GOTO ENTER.CLIENT.ID       
      CASE QI=''
        NULL
      CASE 1
        CALL ELINE('Invalid entry. Must be X, EX, or RETURN.')
        GO VERIFY.SELECTION
    END CASE

  
*********************************************************************************
* Starts process clients with vendor/customer files
**********************************************************************************
*
* SELECT CLIENT FILE
* 
    TEXT='Selecting Truckload History Records.'
    CALL CENTER(TEXT,80)
    CRT @(0,16):TEXT
    DONE=0
    LINE=''
    DARRAY=''
    DARRAY<-1> = 'Carrier #':@VM:'Carrier Name':@VM:'Origin Zip':@VM:'Origin City':@VM:'Origin St':@VM:'Destin Zip':@VM:'Destin City':@VM:'Destin St':@VM:'Ship Date':@VM:'Weight':@VM:'Miles':@VM:'Actual Charge':@VM:'I/O'

    STMT='SSELECT TL.HIST WITH 1 = ':CLIENT.ID
    STMT:=' WITH 3 GE ':BEG.DATE:' AND 3 LE ':END.DATE
    EXECUTE STMT PASSLIST RTNLIST TLH.LIST CAPTURING OUTPUT
    LOOP
       READNEXT TLH.ID FROM TLH.LIST ELSE DONE = 1      
    UNTIL DONE DO
       LINE=''
       READ TLH.REC FROM F.TL.HIST,TLH.ID ELSE TLH.REC = ''
       ORIGIN.ZIP = FIELD(TLH.ID,'*',1)
       READ ZIP.REC FROM F.ZIPS,ORIGIN.ZIP THEN
         ORIGIN.CITY = ZIP.REC<1>
         ORIGIN.ST = ZIP.REC<2>
       END
       DEST.ZIP = FIELD(TLH.ID,'*',2)
       READ ZIP.REC FROM F.ZIPS,DEST.ZIP THEN
         DEST.CITY = ZIP.REC<1>
         DEST.ST = ZIP.REC<2>
       END
       CLIENTS = TLH.REC<1>
       NUM.SHIPS = DCOUNT(CLIENTS,@VM)
       FOR X = 1 TO NUM.SHIPS
         A.CLIENT = TLH.REC<1,X>
         SHIP.DATE = TLH.REC<3,X>
         IF A.CLIENT = CLIENT.ID THEN
           IF SHIP.DATE GE BEG.DATE AND SHIP.DATE LE END.DATE THEN
             CARRIER = TLH.REC<2,X>
             READV CARRIER.NAME FROM F.CARRIERS,CARRIER,1 ELSE CARRIER.NAME = ''
             BILL.DATE = TLH.REC<3,X>'D2/'
             WEIGHT = TLH.REC<4,X>
             MILES = TLH.REC<5,X>
             ACTUAL.CHARGE = TLH.REC<6,X>'R26#8'
             IOT = TLH.REC<7,X>'L#4'
             CRT @(0,22):CARRIER
             LINE<1>=CARRIER:@VM:CARRIER.NAME:@VM:ORIGIN.ZIP:@VM:ORIGIN.CITY:@VM:ORIGIN.ST:@VM
             LINE<1>:=DEST.ZIP:@VM:DEST.CITY:@VM:DEST.ST:@VM:BILL.DATE:@VM:WEIGHT:@VM:MILES:@VM:ACTUAL.CHARGE:@VM:IOT
             DARRAY<-1> = LINE<1>
           END
         END
       NEXT
     REPEAT

      RECORD.NAME = CLIENT.ID'R%5'
      RECORD.NAME:= '-TL-'
      D=BEG.DATE'D2/'
      RECORD.NAME:=D[1,2]:D[4,2]
      D=END.DATE'D2/'
      RECORD.NAME:=D[1,2]:D[4,2]      
      RECORD.NAME:='.XLS'
      DARRAY=CHANGE(DARRAY,@VM,TAB)
      WRITE DARRAY ON BILLDATA,RECORD.NAME
RETURN  

       


*
* CRITICAL ERROR HANDLER - GENERIC ROUTINE (TERMINATES PROGRAM)
*
CALL.NET.ADMIN:***
      CALL ELINE("CALL NETWORK ADMINISTRATOR!")
      CALL ELINE("CALL NETWORK ADMINISTRATOR!!!!!")
RETURN
*

