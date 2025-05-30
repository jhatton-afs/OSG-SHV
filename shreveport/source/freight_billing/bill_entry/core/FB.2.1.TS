*******************************************************
* Program name : FB.2.1.TS
* Author       : BRIAN M. QUEEN
* Date written : DECEMBER 5, 1990
* Library      : EDIBP
* COPYRIGHT (C) 2016 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
* FREIGHT BILL ENTRY SCREEN 
*
* Last updated by afs (AFSLOGISTICS\nmeddaugh) at 09:22:51 on 03/26/2019.
*
* Start modification history
*---- Last updated by AFS.SOURCE (steve) at 07:55:26 on 09/21/1994.
* added NOT.PROCESSED boolean to prevent double billing via CHANGE
* Last updated by AFS.SOURCE (valerie) at 14:19:48 on 07/13/94
* ADDED MORE INSERTS, ACTUAL CHARGES TO OVERCHARGE MESSAGE, AND
* ABILITY TO ENTER A ROUTE OF ZIP CODES INSTEAD OF JUST ORIGIN AND
* DESTINATION.
* Last updated by AFS (valerie) at 11:25:16 on 06/02/1994.
* ADDED A WRITE TO DELETED.BILLS TO CAPTURE DISAPPEARING BILLS.
* Last updated by AFS.SOURCE (valerie) at 09:52:55 on 05/26/1994.
* ADDED NEW INSERT FOR DIVISION CODES.

* 051614 - DRF01 - SysAid 9828 - Make sure client number starts with 99
* 091009 - JMK04 - T091133 - Unable to key bills in a traffic survey
* 030309 - NPR01 - T090253 - Highlight Client name based on ranking
* 070307 - JCW04 - UPDATE CORE CARRIER FLAG IN BILL RECORDS
* 032907 - JCW03 - UPDATE VEND.CUST.XREF AND VEND.CUST.ZIPS FILES
* 012507 - JCW02 - USE VEND.CUST.NAMES FILE
* 090806 - JCW01 - USE NEW FB.CHECKS FILES
* 033105 - JMK03 - ADD CLIENT AND CARRIER FOR ARTCO BELL AND CRETE
* 040804 - JMK02 - ADD CC DURATION TIME FOR EMP PERF
* 012403 - JMK01 - CHECK CARRIER STATUS FLAG FOR LOOKUP
* 030309 - NPR01 - T090253 - Highlight Client name based on ranking
* 111610 - NPR02 - T999999 - Bring updating of Stops in Transit in line with normal FB Entry
* 032619 - NKH01 - ACCU-316 Modified CREATE-FILE file sizes
* End modification history
*
*******************************************************
      $INCLUDE PROG.ADMIN INC_OPTIONS
      $INCLUDE FILE.DEFS INC_DIVISION.CODES
      $INCLUDE FILE.DEFS INC_FB.CHECKS
      $INCLUDE FILE.DEFS INC_CLIENTS

*---- Initialize variables

*
* 1 = Verify zip codes with MiddleWest 500
*     zips on file (MWB.500.ZIPS)
*
      EQU USE.MWB.500.ZIPS TO 0

*
* Setup Data mapping/moving for Traffic Survey from Real data
*
* NOTE: I did not use the '-1' to assure "visual" propper mapping...
*
      ALT.CLIENTS=''
      ALT.CLIENTS<1,1>='99932' ; ALT.CLIENTS<2,1>='00850'
      ALT.CLIENTS<1,2>='99914' ; ALT.CLIENTS<2,2>='00816'
      ALT.CLIENTS<1,3>='99912' ; ALT.CLIENTS<2,3>='00664'
      ALT.CLIENTS<1,4>='99913' ; ALT.CLIENTS<2,4>='00664'
      ALT.CLIENTS<1,5>='99926' ; ALT.CLIENTS<2,5>='00664'
      ALT.CLIENTS<1,6>='99928' ; ALT.CLIENTS<2,6>='00664'
      ALT.CLIENTS<1,-1>='99907' ; ALT.CLIENTS<2,-1>='00816'
      ALT.CLIENTS<1,-1>='99003' ; ALT.CLIENTS<2,-1>='00853'
      ALT.CLIENTS<1,-1>='99004' ; ALT.CLIENTS<2,-1>='00853'
      ALT.CLIENTS<1,-1>='99066' ; ALT.CLIENTS<2,-1>='00910'


      SENT.TO.PCMILER=0
      TASKMAN=1                          ; * Use Task Manager for Prophesy Miles
      READ.WAD.FLAG=0
      OVERRIDE.MILEAGE='N'
      CARRIER.NAME = '' ; CARRIER.CITY = ''
*OH   CARRIER.STATE=''; APRVD.STR=''
      CARRIER.STATE=''
      OLD.CHECK.NUM=''
      OLD.CHECK.DATE=''

      PROMPT ''
      PROG.NAME = 'FB.2.1.TS'
      PROG.DESC = 'FREIGHT BILL ENTRY'
      PACK.NAME = 'FREIGHT BILLING'
      CALL CHANNEL(CH.NUM)
      UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'FB.2.1.TS' ; UPL.VOUT = ''                    ;* NPR_UPL 04/23/2010
      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010
*      USER = SYSTEM(19)
*      USER = OCONV(USER,'MCU')
      CALL GET.USER(USER)

      IF USER = "NPRATT" THEN USER = "XNPRATT"

      IF USER='MRICE' THEN
         IF DATE() GE 13105 AND DATE() LE 13109 ELSE STOP
      END
      CO.NAME = 'AFS Logistics, LLC'
      EXP.DIST = '' ; BAL.DUE = 0 ; CLIENT.ID = ''
      CLIENT.NAME = '' ; CARRIER.ID = ''
      BACK.FLAG = 0 ; CHANGE.FLAG = 0 ; VOIDED = 0
      F.DIV = ''
      NOT.PROCESSED = 0
      MAT DIV.REC = ''
      MAT CHECK.REC = ''
      MAT CLIENT.REC = ''

      HLA = '' ; HLB = ''             ;* NPR01

      GOSUB 8000

*---- Open general files
      OPEN 'EMP.HR.PERF' TO F.EMP.HR.PERF ELSE
         CALL OPEN.ABORT("EMP.HR.PERF",PROG.NAME)
      END
      OPEN 'EMP.DY.PERF' TO F.EMP.DY.PERF ELSE
         CALL OPEN.ABORT("EMP.DY.PERF",PROG.NAME)
      END

      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         CALL OPEN.ABORT("CLIENTS",PROG.NAME)
      END
      OPEN '','FB.MILEAGE' TO F.MILEAGE ELSE
         CALL OPEN.ABORT("FB.MILEAGE",PROG.NAME)
      END
      OPEN 'DICT','CLIENTS' TO F.DICT.CLIENTS ELSE
         CALL OPEN.ABORT("DICT CLIENTS",PROG.NAME)
      END
      OPEN '','CARRIERS' TO F.CARRIERS ELSE
         CALL OPEN.ABORT("CARRIERS",PROG.NAME)
      END
      OPEN 'DICT','CARRIERS' TO F.DICT ELSE
         CALL OPEN.ABORT("DICT CARRIERS",PROG.NAME)
      END
      OPEN '','FB.ADJUSTS' TO F.ADJUSTS ELSE
         CALL OPEN.ABORT("FB.ADJUSTS",PROG.NAME)
      END
*     OPEN '','FB.CHECKS' TO F.CHECKS ELSE          ; * JCW01
*        CALL OPEN.ABORT("FB.CHECKS",PROG.NAME)     ; * JCW01
*     END                                           ; * JCW01
      OPEN '','FB.CHECKS.HDR' TO F.CHECKS ELSE      ; * JCW01
         CALL OPEN.ABORT("FB.CHECKS.HDR",PROG.NAME)  ; * JCW01
      END                                           ; * JCW01
      OPEN '','FB.BILLS.CRX' TO F.CRX ELSE
         EXECUTE 'CREATE-FILE FB.BILLS.CRX 1 103' CAPTURING OUTPUT
         OPEN '','FB.BILLS.CRX' TO F.CRX ELSE
            CALL OPEN.ABORT("FB.BILLS.CRX",PROG.NAME)
         END
      END
*
*
      OPEN '','FB.INQUIRE' TO F.INQUIRE ELSE
         CALL OPEN.ABORT("FB.INQUIRE",PROG.NAME)
      END
      OPEN '','FB.MODS' TO F.MODS ELSE
         CALL OPEN.ABORT("FB.MODS",PROG.NAME)
      END
      OPEN '','FB.TABLES' TO F.TABLES ELSE
         CALL OPEN.ABORT("FB.TABLES",PROG.NAME)
      END
      READ LI.CODES FROM F.TABLES,'LI.CODES' ELSE
         CALL ELINE("Unable to Read Line Item Code Table")
         LI.CODES=''
      END
      READ TARIFF.REC FROM F.TABLES,'TARIFF.DATE.XREF' ELSE TARIFF.REC=''
      READ PROG.TARIFF.REC FROM F.TABLES,'TARIFFS' ELSE PROG.TARIFF.REC=''
      OPEN '','BR.OPEN.BILLS.1000.1' TO F.OPEN.BILLS ELSE
         CALL OPEN.ABORT("BR.OPEN.BILLS.1000.1",PROG.NAME)
      END
      OPEN '','FB.OPEN.BILLS' TO F.OPEN ELSE
         CALL OPEN.ABORT("FB.OPEN.BILLS",PROG.NAME)
      END
      OPEN '','FB.TRANSPORT' TO F.TRANSPORT ELSE
         CALL OPEN.ABORT("FB.TRANSPORT",PROG.NAME)
      END
      OPEN '', 'DELETED.BILLS' TO F.DEL.BILLS ELSE
         CALL OPEN.ABORT('DELETED.BILLS',PROG.NAME)
      END
      OPEN '','ZIPS.CODES' TO F.ZIPS ELSE
         CALL OPEN.ABORT('ZIPS.CODES',PROG.NAME)
      END

*---- Open mileage input and output files

      IF TASKMAN THEN
         OPEN '','PCIN' TO F.PCIN ELSE
            CALL OPEN.ABORT('PCIN',PROG.NAME)
         END
         OPEN '','PCOUT' TO F.PCOUT ELSE
            CALL OPEN.ABORT('PCOUT',PROG.NAME)
         END
      END ELSE
         OPEN '','INPUT' TO F.INPUT ELSE
            EXECUTE 'SET-FILE PROPHESY INPUT (S' CAPTURING OUTPUT
            OPEN '','INPUT' TO F.INPUT ELSE
               CALL OPEN.ABORT('INPUT',PROG.NAME)
            END
         END
         OPEN '','OUTPUT' TO F.OUTPUT ELSE
            EXECUTE 'SET-FILE PROPHESY OUTPUT (S' CAPTURING OUTPUT
            OPEN '','OUTPUT' TO F.OUTPUT ELSE
               CALL OPEN.ABORT('OUTPUT',PROG.NAME)
            END
         END
      END

      IF USE.MWB.500.ZIPS THEN
         OPEN '','MWB.500.ZIPS' TO F.MWB.ZIPS ELSE
            CALL OPEN.ABORT('MWB.500.ZIPS',PROG.NAME)
         END
      END

*----
* MAIN PROCESSING
*
      CHR.START.TIME=TIME()              ; * JMK02

*---- Enter client number

100:
      GOSUB 8100                         ; * Display screen
      SEQ.FLAG = 0
      HELP = "Enter the client number [X] = Exit [EX] = Exit"
      IF CLIENT.ID = '' THEN MASK = '#####' ELSE MASK = CLIENT.ID
      CALL GEN.IN(15,3,MASK,'',Q,0,20,'','',2,-5,3,1,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = 'EX' ! QI = 'X'
            STOP
         CASE QI = '' & CLIENT.ID = ''
            STOP
         CASE QI = ''
            Q = CLIENT.ID
         CASE NOT(QI MATCHES "0N")
            CALL SOUNDEX.DISPLAY(QI,'BCUST','SDX.CLIENTS,NAME',2,
            ITEM.LIST)
            CALL AFS.SCR.REFRESH(PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,
            TIME.DATE,1)
            BEGIN CASE
               CASE ITEM.LIST = ''
                  GOTO 100               ; * START OVER
               CASE DCOUNT(ITEM.LIST<1>,@VM) GT 1
                  GOTO 100
               CASE ITEM.LIST NE ''
                  IF NUM(ITEM.LIST<1,1>) THEN DATA ITEM.LIST<1,1>
                  GOTO 100
               CASE 1
                  GOTO 100               ; * START OVER
            END CASE
         CASE NUM(QI)
            Q = QI'R%5'
         CASE 1
            GOTO 100                     ; * START OVER
      END CASE
      IF Q[1,2]#'99' THEN    ; * DRF01
         CALL ELINE('Traffic Survey client numbers should alway start with 99')    ; * DRF01
         GOTO 100            ; * DRF01
      END                    ; * DRF01

*---- Get client name

      IF CLIENT.ID # Q THEN CLIENT.ID = Q'R%5'
      MATREAD CLIENT.REC FROM F.CLIENTS,CLIENT.ID ELSE
         CALL ELINE("ERROR - Client ":CLIENT.ID:" not on file.")
         GOTO 100                        ; * START OVER
      END
      CLIENT.NAME = CL.NAME
      CLIENT.ZIP=CLIENT.REC(6)
*     TARIFF.NAME=CL.TS.TARIFF           ; * JMK05
*     IF TARIFF.NAME='' THEN TARIFF.NAME='AFS500_9501'       ; * JMK05
      TARIFF.NAME='AFS500_9501'          ; * JMK03
      TARIFF.MASK="Enter the tariff or <S> to Select: ":TARIFF.NAME    ; * JMK03
      TVIN=''                            ; * JMK03
      TVOUT=''                           ; * JMK03
*
* Get Tariff to use
*
150:  HELP='Enter Tariff Name to use, S=Select, X=Back, EX=Exit.'      ; * JMK03
      CALL GEN.IN(0,22,TARIFF.MASK,'',Q,0,35,'','',1,35,22,0,QI,HELP,0,23)          ; * JMK03
      Q=OCONV(Q,'MCU')                   ; * JMK03
      BEGIN CASE                         ; * JMK03
         CASE Q = 'X'                    ; * JMK03
            GO 100                       ; * JMK03
         CASE Q = 'EX'                   ; * JMK03
            STOP                         ; * JMK03
         CASE Q = ''                     ; * JMK03
            IF TVOUT#'' THEN             ; * JMK03
               Q=TVOUT                   ; * JMK03
            END ELSE                     ; * JMK03
               Q=TARIFF.NAME             ; * JMK03
            END                          ; * JMK03
         CASE Q = 'S'                    ; * JMK03
            TVIN='' ; TVOUT=''           ; * JMK03
            CALL TARIFF.SELECT(TVIN,TVOUT,TARIFF.REC)        ; * JMK03
            CALL AFS.SCR.REFRESH(PROG.NAME,PROG.DESC,PACK.NAME,CO.NAME,TIME.DATE,1)        ; * JMK03
            CRT @(0,3):'Enter Client Number ':CLIENT.ID'R%5 ':CLIENT.NAME:@(-4):           ; * JMK03
            GOSUB 8100                   ; * JMK05
            BEGIN CASE                   ; * JMK03
               CASE TVOUT='X' ; GO 100   ; * JMK03
               CASE TVOUT='EX' ; STOP    ; * JMK03
               CASE 1                    ; * JMK03
                  Q=TVOUT                ; * JMK03
                  TARIFF.MASK="Enter the tariff or <S> to Select: ":Q  ; * JMK03
                  GO 150                 ; * JMK03
            END CASE                     ; * JMK03
         CASE 1                          ; * JMK03
            CALL ELINE(Q:' is an invalid answer.!')          ; * JMK03
            GO 150                       ; * JMK03
      END CASE                           ; * JMK03
      LOCATE Q IN TARIFF.REC<1> SETTING POS THEN
         TARIFF.ACT.NAME=TARIFF.REC<2,POS>
         TARIFF.EFF.DATE=TARIFF.REC<3,POS>
         TARIFF.DESC=TARIFF.REC<4,POS>
         TARIFF.FACTOR=TARIFF.REC<5,POS>
      END ELSE
         CALL ELINE(TARIFF.NAME:' missing from TARIFF.DATE.XREF')
         CALL ELINE("Unable to locate tariff ":Q:" in FB.TABLES TARIFF.DATE.XREF")
         GO 150
      END
      LOCATE TARIFF.ACT.NAME IN PROG.TARIFF.REC<1> SETTING POS THEN
         TARIFF.DRIVER=PROG.TARIFF.REC<3,POS>
      END ELSE
         CALL ELINE("Unable to locate tariff ":TARIFF.ACT.NAME:" in FB.TABLES TARIFFS")
         GO 150
      END
      TARIFF.NAME=Q                      ; * JMK03
      LOCATE TARIFF.NAME IN TARIFF.REC<1> SETTING POS THEN
         TARIFF.ACT.NAME=TARIFF.REC<2,POS>
         TARIFF.EFF.DATE=TARIFF.REC<3,POS>
         TARIFF.FACTOR=TARIFF.REC<5,POS>
      END ELSE
         CALL ELINE(TARIFF.NAME:' missing from TARIFF.DATE.XREF')
         CALL ELINE("Unable to locate tariff ":TARIFF.NAME:" in FB.TABLES TARIFF.DATE.XREF")
         STOP
      END
      LOCATE TARIFF.ACT.NAME IN PROG.TARIFF.REC<1> SETTING POS THEN
         TARIFF.DRIVER=PROG.TARIFF.REC<3,POS>
      END ELSE
         CALL ELINE("Unable to locate tariff ":TARIFF.ACT.NAME:" in FB.TABLES TARIFFS")
         STOP
      END
      FAK.POS=INDEX(CLIENT.NAME,'FAK',1)
      IF FAK.POS#0 AND FAK.POS<LEN(CLIENT.NAME)-8 THEN
         CALL ELINE('FAK Description Error!!! Call Programming')
         ABORT
      END
      IF FAK.POS#0 THEN
         CALL ELINE("Cannot Enter/Change Bills on FAK Clients ... Reprocess to Normal then Enter")
         GO 100
      END
      ZIP.LEN = CL.ZIP.FLAG
*     IF CL.ZIP.FLAG='C' THEN ZIP.LEN=6

      HIN = CLIENT.REC(240)  ; HOUT = ""                              ;* NPR01  Highlight based on ranking
      CALL CLIENT.HL(HIN,HOUT)   ; HLB = HOUT<1,1> ; HLA = HOUT<1,2>  ;* NPR01

      CRT @(15,3):CLIENT.ID:' ':HLB:CLIENT.NAME:HLA:@(-4):            ;* NPR01
      CRT @(59,3):'Override Mileage: ':OVERRIDE.MILEAGE:

*---- Open client files

      LOCATE CLIENT.ID IN ALT.CLIENTS<1> SETTING POS THEN
         ALT.CLIENT=ALT.CLIENTS<2,POS>
         OPEN '','FB.BILLS.HIST,':ALT.CLIENT TO F.ALT.HIST ELSE
            CALL ELINE("ERROR - Cannot open FB.BILLS.HIST,":ALT.CLIENT:" file")
            ABORT
         END
      END

*
*  OLD CODE - JIM - Please remove once working propperly...
*
*      IF CLIENT.ID='99932' THEN
*        OPEN '','FB.BILLS.HIST,00850' TO F.DARL.HIST ELSE
*          CALL ELINE("ERROR - Cannot open FB.BILLS.HIST,00850 file")
*          ABORT
*        END
*      END
*      IF CLIENT.ID='99914' THEN
*        OPEN '','FB.BILLS.HIST,00816' TO F.SAUL.HIST ELSE
*          CALL ELINE("ERROR - Cannot open FB.BILLS.HIST,00816 file")
*          ABORT
*        END
*      END
*      IF CLIENT.ID='99928' OR CLIENT.ID='99926' OR CLIENT.ID='99913' OR CLIENT.ID='99912' THEN
*        OPEN '','FB.BILLS.HIST,00664' TO F.LIB.HIST ELSE
*          CALL ELINE("ERROR - Cannot open FB.BILLS.HIST,00664 file")
*          ABORT
*        END
*      END
*
*  JIM END
*

      OPEN '','FB.BILLS,':CLIENT.ID TO F.BILLS ELSE
         CALL ELINE("ERROR - Cannot open FB.BILLS for client ":CLIENT.ID)
         GOTO 100                        ; * START OVER
      END
      OPEN '','FB.BILLS.HIST,':CLIENT.ID TO F.HIST ELSE
         CALL ELINE("Cannot open FB.BILLS.HIST for client ":CLIENT.ID)
         GOTO 100                        ; * START OVER
      END
      OPEN '','FB.AUDIT,':CLIENT.ID TO F.AUDIT THEN ; * JCW04
         AUDIT = 1                                  ; * JCW04
      END ELSE                                      ; * JCW04
         AUDIT = 0                                  ; * JCW04
      END                                           ; * JCW04
      IF CL.VAR.FLAG = 'Y' THEN
         OPEN '','VARIANCE.CODES,':CLIENT.ID TO F.VAR ELSE
            CALL ELINE("Cannot open VARIANCE.CODES for client ":CLIENT.ID)
            GOTO 100                     ; * START OVER
         END
      END
      IF CL.DIV.FLAG = 'Y' THEN
         OPEN '','DIVISION.CODES,':CLIENT.ID TO F.DIV ELSE
            CALL ELINE("Cannot open DIVISION.CODES for client ":CLIENT.ID)
            GOTO 100                     ; * START OVER
         END
         READV TEST FROM F.DIV,'99999',1 ELSE
            WRITEV '' ON F.DIV,'99999',1
         END
* Ensure that 99999 is on file for 3rd party Shipments
      END
      IF CL.EXP.FLAG = 'Y' THEN
         OPEN '','EXPENSE.CODES,':CLIENT.ID TO F.EXP ELSE
            CALL ELINE("Cannot open EXPENSE.CODES for client ":CLIENT.ID)
            GOTO 100                     ; * START OVER
         END
      END
      IF CL.VEND.FLAG = 'Y' ! CL.CUST.FLAG = 'Y' THEN
         OPEN '','VEND.CUST,':CLIENT.ID TO F.VEND.CUST ELSE
            EXECUTE 'CREATE-FILE DATA VEND.CUST,':CLIENT.ID:' 1009,2' CAPTURING OUTPUT    ; * NKH01
            OPEN '','VEND.CUST,':CLIENT.ID TO F.VEND.CUST ELSE
               CALL ELINE("Cannot open VEND.CUST for client ":CLIENT.ID)
               GOTO 100                  ; * START OVER
            END
         END
         OPEN '','VEND.CUST.NAMES,':CLIENT.ID TO F.VCN ELSE                             ; * JCW02
            EXECUTE 'CREATE-FILE DATA VEND.CUST.NAMES,':CLIENT.ID:' 601,1' CAPTURING OUTPUT ; * JCW02    NKH01
            OPEN '','VEND.CUST.NAMES,':CLIENT.ID TO F.VCN ELSE                          ; * JCW02
               CALL ELINE("Cannot open VEND.CUST.NAMES for client ":CLIENT.ID)          ; * JCW02
               GOTO 100                  ; * START OVER                                 ; * JCW02
            END                                                                         ; * JCW02
         END                                                                            ; * JCW02
         OPEN '','VEND.CUST.XREF,':CLIENT.ID TO F.VC.XREF ELSE                          ; * JCW03
            EXECUTE 'CREATE-FILE DATA VEND.CUST.XREF,':CLIENT.ID:' 401,1' CAPTURING OUTPUT  ; * JCW03    NKH01
            OPEN '','VEND.CUST.XREF,':CLIENT.ID TO F.VC.XREF ELSE                       ; * JCW03
               CALL ELINE("Cannot open VEND.CUST.XREF for client ":CLIENT.ID)           ; * JCW03
               GOTO 100                  ; * START OVER                                 ; * JCW03
            END                                                                         ; * JCW03
         END                                                                            ; * JCW03
         OPEN '','VEND.CUST.ZIPS,':CLIENT.ID TO F.VC.ZIPS ELSE                          ; * JCW03
            EXECUTE 'CREATE-FILE DATA VEND.CUST.ZIPS,':CLIENT.ID:' 131,1' CAPTURING OUTPUT  ; * JCW03    NKH01
            OPEN '','VEND.CUST.ZIPS,':CLIENT.ID TO F.VC.ZIPS ELSE                       ; * JCW03
               CALL ELINE("Cannot open VEND.CUST.ZIPS for client ":CLIENT.ID)           ; * JCW03
               GOTO 100                  ; * START OVER                                 ; * JCW03
            END                                                                         ; * JCW03
         END                                                                            ; * JCW03
      END
      OPEN '','FB.APRVD.CARRS,':CLIENT.ID TO F.APRVD.CARRS THEN
         APRVD.CARRS = 1
      END ELSE
         APRVD.CARRS = 0
         APRVD.CARRIER = ''              ; * Set Individual Switch to '' (Skip Entry)
*OH      IF CL.MISROUTE.CH='Y' THEN
*OH        CALL ELINE("Error - Client Set Up for Misroutings and No Apprvd Carriers have been entered!")
*OH        GO 100
*OH      END
      END

*----
* Enter carrier
*

200:
      IF CARRIER.ID # '' THEN MASK = CARRIER.ID'R%5' ELSE MASK = '#####'
      HELP = "Enter the carrier number. [L]=List [X]=Back [EX]=Exit"
      CALL GEN.IN(15,4,MASK,'',Q,0,20,'','',2,-5,4,0,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = 'L'
            SENTENCE = 'SORT FB.BILLS,' : CLIENT.ID
            SENTENCE := ' BY CARRIER BREAK.ON CARRIER PRO.NUML'
            SENTENCE := ' TOTAL 7 TOTAL 8 TOTAL VARIANCE ID.SUP'
            EXECUTE SENTENCE
            CALL ELINE('')
            GOTO 100                     ; * START OVER
         CASE QI = 'N'
            DONE = 0
            READVU X FROM F.DICT,'NEXT',1 ELSE X = 0
            LOOP
            UNTIL DONE DO
               X = X+1
               READ DUMMY FROM F.CARRIERS,X'R%5' ELSE DONE = 1
            REPEAT
            WRITEV X ON F.DICT,'NEXT',1
            Q = X'R%5'
            DATA 'EDIT',Q
            EXECUTE 'FB.1.2'
            GOSUB 8100                   ; * Display screen
         CASE QI = 'X'
            CRT @(15,4):@(-4):
            IF CHANGE.FLAG THEN GOTO 200 ELSE GOTO 100
         CASE QI = 'EX'
            STOP
         CASE NOT(QI MATCHES "0N")
            CALL SOUNDEX.DISPLAY(QI,'CARRIERS','SDX.CARRIER,NAME','1,3,4',ITEM.LIST)
            GOSUB 8100                   ; * Display screen
            BEGIN CASE
               CASE ITEM.LIST = ''
                  GOTO 200               ; * ENTER CARRIER
               CASE DCOUNT(ITEM.LIST<1>,@VM) GT 1
                  GOTO 200               ; * ENTER CARRIER
               CASE ITEM.LIST # ''
                  IF NUM(ITEM.LIST<1,1>) THEN DATA ITEM.LIST<1,1>
                  GOTO 200               ; * ENTER CARRIER
            END CASE
         CASE QI = ''
            Q = CARRIER.ID
         CASE NUM(QI)
            Q = QI'R%5'
         CASE 1
            GOTO 200                     ; * ENTER CARRIER
      END CASE
      CARRIER.ID = Q
      CALL CLR.CONTROL(CARRIER.ID)

*---- Get carrier data

      READ CARRIER.REC FROM F.CARRIERS,CARRIER.ID ELSE
         CALL ELINE("ERROR - Carrier ":CARRIER.ID:" not on file.")
         GOTO 200                        ; * ENTER CARRIER
      END
      IF CARRIER.REC<89>='I' THEN        ; * JMK01
         CALL ELINE("ERROR - This carrier is not active.")   ; * JMK01
         GOTO 200                        ; * JMK01
      END                                ; * JMK01
      APRVD.CARRIER = 'N'
*OH   APRVD.STR=''
*OH   IF APRVD.CARRS THEN
*OH      GOSUB SET.APRVD.CARR
*OH      IF APRVD.CARRIER='N' THEN APRVD.STR=' - Unapproved -'
*OH   END
      CARRIER.NAME = CARRIER.REC<1>
      CARRIER.CITY = CARRIER.REC<3>
      CARRIER.STATE = CARRIER.REC<4>
      READV T.MODE FROM F.TRANSPORT,CARRIER.REC<44>,1 ELSE T.MODE = ''
      T.MODE = OCONV(T.MODE,'MCU')
      CRT @(15,4):CARRIER.ID:' ':CARRIER.NAME:' ':CARRIER.CITY:
*OH   CRT ', ':CARRIER.STATE:APRVD.STR:@(-4):
      CRT ', ':CARRIER.STATE:@(-4):

220:
      CRT @(59,3):'Override Mileage: ':OVERRIDE.MILEAGE:
      MASK=OVERRIDE.MILEAGE'L#2'
      HELP = "Override Mileage for this Carrier [Y]es, [N]o, [X]=Back"
      CALL GEN.IN(77,3,MASK,'',Q,0,2,'','',2,-2,3,0,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      IF QI='1' THEN QI='Y'
      IF QI='0' THEN QI='N'
      BEGIN CASE
         CASE QI='EX'
            STOP
         CASE QI='X'
            GO 200
         CASE QI='Y' OR QI='N'
         CASE QI=''
            QI=OVERRIDE.MILEAGE
         CASE 1
            CALL ELINE('Must be [Y]es, or [N]o')
            GO 220
      END CASE
      OVERRIDE.MILEAGE=QI
      PRINT @(77,3):OVERRIDE.MILEAGE'L#2':
*----
* Enter pro number
*

300:
      IF CHANGE.FLAG = 0 THEN GOSUB 8000
      IF SEQ.FLAG THEN
         IF BACK.FLAG THEN
            BACK.FLAG = 0
            GO 220
         END ELSE
            GOSUB 8400                   ; * Get next pro number
            BACK.FLAG = 0
            GOTO 305
         END
      END
      MASK = PRO:STR('-',20-LEN(PRO))
      CRT @(13,6):@(-4)
      HELP = 'Enter the Pro Number. [S]=Scan Carrier [X]=Back [SEQ]=Sequential [EX]=Exit'
      CALL GEN.IN(5,6,MASK,'',Q,0,20,'','',2,-20,6,0,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      QI = TRIM(QI)
      BEGIN CASE
         CASE QI = 'X'
            CRT @(5,6):SPACE(20)
            GO 220
         CASE QI = 'EX'
            STOP
         CASE QI = 'S'
            CRT @(0,0):@(-3)
            CALL FB.DRAW.BOX(8,3,67,16,' ','')
            CALL FB.DRAW.BOX(9,4,65,12,' ','+=+|+=+|')
            CALL FB.DRAW.BOX(9,4,65,3,' ','+=+|+=+|')
            CALL FB.PRINT.CENT(9,74,8,"C A R R I E R   C O M M E N T S")
            FOR I=1 TO 8
               COMMENT=CARRIER.REC<45,I>'L#60'
               ROW=I+6
               CRT @(10,ROW):I'R#2':'|':COMMENT
            NEXT I
            CALL ELINE('')
* DATA 'SCAN',CARRIER.ID
* EXECUTE 'FB.1.2'
            GOSUB 8100                   ; * Display screen
            GO 300                       ; * ENTER PRO
         CASE QI = 'SEQ'
            GOSUB 8400                   ; * Get next pro number
            SEQ.FLAG = 1
         CASE CHANGE.FLAG = 1 & QI = ''
            Q = PRO
         CASE QI = ''
            GOTO 300                     ; * ENTER PRO
      END CASE

305:
      PRO = TRIM(Q)
      CALL CLR.CONTROL(PRO)
      VERSION = 0
      DISP = PRO:' Version ':VERSION
      CRT @(5,6):DISP'L#20'

310:
      PRO.ID = CARRIER.ID:'*':PRO:"*":VERSION
      IF NOT(CHANGE.FLAG) THEN OLD.PRO.ID = PRO.ID
      OLD.PRO.REC = ''
      READ OLD.PRO.REC FROM F.HIST,PRO.ID THEN

320:
         CRT @(24,0):"Entered By: ":OLD.PRO.REC<53>:" at ":OCONV(OLD.PRO.REC<85,1>,'MTS'):' on ':OLD.PRO.REC<86,1>'D2/'
         VERSION = FIELD(PRO.ID,'*',3)
         DISP = FIELD(PRO.ID,'*',2):' Version ':VERSION
         CRT @(5,6):DISP
         CUST.AMT = OLD.PRO.REC<13>
         CHECK.NUM = FIELD(OLD.PRO.REC<14>,'*',1)
         CHECK.DATE = OLD.PRO.REC<15>
         PROC.DATE = OLD.PRO.REC<37>
         IF CHANGE.FLAG AND NOT.PROCESSED AND (PROC.DATE # '') THEN
            CALL ELINE('Attempt to duplicate bill disallowed')
            GOTO 200
         END
         BANK.ID = OLD.PRO.REC<40>
         LINE.ITEMS=''
         FOR X = 1 TO 14
            LINE.ITEMS<X>=OLD.PRO.REC<X+69>
         NEXT X
         TIME.ENT=OLD.PRO.REC<85>
         DATE.ENT=OLD.PRO.REC<86>
         COMP.WITH.AFS95=OLD.PRO.REC<87>
         IF 0 THEN

*---- Select options for Pro already paid

*           WRITE OLD.PRO.REC ON F.INQUIRE,CLIENT.ID:'*':PRO.ID
            CHECK.ID = CHECK.NUM:'*':BANK.ID
            MATREAD CHECK.REC FROM F.CHECKS, CHECK.ID ELSE
               MAT CHECK.REC = ''
            END
            CHECK.AMT = FCK.AMT
            IF CLIENT.ID = '00000' THEN
               CHECK.AMT = CUST.AMT
               PROC.DATE = CHECK.DATE
            END
            PRO.REC = OLD.PRO.REC
            GOSUB 8100                   ; * Display screen
            GOSUB 8300                   ; * Assign data
            GOSUB 8200                   ; * Display data
            LINE1 = CHAR(7):'Paid ':CHECK.DATE'D2/':' Check #':CHECK.NUM
            LINE2 = 'Client amt ':CUST.AMT'R26,':' Check amt '
            LINE2 := CHECK.AMT'R26,':' Processed ':PROC.DATE'D2/':' '
            IF CLIENT.ID = '00000' THEN
               LINE1 := ' Load number ':OLD.PRO.REC<16>
            END
            CRT @(0,21):LINE1:
            CRT @(0,22):LINE2:

            IF CLIENT.ID = '00000' THEN
               PRO.REC = OLD.PRO.REC
               GOSUB 8300                ; * Assign data
               COL = LEN(LINE2)
               CRT @(COL,22):
               INPUT ACK,1
               CRT @(0,21):@(-3)
               QI = 'I'
               GOSUB 8200                ; * Display data
               CRT @(0,21):@(-3)
               GOSUB 8100                ; * Display screen
               GOTO 300                  ; * ENTER PRO
            END
            HELP = 'Enter [1]=BD [2]=AD [3]=Inquire/Del [4]=Post Dup [EX]=Exit [RETURN]=Back'
            COL = LEN(LINE2)
            CALL GEN.IN(COL,22,'--','',Q,0,2,'','',2,-2,22,0,QI,HELP,0,23)
            CRT @(0,21):@(-3):
            Q = OCONV(QI,'MCU')

            BEGIN CASE
               CASE Q = 'X' OR Q = ''
                  GOSUB 8100             ; * Display screen
                  GOTO 300               ; * ENTER PRO
               CASE Q = 'EX'
                  STOP
               CASE CLIENT.ID = '00000'
                  CALL ELINE('Invalid entry.')
                  GOTO 320
               CASE Q = 1                ; * BALANCE DUE
                  VERSION = 0
                  PRO.REC = OLD.PRO.REC
                  GOSUB 8300             ; * Assign data
                  PRO = PRO:'BD'
                  BAL.DUE = 1
                  CHECK.NUM = ''
                  CHECK.AMT = ''
                  PRO.REC<37> = ''
                  CRT @(5,6):PRO'L#20'
                  GOTO 310
               CASE Q = 2                ; * ADDITIONAL DUE
                  VERSION = 0
                  PRO.REC = OLD.PRO.REC
                  PRO.REC<63>=0          ; * Don't Bring Misroute Forward
                  GOSUB 8300             ; * Assign data
                  PRO = PRO:'AD'
                  CHECK.NUM = ''
                  CHECK.AMT = ''
                  PRO.REC<37> = ''
                  CRT @(5,6):PRO'L#20'
                  GOTO 310
               CASE Q = 3                ; * INQUIRY/DELETE

322:
                  HELP = "Enter version of pro to review or delete. [X]=Back to Pro Entry"
                  COL = LEN(DISP)+4
                  CALL GEN.IN(COL,6,VERSION,'',Q,0,1,'','',2,-1,6,0,QI,
                  HELP,0,23)
                  QI = OCONV(QI,'MCU')
                  IF QI = '' THEN Q = VERSION
                  IF QI = 'X' THEN GOTO 300        ; * ENTER PRO
                  VERSION = Q
                  PRO.LEN = LEN(PRO)
                  IF PRO[PRO.LEN-1,2] = 'BD' THEN
                     BAL.DUE = 1
                  END ELSE
                     BAL.DUE = 0
                  END
                  PRO.ID = CARRIER.ID:'*':PRO:"*":VERSION
                  READ OLD.PRO.REC FROM F.HIST,PRO.ID ELSE
                     CALL ELINE("Pro ":PRO.ID:" not on file.")
                     GOTO 322
                  END
                  PRO.REC = OLD.PRO.REC
                  QI = 'I'
                  GOSUB 8300             ; * Assign data
                  GOSUB 8200             ; * Display data

*---- Delete duplicate pro

                  IF VERSION # 0 THEN
                     CRT @(0,22):"Delete?(Y/N) N"
                     CRT @(13,22):
                     INPUT ACK,1:
                     IF ACK = 'Y' THEN
*                       WRITE PRO.ID:@FM:USER:@FM:@FM:OLD.PRO.REC<8> ON F.DEL.BILLS,DATE():'*':TIME()
                        DELETE F.BILLS,PRO.ID
                        DELETE F.HIST,PRO.ID
*                       DELETE F.CRX,PRO.ID
*                       DELETE F.OPEN,CLIENT.ID:'*':PRO.ID
                     END
                  END
                  CRT @(0,6):@(-3)
                  GOSUB 8100             ; * Display screen
                  DATA PRO
                  GOTO 300               ; * ENTER PRO
               CASE Q = 4                ; * POST DUPLICATE
                  PRO.REC = OLD.PRO.REC

325:
                  VERSION = VERSION+1
                  PRO.ID = CARRIER.ID:'*':PRO:'*':VERSION
                  READ DUMMY FROM F.HIST,PRO.ID THEN GOTO 325
                  GOSUB 8300             ; * Assign data
                  GOSUB 8200             ; * Display data
                  GOTO 4900              ; * UPDATE ACTION
               CASE 1
                  CALL ELINE('Invalid entry.')
                  GOTO 320
            END CASE
         END ELSE

*---- Select option for Pro not paid

            IF CHANGE.FLAG THEN GOTO 400

330:
            HELP = CHAR(7):"Enter option. [X]=Back [EX]=Exit [D]=Delete [I]=Inquire [C]=Change"
            IF CLIENT.ID = '00000' THEN
               HELP = CHAR(7):"Enter option. [X]=Back [EX]=Exit [I]=Inquire"
            END
            LN = 'Pro ' : PRO.ID : ' processed on ' : PROC.DATE'D2/'
            LN := '. Enter option please. --'
            CALL GEN.IN(0,22,LN,'',Q,0,2,'','',2,-2,22,1,QI,HELP,0,23)
            QI = OCONV(QI,'MCU')

            BEGIN CASE
               CASE QI = 'X' OR QI=''
                  GOTO 300               ; * ENTER PRO
               CASE QI = 'EX'
                  STOP
               CASE QI = 'I'
                  PRO.REC = OLD.PRO.REC
*                 WRITE PRO.REC ON F.INQUIRE,CLIENT.ID:'*':PRO.ID
                  GOSUB 8300             ; * Assign data
                  GOSUB 8200             ; * Display data
                  GOSUB 8100             ; * Display screen
                  GOTO 300               ; * ENTER PRO
               CASE CLIENT.ID = '00000'
                  CALL ELINE('Invalid entry.')
                  GOTO 330
               CASE QI = 'D'
*                 WRITE PRO.ID:@FM:USER:@FM:PROC.DATE:@FM:OLD.PRO.REC<8> ON F.DEL.BILLS, DATE():'*':TIME()
                  DELETE F.BILLS,PRO.ID
                  DELETE F.HIST,PRO.ID
*                 DELETE F.CRX,PRO.ID
*                 DELETE F.OPEN,CLIENT.ID:'*':PRO.ID
                  PRO = FIELD(PRO.ID,'*',2)
                  START = LEN(PRO)-1
                  TEMP = LEN(PRO)-2
                  IF PRO[START,2] = 'CM' THEN
                     OLD.PRO.ID = FIELD(PRO.ID,'*',1) : '*' : PRO[1,TEMP]
                     OLD.PRO.ID := '*' : FIELD(PRO.ID,'*',3)
                     WRITEV '' ON F.HIST,OLD.PRO.ID,42
                     WRITEV '' ON F.BILLS,OLD.PRO.ID,42
                  END
                  GOTO 300               ; * ENTER PRO
               CASE QI = 'C'
                  NOT.PROCESSED = (PROC.DATE = '')
                  OLD.PRO.ID = PRO.ID
                  PRO.REC = OLD.PRO.REC
                  LINE.ITEMS=''
                  FOR X = 1 TO 14
                     LINE.ITEMS<X>=OLD.PRO.REC<X+69>
                  NEXT X
                  TIME.ENT=OLD.PRO.REC<85>
                  DATE.ENT=OLD.PRO.REC<86>
                  COMP.WITH.AFS95=OLD.PRO.REC<87>
                  PRO.LEN = LEN(PRO)
                  IF PRO[PRO.LEN-1,2] = 'BD' THEN
                     BAL.DUE = 1
                  END ELSE
                     BAL.DUE = 0
                  END
                  CHANGE.FLAG = 1
                  GOSUB 8300             ; * Assign data
                  GOSUB 8200             ; * Display data
                  GOTO 200               ; * ENTER CARRIER
               CASE 1
                  CALL ELINE('Invalid entry.')
                  GOTO 330
            END CASE
         END
      END ELSE
         LOCATE CLIENT.ID IN ALT.CLIENTS<1> SETTING POS THEN
            READ PRO.REC FROM F.ALT.HIST,PRO.ID THEN
               LINE.ITEMS=''             ; ** Pro Not On File
               TIME.ENT=''
               DATE.ENT=''
               COMP.WITH.AFS95=''
               PRO.REC<7>=PRO.REC<8>     ; * MAKE CHARGES THE SAME
               OLD.PRO.REC=PRO.REC
               GOSUB 8300
               GOSUB 8200
               IF CL.DIV.FLAG AND PRO.REC<9>='' THEN GO 600
*            GO 2300 ; * DONT GO HERE PER DARLENE
               GO 400                    ; * Go to Bill Date Per Darlene
            END
         END

*
* OLD CODE - JIM - PLEASE REMOVE
*
*         IF CLIENT.ID=99932 THEN
*           READ PRO.REC FROM F.DARL.HIST,PRO.ID THEN
*             LINE.ITEMS='' ;** Pro Not On File
*             TIME.ENT=''
*             DATE.ENT=''
*             COMP.WITH.AFS95=''
*             PRO.REC<7>=PRO.REC<8> ; * MAKE CHARGES THE SAME
*             OLD.PRO.REC=PRO.REC
*             GOSUB 8300
*             GOSUB 8200
*             GO 2300
*           END
*         END
*
*         IF CLIENT.ID=99914 THEN
*           READ PRO.REC FROM F.SAUL.HIST,PRO.ID THEN
*             LINE.ITEMS='' ;** Pro Not On File
*             TIME.ENT=''
*             DATE.ENT=''
*             COMP.WITH.AFS95=''
*             PRO.REC<7>=PRO.REC<8> ; * MAKE CHARGES THE SAME
*             OLD.PRO.REC=PRO.REC
*             GOSUB 8300
*             GOSUB 8200
*             GO 2300
*           END
*         END
*
*         IF CLIENT.ID='99928' OR CLIENT.ID='99926' OR CLIENT.ID='99913' OR CLIENT.ID='99912' THEN
*           READ PRO.REC FROM F.LIB.HIST,PRO.ID THEN
*             LINE.ITEMS='' ;** Pro Not On File
*             TIME.ENT=''
*             DATE.ENT=''
*             COMP.WITH.AFS95=''
*             PRO.REC<7>=PRO.REC<8> ; * MAKE CHARGES THE SAME
*             OLD.PRO.REC=PRO.REC
*             GOSUB 8300
*             GOSUB 8200
*             GO 600
*           END
*         END
*
* JIM END
*
         PRO.LEN = LEN(PRO)
         TIME.ENT=''
         DATE.ENT=''
         IF PRO[PRO.LEN-1,2] = 'BD' THEN
            BAL.DUE = 1
         END ELSE
            BAL.DUE = 0
         END
      END

*---- Check for duplicate pro posted to another client, display,
* and clear for another entry

      IF CLIENT.ID[1,2]='99' ELSE
         READ DUMMY FROM F.CRX,PRO.ID THEN
            PRO.REC = DUMMY
            GOSUB 8100                   ; * Display screen
            GOSUB 8300                   ; * Assign data
            GOSUB 8200                   ; * Display data
            LN1 = 'Duplicate pro ':PRO.ID
            LN1 := ' Entered for client ':DUMMY<1>
            LN1 := ' on ':DUMMY<30>'D2/'
            CRT @(0,21):LN1:@(-4)
            VAR = DUMMY<7>-DUMMY<8>
            LN2 = 'Pd ':DUMMY<15>'D2/':' Ck# ':DUMMY<14>:' for '
            LN2 := DUMMY<13>'L26,':' actual chgs ':DUMMY<8>'L26,'
            LN2 := ' var ':VAR'L26,'
            CALL ELINE(LN2)
            CRT @(0,21):@(-3):
            PRO.REC = ''
            GOTO 300                     ; * ENTER PRO
         END
      END
      IF NOT(CHANGE.FLAG) THEN
         LINE.ITEMS=''                   ; ** Pro Not On File
         COMP.WITH.AFS95=''
      END

*----
* FILL IN THE FIELDS
*

*---- Enter pro date

400:
      BACK.FLAG = 0
      IF CHANGE.FLAG ! BILL.DATE # '' THEN
         MASK = BILL.DATE'D2.'
      END ELSE
         MASK = 'MM/DD/YY'
      END
      HELP = "Enter the Pro Date. [T]=Today [X]=Back to Pro Entry [EX]=Exit"
      IF CHANGE.FLAG ! BILL.DATE # '' THEN REQ = 0 ELSE REQ = 1
      CALL GEN.IN(5,7,MASK,'DATE',Q,REQ,8,'','',2,-8,7,0,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE CHANGE.FLAG & QI = ''
            Q = BILL.DATE
         CASE QI = 'T'
            Q = DATE()
         CASE QI = 'X'
            CRT @(5,7):SPACE(8):
            BACK.FLAG = 1
            GOTO 300                     ; * ENTER PRO
         CASE QI = 'EX'
            STOP
      END CASE
      BILL.DATE = Q
      IF BILL.DATE GT DATE() ! BILL.DATE = '' THEN
         CALL ELINE('ERROR - Invalid Date.')
         GOTO 400
      END
      IF CLIENT.ID='00716' & BILL.DATE GE ICONV('12/01/94','D') THEN
         CALL ELINE('NO Dal-Tile After 12/01/94')
         GOTO 400
      END
      CRT @(5,7):BILL.DATE'D2/'

*---- Enter due date

450:
      IF CL.DUE.FLAG # 'Y' THEN
         IF BACK.FLAG THEN GOTO 400 ELSE GOTO 500
      END
      BACK.FLAG = 0
      IF CHANGE.FLAG ! DUE.DATE # '' THEN
         MASK = DUE.DATE'D2.'
      END ELSE
         MASK = DATE()'D2.'
      END
      CRT @(14,7):'Due'
      HELP = "Enter the Due Date. [T]=Today [X]=Back to Pro Date [EX]=Exit"
      IF CHANGE.FLAG ! DUE.DATE # '' THEN REQ = 0 ELSE REQ = 1
      CALL GEN.IN(18,7,MASK,'DATE',Q,REQ,8,'','',2,-8,7,0,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE CHANGE.FLAG & QI = ''
            Q = DUE.DATE
         CASE QI = 'T'
            Q = DATE()
         CASE QI = 'X'
            CRT @(18,7):@(-4):
            GOTO 400
         CASE QI = 'EX'
            STOP
         CASE NOT( NUM(Q) )
            GOTO 450
      END CASE
      DUE.DATE = Q
      CRT @(18,7):DUE.DATE'D2/'

*---- Enter inbound or outbound

500:

      BEGIN CASE
         CASE CL.IO.FLAG = 'I'
            IF BACK.FLAG THEN GOTO 450
            IN.OUT = 'I'
         CASE CL.IO.FLAG = 'O'
            IF BACK.FLAG THEN GOTO 450
            IN.OUT = 'O'
         CASE 1
            BACK.FLAG = 0
            MASK = IN.OUT'L#2'
            HELP = 'Enter [I]=Inbound [O]=Outbound [T]=Third Party [X]=Back [EX]=Exit'
            CALL GEN.IN(5,8,MASK,'',Q,0,2,'','',2,-2,8,0,QI,HELP,0,23)
            QI = OCONV(QI,'MCU')
            BEGIN CASE
               CASE CHANGE.FLAG & QI = ''
                  Q = IN.OUT
               CASE QI = 'X'
                  CRT @(5,8):' ':
                  BACK.FLAG = 1
                  GOTO 450
               CASE QI = 'EX'
                  STOP
               CASE QI = 1 ! QI = 'I'
                  Q = 'I'
               CASE QI = 0 ! QI = 'O'
                  Q = 'O'
               CASE QI = 3 ! QI = 'T'
                  Q = 'T'
               CASE QI = ''
                  IF IN.OUT # '' THEN Q = IN.OUT ELSE
                     CRT CHAR(7):CHAR(7)
                     GOTO 500
                  END
               CASE 1
                  CRT CHAR(7):CHAR(7)
                  GOTO 500
            END CASE
            IN.OUT = Q
      END CASE
      CRT @(5,8):IN.OUT

*---- Enter division

*** IF USER = "NPRATT" THEN DEBUG

600:
      IF CL.DIV.FLAG = 'Y' THEN
         IF IN.OUT='T' THEN
            IF BACK.FLAG THEN GO 500     ; ** Don't Enter Div on "T"
            DIVISION='99999'
            CRT @(5,9):DIVISION
            GO 700
         END
         BACK.FLAG = 0

610:
         MASK = DIVISION:STR('#',5-LEN(DIVISION))
         HELP = 'Enter Division. [X]=Back [EX]=Exit'
         CALL GEN.IN(5,9,MASK,'',Q,0,5,'','',2,-5,9,0,QI,HELP,0,23)
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = 'X'
               CRT @(5,9):'     '
               BACK.FLAG = 1
               GOTO 500
            CASE QI = 'EX'
               STOP
            CASE QI = ''
               Q = DIVISION
         END CASE

         DIVISION = Q'R%5'
         CRT @(5,9):DIVISION
         IF IN.OUT = 'O' THEN
            MATREAD DIV.REC FROM F.DIV, DIVISION ELSE
               CALL ELINE("ERROR - Division ":DIVISION:" not on file.")
               GOTO 610
            END
            ORIG.ZIP = DIV.ZIP
            ZIP.VAR = ORIG.ZIP
            CALL FB.READ.ZIP(ZIP.VAR,CITY,STATE)
            IF ORIG.CITY='' THEN ORIG.CITY = CITY
            IF ORIG.STATE='' THEN ORIG.STATE=STATE
            IF CL.DIV.ZIP.OVER # 'Y' THEN
               IF CITY = '' ! STATE = '' THEN
                  CALL ELINE('Error exists in division code file.')
                  GOTO 600
               END
               ORIG.CITY = CITY
               ORIG.STATE = STATE
               CRT @(5,10) : ORIG.ZIP'R%5' : ' ' : ORIG.CITY : ', ' :
               CRT ORIG.STATE : @(-4)
               OLD.HELP=''
               IF CL.ZIP.RTE = "Y" THEN GO 700
               GOTO 800
            END
         END ELSE
            MATREAD DIV.REC FROM F.DIV, DIVISION ELSE
               CALL ELINE("ERROR - Division ":DIVISION:" not on file.")
               GOTO 610
            END
            DEST.ZIP = DIV.ZIP
            ZIP.VAR = DEST.ZIP
            CALL FB.READ.ZIP(ZIP.VAR,CITY,STATE)
            IF DEST.CITY='' THEN DEST.CITY = CITY
            IF DEST.STATE='' THEN DEST.STATE=STATE

            IF CL.DIV.ZIP.OVER # 'Y' THEN
               IF CITY = '' ! STATE = '' THEN
                  CALL ELINE('Error exists in division code file.')
                  GOTO 600
               END
               DEST.CITY = CITY
               DEST.STATE = STATE
               CRT @(5,11) : DEST.ZIP'L#6' : ' ' : DEST.CITY : ', ' :
               CRT DEST.STATE : @(-4) :
            END
         END
      END ELSE
         IF BACK.FLAG THEN GOTO 500
      END
      OLD.HELP=''

*---- Enter origin zip

700:

      BEGIN CASE
         CASE CL.ZIP.RTE = 'Y'
            QI='E'

*            CALL FB.2.1.ZIP( ZIP.ARR, QI )

            GOSUB FB.2.1.ZIP

            ORIG.ZIP = ZIP.ARR<1,1>
            ORIG.CITY = ZIP.ARR<2,1>
            ORIG.STATE = ZIP.ARR<3,1>
            NUM.ZIPS = DCOUNT( ZIP.ARR<1>, @VM )
            DEST.ZIP = ZIP.ARR<1,NUM.ZIPS>
            DEST.CITY = ZIP.ARR<2,NUM.ZIPS>
            DEST.STATE = ZIP.ARR<3,NUM.ZIPS>
            IF QI = 'X' THEN
               BACK.FLAG = 1
               GOTO 600
            END
            IF USER = "NPRATT" THEN DEBUG
            GOTO 900

         CASE CL.ORIG.FLAG = 'Y'
            IF CL.ZIP.DEF<1,1> # '' THEN
               IF IN.OUT = 'O' & NOT(BACK.FLAG) THEN DATA CL.ZIP.DEF<1,1>
               IF IN.OUT = 'O' & NOT(BACK.FLAG) AND ORIG.ZIP='' THEN ORIG.ZIP=CL.ZIP.DEF<1,1>
            END
            HELP = "Enter the Origination Zip Code. [S]=Search. [X]=Back. [EX]=Exit."
*            IF IN.OUT='O' & ORIG.ZIP='' & CL.DIV.FLAG#'Y' THEN
*              ORIG.ZIP=CLIENT.ZIP
*              CALL FB.2.1.CSZ(10,ORIG.ZIP,HELP,ZIP.LEN,BACK.FLAG,ORIG.CITY,ORIG.STATE)
*            END ELSE
*              CALL FB.2.1.CSZ(10,ORIG.ZIP,HELP,ZIP.LEN,BACK.FLAG,ORIG.CITY,ORIG.STATE)
*            END
            VIN=''
            CALL FB.2.1.CSZ.NEW(VIN,VOUT,10,ORIG.ZIP,HELP,ZIP.LEN,BACK.FLAG,ORIG.CITY,ORIG.STATE)
            IF HELP='S' ! HELP='' THEN OLD.HELP='S' ELSE OLD.HELP=''
            IF BACK.FLAG THEN
               IF OLD.HELP='S' THEN
                  GOSUB 8100
                  GOSUB 8200
                  OLD.HELP=''
               END
               GOTO 600
            END
*
* Check zip
*
            IF USE.MWB.500.ZIPS THEN
               IF CL.ZIP.FLAG='C' AND ORIG.ZIP MATCHES '1A1N1A1N1A1N' ELSE
* Don't Use File if Canadian
                  READ JIM FROM F.MWB.ZIPS,ORIG.ZIP ELSE
                     IF ORIG.ZIP#'99999' THEN
                        CALL ELINE('Zip Code Not Valid in Middlewest 500! Try again.')
                        GOTO 700
                     END
                  END
               END
               IF USER = "NPRATT" THEN DEBUG
            END
            IF OLD.HELP='S' THEN
               GOSUB 8100                ; * Display screen
               GOSUB 8200                ; * Display data
               OLD.HELP=''
            END
            IF ORIG.CITY # '' THEN
               DESC = ORIG.CITY:', ':ORIG.STATE
            END ELSE
               DESC = ORIG.STATE
            END

            CRT @(5,10):ORIG.ZIP'L#6':' ':DESC:@(-4)
            IF CL.DIV.FLAG = 'Y' & NOT(BACK.FLAG) & IN.OUT#'T' THEN
               IF CL.DIV.ZIP.OVER = 'Y' ELSE GOTO 900
            END
         CASE BACK.FLAG
            GOTO 600
         CASE 1
            NULL
      END CASE

*---- Enter destination zip

800:

      BEGIN CASE
         CASE CL.ZIP.RTE = "Y" AND BACK.FLAG
            GO 600
         CASE CL.DEST.FLAG = 'Y'
            IF CL.ZIP.DEF<1,1> # '' THEN
               IF IN.OUT = 'I' & NOT(BACK.FLAG) THEN DATA CL.ZIP.DEF<1,1>
               IF IN.OUT = 'I' & NOT(BACK.FLAG) AND DEST.ZIP='' THEN DEST.ZIP=CL.ZIP.DEF<1,1>
            END
            HELP = "Enter the Destination Zip Code. [S]=Search. [X]=Back. [EX]=Exit."
*            IF IN.OUT='I' & DEST.ZIP='' & CL.DIV.FLAG#'Y' THEN
*              DEST.ZIP=CLIENT.ZIP
*              CALL FB.2.1.CSZ(11,DEST.ZIP,HELP,ZIP.LEN,BACK.FLAG,DEST.CITY,DEST.STATE)
*            END ELSE
*              CALL FB.2.1.CSZ(11,DEST.ZIP,HELP,ZIP.LEN,BACK.FLAG,DEST.CITY,DEST.STATE)
*            END
            VIN=''
            CALL FB.2.1.CSZ.NEW(VIN,VOUT,11,DEST.ZIP,HELP,ZIP.LEN,BACK.FLAG,DEST.CITY,DEST.STATE)
            IF HELP='S' ! HELP='' THEN OLD.HELP='S'
            IF BACK.FLAG THEN
               IF OLD.HELP='S' THEN
                  GOSUB 8100
                  GOSUB 8200
                  OLD.HELP=''
               END
               GOTO 700
            END
*
* Check zip
*
            IF USE.MWB.500.ZIPS THEN
               IF CL.ZIP.FLAG='C' AND DEST.ZIP MATCHES '1A1N1A1N1A1N' ELSE
                  READ JIM FROM F.MWB.ZIPS,DEST.ZIP ELSE
                     IF DEST.ZIP#'99999' THEN
                        CALL ELINE('Zip Code Not Valid in Middlewest 500! Try again.')
                        GOTO 800
                     END
                  END
               END
            END
            IF OLD.HELP='S' THEN
               GOSUB 8100                ; * Display screen
               GOSUB 8200                ; * Display data
               OLD.HELP=''
            END
            IF DEST.CITY # '' THEN
               DESC = DEST.CITY:', ':DEST.STATE
            END ELSE
               DESC = DEST.STATE
            END

            CRT @(5,11):DEST.ZIP'L#6':' ':DESC:@(-4)
            BACK.FLAG = 0
            IF DEST.ZIP = ORIG.ZIP THEN
               CALL ELINE('WARNING - Origin and destination zip are the same.')
            END
         CASE BACK.FLAG
            GOTO 700
         CASE 1
            NULL
      END CASE

*---- Feed origin and destination zips to mileage calc program

900:
      IF CL.ORIG.FLAG='Y' AND CL.DEST.FLAG='Y' THEN CL.MILE.FLAG='Y'
      IF LEN(ORIG.ZIP) < 5 OR LEN(DEST.ZIP) < 5 THEN CL.MILE.FLAG='N'
      IF CL.MILE.FLAG = 'Y' & ORIG.ZIP#99999 & DEST.ZIP#99999 THEN
         BEGIN CASE
            CASE CL.ZIP.RTE = 'Y'
               MILE.REC = ZIP.ARR<1>
            CASE ORIG.ZIP LE DEST.ZIP
               MILE.REC = ORIG.ZIP:@VM:DEST.ZIP
            CASE 1
               MILE.REC = ORIG.ZIP:@VM:DEST.ZIP
*DF               MILE.REC = DEST.ZIP:@VM:ORIG.ZIP
         END CASE
         IF MILEAGE='' OR (ORIG.ZIP#OLD.PRO.REC<3> OR DEST.ZIP#OLD.PRO.REC<4>) OR CL.ZIP.RTE='Y' THEN
* Only go to PC Miler if there was a change!!!
* NPR999            VIN='SEND'
            VIN='BOTH'  ;* NPR999
            VIN<2>=CH.NUM
            VIN<3>=MILE.REC
            VIN<4>=0                     ; * 1 to Skip File Lookup and go to PC
            VIN<5>=PROG.NAME
            VIN<6>=CLIENT.ID:' - ':CLIENT.NAME
            VIN<8>=CLIENT.ID             ; * JMK03
            VIN<9>=CARRIER.ID            ; * JMK03
            SENT.TO.PCMILER=1

            IF USER = "NPRATT" THEN
               DEBUG
               CALL PCMILER.NP(VIN,VOUT,F.PCIN,F.PCOUT,F.MILEAGE)
               DEBUG
            END ELSE
               CALL PCMILER.BETA(VIN,VOUT,F.PCIN,F.PCOUT,F.MILEAGE)
            END

            IF VOUT<2>='FOUNDINFILE' OR VOUT<2>[1,5]='ERROR' THEN
               MILEAGE=VOUT<1>
               CRT @(5,15):MILEAGE'L1,#10'
               SENT.TO.PCMILER=0
            END ELSE                                        ;* NPR99

               MILEAGE=VOUT<1>                              ;* NPR99
               CRT @(5,15):MILEAGE'L1,#10'                  ;* NPR99
               SENT.TO.PCMILER=0                            ;* NPR99
               IF MILEAGE = '' THEN                         ;* NPR99
                  CALL ELINE("1 Check Mileage")             ;* NPR99
               END                                          ;* NPR99
            END                                             ;* NPR99
         END
      END
      IF ORIG.ZIP # '' THEN
         CRT @(5,10):ORIG.ZIP'L#6':' ':ORIG.CITY:', ':ORIG.STATE:@(-4)
      END
      IF DEST.ZIP # '' THEN
         CRT @(5,11):DEST.ZIP'L#6':' ':DEST.CITY:', ':DEST.STATE:@(-4):
      END
*     IF ORIG.STATE=DEST.STATE THEN
      IF 0 THEN                          ; ** DISABLE QUESTION PER BB ON 12/13/95
         HELP="Send This to AFS95 for Comparison? Y/N"
         Q=COMP.WITH.AFS95
         IF Q='' THEN Q='Y'
920:     CALL GEN.IN(0,22,'Compare with AFS95 Rates?: ':COMP.WITH.AFS95'L#2','',Q,0,2,'','',0,-2,22,1,QI,HELP,0,23)
         QI=OCONV(QI,'MCU')
         BACK.FLAG=0
         BEGIN CASE
            CASE QI='X'
               CRT @(0,22):@(-3):
               BACK.FLAG=1
               GO 800
            CASE QI='EX'
               STOP
            CASE QI='Y'
               COMP.WITH.AFS95=''
            CASE QI='N'
               COMP.WITH.AFS95='N'
            CASE 1
               CALL ELINE('Invalid entry. Must be Y, N, X, EX, or RETURN.')
               GOTO 920
         END CASE
         IF COMP.WITH.AFS95='Y' THEN COMP.WITH.AFS95=''
      END

*---- Enter expense code

1300:
      IF CL.EXP.FLAG = 'Y' THEN

1310:
         BACK.FLAG = 0
         HELP = "Enter the Expense Code. [X]=Back [EX]=Exit"
         MASK = EXP.CODE:STR('-',20-LEN(EXP.CODE))
         CALL GEN.IN(5,12,MASK,'',Q,0,20,'','',2,-20,12,0,QI,HELP,0,23)
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = 'X'
               BACK.FLAG = 1
               CRT @(5,12):@(-4):
               GOTO 800
            CASE QI = 'EX'
               STOP
            CASE CHANGE.FLAG & QI = ''
               Q = EXP.CODE
            CASE EXP.CODE # '' & QI = ''
               Q = EXP.CODE
            CASE QI # ''
               NULL
            CASE 1
               CALL ELINE('Invalid entry.')
               GOTO 1310
         END CASE
         EXP.CODE = Q

*---- Verify expense code in expense code file

         READV EXP.CODE.DESC FROM F.EXP,EXP.CODE,1 ELSE
            CRT @(0,22):CHAR(7):CHAR(7):
            HELP = "Enter either Y or N."

1320:
            LINE = 'Expense code ':EXP.CODE
            LINE := ' not on file. Do you want to add? N'
            CALL GEN.IN(0,22,LINE,'',Q,0,1,'','',1,-1,22,1,QI,HELP,0,23)
            QI = OCONV(QI,'MCU')
            IF QI = '' THEN QI = 'N'
            IF QI = 'Y' ! QI = 'N' ELSE GOTO 1320
            IF QI = 'N' THEN GOTO 1310

*---- Enter new expense code description and update expense code file

1330:
            HELP = "Enter the expense code description."
            CALL GEN.IN(0,22,'Enter description ':STR('-',20),'',Q,1,20,
            '','',2,-20,22,0,QI,HELP,0,23)

1335:
            HELP = "Enter either Y or N."
            LINE = 'The description is ':Q:'. Is this correct? Y'
            CALL GEN.IN(0,22,LINE,'',ACK,0,1,'','',1,-1,22,1,QI,HELP,0,23)
            QI = OCONV(QI,'MCU')
            IF QI = '' THEN QI = 'Y'
            IF QI = 'Y' ! QI = 'N' ELSE GOTO 1335
            IF QI = 'N' THEN GOTO 1330
            EXP.CODE.DESC = Q
            WRITEV EXP.CODE.DESC ON F.EXP,EXP.CODE,1
         END
         CRT @(5,12):EXP.CODE:' ':EXP.CODE.DESC:@(-4):
         IF OLD.PRO.REC<5> = OLD.PRO.REC<31> & NOT(CHANGE.FLAG) THEN
            DTAB = ''
            DTAB<1> = EXP.CODE
         END
      END ELSE
         IF BACK.FLAG THEN GOTO 800
      END

*---- Enter vendor/customer number

1400:
      IF IN.OUT = 'I' THEN
         IF CL.VEND.FLAG # 'Y' THEN
            IF BACK.FLAG THEN GOTO 1300
            GOTO 1475
         END ELSE
            DESC = 'Vend'
         END
      END ELSE
         IF CL.CUST.FLAG # 'Y' THEN
            IF BACK.FLAG THEN GOTO 1300
            GOTO 1475
         END ELSE
            DESC = 'Cust'
         END
      END

      BACK.FLAG = 0
      CRT @(0,13):DESC'L#18':

1450:
      CALL FB.2.1.CONSIGN(IN.OUT,CONSIGN.DESC,F.VEND.CUST,F.VC.XREF,F.VC.ZIPS,CLIENT.ID,QI,VOUT)
      BEGIN CASE
         CASE QI = 'NULL'
            GOSUB 8100                   ; * Display screen
            GOSUB 8200                   ; * Display data
            GOTO 1450
         CASE QI = 'X'
            BACK.FLAG = 1
            GOTO 1300
         CASE QI = 'EX'
            STOP
         CASE CONSIGN.DESC = '' & QI = ''
            GOSUB 8100                   ; * Display screen
            GOSUB 8200                   ; * Display data
            CALL ELINE("Entry required!")
            GOTO 1450
      END CASE
      GOSUB 8100                         ; * Display screen
      GOSUB 8200                         ; * Display data
      CRT @(5,13):VOUT<2>:"-":CONSIGN.DESC
      VC.ID=VOUT<2>
ENTER.VEND.CUST:
*DF      T.ADDRESS = CUST.VEND.ADDR
      IF VC.ID # '' THEN
         READ VCUST.REC FROM F.VEND.CUST,VC.ID THEN
*DF            IF IN.OUT#'I' THEN GOTO 1475
            IF VCUST.REC<3,1>#'' THEN GOTO 1475
            T.ADDRESS=''
            T.ADDRESS<1>=VCUST.REC<1>    ; * Name
            T.ADDRESS<2>=VCUST.REC<3,1>  ; * Address 1
            T.ADDRESS<3>=VCUST.REC<3,2>  ; * Address 2
            T.ADDRESS<5>=VCUST.REC<5>    ; * City
            T.ADDRESS<6>=VCUST.REC<6>    ; * State
            T.ADDRESS<4>=VCUST.REC<7>    ; * Zip
            IF T.ADDRESS<4>='' THEN
               IF IN.OUT='O' THEN
                  T.ADDRESS<4>=DEST.ZIP
                  T.ADDRESS<5>=DEST.CITY
                  T.ADDRESS<6>=DEST.STATE
               END ELSE
                  T.ADDRESS<4>=ORIG.ZIP
                  T.ADDRESS<5>=ORIG.CITY
                  T.ADDRESS<6>=ORIG.STATE
               END
            END
*DF         END
*DF      END ELSE
*DF*   CALL ELINE('VC.ID WAS NULL! DID NOT READ VEND.CUST.')
*DF      END

DISPLAY.ADDR:
            ADDR.POS = 1

UPDATE.ADDR:
            CRT @(40, 6):'|     ENTER CUST.VEND ADDRESS      '
            CRT @(40, 7):'|--------------------------------------'
            CRT @(40, 8):'| NAME  :':T.ADDRESS<1>'L#30':@(-4)
            CRT @(40, 9):'| ADDR 1:':T.ADDRESS<2>'L#30':@(-4)
            CRT @(40,10):'| ADDR 2:':T.ADDRESS<3>'L#30':@(-4)
            CRT @(40,11):'| ZIP   :':T.ADDRESS<4>'L#30':@(-4)
            CRT @(40,12):'| CITY  :':T.ADDRESS<5>'L#30':@(-4)
            CRT @(40,13):'| STATE :':T.ADDRESS<6>'L#30':@(-4)
            CRT @(40,14):'| UPDATE:':@(-4)
            CRT @(40,15):'---------------------------------------'

EDIT.ADDR:
            HELP = "Enter Cust.Vendor Address information. [X]=Back [EX]=Exit"
            MASK = T.ADDRESS<ADDR.POS>'L#30'
            CALL GEN.IN(49,7+ADDR.POS,MASK,'',Q,0,30,'','',2,49,7+ADDR.POS,1,QI,HELP,0,23)
            QI = OCONV(QI,'MCU')
*DF      CC+=LEN(QI)+1 ; GOSUB PRINT.CC
            BEGIN CASE
               CASE QI='X'
                  CRT @(49,7+ADDR.POS):T.ADDRESS<ADDR.POS>:@(-4)
                  IF ADDR.POS = 1 THEN
                     GOTO 1400
                  END ELSE
                     ADDR.POS-=1
                     GOTO EDIT.ADDR
                  END
               CASE QI='EX'
                  STOP
               CASE 1
                  IF Q#'' THEN T.ADDRESS<ADDR.POS>=TRIM(Q)
                  VAL = T.ADDRESS<ADDR.POS>
                  CRT @(49,7+ADDR.POS):T.ADDRESS<ADDR.POS>:@(-4)
                  IF ADDR.POS = 2 AND (TRIM(VAL) = '' OR TRIM(VAL) = 'BAD ADDRESS') THEN
                     CALL ELINE('MUST HAVE AN ADDRESS.')
                     GOTO EDIT.ADDR
                  END
                  IF ADDR.POS = 3 THEN GOTO SAVE.ADDR
                  ADDR.POS+=1
                  IF ADDR.POS = 5 AND VAL # '' THEN
                     READ T.REC FROM F.ZIPS,VAL THEN
                        T.ADDRESS<5> = T.REC<1>
                        T.ADDRESS<6> = T.REC<2>
                        GOTO UPDATE.ADDR
                     END
                  END
                  GOTO EDIT.ADDR
            END CASE

SAVE.ADDR:
            HELP = "Update Cust.Vendor Address Information? [Y]es [N]o [X]=Back [EX]=Exit"
            MASK = 'Y '
            CALL GEN.IN(49,14,MASK,'',Q,0,2,'','',2,49,14,1,QI,HELP,0,23)
            QI = OCONV(QI,'MCU')
*DF      CC+=LEN(QI)+1 ; GOSUB PRINT.CC
            BEGIN CASE
               CASE QI='X' OR QI='N'
                  GOTO EDIT.ADDR
               CASE QI='EX'
                  STOP
               CASE QI='' OR QI='Y'
               CASE 1
                  CALL ELINE('Invalid Option.  Y, N, X or EX.')
                  GOTO SAVE.ADDR
            END CASE

            IF VC.ID # '' THEN
               OLD.VCUST.NAME = VCUST.REC<1>
               VCUST.REC<1> = T.ADDRESS<1>
               VCUST.REC<3,1>= T.ADDRESS<2>
               VCUST.REC<3,2>= T.ADDRESS<3>
               VCUST.REC<5> = T.ADDRESS<5>
               VCUST.REC<6> = T.ADDRESS<6>
               VCUST.REC<7> = T.ADDRESS<4>
*** BEGIN JCW02
*
* Update VEND.CUST.NAMES file
*
               IF VCUST.REC<1> # OLD.VCUST.NAME THEN
*** Remove link to old description in VEND.CUST.NAMES
                  VCN.ID = VCUST.REC<42>
                  READ VCN.REC FROM F.VCN, VCN.ID THEN
                     LOCATE VC.ID IN VCN.REC<2> SETTING POS THEN
                        VCN.REC = DELETE(VCN.REC,2,POS)
                        IF VCN.REC<2> # '' THEN
                           WRITE VCN.REC ON F.VCN, VCN.ID
                        END ELSE
                           DELETE F.VCN, VCN.ID
                           CALL SOUNDEX.EDIT(OLD.VCUST.NAME,'',VCN.ID,'SDX.VCN,':CLIENT.ID)
                        END
                     END
                  END
*** Add link to new description to VEND.CUST.NAMES
                  STMT = 'SELECT VEND.CUST.NAMES,':CLIENT.ID:' WITH 1 = "':VCUST.REC<1>:'" SAMPLE 1'
                  EXECUTE STMT RTNLIST VCN.LIST CAPTURING MSG
                  BEGIN CASE
*** New Vend/Cust Description
                     CASE @SELECTED < 1
                        GOSUB ADD.NEW.VCN
                        VCN.REC = ''
                        VCN.REC<1> = VCUST.REC<1>
                        VCN.REC<2> = VC.ID
                        WRITE VCN.REC TO F.VCN, VCN.ID
                        CALL SOUNDEX.EDIT('',VCUST.REC<1>,VCN.ID,'SDX.VCN,':CLIENT.ID)
*** Description is already in VEND.CUST.NAMES
                     CASE @SELECTED = 1
                        READNEXT VCN.ID FROM VCN.LIST THEN
                           READ VCN.REC FROM F.VCN, VCN.ID THEN
                              LOCATE VC.ID IN VCN.REC<2> SETTING POS ELSE
                                 VCN.REC<2,-1> = VC.ID
                                 WRITE VCN.REC ON F.VCN, VCN.ID
                              END
                           END
                        END
                  END CASE
                  VCUST.REC<42> = VCN.ID
               END
*** END JCW02
** Update VEND.CUST record
               WRITE VCUST.REC ON F.VEND.CUST,VC.ID
** Update Soundex file for VEND.CUST  (Remove old name and add New Name)
               CALL SOUNDEX.EDIT(OLD.VCUST.NAME,VCUST.REC<1>,VC.ID,'SDX.VEND.CUST,':CLIENT.ID)
*** Update VEND.CUST.XREF file ; * JCW03
               ZIP = VCUST.REC<7>             ; * JCW03
               DESC = VCUST.REC<1>            ; * JCW03
               DESC = TRIM(OCONV(DESC,'MCU')) ; * JCW03
               IF ZIP # 99999 THEN            ; * JCW03
                  XREF.ID = DESC:'*':ZIP      ; * JCW03
               END ELSE                       ; * JCW03
                  XREF.ID = DESC              ; * JCW03
               END                            ; * JCW03
               WRITEV VC.ID TO F.VC.XREF, XREF.ID, 1                    ; * JCW03
*** Update VEND.CUST.ZIPS file                           ; * JCW03
               READ VC.ZIP.REC FROM F.VC.ZIPS, ZIP ELSE VC.ZIP.REC = '' ; * JCW03
               LOCATE VC.ID IN VC.ZIP.REC<1> SETTING POS ELSE           ; * JCW03
                  VC.ZIP.REC<1,-1> = VC.ID                              ; * JCW03
                  WRITE VC.ZIP.REC TO F.VC.ZIPS, ZIP                    ; * JCW03
               END                                                      ; * JCW03
            END ELSE
*              CALL ELINE('VC.ID WAS NULL! DID NOT UPDATE VEND.CUST')
            END

            CUST.VEND.ADDR = T.ADDRESS
            GOSUB 8100                   ; * Display screen
            GOSUB 8200                   ; * Display data
*DF   END

         END
      END

*---- Enter class

1475:
      IF CL.CLS.FLAG = 'Y' THEN
         BACK.FLAG = 0
         CALL FB.2.1.CLASS(CLASS,QI,'E')
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = 'X'
               BACK.FLAG = 1
               CALL FB.CLEAR.WINDOW
               GOTO 1400
            CASE QI = 'EX'
               STOP
         END CASE
         WEIGHT = 0
         X = DCOUNT(CLASS<2>,CHAR(253))
         FOR I = 1 TO X
            WEIGHT = WEIGHT+CLASS<2,I>
         NEXT I
      END ELSE
         IF BACK.FLAG THEN GOTO 1400
      END

*---- Enter bill of lading code

1500:
      IF CL.BOL.FLAG = 'Y' THEN
         BACK.FLAG = 0
         CALL FB.2.1.BOL(CLIENT.ID,MAT CLIENT.REC,BOL,QI,'E')
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = 'X'
               BACK.FLAG = 1
               GOTO 1475
            CASE QI = 'EX'
               STOP
         END CASE
      END ELSE
         IF BACK.FLAG THEN GOTO 1475
      END

*---- Enter discounts

1550:
      IF CL.DISC.FLAG = 'Y' THEN
         BACK.FLAG = 0
         CALL FB.2.1.DISC(DISC.PERC,DISC.DET,NET,QI)
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = 'X'
               BACK.FLAG = 1
               GOTO 1500
            CASE QI = 'EX'
               STOP
         END CASE

1555:
         IF DISC.PERC = 0 THEN
            DISC.FLAG = ''
            LOOP
            UNTIL DISC.FLAG # '' DO
               HELP = "Enter Y if pro is discountable or N if not."
               CRT CHAR(7):CHAR(7)
               CALL GEN.IN(36,18,'Is pro discountable? N','',Q,1,1,'','',1,-1,18,0,QI,HELP,0,23)
               QI = OCONV(QI,'MCU')
               BEGIN CASE
                  CASE QI = 'N'
                     DISC.FLAG = 'N'
                     HELP = "Enter Y if pro is minimum charge or N if not."
                     CRT CHAR(7):CHAR(7)

1560:
                     CALL GEN.IN(36,19,'Is pro minimum charge? N','',Q,1,1,
                     '','',1,-1,19,0,QI,HELP,0,23)
                     QI = OCONV(QI,'MCU')
                     BEGIN CASE
                        CASE QI = 'N' ! QI = ''
                           MIN.CHG = 'N'
                        CASE QI = 'Y'
                           IF NET LE '6500' THEN
                              MIN.CHG = 'Y'
                           END ELSE
                              CALL ELINE('Net value of pro is greater than $65.00')
                              MIN.CHG = 'N'
                           END
                        CASE 1
                           GOTO 1560
                     END CASE
                     QI = OCONV(QI,'MCU')
                  CASE QI = 'Y'
                     DISC.FLAG = 'Y'
                  CASE 1
                     CALL ELINE('Invalid entry!')
               END CASE
            REPEAT
         END
         CARRIER.CHG = NET
      END ELSE
         IF BACK.FLAG THEN GOTO 1500
      END


1575:
      BACK.FLAG = 0
      IF CHECK.NUM='' THEN CHECK.NUM=OLD.CHECK.NUM
      IF CHECK.DATE='' THEN CHECK.DATE=OLD.CHECK.DATE
      CALL FB.2.1.CHECK(CLIENT.ID,MAT CLIENT.REC,CHECK.NUM,CHECK.DATE,QI,'E')
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = 'X'
            BACK.FLAG = 1
            GOTO 1550
         CASE QI = 'EX'
            STOP
      END CASE


*---- Enter weight

1600:
      IF CL.WT.FLAG = 'Y' THEN
         BACK.FLAG = 0
         HELP = 'Enter the shipment weight. [X]=Back [EX]=Exit'
         IF WEIGHT = '' THEN REQ = 1 ELSE REQ = 0
         CALL GEN.IN(1,19,WEIGHT'R#6','',Q,REQ,6,'','',2,-6,19,0,QI,
         HELP,0,23)
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = 'X'
               CRT @(1,19):'      ':
               BACK.FLAG = 1
               GOTO 1575
            CASE QI = 'EX'
               STOP
            CASE CHANGE.FLAG & QI = ''
               Q = WEIGHT
            CASE QI = ''
               Q = WEIGHT
            CASE NUM(QI)
               Q = QI
            CASE 1
               GOTO 1600
         END CASE
         WEIGHT = Q
         CALL FB.CLEAR.WINDOW
         CRT @(1,19):WEIGHT'R#6'
      END ELSE
         IF BACK.FLAG THEN GOTO 1575
      END

*---- Enter carrier charge

1700:
      BACK.FLAG = 0
      HELP = "Enter the Carrier's Charge. [X]=Back [EX]=Exit"
      IF CARRIER.CHG = '' THEN REQ = 1 ELSE REQ = 0
      CALL GEN.IN(8,19,CARRIER.CHG'R26#7','AMT2',Q,REQ,7,'','',2,-7,19,0,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = ''
            Q = CARRIER.CHG
         CASE QI = 'X'
            CRT @(8,19):'       ':
            BACK.FLAG = 1
            GOTO 1600
         CASE QI = 'EX'
            STOP
         CASE NUM(QI)
            VAR.ARR = ''
            ACTUAL.CHG = ''
         CASE 1
            GOTO 1700
      END CASE
      CARRIER.CHG = Q'R0'
      CRT @(8,19):CARRIER.CHG'R26#7'
      IF ACTUAL.CHG = '' THEN ACTUAL.CHG = CARRIER.CHG

*---- Enter actual charge

1800:
*      BACK.FLAG = 0
*      HELP = "Enter the Actual Charge. [X]=Back [EX]=Exit"
*      CALL GEN.IN(16,19,ACTUAL.CHG'R26#7','AMT2',Q,0,7,'','',2,-7,
*         19,0,QI,HELP,0,23)
*      QI = OCONV(QI,'MCU')
*      BEGIN CASE
*         CASE QI = ''
*            Q = ACTUAL.CHG
*         CASE QI = 'X'
*            CRT @(16,19):'       ':
*            GOTO 1700
*         CASE NUM(QI)
*            VAR.ARR = ''
*         CASE QI = 'EX'
*            STOP
*         CASE 1
*            GOTO 1800
*      END CASE
*      ACTUAL.CHG = Q'R0'
      ACTUAL.CHG = CARRIER.CHG
      CRT @(16,19):ACTUAL.CHG'R26#7'
*      IF ACTUAL.CHG GT CARRIER.CHG THEN
*         CALL ELINE('ERROR - Actual charge cannot be greater than carrier charge.')
*         GOTO 1800
*      END

*---- Display mileage
*---- Display mileage
      IF CL.MILE.FLAG = 'Y' THEN
         IF SENT.TO.PCMILER THEN
            VIN='READ'
            VIN<2>=CH.NUM
***            CALL PCMILER(VIN,VOUT,F.PCIN,F.PCOUT,F.MILEAGE)

            IF USER = "NPRATT" THEN
               DEBUG
               CALL PCMILER.NP(VIN,VOUT,F.PCIN,F.PCOUT,F.MILEAGE)
               DEBUG
            END ELSE
               CALL PCMILER.BETA(VIN,VOUT,F.PCIN,F.PCOUT,F.MILEAGE)
            END

            SENT.TO.PCMILER=0
            MILEAGE=VOUT<1>
            IF MILEAGE = '' THEN                            ;* NPR99
               CALL ELINE("2 Unable to calculate mileage ")   ;* NPR99
            END                                             ;* NPR99
         END
         CRT @(5,15):MILEAGE'L1,#10'
         CRT @(0,22):@(-4):
      END

*---- Calculate charges

1850:
      CHARGES = 0
      CALL FB.2.1.RATE(CLIENT.ID,CARRIER.ID,CLASS,MILEAGE,WEIGHT,CHARGES,MARGIN)

*---- Check actual charges against calculated charges

      IF CHARGES # 0 THEN
         XX = ACTUAL.CHG-CHARGES
         IF XX GT MARGIN THEN
            CRT @(0,21):CHAR(7):CHAR(7):
            LOOP
               CALL INPUT.CLEAR(0,21)
               HELP = "[Y]=Yes. [N]=No."
               DVAR = "WARNING - Actual ":CHARGES'L26,'
               DVAR := ", Overcharge ":XX'L26,'
               DVAR := ", set bill aside for auditor? Y"
               CALL GEN.IN(0,22,DVAR,'',Q,0,1,'','',0,-1,22,1,QI,HELP,0,23)
               QI = OCONV(QI,'MCU')
            UNTIL QI = 'Y' ! QI = 'N' ! QI = '' DO
            REPEAT
            IF QI # 'N' THEN
               GOSUB 8100
               GOTO 300                  ; * ENTER PRO
            END
         END
      END

*---- Select variance

1900:
      VARIANCE = (CARRIER.CHG-ACTUAL.CHG)'R0'
      CRT @(25,19):VARIANCE'R26#7'
      IF VARIANCE # 0 & VERSION = 0 THEN
         BACK.FLAG = 0
         CALL FB.2.1.VARIANCE(MAT CLIENT.REC,BAL.DUE,VARIANCE,VAR.ARR,QI)
         GOSUB 8100                      ; * Display screen
         GOSUB 8200                      ; * Display data
         IF QI = 'X' THEN
            BACK.FLAG = 1
            CRT @(16,19):'       ':
            GOTO 1700
         END
         IF QI = 'D' THEN GOTO 1900
         IF QI = 'EX' THEN STOP
      END ELSE
         IF BACK.FLAG THEN
            CRT @(16,19):'       ':
            GOTO 1700
         END
      END
********************* Add Misrouting **********************
*---- Enter Misrouting charge

1950:
*OH   IF APRVD.CARRS & APRVD.CARRIER='N' THEN
      IF CL.MISROUTE.CH='Y' THEN
         BACK.FLAG = 0
         HELP = "Enter the Misrouting Charge. [X]=Back [EX]=Exit"
         REQ=0
         CALL GEN.IN(33,19,MISROUTING'R26#10','AMT2',Q,REQ,9,'','',2,-10,19,0,QI,HELP,0,23)
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = ''
               Q = MISROUTING
            CASE QI = 'X'
               CRT @(33,19):'          ':
               CRT @(16,19):'       ':
               GOTO 1700
            CASE NUM(QI)
               NULL
            CASE QI = 'EX'
               STOP
            CASE 1
               GOTO 1950
         END CASE
         MISROUTING = Q'R0'
         CRT @(33,19):MISROUTING'R26#10'
         IF MISROUTING > ACTUAL.CHG THEN
            CALL ELINE('ERROR - Misrouting Charge cannot be greater than the actual charge.')
            GOTO 1950
         END
      END ELSE
         IF BACK.FLAG THEN GO 1900
      END
***********************************************************

*---- Enter air shipment pieces

2000:
      IF T.MODE = 'AIR' & CL.AIR.FLAG = 'Y' THEN
         BACK.FLAG = 0
         HELP = 'Enter the number of air pieces. [X]=Back [EX]=Exit'
         IF AIR.PIECES = '' THEN REQ = 1 ELSE REQ = 0
         CALL GEN.IN(0,21,AIR.PIECES'R#7','',Q,REQ,7,'','',2,-7,21,0,QI,HELP,0,23)
         QI = OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI = 'X'
               CRT @(0,21):'       ':
               BACK.FLAG = 1
               GOTO 1950
            CASE QI = 'EX'
               STOP
            CASE CHANGE.FLAG & QI = ''
               Q = AIR.PIECES
            CASE QI = ''
               Q = AIR.PIECES
            CASE NUM(QI)
               Q = QI
            CASE 1
               GOTO 2000
         END CASE
         AIR.PIECES = Q
         CRT @(0,21):AIR.PIECES'R#7'
      END ELSE
         IF BACK.FLAG THEN GOTO 1950
      END

*---- Enter expense distributions

2100:
      IF CL.EXP.DIST.FLAG MATCHES 'Y':@VM:'O' AND VERSION = 0 THEN
         BACK.FLAG = 0
         IF CL.EXP.DIST.FLAG = 'Y' THEN
            IF DTAB<3> = '' THEN DTAB<3> = ACTUAL.CHG
            QI = ''
            CALL FB.2.1.DIST(F.DIV,F.EXP,ACTUAL.CHG,DTAB,QI)
         END ELSE
            IF CHANGE.FLAG = 1 THEN DATA 'Y'
            HELP = "Distribute expenses? [Y or 1]=Yes [N or cr]=No [X]=Back [EX]=Exit"
            CRT @(0,22):
            CALL GEN.IN(0,22,'Enter option please. --','',Q,0,2,'',
            '',2,-2,22,1,Q2,HELP,0,23)
            Q2 = OCONV(Q2,'MCU')
            IF Q = 'Y' ! Q = '1' THEN
               QI = ''
               CALL FB.2.1.DIST(F.DIV,F.EXP,ACTUAL.CHG,DTAB,QI)
            END ELSE
               DTAB<3> = ACTUAL.CHG
            END
            IF Q2 = 'X' THEN
               BACK.FLAG = 1
               GOTO 2000
            END
            IF Q2 = 'EX' THEN STOP
         END
      END ELSE
         IF BACK.FLAG THEN GOTO 2000
         DTAB<3> = ACTUAL.CHG
         QI = ''
      END
      IF QI = 'X' THEN
         BACK.FLAG = 1
         GOTO 2000
      END
      IF QI = 'EX' THEN STOP

*---- Enter variance distributions

2200:
      QI = ''
      IF CL.VAR.FLAG = 'Y' & VERSION = 0 THEN
         IF VAR.ARR<3> # 0 THEN
            BACK.FLAG = 0
            CALL FB.2.1.VAR.DIST(F.VAR,VAR.ARR<3>,VAR.REC,QI)
            IF QI = 'X' THEN
               BACK.FLAG = 1
               GOTO 2100
            END
            IF QI = 'EX' THEN STOP
         END ELSE
            IF BACK.FLAG THEN GOTO 2100
         END
      END ELSE
         IF BACK.FLAG THEN GOTO 2100
      END

*
*---- Enter Bill Line Items
*
2250: * Enter/Correct Mileages
      IF OVERRIDE.MILEAGE='N' THEN
         IF BACK.FLAG THEN GO 2200
         GO 2300
      END
      IF MILEAGE='' THEN MASK='######' ELSE MASK=MILEAGE'L#6'
      HELP = 'Enter another Mileage or Press <Enter> to accept'
      CALL GEN.IN(0,22,'Mileage: ':MASK,'',Q,0,6,'','',2,-6,22,1,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      IF QI = 'EX' THEN STOP
      IF QI = 'X' THEN
         BACK.FLAG=1
         GO 2200
      END
      IF QI#'' THEN
         IF NOT(NUM(QI)) THEN
            CALL ELINE("ERROR! You must enter a mileage or 0 if you don't know the miles")
            GO 2250
         END
         IF QI < 0 THEN
            CALL ELINE("ERROR! The mileage must be a positive number!")
            GO 2250
         END
         MILEAGE=QI
         IF QI<100 THEN CALL ELINE("WARNING Mileage is less than 100 Miles")
      END
2300:
*----
      IF DATA.ENTRY.OPTS2<1,1>='Y' THEN  ; * Enter Line Items
         VIN=TASKMAN
         VIN<2>=ORIG.ZIP
         VIN<3>=DEST.ZIP
         VIN<4>=COMP.WITH.AFS95
         VIN<5>=CH.NUM
         VIN<6>=ORIG.CITY:', ':ORIG.STATE:' ':ORIG.ZIP
         VIN<7>=DEST.CITY:', ':DEST.STATE:' ':DEST.ZIP
         VIN<8>=TARIFF.ACT.NAME
         VIN<9>=TARIFF.EFF.DATE
         VIN<10>=TARIFF.FACTOR
         VIN<11>=TARIFF.DRIVER
         VIN<12>=CL.ZIP.RTE
         IF VIN<12>='Y' AND DCOUNT(ZIP.ARR, @VM)>2 THEN
            VIN<13>=NUM.ZIPS
         END ELSE
            VIN<13>=0
         END
         VIN<14> = MILEAGE               ; * JMB
*IF USER='OWEN' OR USER='DAVID' THEN
*IF USER = 'JAMES' THEN
*  CALL LI.TEST(LI.CODES,QI,LINE.ITEMS,CARRIER.CHG,'E',F.PCIN,F.PCOUT,VIN,VOUT)
*  CALL JBLI.TXT(LI.CODES,QI,LINE.ITEMS,CARRIER.CHG,'E',F.PCIN,F.PCOUT,VIN,VOUT); *JMB
*END ELSE
*        CALL FB.2.1.LINE.ITEMS(LI.CODES,QI,LINE.ITEMS,CARRIER.CHG,'E',F.PCIN,F.PCOUT,VIN,VOUT)      ; * JMK04
         CALL FB.2.1.LINE.ITEMS(LI.CODES,QI,LINE.ITEMS,CARRIER.CHG,'E',F.PCIN,F.PCOUT,F.TABLES,VIN,VOUT)       ; * JMK04
*END
         IF QI='X' THEN
            GOSUB 8100
            GOSUB 8200
            BACK.FLAG=1
            GOTO 2250
         END
      END ELSE
         IF BACK.FLAG THEN GOTO 2200
      END

* Item update
*
4900:
      HELP = '[Y]=Update. [N]=No update. [W]=Carrier Warning. [X]=Back. [EX]=Exit'
      CALL GEN.IN(0,22,'Update? Y ','',Q,0,2,'','',2,-2,22,1,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = 'EX'
            STOP
         CASE QI = 'N'
            CHANGE.FLAG = 0
            GOSUB 8100                   ; * Display screen
            GOTO 300                     ; * ENTER PRO
         CASE QI = 'X'
            IF VERSION GT 0 THEN
               CALL ELINE('Back up not allowed on duplicate posting.')
               GOTO 4900                 ; * UPDATE ACTION
            END
            BACK.FLAG = 1
            GOTO 2300
         CASE QI = 'Y' ! QI = 'W' ! QI = ''
            PRO.REC = ''
            PRO.REC<1> = BILL.DATE
            PRO.REC<2> = IN.OUT
            PRO.REC<3> = ORIG.ZIP
            PRO.REC<4> = DEST.ZIP
            PRO.REC<5> = EXP.CODE
            PRO.REC<6> = WEIGHT
            PRO.REC<7> = CARRIER.CHG
            PRO.REC<8> = ACTUAL.CHG
            IF DIVISION='' THEN DIVISON='00001'    ; * Always have a Div #
            PRO.REC<9> = DIVISION
            PRO.REC<10> = 0-VAR.ARR<1>
            PRO.REC<11> = 0-VAR.ARR<2>
            PRO.REC<12> = 0-VAR.ARR<3>
            PRO.REC<13> = CHECK.AMT
            PRO.REC<14> = CHECK.NUM
            OLD.CHECK.NUM=CHECK.NUM
            PRO.REC<15> = CHECK.DATE
            OLD.CHECK.DATE=CHECK.DATE
            PRO.REC<16> = BOL
            IF CL.BOL.CRX.FLAG = 'Y' THEN
               GOSUB SET.BOL.CRX
            END
            PRO.REC<17> = CONSIGN.DESC
            PRO.REC<18> = ZIP.ARR<1>
*NPR02 Start Changes
            NUM.ZIPS = DCOUNT(PRO.REC<18>, @VM)
            IF NUM.ZIPS > 1 THEN
               DEL PRO.REC<18,NUM.ZIPS>
               DEL PRO.REC<18,1>
            END
*NPR02 End Changes
            PRO.REC<19> = MILEAGE
            PRO.REC<20> = CARRIER.ID
            X = DCOUNT(DISC.DET,@AM)
            FOR I = 1 TO X
               PRO.REC<22,I> = DISC.DET<I,1>
               PRO.REC<23,I> = DISC.DET<I,2>
            NEXT I
            PRO.REC<24> = DISC.PERC
            PRO.REC<25> = ORIG.STATE
            PRO.REC<26> = DEST.STATE
            PRO.REC<27> = ORIG.CITY
            PRO.REC<28> = DEST.CITY
            PRO.REC<38> = DUE.DATE
            VAR.CODE = ''
            IF VARIANCE = 0 THEN VAR.ARR = ''
            IF VAR.ARR<1>'R0' # 0 ! VAR.ARR<4>'R0' NE 0 THEN
               VAR.CODE = VAR.CODE:'D'
            END
            IF VAR.ARR<2>'R0' # 0 ! VAR.ARR<5>'R0' NE 0 THEN
               VAR.CODE = VAR.CODE:'O'
            END
            IF VAR.ARR<3>'R0' # 0 ! VAR.ARR<6>'R0' NE 0 THEN
               VAR.CODE = VAR.CODE:'C'
            END
            PRO.REC<29> = VAR.CODE
            E.DATE = ''
            READV E.DATE FROM F.HIST, OLD.PRO.ID, 30 THEN
               PRO.REC<30> = E.DATE
            END
            IF VERSION > 0 THEN
               READV E.DATE FROM F.HIST, PRO.ID, 30 ELSE
                  PRO.REC<30> = DATE()
               END
            END
            IF PRO.REC<30> = '' THEN PRO.REC<30> = DATE()
            PRO.REC<31> = DTAB<1>
            PRO.REC<32> = DTAB<2>
            PRO.REC<33> = DTAB<3>
            PRO.REC<34> = 0-VAR.ARR<4>
            PRO.REC<35> = 0-VAR.ARR<5>
            PRO.REC<36> = 0-VAR.ARR<6>
            PRO.REC<40> = BANK.ID
            PRO.REC<88> = OLD.PRO.REC<88>          ; * Copy over EDI Links
            IF (OLD.PRO.REC<88>) THEN
               PRO.REC<39>='V'           ; * IF EDI, Mark as verified
            END
            READV P.DATE FROM F.HIST, OLD.PRO.ID, 37 THEN
               PRO.REC<37> = P.DATE
            END
            PRO.REC<41,1> = VAR.ARR<7>
            PRO.REC<41,2> = VAR.ARR<8>
            PRO.REC<41,3> = VAR.ARR<9>
            PRO.REC<42> = VOID.DESC
            PRO.REC<45> = DISC.FLAG
            PRO.REC<46> = MIN.CHG
            APRVD.CARRIER = 'N'
            IF APRVD.CARRS THEN
               GOSUB SET.APRVD.CARR
            END
            PRO.REC<47> = APRVD.CARRIER
            IF QI = 'W' THEN PRO.REC<48> = 'Y' ELSE PRO.REC<48> = ''
            CALC = 0
            COST.MILE = 0
            IF MILEAGE'R0' # 0 THEN
               COST.MILE = OCONV(ACTUAL.CHG,'MD2')/MILEAGE
               COST.MILE = ICONV( COST.MILE,'MD2' )
            END
            IF COST.MILE LT CL.CPM.MIN OR CL.CPM.MIN = '' THEN
               COST.MILE = ''
            END
            PRO.REC<49> = COST.MILE'R0'
            PRO.REC<50> = CLASS<1>
            PRO.REC<51> = VAR.REC<1>
            PRO.REC<52> = VAR.REC<2>
            PRO.REC<56> = VAR.REC<3>
            IF PRO.REC<53> = '' THEN PRO.REC<53> = USER
            PRO.REC<55> = LEN(PRO.REC)-LEN(USER)
            PRO.REC<57> = AIR.PIECES
            PRO.REC<58> = CLASS<2>
            PRO.REC<63> = MISROUTING
            IF DATA.ENTRY.OPTS2<1,1>='Y' THEN      ; * Line Items
               FOR X = 1 TO 14
                  PRO.REC<X+69>=LINE.ITEMS<X>
               NEXT X
               LOCATE 'MIN' IN LINE.ITEMS<1> SETTING POS THEN
                  PRO.REC<46>='Y'
               END
               TIMES=DCOUNT(LINE.ITEMS<6>,CHAR(253))
               TWGT=0
               FOR X = 1 TO TIMES
                  TWGT += LINE.ITEMS<6,X>
               NEXT X
               PRO.REC<6> = TWGT
            END
            IF TIME.ENT='' THEN TIME.ENT=TIME()
            PRO.REC<85>=TIME.ENT
            IF DATE.ENT='' THEN DATE.ENT=DATE()
            PRO.REC<86>=DATE.ENT
            PRO.REC<87>=COMP.WITH.AFS95  ; * Flag if "Y" Dont Send to AFS95
            IF VERSION GT 0 THEN PRO.REC<39> = 'V'
            IF AUDIT THEN               ; * JCW04
               READV CORE.CARRIER FROM F.AUDIT, CARRIER.ID, 13 ELSE ; * JCW04
                  CORE.CARRIER = 'N'    ; * JCW04
               END                      ; * JCW04
            END ELSE                    ; * JCW04
               CORE.CARRIER = 'N'       ; * JCW04
            END                         ; * JCW04
            PRO.REC<197> = CORE.CARRIER ; * JCW04
* Force a Division of 1 even if they don't specify a division
            IF PRO.REC<9>='' THEN PRO.REC<9>='00001'
            IF CHANGE.FLAG THEN
*              WRITE OLD.PRO.ID:@FM:USER:@FM:PRO.ID:@FM:OLD.PRO.REC<8> ON F.DEL.BILLS, DATE():'*':TIME()
               DELETE F.BILLS,OLD.PRO.ID
               DELETE F.HIST,OLD.PRO.ID
*              DELETE F.CRX,OLD.PRO.ID ; ** Do Not Delete for TS
*              DELETE F.OPEN,CLIENT.ID:'*':OLD.PRO.ID
            END
            IF VOIDED THEN
               WRITEV VOID.DESC ON F.HIST,OLD.PRO.ID,42
               WRITEV VOID.DESC ON F.BILLS,OLD.PRO.ID,42
               PRO.REC<39> = 'V'
            END
            IF PRO.REC<37> = '' ! VERSION GT 0 THEN
*              IF CLIENT.ID # '00000' THEN WRITE PRO.REC ON F.BILLS,PRO.ID
            END
            WRITE PRO.REC ON F.HIST,PRO.ID
            WRITE PRO.REC ON F.BILLS,PRO.ID
            VIN=USER                     ; * User 'MCU' That Gets Credit
            VIN<2>=TIME()                ; * Current Time
            VIN<3>=DATE()                ; * Bill Date (Use Today)
            VIN<4>='E'                   ; * "E"ntered
            VIN<5>=CLIENT.ID
            CHARS=0
            IF OLD.PRO.REC='' THEN CHARS+=LEN(PRO)           ; * Pro Number
*           CHARS+=LEN(PRO.REC<31>) ;* MV Expense Codes
*           CHARS+=LEN(PRO.REC<33>) ;* MV Expense Code Amounts
            CHARS+=LEN(PRO.REC<6>)-LEN(OLD.PRO.REC<6>)       ; * Weight
*           CHARS+=LEN(PRO.REC<16>) ;* Bill Of Lading
            CHARS+=LEN(PRO.REC<3>)       ; * Origin Zip Code
            CHARS+=LEN(PRO.REC<3>)-LEN(OLD.PRO.REC<3>)       ; * Orig Zip
            CHARS+=LEN(PRO.REC<4>)-LEN(OLD.PRO.REC<4>)       ; * Dest Zip
*           CHARS+=LEN(PRO.REC<17>) ;* Customer / Vendor
*           CHARS+=LEN(PRO.REC<41>) ;* Cutback Codes
            CHARS+=LEN(PRO.REC<2>)-LEN(OLD.PRO.REC<2>)       ; * I/O/T
*           CHARS+=LEN(PRO.REC<63>) ;* Misroute Amount
            CHARS+=LEN(PRO.REC<70>)-LEN(OLD.PRO.REC<70>)     ; * Code
            CHARS+=LEN(PRO.REC<71>)-LEN(OLD.PRO.REC<71>)     ; * Pieces
            CHARS+=LEN(PRO.REC<72>)-LEN(OLD.PRO.REC<72>)     ; * Hax Mat
            CHARS+=LEN(PRO.REC<74>)-LEN(OLD.PRO.REC<74>)     ; * Class
            CHARS+=LEN(PRO.REC<75>)-LEN(OLD.PRO.REC<75>)     ; * Weight
            CHARS+=LEN(PRO.REC<76>)-LEN(OLD.PRO.REC<76>)     ; * Carr Rate
            CHARS+=LEN(PRO.REC<77>)-LEN(OLD.PRO.REC<77>)     ; * Carr Charge
            CHARS+=LEN(PRO.REC<83>)-LEN(OLD.PRO.REC<83>)     ; * Carr Disc
            VIN<6>=CHARS                 ; * Characters Keyed
            IF OLD.PRO.REC<70>='' THEN VIN<7>=1    ; * New Bill (Not Changed)
            VIN<10>=CHR.START.TIME       ; * JMK02
            VIN<11>=TIME()               ; * JMK02
            CALL EMP.PERF.UPDATE(VIN,VOUT,F.EMP.HR.PERF,F.EMP.DY.PERF)
            IF CLIENT.ID = '00000' THEN
*              WRITE PRO.REC ON F.OPEN.BILLS,PRO.ID
            END
            IF CHANGE.FLAG THEN
               IF PRO.REC<37> # '' THEN
*                 WRITE PRO.REC ON F.OPEN,CLIENT.ID:'*':PRO.ID
                  CHANGE = PRO.REC<8>-OLD.PRO.REC<8>
                  IF CHANGE # 0 THEN
*                    GOSUB WRITE.MODS
                  END
               END
            END

*---- Update freight bill cross reference (skeletal) record

            IF SEQ.FLAG ELSE
               REC = ''
               REC<1> = CLIENT.ID
               REC<2> = BILL.DATE
               REC<7> = PRO.REC<7>
               REC<8> = PRO.REC<8>
               REC<10> = PRO.REC<10>
               REC<11> = PRO.REC<11>
               REC<12> = PRO.REC<12>
               REC<30> = DATE()
               REC<37> = PRO.REC<37>
               REC<41> = PRO.REC<41>
               REC<53> = PRO.REC<53>
               REC<54> = PRO.REC<54>
               REC<55> = PRO.REC<55>
               REC<63> = PRO.REC<63>
               IF CLIENT.ID[1,2]='99' ELSE
                  WRITE REC ON F.CRX,PRO.ID
               END
            END
            CHANGE.FLAG = 0
            GOSUB 8100                   ; * Display screen
            CHR.START.TIME=TIME()        ; * JMK02
            GOTO 300                     ; * ENTER PRO
      END CASE
      GOTO 4900                          ; * UPDATE ACTION

*----

*---- INTERNAL SUBROUTINES

*----

*----
8000:
*---- Initialize data
*

      PRO = '' ; BILL.DATE = '' ; DUE.DATE = ''
      IN.OUT = '' ; DIVISION = ''
      EXP.CODE = '' ; CONSIGN.DESC = '' ; EXP.CODE.DESC = '' ; BOL = ''
      WEIGHT = '' ; CARRIER.CHG = '' ; ACTUAL.CHG = '' ; VARIANCE = ''
      VAR.ARR = '' ; DTAB = '' ; CHECK.NUM = '' ; ZIP.ARR = ''
      CHECK.AMT = '' ; CHECK.DATE = ''
      ORIG.ZIP = '' ; DEST.ZIP = '' ; ORIG.CITY = '' ; DEST.CITY = ''
      ORIG.STATE = '' ; DEST.STATE = '' ; VOID.DESC = '' ; MILEAGE = ''
      DISC.DET = '' ; DISC.PERC = 0 ; DISC.FLAG = '' ; MIN.CHG = ''
      VAR.REC = '' ; CLASS = '' ; BANK.ID = '' ; AIR.PIECES = ''
      MISROUTING=''
*OH   CARRIER.NAME = '' ; CARRIER.CITY = ''
*OH   CARRIER.STATE=''; APRVD.STR=''

      RETURN

*----
8100:
*---- Display screen
*

      CALL AFS.SCR.REFRESH(PROG.NAME, PROG.DESC, PACK.NAME, CO.NAME,
      TIME.DATE, 1)

      CRT @(0,3):'Client number  ':CLIENT.ID:' ':HLB:CLIENT.NAME:HLA:@(-4)
      CRT @(59,3):'Override Mileage: ':OVERRIDE.MILEAGE:
      CRT @(0,4):'Carrier number ':CARRIER.ID:' ':CARRIER.NAME:' ':CARRIER.CITY:
*OH   CRT ', ':CARRIER.STATE:APRVD.STR:@(-4):
*KD
      IF CARRIER.ID='' ELSE
         CRT ', ':CARRIER.STATE:@(-4):
      END
      CRT @(0,5):STR('-',79)
      CRT @(0,6):'Pro..'
      CRT @(0,7):'Date.'
      CRT @(0,8):'I/O..'
      CRT @(0,9):'Div..'
      CRT @(0,10):'Orig.'
      CRT @(0,11):'Dest.'
      CRT @(0,12):'Exp..'
      CRT @(0,14):'Clas.'
      CRT @(0,15):'Mile.'
      CRT @(0,16):'        Carrier  Actual          Misrouting'
      CRT @(0,17):' Weight Charges Charges Variance  Charges'
      CRT @(0,18):' ------ ------- ------- -------- ----------'
      CRT @(0,20):'Air Pcs'

      IF BAL.DUE THEN CRT @(25,16):'Bal Due'
      IF CHANGE.FLAG THEN GOSUB 8200

      RETURN

*----
8200:
*---- Display data
*

      CRT @(5,6):PRO:' Version ':VERSION
      CRT @(5,7):BILL.DATE'D2/':
      IF DUE.DATE # '' THEN CRT @(14,7):'Due ':DUE.DATE'D2/'
      CRT @(5,8):IN.OUT'L#5':
      IF DIVISION # '' THEN CRT @(5,9):DIVISION'R%5':

      IF ORIG.ZIP # '' THEN
         DESC = ORIG.ZIP'L#6'
         DESC = DESC:' ':ORIG.CITY:', ':ORIG.STATE
         CRT @(5,10):DESC:@(-4):
      END
      IF DEST.ZIP # '' THEN
         DESC = DEST.ZIP'L#6'
         DESC = DESC:' ':DEST.CITY:', ':DEST.STATE
         CRT @(5,11):DESC:@(-4):
      END

      CRT @(5,12):EXP.CODE:' ':EXP.CODE.DESC:@(-4):
      IF CONSIGN.DESC # '' THEN
         IF IN.OUT = 'I' THEN
            LN = 'Vend ':CONSIGN.DESC
         END ELSE
            LN = 'Cust ':CONSIGN.DESC
         END
         CRT @(0,13):LN
      END

      CRT @(5,14):CLASS<1,1>
      CRT @(5,15):MILEAGE'L1,#10'
      CRT @(0,19) : WEIGHT'R#7' : CARRIER.CHG'R26#8' :
      CRT ACTUAL.CHG'R26#8' : VARIANCE'R26#9' : MISROUTING'R26#11' :
      CRT @(0,21):AIR.PIECES'R#7'
      IF VOID.DESC # '' THEN CRT @(0,21):'Voided - ':VOID.DESC'L#60'

*---- Select inquire options

      IF QI = 'I' THEN
         LOOP
            HELP = "[cr]=Exit. [B]=Bills/Lading. [C]=Class. [D]=Disc. [V]=Var. [E]=Exp. [L]=Logis."
            CALL GEN.IN(0,22,'Enter inquiry options. -','',Q,0,1,'','',1,-1,22,1,QI,HELP,0,23)
         UNTIL QI = '' DO
            QI = OCONV(QI,'MCU')
            BEGIN CASE
               CASE QI = ''
                  NULL
               CASE QI = 'B'
                  CALL FB.2.1.BOL(CLIENT.ID,MAT CLIENT.REC,BOL,QI,'I')
               CASE QI = 'D'
                  CALL FB.2.1.DISC(DISC.PERC,DISC.DET,NET,'I')
                  CALL FB.CLEAR.WINDOW
               CASE QI = 'C'
                  CALL FB.2.1.CLASS(CLASS,QI,'I')
                  CALL FB.CLEAR.WINDOW
               CASE QI = 'V'
                  CALL FB.2.1.VARIANCE(MAT CLIENT.REC,BAL.DUE,VARIANCE,VAR.ARR,'I')
                  GOSUB 8100
                  GOSUB 8200
               CASE QI = 'E'
                  CALL FB.2.1.DIST(F.DIV,F.EXP,ACTUAL.CHG,DTAB,'I')
                  CALL FB.CLEAR.WINDOW
               CASE QI = 'L'
                  CALL FB.2.1.VAR.DIST(F.VAR,VAR.ARR<3>,VAR.REC,'I')
                  CALL FB.CLEAR.WINDOW
            END CASE
         REPEAT
      END

      RETURN

*----
8300:
*---- Assign data
*

      BILL.DATE = PRO.REC<1>
      DUE.DATE = PRO.REC<38>
      IN.OUT = PRO.REC<2>
      ORIG.ZIP = PRO.REC<3>
      DEST.ZIP = PRO.REC<4>
      EXP.CODE = PRO.REC<5>
      WEIGHT = PRO.REC<6>
      CARRIER.CHG = PRO.REC<7>
      ACTUAL.CHG = PRO.REC<8>
      DIVISION = PRO.REC<9>

      VAR.ARR<1> = -PRO.REC<10>
      VAR.ARR<2> = -PRO.REC<11>
      VAR.ARR<3> = -PRO.REC<12>

      BOL = PRO.REC<16>
      CONSIGN.DESC = PRO.REC<17>
      MILEAGE = PRO.REC<19>
      ORIG.STATE = PRO.REC<25>
      DEST.STATE = PRO.REC<26>
      ORIG.CITY = PRO.REC<27>
      DEST.CITY = PRO.REC<28>
      DISC.FLAG = PRO.REC<45>
      MIN.CHG = PRO.REC<46>
      CLASS<1> = PRO.REC<50>
      CLASS<2> = PRO.REC<58>
      AIR.PIECES = PRO.REC<57>

      DTAB<1> = PRO.REC<31>
      DTAB<2> = PRO.REC<32>
      DTAB<3> = PRO.REC<33>
      VAR.ARR<4> = -PRO.REC<34>
      VAR.ARR<5> = -PRO.REC<35>
      VAR.ARR<6> = -PRO.REC<36>
      VAR.ARR<7> = PRO.REC<41,1>
      VAR.ARR<8> = PRO.REC<41,2>
      VAR.ARR<9> = PRO.REC<41,3>
      VOID.DESC = PRO.REC<42>
      VAR.REC<1> = PRO.REC<51>
      VAR.REC<2> = PRO.REC<52>
      VAR.REC<3> = PRO.REC<56>
      VARIANCE = CARRIER.CHG-ACTUAL.CHG
      IF VARIANCE = 0 THEN VAR.ARR = ''

      X = DCOUNT(PRO.REC<22>,CHAR(253))
      FOR I = 1 TO X
         DISC.DET<I,1> = PRO.REC<22,I>
         DISC.DET<I,2> = PRO.REC<23,I>
      NEXT I
      DISC.PERC = PRO.REC<24>
      IF VOID.DESC # '' THEN VOIDED = 1 ELSE VOIDED = 0

      ZIP.ARR = PRO.REC<18>
      IF CL.ZIP.RTE='Y' AND ZIP.ARR='' THEN
         ZIP.ARR<1,1>=ORIG.ZIP
         ZIP.ARR<1,2>=DEST.ZIP
      END
      MISROUTING = PRO.REC<63>

      RETURN

*----
8400:
*---- Get next sequential pro number
*

      READVU NEXT.NUM FROM F.DICT.CLIENTS, 'SEQ', 1 ELSE NEXT.NUM = ''
      NEXT.NUM = NEXT.NUM 'R0'
      IF NEXT.NUM = 0 THEN NEXT.NUM = 1
      NEXT.NUM += 1
      WRITEV NEXT.NUM ON F.DICT.CLIENTS, 'SEQ', 1
      Q = NEXT.NUM 'R%5'

      RETURN

*----
SET.BOL.CRX:
*---- SET BILL-OF-LADING CROSS REFERENCE
*

      OPEN '','FB.BOL.CRX,':CLIENT.ID TO F.BOL.CRX ELSE
         CALL OPEN.ABORT("FB.BOL.CRX,":CLIENT.ID,PROG.NAME)
      END
      X = DCOUNT(BOL<1>,CHAR(253))
      FOR I = 1 TO X
         READ TEMP FROM F.BOL.CRX,BOL<1,I> ELSE
            TEMP = ''
            TEMP<1> = FIELD(PRO.ID,'*',2)
            TEMP<2> = FIELD(PRO.ID,'*',1)
            TEMP<3> = DATE()
            WRITE TEMP ON F.BOL.CRX,BOL<1,I>
         END
      NEXT I

      RETURN

*----
SET.APRVD.CARR:
*---- SET APPROVED CARRIER FLAG
*

      READ X FROM F.APRVD.CARRS,CARRIER.ID THEN
         BEGIN CASE
            CASE X<1> = '' AND X<2> = ''
               APRVD.CARRIER = 'Y'
            CASE X<1> # '' & X<2> NE ''
               IF PRO.REC<1> LT X<1> OR PRO.REC<1> GT X<2> ELSE
                  APRVD.CARRIER = 'Y'
               END
            CASE X<1> # '' AND X<2> = ''
               IF PRO.REC<1> GE X<1> THEN APRVD.CARRIER = 'Y'
            CASE X<1> = '' AND X<2> # ''
               IF PRO.REC<1> LE X<2> THEN APRVD.CARRIER = 'Y'
         END CASE
      END

      RETURN

*----
WRITE.MODS:
*---- WRITE MODIFICATIONS
*

      LOOP
         HELP = "[Y]=Post adjustment. [N]=Do not post adjustment."
         CALL GEN.IN(0,22,'Post adjustment? N','',Q,0,1,'','',1,-1,22,1,QI,HELP,0,23)
         QI = OCONV(QI,'MCU')
         IF QI = '' THEN QI = 'N'
      UNTIL QI = 'Y' ! QI = 'N' DO
      REPEAT
      ADJ.REC = ''
      ADJ.REC<1> = DATE()
      ADJ.REC<2> = PRO.REC<8>-OLD.PRO.REC<8>
      ADJ.REC<3> = CARRIER.ID
      ADJ.REC<4> = CLIENT.ID
      ADJ.REC<5> = PRO

*---- Post carrier adjustment if requested

      IF QI = 'Y' THEN
         DONE = 0
         SEQ = 1
         LOOP
            ADJ.ID = DATE():'*':CLIENT.ID:'*':SEQ
            READ DUMMY FROM F.ADJUSTS,ADJ.ID ELSE DONE = 1
         UNTIL DONE DO
            SEQ = SEQ+1
         REPEAT
*         WRITE ADJ.REC ON F.ADJUSTS,ADJ.ID
      END

*---- Post freight bill modification record

      DONE = 0
      SEQ = 1
      LOOP
         ADJ.ID = DATE():'*':CLIENT.ID:'*':SEQ
         READ DUMMY FROM F.MODS,ADJ.ID ELSE DONE = 1
      UNTIL DONE DO
         SEQ = SEQ+1
      REPEAT
      WRITE ADJ.REC ON F.MODS,ADJ.ID

      RETURN
****************************************************************************
*
* FB.2.1.ZIP IMPORTED INTO FB.2.1.TS BY KEITH
*
* NECESSARY FOR HAVING ACCESS TO THE GLOBAL VARIABLES SO YOU CAN
* REDRAW THE ENTIRE SCREEN AFTER DOING A SEARCH AS YOU WOULD
* IN THE INPUT FILEDS OF ORIGIN OR DESTINATION ZIP - THE ENTIRETY
* OF THE PROGRAM IS BROKEN DOWN INTO INTERNAL SUBS WITH NAMES
* CORRESPONDING TO THAT OF THE ACTUAL PROGRAM - VARIABLE NAMES
* HAVE BEEN CHANGED ALSO - PRE-APPENDED WITH "FB21Z."
*
*
* TO CALL THIS SUBROUTINE INTERNALLY SIMPLY LOAD ALL VARIABLES AS YOU
* NORMALLY WOULD AND - GOSUB FB.2.1.ZIP
*
****************************************************************************

FB.2.1.ZIP:

*
* Initialize Variables
*

      Z.PROMPT=''
      Z.OPT=QI
      IF Z.OPT='I' THEN
         Z.INQUIRE=1
         Z.MODE='EDIT'
      END ELSE
         Z.INQUIRE=0
         Z.MODE='INPUT'
      END
      Z.LN=0
      CALL FB.CLEAR.WINDOW
      GOSUB Z.DISPLAY.HEADINGS

      Z.PAGE=1
      GOSUB Z.9000

****************************************************************************
* Enter zip code line number
****************************************************************************
*
Z.100:
*

      IF Z.MODE = 'INPUT' THEN
         Z.LN += 1
         QI = Z.LN
         IF Z.LN GT Z.STOP THEN
            Z.PAGE += 1
            GOSUB Z.9000
         END
      END ELSE
         HELP = "Enter Line Num. ''=End. 'B'=Back. 'F'=Forward page. 'EX'=Exit."
         CALL GEN.IN(36,18,'Enter line number. ###','',Q,0,3,'','',0,-3,18,0,QI,HELP,0,23)
      END
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = 'B'
            Z.PAGE -= 1
            IF Z.PAGE = 0 THEN Z.PAGE=1
            GOSUB Z.9000
         CASE QI = 'F'
            Z.PAGE += 1
            GOSUB Z.9000
         CASE QI = ''
            GOTO Z.9900
         CASE QI = 'X'
            CALL FB.CLEAR.WINDOW
            RETURN
         CASE QI = 'EX'
            RELEASE
            STOP
         CASE NUM(QI) AND Z.INQUIRE
            CALL ELINE('Cannot access detail in inquiry.')
         CASE NUM(QI)
            Z.SEL = QI
            IF IN.OUT='I' THEN
               IF ZIP.ARR<1,Z.SEL-1>=DEST.ZIP AND DEST.ZIP#'' THEN
                  Z.MODE='EDIT'
                  GO Z.100
               END
            END
            IF Z.SEL>1 & CL.DIV.FLAG='Y' & ZIP.ARR<1,Z.SEL>='' & IN.OUT='I' THEN
               ZIP.ARR<1,Z.SEL>=DEST.ZIP
            END
            IF Z.SEL>1 & CL.DIV.FLAG='Y' & ZIP.ARR<1,Z.SEL>='' & IN.OUT='T' THEN
               ZIP.ARR<1,Z.SEL>=DEST.ZIP
            END
            IF Z.SEL=1 & CL.DIV.FLAG='Y' & ZIP.ARR<1,Z.SEL>='' & IN.OUT='O' THEN
               ZIP.ARR<1,Z.SEL>=ORIG.ZIP
            END
            GOSUB Z.8000
            BEGIN CASE
               CASE QI = '' & Z.OPT='V'
                  RETURN
               CASE QI = 'X'
                  CALL FB.CLEAR.WINDOW
                  RETURN
               CASE Z.LN + 1 > 50 AND Z.MODE = 'INPUT'
                  Z.MODE = 'EDIT'
               CASE 1
                  NULL
            END CASE
      END CASE

      GOTO Z.100


****************************************************************************
****************************************************************************
*INTERNAL SUBROUTINES
****************************************************************************
****************************************************************************

****************************************************************************
* Enter zip codes
****************************************************************************
*
Z.8000:
*

      IF Z.SEL LT Z.START ! Z.SEL GT Z.STOP THEN
         CALL ELINE('Invalid entry.')
         RETURN
      END

      GOSUB Z.9100

*
Z.8010:
*

      HELP = "Enter Zip Code. "
      IF Z.OPT = 'V' THEN
         MASK = SPACE(5)
         HELP := "''=End. 'X'=Back. 'EX'=Exit."
      END ELSE
         IF CL.DIV.FLAG='Y' THEN
            HELP := "''=Accept [D]elete [E]dit [1]=End [S]earch [X]=Back [EX]it"
         END ELSE
            HELP := "''=Accept [D]elete [E]dit [S]earch [X]=Back [EX]it"
         END
         MASK = ZIP.ARR<1,Z.SEL>'L#6'
      END

*IF USER='DONNA' THEN CALL ELINE('Owen press break... others press enter')

      TEMP.ZIP.LEN = CL.ZIP.FLAG
      IF CL.ZIP.FLAG='C' THEN TEMP.ZIP.LEN=6
      CALL GEN.IN(40,Z.LINE,MASK,'',Q,0,TEMP.ZIP.LEN,'','',2,-TEMP.ZIP.LEN,Z.LINE,0,QI,HELP,0,23)
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = 'EX'
            RELEASE
            STOP
         CASE QI = 'X'
            IF CL.DIV.FLAG='Y' THEN DEL ZIP.ARR<1,Z.SEL>
            IF Z.OPT NE 'V' THEN CRT @(40,Z.LINE):ZIP.ARR<1,Z.SEL>'L#6'
            RETURN
         CASE QI = 'D' & Z.OPT NE 'V'
            DEL ZIP.ARR<1,Z.SEL>
            DEL ZIP.ARR<2,Z.SEL>
            DEL ZIP.ARR<3,Z.SEL>
            GOSUB Z.9000
            RETURN
         CASE QI='.' ! QI='1'
            DEL ZIP.ARR<1,Z.SEL>
            DEL ZIP.ARR<2,Z.SEL>
            DEL ZIP.ARR<3,Z.SEL>
            GOSUB Z.9000
            Z.MODE='EDIT'
            RETURN
         CASE QI = 'E' & Z.OPT NE 'V'
            Z.MODE = 'EDIT'
            CRT @(40,Z.LINE):ZIP.ARR<1,Z.SEL>'L#6'
            RETURN
         CASE QI = '' & Z.OPT NE 'V'
            Q = ZIP.ARR<1,Z.SEL>
            IF Q = '' & Z.MODE = 'INPUT' THEN
               Z.MODE = 'EDIT'
               RETURN
            END
            IF Q = '' THEN RETURN
         CASE QI = ''
            Z.X = DCOUNT(ZIP.ARR<1>,CHAR(253))
            FOR Z.I = 1 TO Z.X
               IF ZIP.ARR<4,Z.I> NE '*' THEN
                  CALL ELINE('All zip codes have not been verified.')
                  GOTO Z.8010
               END
            NEXT Z.I
            RETURN
         CASE Z.OPT = 'V'
            IF QI # ZIP.ARR<1,Z.SEL> THEN
               CALL ELINE('INVALID ZIP CODE.')
               GOTO Z.8010
            END
            ZIP.ARR<4,Z.SEL> = '*'
         CASE QI='S'
            HELP="Enter city and state for zip code search. Separate with comma(,)."
            CALL GEN.IN(40,Z.LINE,STR('-',39),'',Q,0,40,'','',1,-39,Z.LINE,0,QI,HELP,0,23)
            CALL ZIPS.DISPLAY(Q,'ZIPS.CODES','ZIPS.CITY','1,2',Z.ITEM.LIST)
            GOSUB 8100
            GOSUB 8200
            HELP='S'
            BEGIN CASE
               CASE DCOUNT(Z.ITEM.LIST<1>,@VM) GT 1 OR Z.ITEM.LIST=''
                  CALL FB.CLEAR.WINDOW
                  GOSUB Z.DISPLAY.HEADINGS
                  GOSUB Z.9000
               CASE Z.ITEM.LIST NE ''
*CRT @(0,23):"STOP NOW": ; INPUT NUL
                  ZIP.ARR<1,Z.SEL>=Z.ITEM.LIST<1,1>
                  Z.CODE=ZIP.ARR<1,Z.SEL>
                  CALL FB.CLEAR.WINDOW
                  GOSUB Z.DISPLAY.HEADINGS
                  GOSUB Z.8090
                  GOSUB Z.9000
            END CASE
         CASE NUM(QI) AND LEN(QI) < 6
            ZIP.ARR<1,Z.SEL> = Q
         CASE CL.ZIP.FLAG='C' AND QI MATCHES '1A1N1A1N1A1N'
            ZIP.ARR<1,Z.SEL> = Q
         CASE 1
            CALL ELINE('INVALID ZIP CODE.')
            GOTO Z.8010
      END CASE

      IF Z.OPT NE 'V' THEN
         Z.CODE = ZIP.ARR<1,Z.SEL>
         GOSUB Z.8090
         IF Z.ACK = 'ERR' THEN GOTO Z.8010
         CRT @(40,Z.LINE):ZIP.ARR<1,Z.SEL>'L#6'
      END

*
Z.CHECK.99999:
*

      IF ZIP.ARR<1,Z.SEL>='99999' THEN
         HELP="Enter different city, state. ''=Accept. 'X'=Back. 'EX'=Stop."
         MASK=Z.CITY:', ':Z.STATE
         CALL GEN.IN(56,Z.LINE,MASK'L#24','',Q,0,24,'','',2,-24,Z.LINE,0,QI,HELP,0,23)
         QI=OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI='X'
               CRT @(56,Z.LINE):@(-4)
               GOTO Z.8010
            CASE QI='EX'
               STOP
            CASE QI=''
               Q=MASK
         END CASE
         Z.X=0
         Z.X=INDEX(Q,',',1)
         IF Z.X THEN
            Z.CITY=FIELD(Q,',',1)
            Z.CITY=OCONV(CITY,'MCT')
            Z.STATE=FIELD(Q,',',2)
            Z.STATE=OCONV(STATE,'MCU')
         END ELSE
            CALL ELINE('Invalid entry.')
            GOTO Z.CHECK.99999
         END
      END


      RETURN
****************************************************************************

****************************************************************************
* Display headings
****************************************************************************
*
Z.DISPLAY.HEADINGS:
*

      IF Z.OPT = 'V' THEN
         CRT @(39,6):"--------------- Zip Codes --------------"
         CRT @(39,7):" Zip Code":@(56):"City and State"
         CRT @(40,8):STR("-",39)
      END ELSE
         CRT @(36,6):"---------------- Zip Codes ----------------"
         CRT @(36,7):"Lin Zip Code":@(56):"City and State"
         CRT @(36,8):STR("-",43)
      END

      RETURN
****************************************************************************

****************************************************************************
* Check for Valid Zip Code
****************************************************************************
*
Z.8090:
*

*DFIF Z.CODE # '' AND NOT(Z.CODE MATCHES '1A1N1A1N1A1N') THEN
      Z.CITY='' ; Z.STATE=''
      CALL FB.READ.ZIP( Z.CODE, Z.CITY, Z.STATE )
      IF Z.CITY='' AND NOT(Z.CODE MATCHES '1A1N1A1N1A1N') THEN
         Z.ACK='ERR'
         RETURN
      END
      ZIP.ARR<2,Z.SEL> = Z.CITY
      ZIP.ARR<3,Z.SEL> = Z.STATE
*DFEND
      CRT @(56,Z.LINE) : ZIP.ARR<2,Z.SEL> : ' ' : ZIP.ARR<3,Z.SEL>:@(-4):
      Z.ACK = ''

      RETURN
****************************************************************************

****************************************************************************
* Get new VEND.CUST.NAMES ID
****************************************************************************
*
ADD.NEW.VCN: ***                                     ; * JCW02
      TABLE.ID = 'VCN*':CLIENT.ID                 ; * JCW02
      READ TABLE.REC FROM F.TABLES, TABLE.ID ELSE ; * JCW02
         TABLE.REC = ''                            ; * JCW02
         TABLE.REC<1> = 0                          ; * JCW02
      END                                         ; * JCW02
      DONE = 0                                    ; * JCW02
      LOOP UNTIL DONE DO                          ; * JCW02
         VCN.ID = TABLE.REC<1>'R%5'                ; * JCW02
         TABLE.REC<1> += 1                         ; * JCW02
         READ TEST FROM F.VCN, VCN.ID ELSE         ; * JCW02
            WRITE TABLE.REC ON F.TABLES, TABLE.ID   ; * JCW02
            DONE = 1                                ; * JCW02
         END                                       ; * JCW02
      REPEAT                                      ; * JCW02
      RETURN                                      ; * JCW02
****************************************************************************

****************************************************************************
* Print Page
****************************************************************************
*
Z.9000:
*

      Z.START = (Z.PAGE * 9) - 8
      Z.STOP = Z.START + 8
      FOR Z.SEL = Z.START TO Z.STOP
         GOSUB Z.9100
         IF Z.OPT NE 'V' THEN
            IF ZIP.ARR<1,Z.SEL> = '' THEN
               CRT @(36,Z.LINE):Z.SEL'L#3':@(-4):
            END ELSE
               CRT @(36,Z.LINE):Z.SEL'L#3':' ':ZIP.ARR<1,Z.SEL>'L#5':
               IF ZIP.ARR<2,Z.SEL> = '' AND ZIP.ARR<3,Z.SEL> = '' THEN
                  Z.CODE = ZIP.ARR<1,Z.SEL>
                  GOSUB Z.8090
               END ELSE
                  CRT @(56,Z.LINE):ZIP.ARR<2,Z.SEL>:' ':ZIP.ARR<3,Z.SEL>:@(-4):
               END
            END
         END
      NEXT Z.SEL

      RETURN
****************************************************************************

****************************************************************************
* Calculate Line
****************************************************************************
*
Z.9100:
*

      Z.X = REM(Z.SEL,9)
      IF Z.X = 0 THEN Z.X = 9
      Z.LINE = 8 + Z.X

      RETURN
****************************************************************************

****************************************************************************
* Compress zip codes and return
****************************************************************************
*
Z.9900:
*

      IF NOT(Z.INQUIRE) THEN
         TIMES = DCOUNT(ZIP.ARR<1>,CHAR(253))
         Z.NEW.ZIP.ARR=''
         Z.LAST.ZIP='FIRST'
         FOR Z.I = 1 TO TIMES
            IF ZIP.ARR<1,Z.I>#'' THEN
               IF Z.LAST.ZIP=ZIP.ARR<1,Z.I> AND Z.LAST.ZIP#'FIRST' ELSE
                  FOR Z.X = 1 TO 4
                     Z.NEW.ZIP.ARR<Z.X,-1>=ZIP.ARR<Z.X,Z.I>
                  NEXT Z.X

*       Z.LAST.ZIP=ZIP.ARR<1,Z.I> ; * Allow Dups Per Paul

               END
            END
         NEXT Z.I
      END
      ZIP.ARR=Z.NEW.ZIP.ARR
      CALL FB.CLEAR.WINDOW

      RETURN
****************************************************************************
