****************************************
* Program name : FB.PROC.REST
* Author       : Greg Bino
* Date written : March 14, 2019
* Library      : FBBP
* COPYRIGHT (c) : AFS, LLC 2019, All Rights Reserved.
*
* update image that bill has processed so it is visable in power grid
*
* Last updated by afs (AFSLOGISTICS\gbino) at 10:00:13 on 11/18/2019.
*
* Start modification history
* Mod nn  mm/dd/yy, init, req #, description
* 111819 - GRB01 - ACCU-XXX Add PRO NUM AND SEQ NUMBER TO CALL
* End modification history
*
*******************************************

      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'FB.PROC.REST' ; UPL.VOUT = ''
      CALL GET.USER.NEW(USER,CH.NUM)
      UPL.VIN<3> = USER
      UPL.VIN<4> = CH.NUM
      **     CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)
      **     CALL GET.SERVER.INFO(SVR.VIN,SVR.VOUT)
***      SVR.NAME=SVR.VOUT<1>
      BEGIN CASE
         CASE USER='DAVID'
         CASE USER = "GBINO"
         CASE USER = "NMEDDAUGH"         ; * NKH01
         CASE USER='SV.UVAUTO'
         CASE USER='UVTASKS'
         CASE 1
            CRT "YOU ARE NOT AUTHORIZED TO USE THIS PROGRAM"
            STOP
      END CASE

      VIN1=""
      VIN1<1> = "FB.PROC.REST"
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "S"
      **    CALL PROGTRACK(VIN1,VOUT1)
      OPEN "BILLS.CNT" TO F.CNT ELSE CALL OPEN.ABORT('BILLS.CNT', PROG.NAME)

      GET (ARG.,1) OBEG.DATE THEN
         BEG.DATE=ICONV(OBEG.DATE,'D')
      END ELSE
         BEG.DATE = DATE()
      END
      GET (ARG.,2) OEND.DATE THEN
         END.DATE=ICONV(OEND.DATE,'D')
      END ELSE
         END.DATE=DATE()
      END
   ****   CRT @(0,0):@(-1):@(0,3):'FB.PROC.REST - Processing Clients from ':BEG.DATE'D2/':' to ':END.DATE'D2/':'...'
      GOSUB OPEN.FILES

      GET (ARG.,3) CLIENT.LIST.NAME ELSE CLIENT.LIST.NAME=''
      GET (ARG.,4) OPT.LIST ELSE OPT.LIST=''
      GET (ARG.,5) START.TIME ELSE START.TIME=''
      IF START.TIME#'' THEN
         CRT "Waiting until ":START.TIME
         STMT="SLEEP ":START.TIME
         EXECUTE STMT CAPTURING TIME.RESULTS
      END


      STMT='GET-LIST UPDATE.BILLS'

      EXECUTE STMT RTNLIST CLIENT.LIST CAPTURING RESULTS
      NUM.CLIENTS=@SELECTED

      DIM BILL.REC(300),CLIENT.REC(350)
      MAT BILL.REC = '' ; MAT CLIENT.REC =''

      NULL=""
      TOT.NUM.BILLS=0
      ERROR.CNT=0
10:   ERRORS=''

*************************** CLIENT LOOP
      CLIENT.EOF=0
      CLIENT.CNT=0
      CLIENT.PER=0
      LOOP
         READNEXT ID FROM CLIENT.LIST ELSE CLIENT.EOF=1
      UNTIL CLIENT.EOF DO
         CLIENT.CNT+=1
         CLIENT.ID = FIELD(ID,"*",1)
         MATREAD CLIENT.REC FROM F.CNT,ID THEN
            CRT @(0,5):@(-4):CLIENT.CNT'R#4':' - ':CLIENT.ID

           
            IMAGE.NO = FIELD(ID,"*",2)
            OPEN '','FB.BILLS.HIST,':CLIENT.ID TO F.BILL THEN
               PRO.CNT = DCOUNT(CLIENT.REC(2),@VM)
               FOR I = 1 TO PRO.CNT
                  PRO.NO = CLIENT.REC(2)<1,I>
                  MATREAD BILL.REC FROM F.BILL,PRO.NO THEN
                     SEQ.NO = I
                     PRO = FIELD(PRO.NO,"*",2)
                     VERSION = FIELD(PRO.NO,"*",3)
                     IF VERSION GT "2" THEN CONTINUE
                     IF BILL.REC(39) = "P" THEN CONTINUE
                     IF BILL.REC(37) = "" THEN CONTINUE
                     
                     VIN=""
                     VIN<1> = IMAGE.NO
                     IF BILL.REC(39) = "R" THEN
                        VIN<2> = "REJECTED"
                     END ELSE
                        VIN<2> = "PROCESSED"
                     END
                     VIN<3> = PRO
                     VIN<4> = SEQ.NO
                     CALL SEND.IMG.PROC.REST(VIN,VOUT)
                  END
               NEXT I

            END
         END

      REPEAT
*****************************************************************
THE.END:***
****************************************************************

      IF ERRORS#'' THEN
         ERROR.CNT+=1
         IF ERROR.CNT>3 THEN
            MVIN=''
            MVIN<1>='UPD.SQL.Group@afs.net'
            MVIN<4>='AFS_UPD.SQL.FBHIST.SUB'
            MVIN<5>='SQL Client Update Errors'
            TEXT='On ':DATE()'D2/':' ':OCONV(TIME(),'MTHS'):', ':USER:' updated '
            TEXT<1,-1>='Client ':CLIENT.ID:', Bill ':ID:', but did not succeed in updating SQL due to:'
            TEXT<1,-1>=' '
            TEXT<1,-1>=ERRORS
            MVIN<6>=TEXT
            MVIN<7>=1
            CALL SENDMAIL(MVIN,MVOUT)
         END ELSE
            **    	WRITE ERRORS ON F.ERR,"SQL.FBHIST":TIMEDATE()

         END
      END

      VIN1=''
      VIN1<1> = "FB.PROC.REST"
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "E"
      **    CALL PROGTRACK(VIN1,VOUT1)

      STOP

******************************************************
OPEN.FILES:
********************************************************

      OPEN '','FB.TABLES' TO F.TABLES ELSE
         CALL OPEN.ABORT("FB.TABLES",PROG.NAME)
      END

      OPEN '','CLIENTS' TO F.CLIENT ELSE ABORT 201,'CLIENTS'

      OPEN '','ERRORS.LOG' TO F.ERR ELSE ABORT 201,'ERRORS.LOG'


      RETURN
   END
