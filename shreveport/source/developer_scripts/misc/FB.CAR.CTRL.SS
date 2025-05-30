********************************************************************************
*  Program : FB.CAR.CTRL.SS
*  Author  : N.C.G. Pratt
*  Date    : December 2009
********************************************************************************
*
*      COPYRIGHT (C) 2002 by AFS LOGISTICS, LLC. - ALL RIGHTS RESERVED
*
*  This program is the sole property of AFS Logistics, LLC (AUTOMATED FREIGHT
*  SYSTEMS) and may not be used, copied, or modified without the express
*  written consent of Brian Barker of AFS Logistics, LLC.
********************************************************************************


* Initialize general program variables

      PROMPT''

      CALL GET.USER(USER)
      PROG.NAME='FB.CAR.CTRL.SS'
      PROG.DESC='Carrier Control Spreadsheet'
      PACK.NAME='USER : ':USER
      CO.NAME='AFS Logistics, LLC'
       UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'FB.CAR.CTRL.SS' ; UPL.VOUT = ''                    ;* NPR_UPL 04/23/2010
       CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010
      EDIT.MASK.CHAR='-'

* Open files

      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         CALL OPEN.ABORT('CLIENTS',PROG.NAME)
      END
      OPEN '','CARRIERS' TO F.CARRIERS ELSE
         CALL OPEN.ABORT('CARRIERS',PROG.NAME)
      END
      OPEN '','FB.CAR.CTRL' TO F.CONTROL ELSE
         CALL OPEN.ABORT('FB.CAR.CTRL',PROG.NAME)
      END

      OPEN '','BILLDATA.':USER TO F.BILLDATA ELSE
         CALL OPEN.ABORT('FB.CAR.CTRL',PROG.NAME)
      END

* Display initial screen
      
     CALL AFS.SCR.REFRESH(PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)

* Restrict access

      BEGIN CASE
         CASE USER='OWEN'
         CASE USER='DAVID'
         CASE USER='MYRA'
         CASE USER='MARY'
         CASE USER='NPRATT'
         CASE USER='MKERBOW'
         CASE 1
            CALL FB.PRINT.CENT(1,80,12,'! Restricted Access Application !')
            CALL FB.PRINT.CENT(1,80,14,'Access Denied')
            CALL ELINE('')
            STOP
      END CASE

*

HLINE = "Client"
HLINE<1,-1> = "Client Name"
HLINE<1,-1> = "Client Status"
HLINE<1,-1> = "Carrier"
HLINE<1,-1> = "Carrier Name"
HLINE<1,-1> = "I/E"
HLINE<1,-1> = "Start Date"
HLINE<1,-1> = "End Date"
HLINE<1,-1> = "Last Updated By"
HLINE<1,-1> = "Last Updated On"
HLINE<1,-1> = "Last Updated At"
HLINE<1,-1> = "NOTES"

XLS.REC = HLINE

W.STMT = \SSELECT FB.CAR.CTRL\
EXECUTE W.STMT CAPTURING OUTPUT

EOF = "N"
CRT @(-1)

LOOP
   READNEXT ID.CAR.CTRL ELSE EOF = "Y"
UNTIL EOF = "Y" DO

   READ CTRL.REC FROM F.CONTROL, ID.CAR.CTRL ELSE CTRL.REC = ''

   READ CLIENT.REC FROM F.CLIENTS, ID.CAR.CTRL ELSE CLIENT.REC = ""
   CLIENT.NAME = CLIENT.REC<2>
   CLIENT.STATUS = CLIENT.REC<30>

   N.CARS = DCOUNT(CTRL.REC<2>,@VM)
   FOR IC = 1 TO N.CARS
      ID.CARRIER = CTRL.REC<2,IC>
      READ CARR.REC FROM F.CARRIERS, ID.CARRIER ELSE CARR.REC = ''

      XLINE = ID.CAR.CTRL
      XLINE<1,-1> = CLIENT.NAME :" "
      XLINE<1,-1> = CLIENT.STATUS :" "
      XLINE<1,-1> = ID.CARRIER :" "
      XLINE<1,-1> = CARR.REC<1>
      XLINE<1,-1> = CTRL.REC<1> :" "

      XLINE<1,-1> = OCONV(CTRL.REC<3,IC>,"D2/") :" "
      XLINE<1,-1> = OCONV(CTRL.REC<4,IC>,"D2/") :" "
      XLINE<1,-1> = CTRL.REC<5> :" "
      XLINE<1,-1> = OCONV(CTRL.REC<6>,"D2/") :" "

      XLINE<1,-1> = OCONV(CTRL.REC<7>,"MTS") :" "

      NOTES = CTRL.REC<11,IC>
      CONVERT @SVM TO " " IN NOTES

      XLINE<1,-1> = NOTES
      XLS.REC<-1> = XLINE
   NEXT IC
REPEAT

CONVERT @VM TO CHAR(9) IN XLS.REC

DATEX = OCONV(DATE(),"D2/")
CONVERT "/" TO "" IN DATEX

ID.XLS = "CARRIER_CTRL_":DATEX:".XLS"
WRITE XLS.REC ON F.BILLDATA, ID.XLS

CALL ELINE("File ":ID.XLS:" Created on your U: drive")
*
STOP
