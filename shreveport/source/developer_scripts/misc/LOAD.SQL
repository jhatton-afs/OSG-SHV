****************************************
* Program name : LOAD.SQL
* Author       : UNKNOWN
* Date written : Jan 28, 2016
* Library      : FBBP
* COPYRIGHT (C) 1998 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
*
* This program clears out files used to send emails
* Last updated by afs (gbino) at 08:20:39 on 03/29/2016.
*
* Start modification history
* Mod nn  mm/dd/yy, init, req #, description
* End modification history
*
****************************************
      COMMON PROGPARAMS(24)
      EQU PROGFROM TO PROGPARAMS(1)
      EQU USER TO PROGPARAMS(2)
      EQU PROCDATE TO PROGPARAMS(3)
      EQU CHNUM TO PROGPARAMS(4)
      CALL GET.USER(USER)
      OPEN '','SQL.LOAD' TO F.SQL.LOAD ELSE ABORT 201,'SQL.LOAD'
****      START.TIME=ICONV('05:00','MTH')
      START.TIME = TIME() - 100
      END.TIME=ICONV('19:15','MTH')
****      BEG.DATE=ICONV('05/31/13','D')
      BEG.DATE = DATE()-1
      TODAY=DATE()
****IF USER = "GBINO" THEN DEBUG
      READ SQL.PROC.REC FROM F.SQL.LOAD,'SQL_PROCESS' THEN
         IF TODAY LE SQL.PROC.REC<2> THEN
            EXECUTE "BBSEND GREGB LOAD.SQL STARTED TWICE."
            STOP
         END
      END ELSE
         SQL.PROC.REC=''
      END
      SQL.PROC.REC<1>=USER
      SQL.PROC.REC<2>=TODAY
      SQL.PROC.REC<3>=TIME()
      WRITE SQL.PROC.REC ON F.SQL.LOAD,'SQL_PROCESS'
      LOOP
         VIN=''
         VOUT=''
         STATUS=''
         OBEG.DATE=OCONV(BEG.DATE,'D2/')
         CALL NEXT.BUSINESS.DAY(OBEG.DATE,NEXT.BUS.DATE,STATUS,VIN,VOUT)
      UNTIL VOUT<1> > TODAY DO
         IF STATUS#'SUCCESS' THEN
            STATUS.STMT='BBSEND GREGB LOAD.SQL FAILURE DUE TO ':STATUS
            EXECUTE STATUS.STMT
            STOP
         END
         INEXT.BUS.DATE=VOUT<1>
CHECK.TIME:
         IF USER = "GBINO" THEN DEBUG
         BUS.TIME=0
         CURRENT.TIME=TIME()
         IF CURRENT.TIME>START.TIME AND CURRENT.TIME<END.TIME THEN BUS.TIME=1
         DOW=OCONV(DATE(),'DW')
         IF DOW=6 THEN BUS.TIME=0
         IF DOW=7 THEN BUS.TIME=0
         IF BUS.TIME THEN
            CRT TIMEDATE():" SLEEPING UNTIL 7:15 PM"
            STMT='SLEEP 19:15'
            EXECUTE STMT CAPTURING RESULTS
            GO CHECK.TIME
         END
         READ TEST FROM F.SQL.LOAD,INEXT.BUS.DATE ELSE
            TODAY = OCONV(DATE(),'DOW')
            IF TODAY = 1 THEN            ; * monday
               BEGIN.DATE = DATE() - 2   ; * saturday
               END.DATE = DATE() - 1     ; * sunday
               CMD = 'SELECT CLIENTS WITH LAST.PROC GE "' : BEGIN.DATE : '" AND WITH LAST.PROC LE "' : END.DATE : '"'
               EXECUTE CMD CAPTURING STUFF RETURNING JUNK
               IF JUNK GT 0 THEN     ; * clients processed over weekend
                  BEG.DATE = OCONV(DATE() - 2,'D4-')
                  NEXT.BUS.DATE = OCONV(DATE(),'D4-')
                  SQL.STMT='UPD.SQL.DAILY ':BEG.DATE:' ':NEXT.BUS.DATE
               END ELSE
                  SQL.STMT='UPD.SQL.DAILY ':NEXT.BUS.DATE:' ':NEXT.BUS.DATE
               END
            END ELSE
               SQL.STMT='UPD.SQL.DAILY ':NEXT.BUS.DATE:' ':NEXT.BUS.DATE
            END
            CRT SQL.STMT
            EXECUTE SQL.STMT
            CRT @(0,20):'Sleeping...zzz...zzz...':
            EXECUTE "SLEEP 3"
            CRT @(0,20):@(-4):
         END
         BEG.DATE=INEXT.BUS.DATE
      REPEAT
      DELETE F.SQL.LOAD,'SQL_PROCESS'
*     EXECUTE "UPD.ORB.SL"
*     EXECUTE "BBSEND MIKE UPD.ORB.SL HAS FINISHED"
*     EXECUTE "UPD.ARVW.SL"
*     EXECUTE "BBSEND MIKE UPD.ARVW.SL HAS FINISHED"
      CHAIN "OFF"
      STOP
*      FOR YEAR=2005 TO 2008
*         FOR MONTH=1 TO 12
*            IF YEAR='2008' AND MONTH>OCONV(DATE(),'DM') THEN GO SKIP.MONTH
*            FDAY=ICONV(MONTH:'/01/':YEAR,'D')
*            IF MONTH=12 THEN
*               LDAY=ICONV('01/01/':YEAR+1,'D')-1
*            END ELSE
*               LDAY=ICONV(MONTH+1:'/01/':YEAR,'D')-1
*            END
*            PARM1=FDAY'D2/'
*            PARM2=LDAY'D2/'
*            PARM3='CLIENTFBHIST'
*            SQL.FBPROC.ID='SQL.FBPROC*':YEAR:'*':FDAY:'*':LDAY
*            READ SQL.FBPROC.REC FROM F.SQL.LOAD,SQL.FBPROC.ID ELSE
*               STMT='UPD.SQL.FBPROC.PX ':PARM1:' ':PARM2:' ':PARM3
*               CRT TIMEDATE():' ':STMT
*               EXECUTE STMT CAPTURING RESULTS
*               SQL.FBPROC.REC=RESULTS
*               WRITE SQL.FBPROC.REC ON F.SQL.LOAD,SQL.FBPROC.ID
*            END
*
*            SQL.FBHIST.ID='SQL.FBHIST*':YEAR:'*':FDAY:'*':LDAY
*            READ SQL.FBHIST.REC FROM F.SQL.LOAD,SQL.FBHIST.ID ELSE
*               STMT='UPD.SQL.FBHIST.PX ':PARM1:' ':PARM2:' ':PARM3
*               CRT TIMEDATE():' ':STMT
*               EXECUTE STMT CAPTURING RESULTS
*               SQL.FBHIST.REC=RESULTS
*               WRITE SQL.FBHIST.REC ON F.SQL.LOAD,SQL.FBHIST.ID
*            END
*
*            SQL.FBPYMT.ID='SQL.FBPYMT*':YEAR:'*':FDAY:'*':LDAY
*            READ SQL.FBPYMT.REC FROM F.SQL.LOAD,SQL.FBPYMT.ID ELSE
*               STMT='UPD.SQL.FBPYMT.PX ':PARM1:' ':PARM2
*               CRT TIMEDATE():' ':STMT
*               EXECUTE STMT CAPTURING RESULTS
*               SQL.FBPYMT.REC=RESULTS
*               WRITE SQL.FBPYMT.REC ON F.SQL.LOAD,SQL.FBPYMT.ID
*            END
*
*            SQL.FBDUP.ID='SQL.FBDUP*':YEAR:'*':FDAY:'*':LDAY
*            READ SQL.FBDUP.REC FROM F.SQL.LOAD,SQL.FBDUP.ID ELSE
*               STMT='UPD.SQL.FBDUP.PX ':PARM1:' ':PARM2
*               CRT TIMEDATE():' ':STMT
*               EXECUTE STMT CAPTURING RESULTS
*               SQL.FBDUP.REC=RESULTS
*               WRITE SQL.FBDUP.REC ON F.SQL.LOAD,SQL.FBDUP.ID
*            END
*SKIP.MONTH: *
*         NEXT MONTH
*      NEXT YEAR
      CRT TIMEDATE():' COMPLETED.'
   END
