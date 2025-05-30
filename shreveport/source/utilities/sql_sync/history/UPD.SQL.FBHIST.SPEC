****************************************
* Program name : UPD.SQL.FBHIST.SPEC
* Author       : Greg Bino
* Date written : May 31, 2018
* Library      : FBBP
* COPYRIGHT (C) 2016 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
*
* This program sends fb.bills.hist data to sql server from list of pro numbers
* * Last updated by afs (AFSLOGISTICS\gbino) at 11:06:45 on 05/16/2018
*
* Start modification history
* Mod nn  mm/dd/yy, init, req #, description

* End modification history
*
****************************************

$INCLUDE UNIVERSE.INCLUDE ODBC.H

      form = "T##########"
      dash = "----------"
      Expect = ""
      NULL=""
      TOT.NUM.BILLS=0

      CALL GET.USER(USER)
* Begin GRB01
      VIN1=""
      VIN1<1> = "UPD.SQL.FBHIST.SPEC"
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "S"
      CALL PROGTRACK(VIN1,VOUT1)
* End GRB01
      BEGIN CASE
         CASE USER='DAVID'
         CASE USER = "GBINO"
         CASE USER = "NMEDDAUGH" ; * NKH01
         CASE USER='SV.UVAUTO'
       
         CASE 1
            CRT "YOU ARE NOT AUTHORIZED TO USE THIS PROGRAM"
            STOP
      END CASE
     
      OPEN '','CLIENTS' TO F.CLIENT ELSE ABORT 201,'CLIENTS'
      OPEN '','FB.TABLES' TO F.TABLES ELSE ABORT 201,'FB.TABLES'
      READ LI.CODE.REC FROM F.TABLES,'LI.CODES' ELSE LI.CODE.REC=''
      CRT @(0,0):@(-1):@(0,3):'UPD.SQL.FBHIST.PX - Processing Pros...'

      CLIENT.EOF=0
      CLIENT.CNT=0
      CLIENT.PER=0
          
      GRB.ID = 'FBHIST.SPEC4.csv'
GRB.ID = 'Truckload2016.csv'
GRB.ID = 'rerun.csv'
DEBUG
     
      OPEN 'GRB' TO F.GRB ELSE ABORT 201,'GRB'
      READ DAT FROM F.GRB,GRB.ID ELSE STOP
       REC.CNT = DCOUNT(DAT,@AM)
       FOR I = 2 TO REC.CNT
       REC = DAT<I>
       CLIENT.ID = FIELD(REC,",",1)"R%5"
       CARRIER.ID = FIELD(REC,",",2)"R%5"
       PRO.NUM = FIELD(REC,",",3)
        BILL.ID = CARRIER.ID:"*":PRO.NUM:"*0"   
         CLIENT.CNT+=1
        GB = 0
         READ CLIENT.REC FROM F.CLIENT,CLIENT.ID THEN
            CRT @(0,5):@(-4):CLIENT.CNT'R#4':' - ':CLIENT.ID:' - ':CLIENT.REC<2>
            OPEN '','FB.BILLS.HIST,':CLIENT.ID TO F.BILL THEN

               EDI.FOUND=0
               VC.FOUND=0
               DIV.FOUND=0

               OPEN '','EDI.BILLS.HIST,':CLIENT.ID TO F.EDI THEN EDI.FOUND=1
               OPEN '','VEND.CUST,':CLIENT.ID TO F.VC THEN VC.FOUND=1
               OPEN '','DIVISION.CODE,':CLIENT.ID TO F.DIV THEN DIV.FOUND=1
                                
               NUM.BILLS=I
               TOT.NUM.BILLS=REC.CNT
               CRT @(0,10):@(-3):' #Bills - ':NUM.BILLS'R#12':' - ':TOT.NUM.BILLS'R#15'
               BILL.EOF=0
               BILL.CNT=0
               BILL.PER=0
              
                  BILL.CNT+=1
                                
                  READ BILL.REC FROM F.BILL,BILL.ID THEN
                     EDI.REC=''
                     IF EDI.FOUND THEN
                        READ EDI.REC FROM F.EDI,BILL.ID ELSE EDI.REC=''
                     END

                     CARRIER.ID=FIELD(BILL.ID,'*',1)
                     PRO=FIELD(BILL.ID,'*',2)
                     DIV.REC=''
                     IF DIV.FOUND THEN
                        DIV.ID=BILL.REC<9>
                        READ DIV.REC FROM F.DIV,DIV.ID ELSE DIV.REC=''
                     END
                     VC.REC=''
                     IF VC.FOUND THEN
                        VC.ID=BILL.REC<17>
                        READ VC.REC FROM F.VC,VC.ID ELSE VC.REC=''
                     END
                     SQLVIN=''
                     SQLVIN<1>=USER
                     SQLVIN<2>=CLIENT.ID
                     SQLVIN<3>=BILL.ID
                     SQLVIN<4>='111111'
                     
                     SQLVIN<5>=LI.CODE.REC<1>
                     SQLVIN<6>=LI.CODE.REC<3>
                     SQLVOUT=''
                           
                     CALL UPD.SQL.FBHIST.SUB2(SQLVIN,SQLVOUT,CLIENT.REC,DIV.REC,VC.REC,BILL.REC,EDI.REC)
                     IF MOD(BILL.CNT,10)=0 THEN
                        CRT @(0,22):@(-4):
                     END
                  END
  
               IF TOT.NUM.BILLS+0#0 THEN
                  CRT @(0,22):@(-3):
               END
            END
         END
     NEXT X

THE.END:***
*     End of program
* Begin GRB01
      VIN1=''
      VIN1<1> = "UPD.SQL.FBHIST.PX"
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "E"
      CALL PROGTRACK(VIN1,VOUT1)
* End GRB01
      STOP
