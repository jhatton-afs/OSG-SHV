*PRINT @(-1):"Now sleeping for 1hr"
*EXECUTE 'SLEEP 3600'
      CALL CHANNEL(CH.NUM)
      OPEN 'CLIENTS' TO F.CLIENTS ELSE ABORT
      OPEN 'AFS.SL' TO F.SL ELSE ABORT
      OPEN 'BILLDATA.MKERBOW' TO F.BILLDATA ELSE ABORT
      CHANGE.LIST=''
*
* SELECT CLIENT FILE
*
      TEXT='Selecting Clients...'
      CALL CENTER(TEXT,80)
      CRT @(0,10):TEXT
*
      CLIENT.STMT='SSELECT CLIENTS WITH @ID # "99]" AND WITH STATUS # "I"'
      PRINT CLIENT.STMT
******************************************************************
* Select of First List
******************************************************************
      EXECUTE CLIENT.STMT RTNLIST CLIENT.LIST CAPTURING CLIENT.RESULTS
      CLIENT.NITM = @SELECTED
      IF NOT( @SELECTED ) THEN
         CALL ELINE('ERROR - No clients on file.')
         STOP
      END
      CLIENT.CNT=0
      CLIENT.PER=0
      CLIENT.EOF=0
      LOOP
         READNEXT CLIENT.ID FROM CLIENT.LIST ELSE CLIENT.EOF=1
      UNTIL CLIENT.EOF DO
         CLIENT.CNT+=1
*        IF CLIENT.ID='10356' THEN GO SKIP.CLIENT
         IF CLIENT.ID='FB.BILLS.HIST' OR CLIENT.ID[1,2]='99' THEN GO SKIP.CLIENT
         READ CLIENT.REC FROM F.CLIENTS,CLIENT.ID ELSE CLIENT.REC=''
         CLIENT.NAME=CLIENT.REC<2>
         IF CLIENT.NAME='' THEN
            CLIENT.NAME='*** Not On File ***'
         END
         ORB.SL.ID='ARVW.':CLIENT.ID
         CRT @(0,17):CLIENT.ID:" ":CLIENT.NAME:" - Now selecting freight bills":@(-4):
         CALL PROG.BAR(20,CLIENT.CNT,CLIENT.NITM,CLIENT.PER)
         OPEN '','FB.BILLS.HIST,':CLIENT.ID TO F.BILLS.HIST THEN
            ORG.ORB.LIST=''
            CUR.ORB.LIST=''
            READ ORG.ORB.LIST FROM F.SL,ORB.SL.ID ELSE ORG.ORB.LIST=''
            ORG.NATT=DCOUNT(ORG.ORB.LIST,@AM)
            EXECUTE 'DELETE-LIST ':ORB.SL.ID CAPTURING RESULTS
            BILL.STMT='SELECT FB.BILLS.HIST,':CLIENT.ID
            BILL.STMT:=' AND WITH 66 EQ "A"'
            BILL.STMT:=' AND WITH 39 EQ "R"'
            EXECUTE BILL.STMT RTNLIST BILL.LIST CAPTURING BILL.RESULTS
            BILL.NITM = @SELECTED
            IF BILL.NITM>0 THEN
               CRT @(0,17):CLIENT.ID:" ":CLIENT.NAME:" - Now processing ":BILL.NITM:" Freight Bills...":@(-4):
               ORB.LIST.STMT='SAVE-LIST ':ORB.SL.ID
               EXECUTE ORB.LIST.STMT PASSLIST BILL.LIST CAPTURING ORB.LIST.RESULTS
               READ CUR.ORB.LIST FROM F.SL,ORB.SL.ID ELSE CUR.ORB.LIST=''
               CUR.NATT=DCOUNT(CUR.ORB.LIST,@AM)
               IF CUR.ORB.LIST#'' OR ORG.ORB.LIST#'' THEN
                  IF ORG.ORB.LIST#CUR.ORB.LIST THEN
                     CHG.VAL=DCOUNT(CHANGE.LIST<1>,@VM)+1
                     CHANGE.LIST<1,CHG.VAL>=CLIENT.ID:' ':CLIENT.NAME
                     CHANGE.LIST<2,CHG.VAL>=ORG.NATT
                     CHANGE.LIST<3,CHG.VAL>=CUR.NATT
                  END
               END
            END
         END
SKIP.CLIENT:***
      REPEAT
      WRITE CHANGE.LIST ON F.BILLDATA,'ARVW.CHANGE.LIST'
   END
