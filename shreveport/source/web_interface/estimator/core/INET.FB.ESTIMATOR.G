      SUBROUTINE INET.FB.ESTIMATOR.G(VIN,VOUT)
****************************************************
* Program name : INET.FB.ESTIMATOR.G
* Author       : Greg Bino
* Date written : 07-06-2018
* Library      : FBBP
* COPYRIGHT (C) 2016 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
* Last updated by afs (AFSLOGISTICS\gbino) at 07:08:46 on 08/02/2018.
*
* Start modification history
* 07/06/18 GRB New Program
* End modification history
*
*******************************************************

****************************************************************
* Initialize variables
****************************************************************
      EBS.CLIENTS=''                     ; * JMK37
      EBS.CLIENTS<1,1>='01148'           ; * JMK37
      EBS.CLIENTS<1,2>='01371'           ; * JMK37
      EBS.CLIENTS<1,3>='01398'           ; * JMK37
      EBS.CLIENTS<1,4>='01539'           ; * JMK37
      EBS.CLIENTS<1,5>='01704'           ; * JMK37

      AG.CLIENTS=''                      ; * JMK38
      AG.CLIENTS<1,-1>='00879'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01079'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01083'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01101'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01112'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01113'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01267'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01271'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01382'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01389'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01418'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01432'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01597'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01604'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01654'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01686'           ; * JMK38 ; * JMK47
      AG.CLIENTS<1,-1>='01739'           ; * JMK52
      AG.CLIENTS<1,-1>='01868'
      AG.CLIENTS<1,-1>='01873'           ; * JMK52

      RL.FERRY.ZIP=''                    ; * JMK73
      RL.FERRY.ZIP<1,-1>='27915'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='27920'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='27936'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='27943'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='27960'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='27968'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='27972'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='27982'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='48028'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98261'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98243'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98245'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98279'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98280'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98297'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98286'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98250'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98070'         ; * JMK73
      RL.FERRY.ZIP<1,-1>='98110'         ; * JMK73

      * Begin NKH02
      TRANSIT.TIME = ''
      RELEASE.DATE = ''
      ORIG.DIR.FLG = ''
      DEST.DIR.FLG = ''
      COMB.DIR.FLG = ''
      ORIG.TERM.NAME = ''
      ORIG.TERM.CODE = ''
      ORIG.TERM.ADR1 = ''
      ORIG.TERM.ADR2 = ''
      ORIG.TERM.CITY = ''
      ORIG.TERM.ST = ''
      ORIG.TERM.ZIP = ''
      ORIG.TERM.PHONE = ''
      ORIG.TERM.TPHONE = ''
      ORIG.TERM.FAX = ''
      ORIG.TERM.EMAIL = ''
      ORIG.TERM.CNAME = ''
      ORIG.TERM.CTITLE = ''
      DEST.TERM.NAME = ''
      DEST.TERM.CODE = ''
      DEST.TERM.ADR1 = ''
      DEST.TERM.ADR2 = ''
      DEST.TERM.CITY = ''
      DEST.TERM.ST = ''
      DEST.TERM.ZIP = ''
      DEST.TERM.PHONE = ''
      DEST.TERM.TPHONE = ''
      DEST.TERM.FAX = ''
      DEST.TERM.EMAIL = ''
      DEST.TERM.CNAME = ''
      DEST.TERM.CTITLE = ''
      CARR.DATA.DATE = ''
      RW.TARIFF = ''
      RW.EFF.DATE=''
      A1 =''
      A2=''
      A3=''
      A4=''
      A5=''
      A6=''
      MISROUTE=0
      CLIENT.STATUS = "A"
      GB.LOG.AMT = 0
      * End NKH02
*OPEN '','NKM.TEMP' TO NKM.TEMP ELSE STOP 201, 'NKM.TEMP'

      CARRIER.EST.ARRAY=''
      CARRIER.COST.ARRAY=''
      SORT.MISROUTE.ARRAY=''             ; * NPR09
      DEST.CITY = ''
      DEST.ST = ''
      ORIG.CITY = ''
      ORIG.ST = ''
      MAX.LTL = ''
      CALL GET.USER.NEW(USER,CH.NUM)
      BEGIN CASE                         ; * JMK67
         CASE USER='DAVID' ; USER.TYPE='PROGRAMMER'          ; * JMK67
         CASE USER='GBINO' ; USER.TYPE='PROGRAMMER'          ; * JMK67
         CASE USER='NMEDDAUGH' ; USER.TYPE='PROGRAMMER'      ; * NKH02
         CASE 1 ; USER.TYPE='NORMAL'     ; * JMK67
      END CASE                           ; * JMK67
      ACTIVITY.REC=''                    ; * JMK17
      ACTIVITY.ID=''                     ; * JMK17
      VENDOR.STATUS=0                    ; * JMK40
      COMBINE.RATE=0                     ; * JMK37
      LOG.COMM=0                         ; * JMK57
      VENDOR.QUOTE.LIMIT.PERC=0
      NUMBER.LIMIT=0
      VALID.CL=1
      VALID.WT=1
      VALID.ORIG.ZIP=1
      VALID.DEST.ZIP=1
      DIM CLIENT.REC(350)
      MAT CLIENT.REC = ''
      NEW.LOG.COMM = 0
      GBB.CONTRACT.ACC=0
      GBB.BENCH.ACC = 0

      UPL.VIN = 'FBBP'
      UPL.VIN<2> = 'INET.FB.ESTIMATOR'
      UPL.VIN<3> = USER
      UPL.VIN<4> = CH.NUM
      UPL.VOUT = ''                      ; * NPR_UPL 04/23/2010
*****      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/23/2010

      INPUT CLIENT.ID
      INPUT CARRIER.ID
      INPUT OSHIP.DATE
      INPUT IOT
      INPUT ORIG.ZIP
      INPUT DEST.ZIP
      INPUT TEMP.CLASSES
      INPUT TEMP.WEIGHTS

      CLIENT.ID=CLIENT.ID'R%5'           ; * JMK26
      HOLD.CLIENT.ID=CLIENT.ID           ; * JMK38
      IF CARRIER.ID#'ALL' THEN CARRIER.ID=CARRIER.ID'R%5'    ; * JMK26
      IOT=OCONV(IOT,'MCU')               ; * JMK26
      TEMP.CLASSES=CHANGE(TEMP.CLASSES,"|",@VM)
      TEMP.WEIGHTS=CHANGE(TEMP.WEIGHTS,"|",@VM)

      TEMP.STRING2 = "" ; TEMP.STRING3 = ""
      TEMP.STRING4 = ""                  ; * DRF07
      TEMP.CLASSES.HOLD = TEMP.CLASSES

      IF INDEX(TEMP.CLASSES,"~",1) THEN
         TEMP.CLASSES.HOLD = TEMP.CLASSES
         N.CL = DCOUNT(TEMP.CLASSES,@VM)
         TEMP.CLASSES = ""
         FOR CL = 1 TO N.CL
            W.CLASS.COMM = TEMP.CLASSES.HOLD<1,CL>
            TEMP.CLASSES<1,CL> = FIELD(W.CLASS.COMM,"~",1)
            W.COMM.STR = FIELD(W.CLASS.COMM,"~",2)
            I.HAZ.TYPE = TRIM(FIELD(W.COMM.STR,";",1))       ; * NPR08
            I.HAZ.CLASS = TRIM(FIELD(W.COMM.STR,";",2))      ; * NPR08
            I.HAZ.NMFC = TRIM(FIELD(W.COMM.STR,";",3))       ; * DRF07
            TEMP.STRING2<1,CL> = OCONV(I.HAZ.TYPE,"MCU")
            TEMP.STRING3<1,CL> = OCONV(I.HAZ.CLASS,"MCU")
            TEMP.STRING4<1,CL> = OCONV(I.HAZ.NMFC,"MCU")     ; * DRF07
         NEXT CL
      END

      N.BOL.CLS = DCOUNT(TEMP.CLASSES,@VM)
      IF N.BOL.CLS GT 20 THEN
         NEW.CLASSES = ""
         NEW.WEIGHTS = ""
         FOR BL = 1 TO N.BOL.CLS
            W.CLASS = TEMP.CLASSES<1,BL>
            W.WEIGHT = TEMP.WEIGHTS<1,BL>
            LOCATE W.CLASS IN NEW.CLASSES<1> SETTING CLS.POS THEN
               NEW.WEIGHTS<1,CLS.POS> = NEW.WEIGHTS<1,CLS.POS> + W.WEIGHT
            END ELSE
               NEW.CLASSES=INSERT(NEW.CLASSES,1,CLS.POS,0,W.CLASS)
               NEW.WEIGHTS=INSERT(NEW.WEIGHTS,1,CLS.POS,0,W.WEIGHT)
            END
         NEXT BL
         TEMP.CLASSES = NEW.CLASSES
         TEMP.WEIGHTS = NEW.WEIGHTS
      END
      AIRGAS.ZONEA.GAS = 0               ; * NPR08
      AIRGAS.ZONEB.GAS = 0               ; * DRF07
      AIRGAS.ZONEC.GAS = 0               ; * DRF07
      AIRGAS.ZONEE.GAS = 0               ; * DRF07
      AIRGAS.2.3.GAS = 0                 ; * NPR08

      CLASSES=''
      WEIGHTS=''
      TIMES = DCOUNT(TEMP.CLASSES<1>,@VM)
      FOR X = 1 TO TIMES
         CLASS=TEMP.CLASSES<1,X>
         IF CLASS='92.5' THEN CLASS=92
         IF CLASS='77.5' THEN CLASS=77
         WEIGHT=TEMP.WEIGHTS<1,X>'R0'    ; *** Rounded the weight to the nearest LB OH 07-07-04
         IF WEIGHT+0>0 THEN
            CLASSES<1,-1>=CLASS
            WEIGHTS<1,-1>=WEIGHT
         END
      NEXT X
      ZIP.VOUT = ""
      INPUT TEMP.MISC.CHG.CODES
      ***  IF USER = 'GBINO' THEN DEBUG
      TEMP.MISC.CHG.CODES=CHANGE(TEMP.MISC.CHG.CODES,"|",@VM)
      TIMES = DCOUNT(TEMP.MISC.CHG.CODES<1>,@VM)
      MISC.CHG.CODES=''
      ACC.ERROR=''                       ; * JMK27
      FOR X = 1 TO TIMES
         CODE=TEMP.MISC.CHG.CODES<1,X>
         IF CODE='LIFT' THEN CODE = 'L25'          ; * 11-10-03 Owen Per Scott
         IF CODE#'' THEN MISC.CHG.CODES<1,-1>=CODE
      NEXT X
      MISC.CHG.CODES=OCONV(MISC.CHG.CODES,'MCU')

      INPUT USER.NAME
      INPUT USER.PWD
      INPUT QUOTE.PERCENT
*     INPUT MARK.UP.PERCENT              ; * SWB02 * MARK.UP.FACTOR used to be a percentage. It can now be a percentage or a Flat Fee
      INPUT MARK.UP.FACTOR               ; * SWB02

      FLAT.FEE = 0                       ; * SWB02
      IF INDEX(USER.NAME, '~', 1) THEN   ; * SWB02
*For some unknown reason, when the web side passes the '~F' in the user name to
*indicate a Flat Fee, the Fee Amount would not come over in the MARK.UP.FACTOR.
*So, if there is a Flat Fee indicator, use the number after the ~F as the
*MARK.UP.FACTOR and treat it as a dollar amount in ICONV MD2 form.
         IF FIELD(USER.NAME, '~', 2)[1, 1] = 'F' THEN        ; * SWB02
            FLAT.FEE = 1                 ; * SWB02
            MARK.UP.FACTOR = FIELD(USER.NAME, '~', 2)[2,99]
            IF NUM(MARK.UP.FACTOR) THEN  ; * SWB02
               MARK.UP.FACTOR += 0       ; * SWB02
            END ELSE                     ; * SWB02
               MARK.UP.FACTOR = 0        ; * SWB02
            END                          ; * SWB02
         END                             ; * SWB02
         USER.NAME = FIELD(USER.NAME, '~', 1)      ; * SWB02
      END                                ; * SWB02

      IF CLASSES='' THEN
         PRINT "%ERROR:No freight classification to rate."
         VALID.CL=0
         GO 9000
      END
      IF WEIGHTS='' THEN
         PRINT "%ERROR:No freight weight to rate."
         VALID.WT=0
         GO 9000
      END

      IF QUOTE.PERCENT#'' THEN
         QUOTE.PERCENT=QUOTE.PERCENT*100           ; ** 100% Passed from SQL is 100
      END
      ORIG.ZIP=FIELD(ORIG.ZIP,'-',1)
      DEST.ZIP=FIELD(DEST.ZIP,'-',1)
      CANADIAN=0
      ORG.CAN=0                          ; * JMK51
      DST.CAN=0                          ; * JMK51
      CLIENT.STATUS=''                   ; * JMK62
      IF NOT(NUM(ORIG.ZIP)) THEN
         ORIG.ZIP=CHANGE(ORIG.ZIP,' ','')          ; * JMK76
         ORIG.ZIP=OCONV(ORIG.ZIP,'MCU')
         IF NOT(ORIG.ZIP MATCHES '1A1N1A1N1A1N') THEN
            PRINT "%ERROR:Origin Zip-Canadian Zips must be formatted A1A1A1"
            DEBUG
            VALID.ORIG.ZIP=0
            GO 9000
         END
         CANADIAN=1
         ORG.CAN=1                       ; * JMK51
      END ELSE
         IF NOT(ORIG.ZIP MATCHES '5N') THEN
            PRINT "%ERROR:Origin Zip-US Zips must be 5 numeric digits"

            VALID.ORIG.ZIP=0
            GO 9000
         END
      END
      IF NOT(NUM(DEST.ZIP)) THEN
         DEST.ZIP=CHANGE(DEST.ZIP,' ','')          ; * JMK76
         DEST.ZIP=OCONV(DEST.ZIP,'MCU')
         IF NOT(DEST.ZIP MATCHES '1A1N1A1N1A1N') THEN
            PRINT "%ERROR:Destination Zip-Canadian Zips must be formatted A1A1A1"
            DEBUG
            VALID.DEST.ZIP=0
            GO 9000
         END
         CANADIAN=1
         DST.CAN=1                       ; * JMK51
      END ELSE
         IF NOT(DEST.ZIP MATCHES '5N') THEN
            PRINT "%ERROR:Destination Zip-US Zips must be 5 numeric digits"
            VALID.DEST.ZIP=0
            GO 9000
         END
      END
      USER.NAME=OCONV(USER.NAME,'MCU')
      USER.PWD=OCONV(USER.PWD,'MCU')
      IF USER.NAME='FANIM91702' THEN     ; * JMK49
         IF ORIG.ZIP#'91702' AND DEST.ZIP#'91702' THEN       ; * JMK49
            PRINT "%ERROR:RATING NOT ALLOWED OUTSIDE ZIP 91702"        ; * JMK49
            GO 9000                      ; * JMK49
         END                             ; * JMK49
      END                                ; * JMK49
      OPEN '','INET.FBESTIMATOR.ACTIVITY' TO F.ACTIVITY ELSE
         PRINT "%ERROR:COULD NOT OPEN ACTIVITY"
         GO 9000
      END
      OPEN '','SCAC.XREF' TO F.SCAC.XREF ELSE      ; * BOH01
         PRINT "%ERROR:COULD NOT OPEN SCAC.XREF"   ; * BOH01
         GO 9000
      END                                ; * BOH01
      IF NOT(NUM(CARRIER.ID)) AND CARRIER.ID#'ALL' THEN      ; * BOH01
         UP.CARRIER.ID=OCONV(CARRIER.ID,'MCU')
         READV SCAC FROM F.SCAC.XREF,UP.CARRIER.ID,1 THEN    ; * BOH01
            CARRIER.ID=SCAC              ; * BOH01
         END                             ; * BOH01
      END                                ; * BOH01
*
* Open general files
*
      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         ERROR = "CANNOT OPEN FILE CLIENTS"
         GO 9000
      END
      OPEN '','CARRIERS' TO F.CARRIERS ELSE
         ERROR = "CANNOT OPEN FILE CARRIERS"
         GO 9000
      END
      OPEN '','FB.BC.FSC' TO F.NFSC ELSE
         ERROR = "CANNOT OPEN FILE FB.BC.FSC"
         GO 9000
      END
      OPEN '','FB.NFSC.SUB' TO F.NFSC.SUB ELSE
         CALL OPEN.ABORT('FB.NFSC.SUB',PROG.NAME)
      END
      OPEN '','FB.TABLES' TO F.TABLES ELSE
         ERROR = "CANNOT OPEN FILE FB.TABLES"
         GO 9000
      END
      OPEN '','FB.MILEAGE' TO F.MILEAGE ELSE       ; * JMK33
         ERROR = "CANNOT OPEN MILEAGE FILE "       ; * JMK33
         GO 9000                         ; * JMK33
      END                                ; * JMK33

* Open mileage input and output files

      OPEN '','PCIN' TO F.PCIN ELSE
         ERROR = "CANNOT OPEN FILE PCIN"
         GO 9000
      END
      OPEN '','PCOUT' TO F.PCOUT ELSE
         ERROR = "CANNOT OPEN FILE  "
         GO 9000
      END
      OPEN '','ZIPS.CODES' TO F.ZIPS ELSE
         ERROR = "CANNOT OPEN ZIPS FILE "
         GO 9000
      END
      OPEN '','CAN.ZIP.CODES' TO F.CAN.ZIPS ELSE   ; * JMK34
         ERROR = "CANNOT OPEN CAN.ZIP.CODES FILE "           ; * JMK34
         GO 9000                         ; * JMK34
      END                                ; * JMK34
      OPEN '','ZIP.LINE.ITEM' TO F.ZIP.LINE.ITEM ELSE        ; *DRF01
         ERROR = "CANNOT OPEN FILE ZIP.LINE.ITEM"  ; *DRF01
         GO 9000 ;                       ; *DRF01
      END                                ; *DRF01

* Begin NKH02
      IF CARRIER.ID # 'ALL' THEN
         READV CARRIER.SCAC FROM F.CARRIERS, CARRIER.ID, 12 ELSE CARRIER.SCAC = ''
      END ELSE
         CARRIER.SCAC = 'ALL'
      END

      OPEN '','ZIPS' TO ZIPS ELSE
         CALL OPEN.ABORT('ZIPS','INET.FB.ESTIMATOR')
      END

      READV ORIG.COUNTRY FROM ZIPS, ORIG.ZIP, 3 ELSE
         IF NUM(ORIG.ZIP[1,1]) THEN
            ORIG.COUNTRY = 'US'
         END ELSE
            ORIG.COUNTRY = 'CAN'
         END
      END
      BEGIN CASE
         CASE ORIG.COUNTRY = 'US'
            ORIG.COUNTRY = 'USA'
         CASE ORIG.COUNTRY = 'CA'
            ORIG.COUNTRY = 'CAN'
         CASE ORIG.COUNTRY = 'MX'
            ORIG.COUNTRY = 'MEX'
      END CASE
      READV DEST.COUNTRY FROM ZIPS, DEST.ZIP, 3 ELSE
         IF NUM(DEST.ZIP[1,1]) THEN
            DEST.COUNTRY = 'US'
         END ELSE
            DEST.COUNTRY = 'CAN'
         END
      END
      BEGIN CASE
         CASE DEST.COUNTRY = 'US'
            DEST.COUNTRY = 'USA'
         CASE DEST.COUNTRY = 'CA'
            DEST.COUNTRY = 'CAN'
         CASE DEST.COUNTRY = 'MX'
            DEST.COUNTRY = 'MEX'
      END CASE
      CCVIN = ''
      CCVIN<1> = CARRIER.SCAC
      CCVIN<2> = DEST.COUNTRY
      CCVIN<3> = DEST.ZIP
      CCVIN<4> = ORIG.COUNTRY
      CCVIN<5> = ORIG.ZIP
      CCVIN<6> = CLIENT.ID
      CCVIN<7> = USER.NAME
      CCVOUT = ''
      CALL CCXL.V2(CCVIN,CCVOUT)

* End NKH02

      IF TEMP.STRING4 NE "" THEN         ; * DRF07
         N.COM = DCOUNT(TEMP.STRING4,@VM)          ; * DRF07
         FOR IC = 1 TO N.COM             ; * DRF07
            HAZ.NMFC = TEMP.STRING4<1,IC>          ; * DRF07
            IF HAZ.NMFC='85900-1' OR HAZ.NMFC='85900-01' THEN          ; * DRF07
               AIRGAS.ZONEA.GAS=1        ; * DRF07
            END                          ; * DRF07
            IF HAZ.NMFC='85900-2' OR HAZ.NMFC='85900-02' THEN          ; * DRF07
               AIRGAS.ZONEB.GAS=1        ; * DRF07
            END                          ; * DRF07
            IF HAZ.NMFC='85900-3' OR HAZ.NMFC='85900-03' THEN          ; * DRF07
               AIRGAS.ZONEC.GAS=1        ; * DRF07
            END                          ; * DRF07
            IF HAZ.NMFC='85880' THEN     ; * DRF07
               AIRGAS.ZONEE.GAS=1        ; * DRF07
            END                          ; * DRF07
         NEXT IC                         ; * DRF07
      END                                ; * DRF07
      XREF.OPEN = "Y"
      OPEN '','FB.IEFA.XREF' TO F.IEFA.XREF ELSE
         XREF.OPEN = "N"
      END
      IF NUM(ORIG.ZIP) THEN              ; * JMK01
         READ T.REC FROM F.ZIPS,ORIG.ZIP THEN
            ORIG.CITY = T.REC<1>
            ORIG.ST = T.REC<2>
         END ELSE
            VIN=ORIG.ZIP
            CALL ADD.ZIP(VIN,VOUT)
            ORIG.CITY=VOUT<1>
            ORIG.STATE=VOUT<2>
            IF ORIG.CITY='' THEN
               ERROR=ORIG.ZIP:' ZIP NOT ON FILE, PLEASE TRY ANOTHER ZIP'
               VALID.ORIG.ZIP=0
               GO 9000
            END
         END
      END ELSE                           ; * JMK01
         READ T.REC FROM F.CAN.ZIPS,ORIG.ZIP THEN  ; * JMK34
            ORIG.CITY = T.REC<1>         ; * JMK34
            ORIG.ST = T.REC<2>           ; * JMK34
         END ELSE                        ; * JMK34
            ORIG.CITY = ''               ; * JMK01
            ORIG.ST = ''                 ; * JMK01
         END                             ; * JMK34
      END                                ; * JMK01
      IF NUM(DEST.ZIP) THEN              ; * JMK01
         READ T.REC FROM F.ZIPS,DEST.ZIP THEN
            DEST.CITY = T.REC<1>
            DEST.ST = T.REC<2>
         END ELSE
            VIN=DEST.ZIP
            CALL ADD.ZIP(VIN,VOUT)
            DEST.CITY=VOUT<1>
            DEST.STATE=VOUT<2>
            IF DEST.CITY='' THEN
               ERROR=DEST.ZIP:' ZIP NOT ON FILE, PLEASE TRY ANOTHER ZIP'
               VALID.DEST.ZIP=0
               GO 9000
            END
         END
      END ELSE                           ; * JMK01
         READ T.REC FROM F.CAN.ZIPS,DEST.ZIP THEN  ; * JMK34
            DEST.CITY = T.REC<1>         ; * JMK34
            DEST.ST = T.REC<2>           ; * JMK34
         END ELSE                        ; * JMK34
            DEST.CITY = ''               ; * JMK01
            DEST.ST = ''                 ; * JMK01
         END                             ; * JMK34
      END                                ; * JMK01

      PCMVIN='BOTH'                      ; * JMK33
      PCMVIN<2>=CH.NUM                   ; * JMK33
      PCMVIN<3>=ORIG.ZIP:@VM:DEST.ZIP    ; * JMK33
      PCMVIN<7>=1                        ; * JMK33
      PCMVOUT=''                         ; * JMK33
*****      CALL PCMILER.BETA(PCMVIN,PCMVOUT,F.PCIN,F.PCOUT,F.MILEAGE)       ; * JMK33
      MILES=PCMVOUT<1>                   ; * JMK33
      MSG=PCMVOUT<2>                     ; * JMK33
      IF OCONV(MSG,'MCU')='ERROR' THEN   ; * JMK33
         ERROR=PCMVOUT<2>                ; * JMK33
         MILES=ERROR                     ; * JMK33
      END                                ; * JMK33

*
      ACTIVITY.ID = USER.NAME:'*':USER.PWD:'*':DATE():'*':TIME()
*
      ACTIVITY.REC = ''
      ACTIVITY.REC<2> = CLIENT.ID
      ACTIVITY.REC<3> = CARRIER.ID
      ACTIVITY.REC<4> = ICONV(OSHIP.DATE,'D')      ; * JMK20
      ACTIVITY.REC<5> = IOT
      ACTIVITY.REC<6> = ORIG.ZIP
      ACTIVITY.REC<7> = DEST.ZIP
      ACTIVITY.REC<8> = CLASSES
      ACTIVITY.REC<9> = WEIGHTS
      ACTIVITY.REC<10> = MISC.CHG.CODES
      ACTIVITY.REC<11> = QUOTE.PERCENT
      ACTIVITY.REC<12> = MARK.UP.FACTOR  ; * SWB02
      WRITE ACTIVITY.REC ON F.ACTIVITY,ACTIVITY.ID

      IF XREF.OPEN = "Y" THEN
         ID.XREF = CLIENT.ID:"*":DATE()
         READ XREF.REC FROM F.IEFA.XREF, ID.XREF ELSE XREF.REC = ""
         LOCATE ACTIVITY.ID IN XREF.REC SETTING POS ELSE
            XREF.REC<-1> = ACTIVITY.ID
            WRITE XREF.REC ON F.IEFA.XREF, ID.XREF
         END
      END
      CLIENT.AUDIT=1
      ERROR=''
      PROG.NAME='FB.ESTIMATOR'
      PROG.DESC="Estimate freight on shipments using OLA setups"
      PACK.NAME="Freight Billing"

      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'INET.FB.ESTIMATOR' ; UPL.VOUT = ''        ; * NPR_UPL 04/23/2010
*****      CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)       ; * NPR_UPL 04/23/2010
      IF ORIG.ZIP GE 96701 AND ORIG.ZIP LE 96898 THEN
         ERROR = "Cannot Estimate LTL Shipments from Hawaii"
         VALID.ORIG.ZIP=2
         GO 9000
      END
      IF ORIG.ZIP GE 99501 AND ORIG.ZIP LE 99950 THEN
         ERROR = "Cannot Estimate LTL Shipments from Alaska"
         VALID.ORIG.ZIP=3
         GO 9000
      END
      IF DEST.ZIP GE 96701 AND DEST.ZIP LE 96898 THEN
         ERROR = "Cannot Estimate LTL Shipments to Hawaii"
         VALID.DEST.ZIP=2
         GO 9000
      END
      IF DEST.ZIP GE 99501 AND DEST.ZIP LE 99950 THEN
         ERROR = "Cannot Estimate LTL Shipments to Alaska"
         VALID.DEST.ZIP=3
         GO 9000
      END

      CONTR.AMT=''
      BENCH.AMT=''
      TAB=CHAR(9)

      SHIP.DATE=ICONV(OSHIP.DATE,'D')
      IF SHIP.DATE='' THEN
         ERROR='Invalid Ship Date of ':OSHIP.DATE
         GOTO 9000
      END
*DF      IF CLIENT.ID="01697" AND DATE() < 17899 ELSE
      IF CLIENT.ID="01697" AND DATE() < 18264 ELSE
         IF SHIP.DATE > DATE()+7 THEN    ; * JMK35
            ERROR='Ship date cannot be over 7 days in the future. Please re-submit.'       ; * JMK35
            GOTO 9000
         END
      END
      NUM.WEIGHTS = DCOUNT(WEIGHTS,@VM)
      TOT.WEIGHT = 0
      TOT.WEIGHT = SUM(WEIGHTS)
      BEGIN CASE
         CASE IOT = "I"
            IOT.DESC = "Inbound"
         CASE IOT = "O"
            IOT.DESC = "Outbound"
         CASE IOT = "T"
            IOT.DESC = "Third Party"
      END CASE
      READ DTARIFF.DATE.XREF FROM F.TABLES,'TARIFF.DATE.XREF' ELSE DTARIFF.DATE.XREF=''
      READ DTARIFFS FROM F.TABLES,'TARIFFS' ELSE DTARIFFS=''
      READ LI.CODES FROM F.TABLES,'LI.CODES' ELSE LI.CODES=''

CLIENT.START.POINT:*
      VENDOR.STATUS=0                    ; * JMK40
      IF INDEX(USER.NAME,'VENDOR',1) OR INDEX(USER.PWD,'VENDOR',1) THEN          ; * JMK40
         VENDOR.STATUS=1                 ; * JMK40
      END                                ; * JMK40
      COMBINE.RATE=0                     ; * JMK37
      EBS.CLIENT=0                       ; * JMK38
      AG.CLIENT=0                        ; * JMK38
      LOCATE CLIENT.ID IN EBS.CLIENTS<1> SETTING CPOS THEN   ; * JMK37

         IF VENDOR.STATUS THEN           ; * JMK40
            COMBINE.RATE=1               ; * JMK37
            EBS.CLIENT=1                 ; * JMK38
            DEL EBS.CLIENTS<1,CPOS>      ; * JMK37
         END                             ; * JMK37
      END                                ; * JMK37

      LOCATE CLIENT.ID IN AG.CLIENTS<1> SETTING CPOS THEN    ; * JMK38
         IF VENDOR.STATUS THEN           ; * JMK40
            COMBINE.RATE=1               ; * JMK38
            AG.CLIENT=1                  ; * JMK38
            DEL AG.CLIENTS<1,CPOS>       ; * JMK38
         END                             ; * JMK38
      END                                ; * JMK38

      READ DCLIENTS FROM F.CLIENTS,CLIENT.ID ELSE
         ERROR = "Client ":CLIENT.ID:" not on file."
         GO 9000
      END
      CLIENT.STATUS=DCLIENTS<30>         ; * JMK62 ; * JMK63

      CL.LOG.FSC=DCLIENTS<111>
      MAX.LTL=15000                      ; * JMK02
      IF TRIM(DCLIENTS<150>)#'' THEN MAX.LTL=DCLIENTS<150>   ; * JMK02
      IF CLIENT.ID='02427' AND VENDOR.STATUS THEN  ; * JMK79
         MAX.LTL=5000                    ; * JMK79
      END                                ; * JMK79
      IF TOT.WEIGHT GT MAX.LTL THEN
         BEGIN CASE                      ; * JMK79
            CASE CLIENT.ID='01584'       ; * DRF10
               ERROR = 'You have exceeded the maximum LTL weight (':MAX.LTL:' lbs) and could qualify for truckload pricing. Please remember the Max cubic feet for an LTL shipment is 750. Please contact AFS Truckload at (866)475-2374 Ext 3'  ; * DRF10
            CASE CLIENT.ID='02427' AND VENDOR.STATUS         ; * JMK79
               ERROR = 'You have exceeded the maximum LTL weight (':MAX.LTL:' lbs). Please contact Vicky Fell (608-836-5391) of Danielle Pitcock (608-836-6238)'           ; * JMK79
            CASE CLIENT.ID='05171'       ; * DRF08
               ERROR = 'You have exceeded the maximum LTL weight (':MAX.LTL:' lbs). Please contact ACME Central Dispatch (dispatch@brick.com)'         ; * DRF08
            CASE 1                       ; * JMK79
               ERROR = 'For shipments over ':MAX.LTL:' lbs., please contact AFS Customer Service at (866) 533-2111 Ext. 8300'      ; * JCW02
         END CASE                        ; * JMK79
         GOTO 9000
      END

      IF CLIENT.ID='00866' AND TOT.WEIGHT<50 THEN
         ERROR='CANNOT ESTIMATE FOR WEIGHTS LESS THAN 50 POUNDS. PLEASE CONTACT AFS.'
         GOTO 9000
      END
      CARR.ONLY.FSC=DCLIENTS<189>        ; * JMK04
      QUOTE.OFFSET=INDEX("IOT",IOT,1)
      IF QUOTE.OFFSET < 1 OR QUOTE.OFFSET > 3 THEN
         ERROR="Program ERROR: QUOTE.OFFSET is out of range"
         GO 9000
      END

      QUOTE.PERC = QUOTE.PERCENT
      IF QUOTE.PERC = '' THEN            ; * No User OverrideUse Client Default
         QUOTE.PERC = DCLIENTS<135+QUOTE.OFFSET,1>
      END
      IF QUOTE.PERC = 'NO' THEN
         ERROR="No Estimates for ":IOT.DESC:" Type freight allowed!"
         GO 9000
      END
      IF QUOTE.PERC = '' THEN
         ERROR="Cannot Quote ":IOT.DESC:" shipments. Your account has not been setup for this function.  Please contact customer service at AFS and ask that your Quote Percent for ":IOT.DESC:" shipments be setup."
         GO 9000
      END
      IF NOT(NUM(QUOTE.PERC)) THEN
         ERROR="Invalid Quote Percentage set up for ":IOT.DESC:" type freight!"
         GO 9000
      END
      LOGISTICS=DCLIENTS<93>='Y'
      IF FIELD(USER.NAME,'*',1)='AFSONLY' THEN     ; * JMK53 ; * JMK71
         LOGISTICS=0                     ; * JMK53
      END                                ; * JMK53
*
* Open client's files.
*
      AUDIT.CLIENT.ID = CLIENT.ID
      OPEN '','FB.AUDIT,':CLIENT.ID TO F.AUDIT THEN
         READV SUB.CLIENT FROM F.AUDIT,'SUBSTITUTE',1 THEN
            AUDIT.CLIENT.ID = SUB.CLIENT
            OPEN '','FB.AUDIT,':AUDIT.CLIENT.ID TO F.AUDIT ELSE CLIENT.AUDIT=0
         END ELSE
            AUDIT.CLIENT.ID = CLIENT.ID
         END
      END ELSE CLIENT.AUDIT=0
      IF CLIENT.AUDIT=0 THEN
         ERROR = "Client ":CLIENT.ID:" is not setup for freight estimates"
         GO 9000
      END
      OPEN '','FB.AUDIT.TABLES,':AUDIT.CLIENT.ID TO F.AUDIT.TABLES ELSE
         ERROR = "Cannot open file FB.AUDIT.TABLES,":AUDIT.CLIENT.ID
         GO 9000
      END
      OPEN '','FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID TO F.AUDIT.ZIPS ELSE
         ERROR = "Cannot open FB.AUDIT.ZIPS,":AUDIT.CLIENT.ID:" No On-Line Audit Allowed!"
         GO 9000
      END
      IF CLIENT.ID='01282' AND ORG.CAN=1 AND DST.CAN=1 THEN  ; * JMK55
         AUDIT.CLIENT.ID = '01866'       ; * JMK55
         OPEN '','FB.AUDIT,':AUDIT.CLIENT.ID TO F.AUDIT ELSE CLIENT.AUDIT=0      ; * JMK55
         OPEN '','FB.AUDIT.TABLES,':AUDIT.CLIENT.ID TO F.AUDIT.TABLES ELSE       ; * JMK55
            ERROR = "Error! Cannot open file FB.AUDIT.TABLES,":AUDIT.CLIENT.ID   ; * JMK55
            GO 9000                      ; * JMK55
         END                             ; * JMK55
         OPEN '','FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID TO F.AUDIT.ZIPS ELSE           ; * JMK55
            EXECUTE 'CREATE-FILE DATA FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID:' 7,1' CAPTURING OUTPUT        ; * JMK55
            OPEN '','FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID TO F.AUDIT.ZIPS ELSE        ; * JMK55
               ERROR = "Error Cannot open FB.AUDIT.ZIPS,":AUDIT.CLIENT.ID:" No On-Line Audit Allowed!"         ; * JMK55
               GO 9000                   ; * JMK55
            END                          ; * JMK55
         END                             ; * JMK55
         MARK.UP.FACTOR=0                ; * SWB02
      END                                ; * JMK55

      IF CLIENT.ID='01832' THEN          ; * JMK56
         IF ORG.CAN=0 OR DST.CAN=0 THEN  ; * JMK56
            AUDIT.CLIENT.ID = '01870'    ; * JMK56
            OPEN '','FB.AUDIT,':AUDIT.CLIENT.ID TO F.AUDIT ELSE CLIENT.AUDIT=0   ; * JMK56
            OPEN '','FB.AUDIT.TABLES,':AUDIT.CLIENT.ID TO F.AUDIT.TABLES ELSE    ; * JMK56
               ERROR = "Error! Cannot open file FB.AUDIT.TABLES,":AUDIT.CLIENT.ID          ; * JMK56
               GO 9000                   ; * JMK56
            END                          ; * JMK56
            OPEN '','FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID TO F.AUDIT.ZIPS ELSE        ; * JMK56
               EXECUTE 'CREATE-FILE DATA FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID:' 7,1' CAPTURING OUTPUT     ; * JMK56
               OPEN '','FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID TO F.AUDIT.ZIPS ELSE     ; * JMK56
                  ERROR = "Error Cannot open FB.AUDIT.ZIPS,":AUDIT.CLIENT.ID:" No On-Line Audit Allowed!"      ; * JMK56
                  GO 9000                ; * JMK56
               END                       ; * JMK56
            END                          ; * JMK56
            MARK.UP.FACTOR=0             ; * SWB02
         END                             ; * JMK56
      END                                ; * JMK56

      CLIENT.STATUS=DCLIENTS<30>         ; * JMK63
      IF CLIENT.STATUS='I' THEN          ; * JMK63
         READV AUDIT.CLIENT.STATUS FROM F.CLIENTS,AUDIT.CLIENT.ID,30 ELSE AUDIT.CLIENT.STATUS='I'    ; * JMK63
         IF AUDIT.CLIENT.STATUS='A' THEN CLIENT.STATUS='A'   ; * JMK63
         IF CLIENT.STATUS='I' THEN       ; * JMK63
            ERROR='CANNOT ESTIMATE FOR THIS CLIENT. PLEASE CONTACT AFS.'         ; * JMK63
            GOTO 9000                    ; * JMK63
         END                             ; * JMK63
      END                                ; * JMK63
*
* Select Carrier(s) (Even if only one) to Loop thru
*
      STMT= 'SSELECT FB.AUDIT,':AUDIT.CLIENT.ID    ; * NPR09
      STMT:=' BY-DSND CARRIER.NAME'      ; * NPR09
      STMT:=' WITH 1 = "LTLALL"'
      IF CARRIER.ID # 'ALL' THEN
         OLA.CARRIER.ID=CARRIER.ID
         IF CARRIER.ID='13171' THEN OLA.CARRIER.ID='01625'
         STMT:=" AND WITH CARRIER# '":OLA.CARRIER.ID:"'"
      END ELSE
         STMT:=' AND WITH 11 = "ENABLE"'
         IF LOGISTICS THEN STMT:=' AND WITH 13 = "Y""I"'     ; * Core Carrier Flag = "Y"
      END
      IF VENDOR.STATUS AND IOT = "I" THEN          ; * JMK37
         STMT:=' AND WITH 8 = "':DEST.ZIP:'"'      ; * JMK37
      END                                ; * JMK37
      EXECUTE STMT RTNLIST CHECK.LIST CAPTURING OUTPUT
      IF @SELECTED < 1 THEN              ; * JCW01
         IF CARRIER.ID # 'ALL' THEN
            ERROR='Carrier ':CARRIER.ID:' is not set up for freight estimates'
         END ELSE
            ERROR='There are no core carriers set up for freight estimates'
         END
         GO 9000
      END
*
* Setup AUDIT.VIN
      AUDIT=''                           ; * JMK06
      A.VIN=''
      A.VIN<3>=SHIP.DATE
      A.VIN<11>=AUDIT.CLIENT.ID
      A.VIN<12>=IOT
      A.VIN<13,1>=ORIG.ZIP
      A.VIN<13,2>=ORIG.CITY
      A.VIN<13,3>=ORIG.ST
      A.VIN<14,1>=DEST.ZIP
      A.VIN<14,2>=DEST.CITY
      A.VIN<14,3>=DEST.ST
      A.VIN<16>=USER
      A.VIN<17>=0                        ; *Misroute Flag to Ignore Misc Charge Code Errors
      A.VIN<18>=CLASSES
      A.VIN<19>=WEIGHTS
      A.VIN<21>=MISC.CHG.CODES
      A.VIN<24>=LOGISTICS
      A.VIN<25>=''
      A.VIN<35>=CL.LOG.FSC='N'           ; * Flag to NOT Calculate Log FSC
      A.VIN<46>=MAX.LTL                  ; * JMK02
      A.VIN<48>=DCLIENTS<188>            ; * JMK03 Forced Benchmark Minimum Flag Y/N
      A.VIN<49>=CARR.ONLY.FSC            ; * JMK05
*
**** Begin "Loop" of all Carriers *****
*

      IF COMBINE.RATE=0 THEN             ; * JMK37
         CARRIER.EST.ARRAY=''
         CARRIER.COST.ARRAY=''           ; * NPR04
      END                                ; * JMK37
*<1>=Amount (MV Lowest to Highest)
*<2>=Carrier #
*<3>=Carrier Name
*<4>=Carrier Address
*<5>=Carrier City
*<6>=Carrier State
*<7>=Error (If Any)
*<8>=Flag
*<9>=Client's True Cost (Contract Amount + Logistics Commission)
*<10>=Contract Amount
*<11>=Benchmark Amount
*<12>=Logistics Commission Amount
      ACC.ERROR=''                       ; * JMK28
GET.NEXT.CARRIER:
      READNEXT CHECK.CARRIER.ID FROM CHECK.LIST ELSE
         GO 9000
      END
      ERROR=''

      BEGIN CASE
*DF         CASE AIRGAS.ZONEA.GAS AND CHECK.CARRIER.ID NE "00001"         ; * Only allow carrier 00001 ABF for Zone A gasses
         CASE AIRGAS.ZONEA.GAS AND CHECK.CARRIER.ID NE "31597"         ; * Only allow carrier 31597 Air Liquide for Zone A gasses
            GOTO GET.NEXT.CARRIER
         CASE AIRGAS.ZONEA.GAS AND CHECK.CARRIER.ID EQ "00001" AND SHIP.DATE GE "17972"    ; * Do not allow carrier 00001 ABF for Zone A gasses on or after 03/15/17 (17972)
            GOTO GET.NEXT.CARRIER
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "00018"          ; * Allow all carriers except 00018 Saia, 00030 Central, and 01786 Pitt Ohio ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "00030"          ; * Allow all carriers except 00018 Saia, 00030 Central, and 01786 Pitt Ohio ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "01786"          ; * Allow all carriers except 00018 Saia, 00030 Central, and 01786 Pitt Ohio ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "00787"          ; * Allow all carriers except 00787 Averitt, 02715 Dayton, 00979 SEFL, 02434 A Duie Pyle and 00453 ODFL ; * DRF14
            GOTO GET.NEXT.CARRIER        ; * DRF14
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "02715"          ; * Allow all carriers except 00787 Averitt, 02715 Dayton, 00979 SEFL, 02434 A Duie Pyle and 00453 ODFL ; * DRF14
            GOTO GET.NEXT.CARRIER        ; * DRF14
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "00979"          ; * Allow all carriers except 00787 Averitt, 02715 Dayton, 00979 SEFL, 02434 A Duie Pyle and 00453 ODFL ; * DRF14
            GOTO GET.NEXT.CARRIER        ; * DRF14
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "02434"          ; * Allow all carriers except 00787 Averitt, 02715 Dayton, 00979 SEFL, 02434 A Duie Pyle and 00453 ODFL ; * DRF14
            GOTO GET.NEXT.CARRIER        ; * DRF14
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "00453"          ; * Allow all carriers except 00787 Averitt, 02715 Dayton, 00979 SEFL, 02434 A Duie Pyle and 00453 ODFL ; * DRF14
            GOTO GET.NEXT.CARRIER        ; * DRF14
         CASE AIRGAS.ZONEB.GAS AND CHECK.CARRIER.ID = "00001"          ; * Exclude carrier 00001 ABF also ; * DRF14
            GOTO GET.NEXT.CARRIER        ; * DRF14
         CASE AIRGAS.ZONEC.GAS AND CHECK.CARRIER.ID = "00018"          ; * Allow all carriers except 00018 Saia, 00030 Central, and 01786 Pitt Ohio ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
         CASE AIRGAS.ZONEC.GAS AND CHECK.CARRIER.ID = "00030"          ; * Allow all carriers except 00018 Saia, 00030 Central, and 01786 Pitt Ohio ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
         CASE AIRGAS.ZONEC.GAS AND CHECK.CARRIER.ID = "01786"          ; * Allow all carriers except 00018 Saia, 00030 Central, and 01786 Pitt Ohio ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
         CASE AIRGAS.ZONEC.GAS AND CHECK.CARRIER.ID = "00001"          ; * Exclude carrier 00001 ABF also ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
         CASE AIRGAS.ZONEE.GAS AND CHECK.CARRIER.ID = "00001"          ; * Exclude carrier 00001 ABF  ; * DRF07
            GOTO GET.NEXT.CARRIER        ; * DRF07
*DF         CASE AIRGAS.2.3.GAS AND CHECK.CARRIER.ID = "00018"  ; * Allow all carriers except 00018 SAIA class 2.3 gasses ; * DRF07
*DF            GOTO GET.NEXT.CARRIER    ; * DRF07
         CASE 1
      END CASE
      IF CHECK.CARRIER.ID='00114' THEN   ; * JMK73
         LOCATE ORIG.ZIP IN RL.FERRY.ZIP<1> SETTING RLPOS THEN         ; * JMK73
            ERROR=ORIG.ZIP:' - ':ORIG.CITY:', ':ORIG.ST:' requires a Ferry Fee for R&L'    ; * JMK73
            GOTO GET.NEXT.CARRIER        ; * JMK73
         END                             ; * JMK73
         LOCATE DEST.ZIP IN RL.FERRY.ZIP<1> SETTING RLPOS THEN         ; * JMK73
            ERROR=DEST.ZIP:' - ':DEST.CITY:', ':DEST.ST:' requires a Ferry Fee for R&L'    ; * JMK73
            GOTO GET.NEXT.CARRIER        ; * JMK73
         END                             ; * JMK73
      END                                ; * JMK73
      CARR.ONLY.FSC=DCLIENTS<189>        ; * JMK31
      A.VIN<49>=CARR.ONLY.FSC            ; * JMK31

      IF AUDIT.CLIENT.ID='01505' THEN    ; * JMK31
         CARR.ONLY.FSC=DCLIENTS<189>     ; * JMK31
         IF CARR.ONLY.FSC='Y' OR CARR.ONLY.FSC='C' THEN      ; * JMK31
            BEGIN CASE                   ; * JMK31
               CASE CHECK.CARRIER.ID='00124'       ; * JMK31
                  CARR.ONLY.FSC='N'      ; * JMK31
               CASE CHECK.CARRIER.ID='01786'       ; * JMK31
                  CARR.ONLY.FSC='N'      ; * JMK31
               CASE CHECK.CARRIER.ID='05156'       ; * JMK31
                  CARR.ONLY.FSC='N'      ; * JMK31
               CASE CHECK.CARRIER.ID='08924'       ; * JMK31
                  CARR.ONLY.FSC='N'      ; * JMK31
            END CASE                     ; * JMK31
         END                             ; * JMK31
         A.VIN<49>=CARR.ONLY.FSC         ; * JMK31
      END                                ; * JMK31
      IF AUDIT.CLIENT.ID='01758' THEN    ; * JMK39
         CARR.ONLY.FSC=DCLIENTS<189>     ; * JMK39
         IF CARR.ONLY.FSC='Y' OR CARR.ONLY.FSC='C' THEN      ; * JMK39
            BEGIN CASE                   ; * JMK39
               CASE CHECK.CARRIER.ID='00748'       ; * JMK39
                  CARR.ONLY.FSC='N'      ; * JMK39
            END CASE                     ; * JMK39
         END                             ; * JMK39
         A.VIN<49>=CARR.ONLY.FSC         ; * JMK39
      END                                ; * JMK39
      IF AUDIT.CLIENT.ID='01784' THEN    ; * JMK44
         CARR.ONLY.FSC=DCLIENTS<189>     ; * JMK44
         IF CARR.ONLY.FSC='Y' OR CARR.ONLY.FSC='C' THEN      ; * JMK44
            BEGIN CASE                   ; * JMK44
               CASE CHECK.CARRIER.ID='00014'       ; * JMK44
                  CARR.ONLY.FSC='N'      ; * JMK44
            END CASE                     ; * JMK44
         END                             ; * JMK44
         A.VIN<49>=CARR.ONLY.FSC         ; * JMK44
      END                                ; * JMK44
      IF AUDIT.CLIENT.ID='01810' THEN    ; * JMK44
         CARR.ONLY.FSC=DCLIENTS<189>     ; * JMK44
         IF CARR.ONLY.FSC='Y' OR CARR.ONLY.FSC='C' THEN      ; * JMK44
            BEGIN CASE                   ; * JMK44
               CASE CHECK.CARRIER.ID='00014'       ; * JMK44
                  CARR.ONLY.FSC='N'      ; * JMK44
            END CASE                     ; * JMK44
         END                             ; * JMK44
         A.VIN<49>=CARR.ONLY.FSC         ; * JMK44
      END                                ; * JMK44
      GOSUB GET.CARRIER.INFO
      IF ERROR#'' AND CARRIER.ID # 'ALL' THEN      ; * JMK08
         ERROR='Carrier ':CARRIER.ID:' is not set up for freight estimates'
         GO 9000
      END
      A.VIN<10>= CHECK.CARRIER.ID        ; * Add "Current" Carrier to AUDIT.VIN
      A.VIN<50>= CARRIER.SCAC            ; * JMK09
      A.VIN<51>= CARRIER.TYPE            ; * JMK09
      TOT.WEIGHT = SUM(WEIGHTS)          ; *DRF01
      TEMP.MISC.CHG=MISC.CHG.CODES       ; *DRF01
      LOCATE TOT.WEIGHT IN CARRIER.REC<70> BY "AR" SETTING WEIGHT.POS ELSE NULL  ; *DRF01
      TEMP.TRANSPORT.MODE = OCONV(CARRIER.REC<71,WEIGHT.POS>,'MCU')    ; *DRF01
      ZIP.LINE.ID=CHECK.CARRIER.ID:'*':CLIENT.ID:'*':TEMP.TRANSPORT.MODE:'*':IOT           ; *DRF01
      READ DZIP.LINE FROM F.ZIP.LINE.ITEM,ZIP.LINE.ID ELSE   ; *DRF01
         ZIP.LINE.ID=CHECK.CARRIER.ID:'*ALL*':TEMP.TRANSPORT.MODE:'*':IOT        ; *DRF01
         READ DZIP.LINE FROM F.ZIP.LINE.ITEM,ZIP.LINE.ID ELSE DZIP.LINE=''       ; *DRF01
      END                                ; *DRF01
      IF DZIP.LINE#'' THEN               ; *DRF01
         LOCATE ORIG.ZIP IN DZIP.LINE<1> BY 'AR' SETTING ZIP.POS THEN  ; *DRF01
            ZIP.POS=ZIP.POS+1            ; *DRF01
         END                             ; *DRF01
         IF ZIP.POS > 1 THEN             ; *DRF01
            ZIP.POS=ZIP.POS-1            ; *DRF01
            IF DZIP.LINE<2,ZIP.POS> >= ORIG.ZIP THEN         ; *DRF01
               NUM.OF.SVM = DCOUNT(DZIP.LINE<3,ZIP.POS>,@SVM)          ; *DRF01
               FOR Z = 1 TO NUM.OF.SVM   ; *DRF01
                  IF DZIP.LINE<4,ZIP.POS,Z>='O' OR DZIP.LINE<4,ZIP.POS,Z>='B' THEN         ; *DRF01
                     LOCATE DZIP.LINE<3,ZIP.POS,Z> IN TEMP.MISC.CHG<1> SETTING DUMMY.POS ELSE        ; *DRF01
                        INS DZIP.LINE<3,ZIP.POS,Z> BEFORE TEMP.MISC.CHG<1,1>     ; *DRF01
                     END                 ; *DRF01
                  END                    ; *DRF01
               NEXT Z                    ; *DRF01
            END                          ; *DRF01
         END                             ; *DRF01
         LOCATE DEST.ZIP IN DZIP.LINE<1> BY 'AR' SETTING ZIP.POS THEN  ; *DRF01
            ZIP.POS=ZIP.POS+1            ; *DRF01
         END                             ; *DRF01
         IF ZIP.POS > 1 THEN             ; *DRF01
            ZIP.POS=ZIP.POS-1            ; *DRF01
            IF DZIP.LINE<2,ZIP.POS> >= DEST.ZIP THEN         ; *DRF01
               NUM.OF.SVM = DCOUNT(DZIP.LINE<3,ZIP.POS>,@SVM)          ; *DRF01
               FOR Z = 1 TO NUM.OF.SVM   ; *DRF01
                  IF DZIP.LINE<4,ZIP.POS,Z>='D' OR DZIP.LINE<4,ZIP.POS,Z>='B' THEN         ; *DRF01
                     LOCATE DZIP.LINE<3,ZIP.POS,Z> IN TEMP.MISC.CHG<1> SETTING DUMMY.POS ELSE        ; *DRF01
                        INS DZIP.LINE<3,ZIP.POS,Z> BEFORE TEMP.MISC.CHG<1,1>     ; *DRF01
                     END                 ; *DRF01
                  END                    ; *DRF01
               NEXT Z                    ; *DRF01
            END                          ; *DRF01
         END                             ; *DRF01
      END                                ; *DRF01
      A.VIN<21>=TEMP.MISC.CHG<1>
      VIN=A.VIN
      * Begin NKH02
      GOSUB POPULATE.CC.INFO
      VIN<56>=ORIG.DIR.FLG
      IF DEST.DIR.FLG = 'C' OR DEST.DIR.FLG = 'P' THEN DEST.DIR.FLG = 'I'
      VIN<57>=DEST.DIR.FLG
      IF COMB.DIR.FLG = 'C' OR COMB.DIR.FLG = 'P' THEN COMB.DIR.FLG = 'I'
      VIN<58>=COMB.DIR.FLG
      * End NKH02
      A.VOUT = ''
*****DEBUG
      CALL FB.AUTO.V2(VIN,A.VOUT,D.AUDIT,CONTR.DFSC,BENCH.DFSC,DTARIFFS,DTARIFF.DATE.XREF,LI.CODES,F.AUDIT.TABLES,F.AUDIT.ZIPS,F.PCIN,F.PCOUT,F.TABLES)          ; * NKH01
****DEBUG

*      CALL FB.AUTO.TP(VIN,A.VOUT,D.AUDIT,CONTR.DFSC,BENCH.DFSC,DTARIFFS,DTARIFF.DATE.XREF,LI.CODES,F.AUDIT.TABLES,F.AUDIT.ZIPS,F.PCIN,F.PCOUT,F.TABLES) ; * NKH01
      GB1 = A.VOUT<97>
      ** DEBUG
      GBB.RATE = A.VOUT<97,5>
      GBB.CONTRACT.BASE = A.VOUT<97,8>
      GBB.CONTRACT.BASE = GBB.CONTRACT.BASE<1,1>
      GBB.CARRIER.FUEL.BENCH=A.VOUT<97,15,2>
      GBB.AFS.BENCH.TOT = A.VOUT<97,15,1>
      GBB.CONTRACT.CHARGE = A.VOUT<97,6>
      GBB.CONTRACT.DISC = A.VOUT<97,7>
      GBB.CONTRACT.FUEL = A.VOUT<97,8>
      GBB.CONTRACT.FUEL =GBB.CONTRACT.FUEL<1,2>
      GBB.BENCH.CHARGE=A.VOUT<97,12>
      GBB.CONTRACT.ACC = A.VOUT<97,8>
      GBB.CONTRACT.ACC = GBB.CONTRACT.ACC<1,3>
      GBB.BENCH.ACC = A.VOUT<97,14>
      GBB.BENCH.ACC =GBB.BENCH.ACC<1,3>


      WORK = GB1<1>
      CONT.TOT = 0
      BENCH.TOT = 0

      WORK.CNT = DCOUNT(WORK<1,1>,@SVM)
      FOR II = 1 TO WORK.CNT
         IF WORK<1,1,II> = "FRT" THEN CONTINUE
         IF WORK<1,1,II> = "ABMIN" THEN CONTINUE
         IF WORK<1,1,II> = "OMIN" THEN CONTINUE
         IF WORK<1,1,II> = "FSC" THEN CONTINUE
         IF WORK<1,1,II> = "TMIN" THEN CONTINUE
         IF WORK<1,1,II> = "MIN" THEN CONTINUE
         IF WORK<1,1,II> = "DEF" THEN CONTINUE

         CONT.TOT = CONT.TOT +WORK<1,8,II>
         BENCH.TOT = BENCH.TOT + WORK<1,14,II>
      NEXT II

      GBB.BENCH.ACC = BENCH.TOT
      GBB.CONTRACT.ACC = CONT.TOT
      GB.LOG.AMT = 0
      CONTRACT.TOT = 0
      BENCH.TOT = 0
      **    DEBUG
      WORK.CNT = DCOUNT(WORK<1,1>,@SVM)
      FOR II = 1 TO WORK.CNT
         IF WORK<1,1,II> = "FRT" THEN
            FRT.CONTR = WORK<1,8,II>
            FRT.BENCH = WORK<1,14,II>
            IF FRT.CONTR GT FRT.BENCH THEN
               CONTR = 0
               BENCH = 0
            END ELSE
               CONTR = FRT.CONTR
               BENCH = FRT.BENCH
            END
         END ELSE
            CONTR = WORK<1,8,II>
            BENCH = WORK<1,14,II>
         END
         CONTRACT.TOT = CONTRACT.TOT + CONTR
         BENCH.TOT = BENCH.TOT + BENCH

      NEXT II
      GB.LOG.AMT = BENCH.TOT - CONTRACT.TOT


      ** IF WORK<1,1,II> = "ABMIN" THEN CONTINUE
      ** IF WORK<1,1,II> = "OMIN" THEN CONTINUE
      ** IF WORK<1,1,II> = "FSC" THEN CONTINUE
      ** IF WORK<1,1,II> = "TMIN" THEN CONTINUE
      ** IF WORK<1,1,II> = "MIN" THEN CONTINUE
      ** IF WORK<1,1,II> = "DEF" THEN CONTINUE



      * Begin NKH02
      ORIG.ZIP = FIELD(A.VIN<13>,@VM,1,1)
      ORIG.CITY = FIELD(A.VIN<13>,@VM,2,1)
      ORIG.STATE = FIELD(A.VIN<13>,@VM,3,1)
      DEST.ZIP = FIELD(A.VIN<14>,@VM,1,1)
      DEST.CITY = FIELD(A.VIN<14>,@VM,2,1)
      DEST.STATE = FIELD(A.VIN<14>,@VM,3,1)
      * End NKH02

      WHY=A.VOUT<24>                     ; * Save for Debugging purposes

      A.VOUT<24>=''                      ; * Kill Why So you can look at A.VOUT with Debugger
      CONTR.AMT = A.VOUT<8>
      IF CONTR.AMT GE 1000000 THEN
         ERROR='Unable to Quote.. Please call Customer Service'
         CONTR.AMT=0
      END ELSE
         BENCH.AMT = A.VOUT<9>
         ERROR=A.VOUT<1>
         AUDIT=A.VOUT<2>
         ZIP.MESSAGE=A.VOUT<29>
      END
      CONTR.FSC.PARMS=A.VOUT<46>         ; * JMK18
      BENCH.FSC.PARMS=A.VOUT<47>         ; * JMK18
      AFS.FSC.PARMS=A.VOUT<48>           ; * JMK18
      CONTR.FSC.AMT=CONTR.FSC.PARMS<1,7>           ; * JMK18
      BENCH.FSC.AMT=BENCH.FSC.PARMS<1,7>           ; * JMK18
*      TRANSIT.TIME=A.VOUT<49>            ; * JMK09    ; * NKH02
      ORIG.DIRECT.FLAG=A.VOUT<50>        ; * JMK09
      IF ORIG.DIRECT.FLAG = 'C' OR ORIG.DIRECT.FLAG = 'P' THEN ORIG.DIRECT.FLAG = 'I'      ; * NKH02
      DEST.DIRECT.FLAG=A.VOUT<51>        ; * JMK09
      IF DEST.DIRECT.FLAG = 'C' OR DEST.DIRECT.FLAG = 'P' THEN DEST.DIRECT.FLAG = 'I'      ; * NKH02
      COMB.DIRECT.FLAG=A.VOUT<52>        ; * JMK09
      IF COMB.DIRECT.FLAG = 'C' OR COMB.DIRECT.FLAG = 'P' THEN COMB.DIRECT.FLAG = 'I'      ; * NKH02
      IF ORIG.DIRECT.FLAG='I' THEN       ; * DFP01
         IF TRANSIT.TIME # '' THEN       ; * DFP01
            TRANSIT.TIME+=1              ; * DFP01
         END                             ; * DFP01
      END                                ; * DFP01
      IF DEST.DIRECT.FLAG='I' THEN       ; * DFP01
         IF TRANSIT.TIME # '' THEN       ; * DFP01
            TRANSIT.TIME+=1              ; * DFP01
         END                             ; * DFP01
      END                                ; * DFP01

* Begin NKH02
*      ORIG.TERM.NAME=A.VOUT<53>          ; * JMK11
*      ORIG.TERM.CODE=A.VOUT<54>          ; * JMK11
*      ORIG.TERM.ADR1=A.VOUT<55>          ; * JMK11
*      ORIG.TERM.ADR2=A.VOUT<56>          ; * JMK11
*      ORIG.TERM.CITY=A.VOUT<57>          ; * JMK11
*      ORIG.TERM.ST=A.VOUT<58>            ; * JMK11
*      ORIG.TERM.ZIP=A.VOUT<59>           ; * JMK11
*      ORIG.TERM.PHONE=A.VOUT<60>         ; * JMK11
*      ORIG.TERM.TPHONE=A.VOUT<61>        ; * JMK11
*      ORIG.TERM.FAX=A.VOUT<62>           ; * JMK11
*      ORIG.TERM.EMAIL=A.VOUT<63>         ; * JMK11
*      ORIG.TERM.CNAME=A.VOUT<64>         ; * JMK11
*      ORIG.TERM.CTITLE=A.VOUT<65>        ; * JMK11
*      DEST.TERM.NAME=A.VOUT<66>          ; * JMK11
*      DEST.TERM.CODE=A.VOUT<67>          ; * JMK11
*      DEST.TERM.ADR1=A.VOUT<68>          ; * JMK11
*      DEST.TERM.ADR2=A.VOUT<69>          ; * JMK11
*      DEST.TERM.CITY=A.VOUT<70>          ; * JMK11
*      DEST.TERM.ST=A.VOUT<71>            ; * JMK11
*      DEST.TERM.ZIP=A.VOUT<72>           ; * JMK11
*      DEST.TERM.PHONE=A.VOUT<73>         ; * JMK11
*      DEST.TERM.TPHONE=A.VOUT<74>        ; * JMK11
*      DEST.TERM.FAX=A.VOUT<75>           ; * JMK11
*      DEST.TERM.EMAIL=A.VOUT<76>         ; * JMK11
*      DEST.TERM.CNAME=A.VOUT<77>         ; * JMK11
*      DEST.TERM.CTITLE=A.VOUT<78>        ; * JMK11
* End NKH02
      ACC.CODES=CHANGE(A.VOUT<79>,@VM,@SVM)        ; * JMK18
      ACC.CONTR=CHANGE(A.VOUT<80>,@VM,@SVM)        ; * JMK18
      ACC.BENCH=CHANGE(A.VOUT<81>,@VM,@SVM)        ; * JMK18
*      CARR.DATA.DATE=A.VOUT<82>          ; * JMK21    ; * NKH02
      CONTR.BILL.TYPE=A.VOUT<89>         ; * JMK58
      BENCH.BILL.TYPE=A.VOUT<90>         ; * JMK58
      RW.TARIFF=A.VOUT<99>               ; * NKH04
      RW.EFF.DATE=A.VOUT<100>            ; * NKH04
      IF ERROR # "" THEN
         IF CARRIER.ID # 'ALL' AND CONTR.AMT+0=0 THEN
            GO 9000
         END
      END
      IF CLIENT.ID='01365' THEN          ; * JMK27
         IF A.VOUT<49>+0=0 THEN GO GET.NEXT.CARRIER          ; * JMK27
      END                                ; * JMK27
      IF MISC.CHG.CODES#'' AND INDEX(ERROR,'Accessorial',1) THEN       ; * JMK28
         LOCATE ERROR IN ACC.ERROR<1> SETTING EPOS ELSE      ; * JMK28
            ACC.ERROR<1,-1>=ERROR        ; * JMK28
         END                             ; * JMK28
      END                                ; * JMK28
      IF AUDIT # "Y" AND CARRIER.ID="ALL" THEN GO GET.NEXT.CARRIER
      IF AUDIT = "MA" THEN ERROR = "Not an approved carrier for this shipment!"

      IF CONTR.AMT+0=0 THEN GO GET.NEXT.CARRIER
      IF LOGISTICS AND BENCH.AMT+0=0 THEN GO GET.NEXT.CARRIER

      IF COMB.DIRECT.FLAG='I' AND IOT='I' THEN GO GET.NEXT.CARRIER     ; * JMK09 ; * JMK10
*
*** Add Quote Percentage Logic Here ***
**********************************************************************
*** Locate and set percentages for quotes and commissions
      IF LOGISTICS THEN
         LOCATE SHIP.DATE IN DCLIENTS<84> BY 'AR' SETTING POS ELSE
            POS=POS-1
         END
         IF POS<1 THEN
            ERROR="Cannot Estimate! Ship date is before 1st Charge Date in Client Maintenance"
            GO 9000
         END
         COMM.PERC = DCLIENTS<85,POS>/100
         IF AUDIT.CLIENT.ID='00735' THEN COMM.PERC=0         ; * JMK - UNTIL WE CAN ADD PERCENT BY MODE
         SAVINGS = BENCH.AMT-CONTR.AMT
         LOG.COMM = (SAVINGS*COMM.PERC/100)'R0'
         IF CLIENT.ID='01510' THEN       ; * JMK50

            LOG.COMM=(CONTR.AMT*.08)'R0'           ; * JMK50 ; * JMK60
         END                             ; * JMK50
         IF CLIENT.ID='02171' THEN
            LOG.COMM=(CONTR.AMT*.15)'R0'
         END

         IF CLIENT.ID='01769' THEN       ; * JMK67
            LOG.COMM='800'               ; * JMK67
         END                             ; * JMK67
         IF CLIENT.ID='02215' THEN
            LOG.COMM=(CONTR.AMT*.12)'R0'
         END
*DF         IF CLIENT.ID='02465' THEN       ; * JMK69    ; * DRF17
*DF            LOG.COMM=(CONTR.AMT*.20)'R0'           ; * JMK69    ; * DRF17
*DF            DATE.SETUP=DCLIENTS<84>      ; * JMK69    ; * DRF17
*DF            CONSULTING.RATE=DCLIENTS<85>           ; * JMK69    ; * DRF17
*DF            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * JMK69    ; * DRF17
*DF            IF MOD.POS=0 THEN MOD.POS=1  ; * JMK69    ; * DRF17
*DF            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * JMK69    ; * DRF17
*DF            IF CONSULTING.PERC=0 THEN    ; * JMK69    ; * DRF17
*DF               LOG.COMM=0                ; * JMK69    ; * DRF17
*DF            END                          ; * JMK69    ; * DRF17
*DF         END                             ; * JMK69    ; * DRF17


         IF CLIENT.ID='05096' THEN       ; * JMK74
            LOG.COMM=(CONTR.AMT*.10)'R0'           ; * JMK74
            DATE.SETUP=DCLIENTS<84>      ; * JMK74
            CONSULTING.RATE=DCLIENTS<85>           ; * JMK74
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * JMK74
            IF MOD.POS=0 THEN MOD.POS=1  ; * JMK74
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * JMK74
            IF CONSULTING.PERC=0 THEN    ; * JMK74
               LOG.COMM=0                ; * JMK74
            END                          ; * JMK74
         END                             ; * JMK74

         IF CLIENT.ID='05178' THEN       ; * JMK78
            LOG.COMM=(CONTR.AMT*.05)'R0'           ; * JMK78
            DATE.SETUP=DCLIENTS<84>      ; * JMK78
            CONSULTING.RATE=DCLIENTS<85>           ; * JMK78
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * JMK78
            IF MOD.POS=0 THEN MOD.POS=1  ; * JMK78
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * JMK78
            IF CONSULTING.PERC=0 THEN    ; * JMK78
               LOG.COMM=0                ; * JMK78
            END                          ; * JMK78
         END                             ; * JMK78
         IF CLIENT.ID='05238' THEN       ; * JMK77
            LOG.COMM=(CONTR.AMT*.15)'R0'           ; * JMK77
            DATE.SETUP=DCLIENTS<84>      ; * JMK77
            CONSULTING.RATE=DCLIENTS<85>           ; * JMK77
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * JMK77
            IF MOD.POS=0 THEN MOD.POS=1  ; * JMK77
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * JMK77
            IF CONSULTING.PERC=0 THEN    ; * JMK77
               LOG.COMM=0                ; * JMK77
            END                          ; * JMK77
         END                             ; * JMK77
         IF CLIENT.ID='05294' THEN       ; * DRF04
            IF TEMP.TRANSPORT.MODE=1 THEN          ; * DRF05
               LOG.COMM=(CONTR.AMT*.03)'R0'        ; * DRF04
            END ELSE                     ; * DRF05
               LOG.COMM=0                ; * DRF05
            END                          ; * DRF05
            DATE.SETUP=DCLIENTS<84>      ; * DRF04
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF04
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF04
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF04
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF04
            IF CONSULTING.PERC=0 THEN    ; * DRF04
               LOG.COMM=0                ; * DRF04
            END                          ; * DRF04
         END                             ; * DRF04
         IF CLIENT.ID='02374' THEN       ; * DRF06
            IF TEMP.TRANSPORT.MODE=1 THEN          ; * DRF06
               LOG.COMM=(CONTR.AMT*.12)'R0'        ; * DRF06
            END ELSE                     ; * DRF06
               LOG.COMM=0                ; * DRF06
            END                          ; * DRF06
            DATE.SETUP=DCLIENTS<84>      ; * DRF06
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF06
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF06
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF06
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF06
            IF CONSULTING.PERC=0 THEN    ; * DRF06
               LOG.COMM=0                ; * DRF06
            END                          ; * DRF06
         END                             ; * DRF06
         IF CLIENT.ID='02481' THEN       ; * DRF09
            IF TEMP.TRANSPORT.MODE=1 THEN          ; * DRF09
               LOG.COMM=(CONTR.AMT*.10)'R0'        ; * DRF09
            END ELSE                     ; * DRF09
               LOG.COMM=0                ; * DRF09
            END                          ; * DRF09
            DATE.SETUP=DCLIENTS<84>      ; * DRF09
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF09
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF09
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF09
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF09
            IF CONSULTING.PERC=0 THEN    ; * DRF09
               LOG.COMM=0                ; * DRF09
            END                          ; * DRF09
         END                             ; * DRF09
         IF CLIENT.ID='01933' THEN       ; * DRF11
            IF TEMP.TRANSPORT.MODE=1 THEN          ; * DRF11
*DF               LOG.COMM=(CONTR.AMT*.055)'R0'       ; * DRF11
               LOG.COMM=(CONTR.AMT*.0495)'R0'      ; * DRF15
            END ELSE                     ; * DRF11
               LOG.COMM=0                ; * DRF11
            END                          ; * DRF11
            DATE.SETUP=DCLIENTS<84>      ; * DRF11
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF11
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF11
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF11
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF11
            IF CONSULTING.PERC=0 THEN    ; * DRF11
               LOG.COMM=0                ; * DRF11
            END                          ; * DRF11
         END                             ; * DRF11
         IF CLIENT.ID='01801' THEN       ; * DRF12
            LOG.COMM=(CONTR.AMT*.05)'R0'           ; * DRF12
            DATE.SETUP=DCLIENTS<84>      ; * DRF12
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF12
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF12
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF12
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF12
            IF CONSULTING.PERC=0 THEN    ; * DRF12
               LOG.COMM=0                ; * DRF12
            END                          ; * DRF12
         END                             ; * DRF12
         IF CLIENT.ID='05608' THEN       ; * DRF13
            LOG.COMM=(CONTR.AMT*.10)'R0'           ; * DRF13
            DATE.SETUP=DCLIENTS<84>      ; * DRF13
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF13
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF13
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF13
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF13
            IF CONSULTING.PERC=0 THEN    ; * DRF13
               LOG.COMM=0                ; * DRF13
            END                          ; * DRF13
         END                             ; * DRF13
         IF CLIENT.ID='05765' THEN       ; * DRF16
            IF TEMP.TRANSPORT.MODE=1 THEN          ; * DRF16
               LOG.COMM=(CONTR.AMT*.1500)'R0'      ; * DRF16
            END ELSE                     ; * DRF16
               LOG.COMM=0                ; * DRF16
            END                          ; * DRF16
            DATE.SETUP=DCLIENTS<84>      ; * DRF16
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF16
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF16
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF16
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF16
            IF CONSULTING.PERC=0 THEN    ; * DRF16
               LOG.COMM=0                ; * DRF16
            END                          ; * DRF16
         END                             ; * DRF16
         IF CLIENT.ID='05806' THEN       ; * DRF18
            IF TEMP.TRANSPORT.MODE=1 THEN          ; * DRF18
               LOG.COMM=(CONTR.AMT*.0500)'R0'      ; * DRF18
            END ELSE                     ; * DRF18
               LOG.COMM=0                ; * DRF18
            END                          ; * DRF18
            DATE.SETUP=DCLIENTS<84>      ; * DRF18
            CONSULTING.RATE=DCLIENTS<85>           ; * DRF18
            LOCATE DATE() IN DATE.SETUP<1> BY 'AR' SETTING MOD.POS ELSE MOD.POS=MOD.POS-1  ; * DRF18
            IF MOD.POS=0 THEN MOD.POS=1  ; * DRF18
            CONSULTING.PERC=CONSULTING.RATE<1,MOD.POS>       ; * DRF18
            IF CONSULTING.PERC=0 THEN    ; * DRF18
               LOG.COMM=0                ; * DRF18
            END                          ; * DRF18
         END                             ; * DRF18
         CLIENT.COST = CONTR.AMT + LOG.COMM
         CL.SAVINGS = SAVINGS - LOG.COMM
         SAVINGS.QUOTE.AMT = CL.SAVINGS*(1-QUOTE.PERC/10000)
         QUOTE.AMT=OCONV(CONTR.AMT + LOG.COMM + SAVINGS.QUOTE.AMT,'MR0')
*
* CALCULATE FSC QUOTE AMT
*
         FSC.SAVINGS = BENCH.FSC.AMT-CONTR.FSC.AMT           ; * JMK18
         FSC.LOG.COMM = (FSC.SAVINGS*COMM.PERC/100)'R0'      ; * JMK18
         IF CLIENT.ID='01510' THEN       ; * JMK50
            FSC.LOG.COMM = 0             ; * JMK50
         END                             ; * JMK50
         IF CLIENT.ID='02171' THEN
            FSC.LOG.COMM = 0
         END
         IF CLIENT.ID='01769' THEN       ; * JMK67
            FSC.LOG.COMM = 0             ; * JMK67
         END                             ; * JMK67
         IF CLIENT.ID='01909' THEN       ; * JMK53
            FSC.LOG.COMM = 0             ; * JMK53
         END                             ; * JMK53
         IF CLIENT.ID='02215' THEN
            FSC.LOG.COMM = 0
         END
*DF         IF CLIENT.ID='02465' THEN       ; * JMK69    ; * DRF17
*DF            FSC.LOG.COMM = 0             ; * JMK69    ; * DRF17
*DF         END                             ; * JMK69    ; * DRF17
         IF CLIENT.ID='02480' THEN       ; * JMK72
            FSC.LOG.COMM = 0             ; * JMK72
         END                             ; * JMK72
         IF CLIENT.ID='05022' THEN       ; * DRF02
            FSC.LOG.COMM = 0             ; * DRF02
         END                             ; * DRF02
         IF CLIENT.ID='05096' THEN       ; * JMK74
            FSC.LOG.COMM = 0             ; * JMK74
         END                             ; * JMK74
         IF CLIENT.ID='05124' THEN       ; * DRF03
            FSC.LOG.COMM = 0             ; * DRF03
         END                             ; * DRF03
         IF CLIENT.ID='05125' THEN       ; * JMK75
            FSC.LOG.COMM = 0             ; * JMK75
         END                             ; * JMK75
         IF CLIENT.ID='05178' THEN       ; * JMK78
            FSC.LOG.COMM = 0             ; * JMK78
         END                             ; * JMK78
         IF CLIENT.ID='05238' THEN       ; * JMK77
            FSC.LOG.COMM = 0             ; * JMK77
         END                             ; * JMK77
         IF CLIENT.ID='05294' THEN       ; * DRF04
            FSC.LOG.COMM = 0             ; * DRF04
         END                             ; * DRF04
         IF CLIENT.ID='02374' THEN       ; * DRF04
            FSC.LOG.COMM = 0             ; * DRF04
         END                             ; * DRF04
         IF CLIENT.ID='02481' THEN       ; * DRF09
            FSC.LOG.COMM = 0             ; * DRF09
         END                             ; * DRF09
         IF CLIENT.ID='01933' THEN       ; * DRF11
            FSC.LOG.COMM = 0             ; * DRF11
         END                             ; * DRF11
         IF CLIENT.ID='01801' THEN       ; * DRF12
            FSC.LOG.COMM = 0             ; * DRF12
         END                             ; * DRF12
         IF CLIENT.ID='05608' THEN       ; * DRF13
            FSC.LOG.COMM = 0             ; * DRF13
         END                             ; * DRF13
         IF CLIENT.ID='05765' THEN       ; * DRF16
            FSC.LOG.COMM = 0             ; * DRF16
         END                             ; * DRF16
         IF CLIENT.ID='05806' THEN       ; * DRF18
            FSC.LOG.COMM = 0             ; * DRF18
         END                             ; * DRF18
         FSC.CLIENT.COST = CONTR.FSC.AMT + FSC.LOG.COMM      ; * JMK18
         FSC.CL.SAVINGS = FSC.SAVINGS - FSC.LOG.COMM         ; * JMK18
         FSC.SAVINGS.QUOTE.AMT = FSC.CL.SAVINGS*(1-QUOTE.PERC/10000)   ; * JMK18
         FSC.QUOTE.AMT=OCONV(CONTR.FSC.AMT + FSC.LOG.COMM + FSC.SAVINGS.QUOTE.AMT,'MR0')   ; * JMK18
*
* CALCULATE ACCESSORIAL QUOTE AMTS
*
         ACC.QUOTE=''                    ; * JMK18
         NSVAL=DCOUNT(ACC.CODES<1>,@SVM)           ; * JMK18
         FOR SVAL=1 TO NSVAL
            BENCH.ACC.AMT=ACC.BENCH<1,1,SVAL>      ; * JMK18
            CONTR.ACC.AMT=ACC.CONTR<1,1,SVAL>      ; * JMK18
            ACC.SAVINGS = BENCH.ACC.AMT-CONTR.ACC.AMT        ; * JMK18
            ACC.LOG.COMM = (ACC.SAVINGS*COMM.PERC/100)'R0'   ; * JMK18
            IF CLIENT.ID='01510' THEN    ; * JMK50
               ACC.LOG.COMM = 0          ; * JMK50
            END                          ; * JMK50
            IF CLIENT.ID='02171' THEN
               ACC.LOG.COMM = 0
            END
            IF CLIENT.ID='01769' THEN    ; * JMK67
               ACC.LOG.COMM = 0          ; * JMK67
            END                          ; * JMK67
            IF CLIENT.ID='01909' THEN    ; * JMK53
               ACC.LOG.COMM = 0          ; * JMK53
            END                          ; * JMK53
            IF CLIENT.ID='02215' THEN
               ACC.LOG.COMM = 0
            END
*DF            IF CLIENT.ID='02465' THEN    ; * JMK69    ; * DRF17
*DF               ACC.LOG.COMM = 0          ; * JMK69    ; * DRF17
*DF            END                          ; * JMK69    ; * DRF17
            IF CLIENT.ID='02480' THEN    ; * JMK72
               ACC.LOG.COMM = 0          ; * JMK72
            END                          ; * JMK72
            IF CLIENT.ID='05022' THEN    ; * DRF02
               ACC.LOG.COMM = 0          ; * DRF02
            END                          ; * DRF02
            IF CLIENT.ID='05096' THEN    ; * JMK74
               ACC.LOG.COMM = 0          ; * JMK74
            END                          ; * JMK74
            IF CLIENT.ID='05124' THEN    ; * DRF03
               ACC.LOG.COMM = 0          ; * DRF03
            END                          ; * DRF03
            IF CLIENT.ID='05125' THEN    ; * JMK75
               ACC.LOG.COMM = 0          ; * JMK75
            END                          ; * JMK75
            IF CLIENT.ID='05178' THEN    ; * JMK78
               ACC.LOG.COMM = 0          ; * JMK78
            END                          ; * JMK78
            IF CLIENT.ID='05238' THEN    ; * JMK77
               ACC.LOG.COMM = 0          ; * JMK77
            END                          ; * JMK77
            IF CLIENT.ID='05294' THEN    ; * DRF04
               ACC.LOG.COMM = 0          ; * DRF04
            END                          ; * DRF04
            IF CLIENT.ID='02374' THEN    ; * DRF06
               ACC.LOG.COMM = 0          ; * DRF06
            END                          ; * DRF06
            IF CLIENT.ID='02481' THEN    ; * DRF09
               ACC.LOG.COMM = 0          ; * DRF09
            END                          ; * DRF09
            IF CLIENT.ID='01933' THEN    ; * DRF11
               ACC.LOG.COMM = 0          ; * DRF11
            END                          ; * DRF11
            IF CLIENT.ID='01801' THEN    ; * DRF12
               ACC.LOG.COMM = 0          ; * DRF12
            END                          ; * DRF12
            IF CLIENT.ID='05608' THEN    ; * DRF13
               ACC.LOG.COMM = 0          ; * DRF13
            END                          ; * DRF13
            IF CLIENT.ID='05765' THEN    ; * DRF16
               ACC.LOG.COMM = 0          ; * DRF16
            END                          ; * DRF16
            IF CLIENT.ID='05806' THEN    ; * DRF18
               ACC.LOG.COMM = 0          ; * DRF18
            END                          ; * DRF18
            ACC.CLIENT.COST = CONTR.ACC.AMT + ACC.LOG.COMM   ; * JMK18
            ACC.CL.SAVINGS = ACC.SAVINGS - ACC.LOG.COMM      ; * JMK18
            ACC.SAVINGS.QUOTE.AMT = ACC.CL.SAVINGS*(1-QUOTE.PERC/10000)          ; * JMK18
            ACC.QUOTE<1,1,SVAL>=OCONV(CONTR.ACC.AMT + ACC.LOG.COMM + ACC.SAVINGS.QUOTE.AMT,'MR0')    ; * JMK18
         NEXT SVAL                       ; * JMK18
      END ELSE
         QUOTE.AMT=CONTR.AMT
         CLIENT.COST=CONTR.AMT
         FSC.QUOTE.AMT=CONTR.FSC.AMT     ; * JMK18
         FSC.CLIENT.COST=CONTR.FSC.AMT   ; * JMK18
         ACC.QUOTE=ACC.CONTR             ; * JMK18
         ACC.CLIENT.COST=ACC.CONTR       ; * JMK18
      END

      *****************************************************

      LOC.TEST = GB1<1,1>
      CONVERT @SVM TO @VM IN LOC.TEST
      GB2 = GB1<1,8>
      GB3 = GB1<1,14>
      NEW.LOG.COMM = 0
      TOT.BENCH.AMT = GB3<1,1,2>
      TOT.CONTR.AMT = GB2<1,1,3>
      LOCATE("FSC",LOC.TEST,1;FSCPOS) ELSE FSCPOS = 0
      BENCH.FSC.AMT = GB3<1,1,FSCPOS>
      CONTR.FSC.AMT = GB2<1,1,FSCPOS>
      TOT.BENCH.MISC.CHG = ''
      TOT.CONTR.MISC.CHG = ''

      LOCATE("ABMIN",LOC.TEST,1;PPOS) ELSE PPOS = 0
      LOCATE("TMIN",LOC.TEST,1;MINPOS) ELSE MINPOS = 0
      LOCATE("FLAT",LOC.TEST,1;FLATPOS) ELSE FLATPOS = 0
      LOCATE("OMIN",LOC.TEST,1;ADJPOS) ELSE ADJPOS = 0

      ******************** C O N T R A C T  ************************

      A1 = GB2<1,1,1> ;                  ; * contract amount (what if more than 1 line ?)
      A2 = GB2<1,1,1> ;                  ; * bill total contract
      A3 = ''
      BEGIN CASE
         CASE ADJPOS GT 0
            A2 = GB2<1,1,ADJPOS>
            A3 = GB2<1,1,ADJPOS>
         CASE MINPOS GT 0
            A2 = GB2<1,1,MINPOS>
            A3 = GB2<1,1,3>
         CASE PPOS GT 0
            A2 = GB2<1,1,1>
            A3 = GB2<1,1,2>
         CASE FLATPOS GT 0
            A2 = GB2<1,1,2>
            A3 = GB2<1,1,2>
      END CASE
      **************************************

      TOT.CONTR.AMT = A3
      IF A3 # "" THEN
         TOT.CONTR.AMT = A3
      END ELSE
         TOT.CONTR.AMT = A2
      END
      ****************** B E N C H M A R K  *************************
      A4 = GB3<1,1,1>                    ; * bench mark amount (what if more than 1 line ?)
      A5 = GB3<1,1,1>
      A6 =''
      BEGIN CASE
         CASE ADJPOS GT 0
            A5 = GB3<1,1,2>
            A6 = GB3<1,1,ADJPOS>         ; * benchmark minimum
         CASE MINPOS GT 0
            A5 = GB3<1,1,MINPOS>
            A6 = GB3<1,1,3>              ; * contract minimum
         CASE PPOS GT 0
            A5 = GB3<1,1,1>
            A6 = GB3<1,1,PPOS>           ; * contract minimum
         CASE FLATPOS GT 0
            A5 = GB3<1,1,2>
            A6 = GB3<1,1,2>
      END CASE
      TOT.BENCH.AMT = A5
      IF A6 # "" THEN
         TOT.BENCH.AMT = A6
      END ELSE
         TOT.BENCH.AMT = A5
      END

**********************************************************************
      MATPARSE CLIENT.REC FROM DCLIENTS
      VIN=''
      VOUT =''
      VIN<1> = TOT.BENCH.AMT
      VIN<2> = TOT.CONTR.AMT
      VIN<3> = BENCH.FSC.AMT
      VIN<4> = CONTR.FSC.AMT
      VIN<5> = TOT.BENCH.MISC.CHG
      VIN<6> = TOT.CONTR.MISC.CHG
      VIN<7> = USER
   **   DEBUG
         CALL CALC.LTL.MARKUP.MIN(VIN,MAT CLIENT.REC,VOUT)
      NEW.LOG.COMM = VOUT<1> * 100
      VIN=''
      VOUT=''
      VIN<1> = CLIENT.ID
      VIN<2> = CARRIER.ID
      VIN<3> = SHIP.DATE
      VIN<4> = IOT
      VIN<5> = ORIG.ZIP
      VIN<6> = DEST.ZIP
      VIN<7> = DCLIENTS
      **    CALL MISROUTE(VIN,VOUT,F.TABLES,F.CARRIERS,F.CLIENTS,F.NFSC,F.NFSC.SUB,CCVOUT)
      IF VOUT<1> = 1 THEN
         MISROUTE = VOUT<1>
         NEW.LOG.COMM = 0
      END
*********************************************************************
* Special deal for BFG Quincy Compressor
*********************************************************************
*
      OB.QUOTE.INCR.PERC = (DCLIENTS<227>/100)     ; *NPR01
      IB.QUOTE.INCR.PERC = (DCLIENTS<228>/100)     ; *NPR01
      TP.QUOTE.INCR.PERC = (DCLIENTS<229>/100)     ; *NPR01
      VENDOR.QUOTE.LIMIT.PERC=(DCLIENTS<262>)      ; * DFP01
      VENDOR.QUOTE.LIMIT.PERC+=0
      NUMBER.LIMIT=DCLIENTS<263>         ; * DFP01
      NUMBER.LIMIT+=0
*
      QUOTE.AMT = QUOTE.AMT + NEW.LOG.COMM
      BEGIN CASE
         CASE IOT='O' AND OB.QUOTE.INCR.PERC NE "0"          ; *NPR01
            OB.QUOTE.INCR.AMT = QUOTE.AMT * (OB.QUOTE.INCR.PERC/100)   ; *NPR01
****DEBUG
            QUOTE.AMT=(QUOTE.AMT + OB.QUOTE.INCR.AMT)'R0'    ; *NPR01
            OB.FSC.QUOTE.INCR.AMT = FSC.QUOTE.AMT * (OB.QUOTE.INCR.PERC/100)     ; *NPR01
            FSC.QUOTE.AMT=(FSC.QUOTE.AMT + OB.FSC.QUOTE.INCR.AMT)'R0'  ; *NPR01
            NVAL=DCOUNT(ACC.CODES,@VM)   ; *NPR01    @SVM
          
            FOR VAL=1 TO NVAL            ; *NPR01
            	  INCR.AMT = 0
               GBVAL=DCOUNT(ACC.CODES<VAL>,@SVM)
               FOR SVAL = 1 TO GBVAL
                  INCR.AMT = INCR.AMT + ACC.QUOTE<1,VAL,SVAL> * (OB.QUOTE.INCR.PERC/100)   ; *NPR01

                  IF INCR.AMT NE "0" THEN          ; *NPR01
                     ACC.QUOTE<1,VAL,SVAL> = ACC.QUOTE<1,VAL,SVAL> + INCR.AMT    ; *NPR01
                  END                    ; *NPR01
               NEXT SVAL
            NEXT VAL                     ; *NPR01
         CASE IOT='I' AND IB.QUOTE.INCR.PERC NE "0"          ; *NPR01
            IB.QUOTE.INCR.AMT = QUOTE.AMT * (IB.QUOTE.INCR.PERC/100)   ; *NPR01
            QUOTE.AMT=(QUOTE.AMT + IB.QUOTE.INCR.AMT)'R0'    ; *NPR01
****DEBUG
            IB.FSC.QUOTE.INCR.AMT = FSC.QUOTE.AMT * (IB.QUOTE.INCR.PERC/100)     ; *NPR01
            FSC.QUOTE.AMT=(FSC.QUOTE.AMT + IB.FSC.QUOTE.INCR.AMT)'R0'  ; *NPR01
            NVAL=DCOUNT(ACC.CODES,@VM)   ; *NPR01  @SVM
           
            FOR VAL=1 TO NVAL            ; *NPR01
            	 INCR.AMT=0
               GBVAL=DCOUNT(ACC.CODES<VAL>,@SVM)
               FOR SVAL = 1 TO GBVAL
                  **     INCR.AMT = ACC.QUOTE<1,VAL> * (IB.QUOTE.INCR.PERC/100)  ; *NPR01
                  INCR.AMT = INCR.AMT + ACC.QUOTE<1,VAL,SVAL> * (IB.QUOTE.INCR.PERC/100)

                  IF INCR.AMT NE "0" THEN          ; *NPR01
                     ACC.QUOTE<1,VAL,SVAL> = ACC.QUOTE<1,VAL,SVAL> + INCR.AMT    ; *NPR01
                  END                    ; *NPR01
               NEXT SVAL
            NEXT VAL                     ; *NPR01
         CASE IOT='T' AND TP.QUOTE.INCR.PERC NE "0"          ; *NPR01
            TP.QUOTE.INCR.AMT = QUOTE.AMT * (TP.QUOTE.INCR.PERC/100)   ; *NPR01
            QUOTE.AMT=(QUOTE.AMT + TP.QUOTE.INCR.AMT)'R0'    ; *NPR01
            TP.FSC.QUOTE.INCR.AMT = FSC.QUOTE.AMT * (TP.QUOTE.INCR.PERC/100)     ; *NPR01
            FSC.QUOTE.AMT=(FSC.QUOTE.AMT + TP.FSC.QUOTE.INCR.AMT)'R0'  ; *NPR01
            NVAL=DCOUNT(ACC.CODES,@VM)   ; *NPR01  @SVM
           
            FOR VAL=1 TO NVAL            ; *NPR01
             INCR.AMT = 0	
               GBVAL=DCOUNT(ACC.CODES<VAL>,@SVM)
               FOR SVAL = 1 TO GBVAL
                  ***      INCR.AMT = ACC.QUOTE<1,VAL> * (TP.QUOTE.INCR.PERC/100)  ; *NPR01
                  INCR.AMT = INCR.AMT + ACC.QUOTE<1,VAL,SVAL> * (TP.QUOTE.INCR.PERC/100)
                  IF INCR.AMT NE "0" THEN          ; *NPR01
                     ACC.QUOTE<1,VAL,SVAL> = ACC.QUOTE<1,VAL,SVAL> + INCR.AMT    ; *NPR01
                  END                    ; *NPR01
               NEXT SVAL
            NEXT VAL                     ; *NPR01
      END CASE

      IF CANADIAN THEN
         IF ORG.CAN=0 OR DST.CAN=0 THEN  ; * JMK51
            QUOTE.AMT=QUOTE.AMT+3000     ; * 10-21-04 Add $30.00 to each Canadian Quote to cover the homeland security fee
         END                             ; * JMK51
      END

      IF FLAT.FEE THEN                   ; * SWB02
         QUOTE.AMT=QUOTE.AMT+(MARK.UP.FACTOR)      ; * SWB02
      END ELSE                           ; * SWB02
****DEBUG
         IF MARK.UP.FACTOR+0 #0 THEN     ; * SWB02
            QUOTE.AMT=(QUOTE.AMT*(100+MARK.UP.FACTOR)/100)'R0'         ; * SWB02
            FSC.QUOTE.AMT=(FSC.QUOTE.AMT*(100+MARK.UP.FACTOR)/100)'R0'           ; * JMK18   ; * SWB02
            NSVAL=DCOUNT(ACC.CODES<1>,@SVM)        ; * JMK18
            FOR SVAL=1 TO NSVAL          ; * JMK18
               ACC.QUOTE<1,1,SVAL>=(ACC.QUOTE<1,1,SVAL>*(100+MARK.UP.FACTOR)/100)'R0'      ; * JMK18    ; * SWB02
            NEXT SVAL                    ; * JMK18
         END
      END

      IF COMBINE.RATE THEN               ; * JMK37
         LOCATE CHECK.CARRIER.ID IN CARRIER.EST.ARRAY<2> SETTING CPOS THEN       ; * JMK37
            IF CARRIER.EST.ARRAY<1,CPOS> > QUOTE.AMT THEN    ; * JMK37
               NATT=DCOUNT(CARRIER.EST.ARRAY,@AM)  ; * JMK37
               FOR ATT=1 TO NATT         ; * JMK37
                  DEL CARRIER.EST.ARRAY<ATT,CPOS>  ; * JMK37
               NEXT ATT                  ; * JMK37
            END ELSE                     ; * JMK37
               GO GET.NEXT.CARRIER:      ; * JMK37
            END                          ; * JMK37
         END                             ; * JMK37
      END                                ; * JMK37

      CLIENT.COST.HOLD = CLIENT.COST     ; * NPR04
      S.CLIENT.COST = CLIENT.COST
      IF TRANSIT.TIME='' THEN            ; * JMK64
         SORT.STR = CLIENT.COST "R%10" : CONTR.AMT "R%10":'999'        ; * NPR09 ; * JMK64
      END ELSE                           ; * JMK64
         SORT.STR = CLIENT.COST "R%10" : CONTR.AMT "R%10":TRANSIT.TIME'R%3'      ; * NPR09 ; * JMK64
      END                                ; * JMK64

      IF CLIENT.ID = "01457" THEN
         IF DATE() LT ICONV("07/03/10","D2/") THEN AG.CARRIER.ID = "99982" ELSE AG.CARRIER.ID = "99981"        ; * NPR05
         IF CHECK.CARRIER.ID = AG.CARRIER.ID THEN
            S.CLIENT.COST = "-1"
         END
      END

      LOCATE SORT.STR IN SORT.MISROUTE.ARRAY<1> BY 'AR' SETTING POS ELSE NULL    ; * NPR09
      INS SORT.STR BEFORE SORT.MISROUTE.ARRAY<1,POS>
      INS QUOTE.AMT BEFORE CARRIER.EST.ARRAY<1,POS>
      INS CHECK.CARRIER.ID BEFORE CARRIER.EST.ARRAY<2,POS>
      INS CARRIER.NAME BEFORE CARRIER.EST.ARRAY<3,POS>
      INS ERROR BEFORE CARRIER.EST.ARRAY<4,POS>
      INS CARRIER.SCAC BEFORE CARRIER.EST.ARRAY<5,POS>
      INS ZIP.MESSAGE BEFORE CARRIER.EST.ARRAY<6,POS>
      INS CLIENT.COST BEFORE CARRIER.EST.ARRAY<9,POS>
      INS S.CLIENT.COST BEFORE CARRIER.COST.ARRAY<9,POS>     ; * NPR04
      INS CONTR.AMT BEFORE CARRIER.EST.ARRAY<10,POS>
      IF LOGISTICS THEN
         INS BENCH.AMT BEFORE CARRIER.EST.ARRAY<11,POS>
         INS LOG.COMM BEFORE CARRIER.EST.ARRAY<12,POS>
      END
      INS TRANSIT.TIME BEFORE CARRIER.EST.ARRAY<13,POS>      ; * JMK09
      INS ORIG.DIRECT.FLAG BEFORE CARRIER.EST.ARRAY<14,POS>  ; * JMK09
      INS DEST.DIRECT.FLAG BEFORE CARRIER.EST.ARRAY<15,POS>  ; * JMK09
      INS COMB.DIRECT.FLAG BEFORE CARRIER.EST.ARRAY<16,POS>  ; * JMK09
      INS ORIG.TERM.NAME BEFORE CARRIER.EST.ARRAY<17,POS>    ; * JMK11
      INS ORIG.TERM.CODE BEFORE CARRIER.EST.ARRAY<18,POS>    ; * JMK11
      INS ORIG.TERM.ADR1 BEFORE CARRIER.EST.ARRAY<19,POS>    ; * JMK11
      INS ORIG.TERM.ADR2 BEFORE CARRIER.EST.ARRAY<20,POS>    ; * JMK11
      INS ORIG.TERM.CITY BEFORE CARRIER.EST.ARRAY<21,POS>    ; * JMK11
      INS ORIG.TERM.ST BEFORE CARRIER.EST.ARRAY<22,POS>      ; * JMK11
      INS ORIG.TERM.ZIP BEFORE CARRIER.EST.ARRAY<23,POS>     ; * JMK11
      INS ORIG.TERM.PHONE BEFORE CARRIER.EST.ARRAY<24,POS>   ; * JMK11
      INS ORIG.TERM.TPHONE BEFORE CARRIER.EST.ARRAY<25,POS>  ; * JMK11
      INS ORIG.TERM.FAX BEFORE CARRIER.EST.ARRAY<26,POS>     ; * JMK11
      INS ORIG.TERM.EMAIL BEFORE CARRIER.EST.ARRAY<27,POS>   ; * JMK11
      INS ORIG.TERM.CNAME BEFORE CARRIER.EST.ARRAY<28,POS>   ; * JMK11
      INS ORIG.TERM.CTITLE BEFORE CARRIER.EST.ARRAY<29,POS>  ; * JMK11
      INS DEST.TERM.NAME BEFORE CARRIER.EST.ARRAY<30,POS>    ; * JMK11
      INS DEST.TERM.CODE BEFORE CARRIER.EST.ARRAY<31,POS>    ; * JMK11
      INS DEST.TERM.ADR1 BEFORE CARRIER.EST.ARRAY<32,POS>    ; * JMK11
      INS DEST.TERM.ADR2 BEFORE CARRIER.EST.ARRAY<33,POS>    ; * JMK11
      INS DEST.TERM.CITY BEFORE CARRIER.EST.ARRAY<34,POS>    ; * JMK11
      INS DEST.TERM.ST BEFORE CARRIER.EST.ARRAY<35,POS>      ; * JMK11
      INS DEST.TERM.ZIP BEFORE CARRIER.EST.ARRAY<36,POS>     ; * JMK11
      INS DEST.TERM.PHONE BEFORE CARRIER.EST.ARRAY<37,POS>   ; * JMK11
      INS DEST.TERM.TPHONE BEFORE CARRIER.EST.ARRAY<38,POS>  ; * JMK11
      INS DEST.TERM.FAX BEFORE CARRIER.EST.ARRAY<39,POS>     ; * JMK11
      INS DEST.TERM.EMAIL BEFORE CARRIER.EST.ARRAY<40,POS>   ; * JMK11
      INS DEST.TERM.CNAME BEFORE CARRIER.EST.ARRAY<41,POS>   ; * JMK11
      INS DEST.TERM.CTITLE BEFORE CARRIER.EST.ARRAY<42,POS>  ; * JMK11
      INS FSC.QUOTE.AMT BEFORE CARRIER.EST.ARRAY<43,POS>     ; * JMK18
      INS ACC.CODES BEFORE CARRIER.EST.ARRAY<44,POS>         ; * JMK18
      INS ACC.QUOTE BEFORE CARRIER.EST.ARRAY<45,POS>         ; * JMK18
      INS CARR.DATA.DATE BEFORE CARRIER.EST.ARRAY<46,POS>    ; * JMK21
      INFOMESSAGE=''                     ; * JMK30
      IF USER.NAME='WARDKRAFT' OR USER.NAME = "WK" OR USER.NAME = "WKRAFT" OR USER.NAME = "WKWEB" THEN         ; * JMK30
         INFOMESSAGE='B. A. S. E. ':'|':CLIENT.COST          ; * JMK30
         INFOMESSAGE:='|':'B. A. S. E. +15% ':'|':CLIENT.COST*1.15'R0'           ; * JMK46
      END                                ; * JMK30
      IF SHIP.DATE>DATE() THEN           ; * JMK35
         INFOMESSAGE='NOTE :This future quote uses fuel costs based on ':DATE()'D2/':'.'   ; * JMK35
      END                                ; * JMK35
      IF AUDIT.CLIENT.ID='01282' THEN    ; * JMK56
         INFOMESSAGE='US$'               ; * JMK56
      END                                ; * JMK56
      IF AUDIT.CLIENT.ID='01832' THEN    ; * JMK56
         INFOMESSAGE='CAN$'              ; * JMK56
      END                                ; * JMK56
      IF AUDIT.CLIENT.ID='01866' THEN    ; * JMK56
         INFOMESSAGE='CAN$'              ; * JMK56
      END                                ; * JMK56
      IF AUDIT.CLIENT.ID='01870' THEN    ; * JMK56
         INFOMESSAGE='US$'               ; * JMK56
      END                                ; * JMK56
      INS INFOMESSAGE BEFORE CARRIER.EST.ARRAY<47,POS>       ; * JMK30
      INS CLIENT.ID BEFORE CARRIER.EST.ARRAY<48,POS>         ; * JMK38
      INS CONTR.BILL.TYPE BEFORE CARRIER.EST.ARRAY<49,POS>   ; * JMK58
      INS BENCH.BILL.TYPE BEFORE CARRIER.EST.ARRAY<50,POS>   ; * JMK58
      ERROR=''                           ; * JMK28
      GO GET.NEXT.CARRIER
********************************************************************
GET.CARRIER.INFO:***
********************************************************************
      READ CARRIER.REC FROM F.CARRIERS,CHECK.CARRIER.ID ELSE
         ERROR = "Carrier ":CHECK.CARRIER.ID:" not on file."
         RETURN
      END
      CARRIER.NAME = CARRIER.REC<1>
      CARRIER.STREET = TRIM(CHANGE(CARRIER.REC<2>,@VM,' '))
      CARRIER.CITY = CARRIER.REC<3>
      CARRIER.STATE = CARRIER.REC<4>
      CARRIER.SCAC = CARRIER.REC<12>     ; *Added By ROB GAUDET 9/23/2003
      CARRIER.STATUS = CARRIER.REC<89>   ; * JMK14
      IF CARRIER.STATUS = "I" THEN       ; * JMK14
         ERROR = "CARRIER IS NOT ACTIVE - CARRIER# ":CHECK.CARRIER.ID  ; * JMK14
         RETURN                          ; * JMK14
      END                                ; * JMK14
      CARRIER.TYPE = 'A'                 ; * JMK09
      IF CARRIER.REC<44>='6' THEN        ; * JMK09
         CARRIER.TYPE='B'                ; * JMK09
      END                                ; * JMK09
      READ D.AUDIT FROM F.AUDIT, CHECK.CARRIER.ID ELSE
         ERROR = "CARRIER NOT SETUP FOR AUTO AUDIT - CARRIER#":CHECK.CARRIER.ID
         RETURN
      END
      IF D.AUDIT<11>#'ENABLE' THEN
         ERROR='Not Considered in On-Line Audit - Carrier Disabled'
         RETURN
      END

      BENCH.DFSC.ID='B*':CHECK.CARRIER.ID:'*':AUDIT.CLIENT.ID
      READ BENCH.DFSC FROM F.NFSC,'B*':CHECK.CARRIER.ID:'*':AUDIT.CLIENT.ID ELSE
         BENCH.DFSC.ID='B*':CHECK.CARRIER.ID
         READ BENCH.DFSC FROM F.NFSC,'B*':CHECK.CARRIER.ID ELSE BENCH.DFSC=''
      END
      IF BENCH.DFSC<30>='DISABLE' THEN
         BENCH.DFSC=''                   ; ** No Effect
         CONTR.DFSC=''
      END ELSE
         CONTR.DFSC.ID='C*':CHECK.CARRIER.ID:'*':AUDIT.CLIENT.ID
         READ CONTR.DFSC FROM F.NFSC,"C*":CHECK.CARRIER.ID:"*":AUDIT.CLIENT.ID ELSE CONTR.DFSC=BENCH.DFSC
         IF CONTR.DFSC<30>='DISABLE' THEN CONTR.DFSC=''
      END

      IF CARRIER.SCAC='' AND CHECK.CARRIER.ID[1,2]#'99' THEN           ; * JMK12
         BEGIN CASE                      ; * JMK14
            CASE CHECK.CARRIER.ID[1,2]='99'        ; * JMK14
            CASE CHECK.CARRIER.ID='00223'          ; * JMK15
            CASE CHECK.CARRIER.ID='00677'          ; * JMK15
            CASE CHECK.CARRIER.ID='02441'          ; * JMK15
            CASE CHECK.CARRIER.ID='03444'          ; * JMK16
            CASE CHECK.CARRIER.ID='14500'          ; * JMK14
            CASE CHECK.CARRIER.ID='15523'          ; * JMK15
            CASE CHECK.CARRIER.ID='16818'          ; * BOH02
            CASE CHECK.CARRIER.ID='21252'          ; * JMK41
            CASE CHECK.CARRIER.ID = '03595'
            CASE 1                       ; * JMK14
               SUBJ='Carrier ':CHECK.CARRIER.ID:' - ':CARRIER.NAME:' does not have a SCAC code'      ; * JMK12

               TEXT='Web quote request was made from a carrier with no SCAC code.  '       ; * JMK13
               TEXT:='This missing data will prevent Carrier Connect from returning service information.  '    ; * JMK13
               TEXT:='See details below:'          ; * JMK13
               TEXT<1,-1>=' '            ; * JMK13
               TEXT<1,-1>='Request Time':TAB:DATE()'D2/':' ':OCONV(TIME(),'MTHS')          ; * JMK13
               TEXT<1,-1>='Origin Zip':TAB:TAB:ORIG.ZIP      ; * JMK13
               TEXT<1,-1>='Destination Zip':TAB:DEST.ZIP     ; * JMK13
               TEXT<1,-1>='Carrier':TAB:TAB:CARRIER.NAME:' (':CHECK.CARRIER.ID:')'         ; * JMK13
               TEXT<1,-1>='Client ':TAB:TAB:DCLIENTS<2>:' (':CLIENT.ID:')'       ; * JMK14
               MVIN=''                   ; * JMK12
               MVIN<1,-1>='ITDepartment@afs.net'   ; * JMK12
               MVIN<4>='INET.FB.ESTIMATOR'         ; * JMK12
               MVIN<5>=SUBJ              ; * JMK12
               MVIN<6>=TEXT              ; * JMK12
               CALL SENDMAIL(MVIN,MVOUT)           ; * JMK12
         END CASE                        ; * JMK14
      END                                ; * JMK12
      RETURN

* Begin NKH02
********************************************************************
POPULATE.CC.INFO:
********************************************************************
      SCAC.COUNT = DCOUNT(CCVOUT<1>,@VM)
      FOR SC = 1 TO SCAC.COUNT
         LOCATE(CARRIER.SCAC,CCVOUT,1,SC;S.POS;'AL') THEN
            * From TransitMethod
            TRANSIT.TIME = CCVOUT<29,SC>
            IF TRANSIT.TIME = 0 THEN TRANSIT.TIME = 1
            RELEASE.DATE = CCVOUT<19,SC>
            YY = RELEASE.DATE[1,4]
            MM = RELEASE.DATE[6,2]
            DD = RELEASE.DATE[9,2]
            CARR.DATA.DATE = MM:'-':DD:'-':YY
            ORIG.DIR.FLG = CCVOUT<31,SC>[1,1]
            IF ORIG.DIR.FLG = 'C' OR ORIG.DIR.FLG = 'P' THEN ORIG.DIR.FLG = 'I'  ; * NKH01
            DEST.DIR.FLG = CCVOUT<30,SC>[1,1]
            IF DEST.DIR.FLG = 'C' OR DEST.DIR.FLG = 'P' THEN DEST.DIR.FLG = 'I'  ; * NKH01
            COMB.DIR.FLG = CCVOUT<32,SC>[1,1]
            IF COMB.DIR.FLG = 'C' OR COMB.DIR.FLG = 'P' THEN COMB.DIR.FLG = 'I'  ; * NKH01
            *From TerminalsByPostalCode
            ORIG.TERM.NAME = CCVOUT<27,SC,2>
            ORIG.TERM.CODE = CCVOUT<26,SC,2>
            ORIG.TERM.ADR1 = CCVOUT<6,SC,2>
            ORIG.TERM.ADR2 = CCVOUT<7,SC,2>
            ORIG.TERM.CITY = CCVOUT<9,SC,2>
            ORIG.TERM.ST = CCVOUT<25,SC,2>
            ORIG.TERM.ZIP = CCVOUT<21,SC,2>
            ORIG.TERM.PHONE = CCVOUT<13,SC,2>
            ORIG.TERM.TPHONE = CCVOUT<15,SC,2>
            ORIG.TERM.FAX = CCVOUT<11,SC,2>
            ORIG.TERM.EMAIL = CCVOUT<10,SC,2>
            ORIG.TERM.CNAME = CCVOUT<12,SC,2>
            ORIG.TERM.CTITLE = CCVOUT<14,SC,2>
            DEST.TERM.NAME = CCVOUT<27,SC,1>
            DEST.TERM.CODE = CCVOUT<26,SC,1>
            DEST.TERM.ADR1 = CCVOUT<6,SC,1>
            DEST.TERM.ADR2 = CCVOUT<7,SC,1>
            DEST.TERM.CITY = CCVOUT<9,SC,1>
            DEST.TERM.ST = CCVOUT<25,SC,1>
            DEST.TERM.ZIP = CCVOUT<21,SC,1>
            DEST.TERM.PHONE = CCVOUT<13,SC,1>
            DEST.TERM.TPHONE = CCVOUT<15,SC,1>
            DEST.TERM.FAX = CCVOUT<11,SC,1>
            DEST.TERM.EMAIL = CCVOUT<10,SC,1>
            DEST.TERM.CNAME = CCVOUT<12,SC,1>
            DEST.TERM.CTITLE = CCVOUT<14,SC,1>
         END
      NEXT SC
*
      RETURN

* End NKH02
*********************************************************************
9000:****
*********************************************************************
      IF COMBINE.RATE THEN               ; * JMK37
         BEGIN CASE                      ; * JMK38
            CASE EBS.CLIENT=1            ; * JMK38
               CLIENT.ID=EBS.CLIENTS<1,1>          ; * JMK38
            CASE AG.CLIENT=1             ; * JMK38
               CLIENT.ID=AG.CLIENTS<1,1>           ; * JMK38
         END CASE                        ; * JMK38
         IF CLIENT.ID#'' THEN            ; * JMK37
            GO CLIENT.START.POINT        ; * JMK37
         END                             ; * JMK37
         CLIENT.ID=HOLD.CLIENT.ID        ; * JMK37
      END                                ; * JMK37

      METADATA = ""
      METADATA<1,1> = "VARCHAR" ; METADATA<1,2> = "Errors" ; METADATA<1,3> = 0
      METADATA<2,1> = "VARCHAR" ; METADATA<2,2> = "QuoteAmt" ; METADATA<2,3> = 0
      METADATA<3,1> = "VARCHAR" ; METADATA<3,2> = "CarrierID" ; METADATA<3,3> = 0
      METADATA<4,1> = "VARCHAR" ; METADATA<4,2> = "CarrierSCAC" ; METADATA<4,3> = 0
      METADATA<5,1> = "VARCHAR" ; METADATA<5,2> = "CarrierName" ; METADATA<5,3> = 0
      METADATA<6,1> = "VARCHAR" ; METADATA<6,2> = "OCity" ; METADATA<6,3> = 0
      METADATA<7,1> = "VARCHAR" ; METADATA<7,2> = "OState" ; METADATA<7,3> = 0
      METADATA<8,1> = "VARCHAR" ; METADATA<8,2> = "DCity" ; METADATA<8,3> = 0
      METADATA<9,1> = "VARCHAR" ; METADATA<9,2> = "DState" ; METADATA<9,3> = 0
      METADATA<10,1> = "VARCHAR" ; METADATA<10,2> = "Messages" ; METADATA<10,3> = 0
      METADATA<11,1> = "VARCHAR" ; METADATA<11,2> = "ZipMessage" ; METADATA<11,3> = 0
      METADATA<12,1> = "VARCHAR" ; METADATA<12,2> = "TransitTime" ; METADATA<12,3> = 0     ; * JMK09
      METADATA<13,1> = "VARCHAR" ; METADATA<13,2> = "OrigDirect" ; METADATA<13,3> = 0      ; * JMK09
      METADATA<14,1> = "VARCHAR" ; METADATA<14,2> = "DestDirect" ; METADATA<14,3> = 0      ; * JMK09
      METADATA<15,1> = "VARCHAR" ; METADATA<15,2> = "CombDirect" ; METADATA<15,3> = 0      ; * JMK09
      METADATA<16,1> = "VARCHAR" ; METADATA<16,2> = "OrigTerminalName" ; METADATA<16,3> = 0          ; * JMK11
      METADATA<17,1> = "VARCHAR" ; METADATA<17,2> = "OrigTerminalCode" ; METADATA<17,3> = 0          ; * JMK11
      METADATA<18,1> = "VARCHAR" ; METADATA<18,2> = "OrigTerminalAddress1" ; METADATA<18,3> = 0      ; * JMK11
      METADATA<19,1> = "VARCHAR" ; METADATA<19,2> = "OrigTerminalAddress2" ; METADATA<19,3> = 0      ; * JMK11
      METADATA<20,1> = "VARCHAR" ; METADATA<20,2> = "OrigTerminalCity" ; METADATA<20,3> = 0          ; * JMK11
      METADATA<21,1> = "VARCHAR" ; METADATA<21,2> = "OrigTerminalState" ; METADATA<21,3> = 0         ; * JMK11
      METADATA<22,1> = "VARCHAR" ; METADATA<22,2> = "OrigTerminalZip" ; METADATA<22,3> = 0           ; * JMK11
      METADATA<23,1> = "VARCHAR" ; METADATA<23,2> = "OrigTerminalPhone" ; METADATA<23,3> = 0         ; * JMK11
      METADATA<24,1> = "VARCHAR" ; METADATA<24,2> = "OrigTerminalTollFreePhone" ; METADATA<24,3> = 0           ; * JMK11
      METADATA<25,1> = "VARCHAR" ; METADATA<25,2> = "OrigTerminalFax" ; METADATA<25,3> = 0           ; * JMK11
      METADATA<26,1> = "VARCHAR" ; METADATA<26,2> = "OrigTerminalEmail" ; METADATA<26,3> = 0         ; * JMK11
      METADATA<27,1> = "VARCHAR" ; METADATA<27,2> = "OrigTerminalContactName" ; METADATA<27,3> = 0   ; * JMK11
      METADATA<28,1> = "VARCHAR" ; METADATA<28,2> = "OrigTerminalContactTitle" ; METADATA<28,3> = 0  ; * JMK11
      METADATA<29,1> = "VARCHAR" ; METADATA<29,2> = "DestTerminalName" ; METADATA<29,3> = 0          ; * JMK11
      METADATA<30,1> = "VARCHAR" ; METADATA<30,2> = "DestTerminalCode" ; METADATA<30,3> = 0          ; * JMK11
      METADATA<31,1> = "VARCHAR" ; METADATA<31,2> = "DestTerminalAddress1" ; METADATA<31,3> = 0      ; * JMK11
      METADATA<32,1> = "VARCHAR" ; METADATA<32,2> = "DestTerminalAddress2" ; METADATA<32,3> = 0      ; * JMK11
      METADATA<33,1> = "VARCHAR" ; METADATA<33,2> = "DestTerminalCity" ; METADATA<33,3> = 0          ; * JMK11
      METADATA<34,1> = "VARCHAR" ; METADATA<34,2> = "DestTerminalState" ; METADATA<34,3> = 0         ; * JMK11
      METADATA<35,1> = "VARCHAR" ; METADATA<35,2> = "DestTerminalZip" ; METADATA<35,3> = 0           ; * JMK11
      METADATA<36,1> = "VARCHAR" ; METADATA<36,2> = "DestTerminalPhone" ; METADATA<36,3> = 0         ; * JMK11
      METADATA<37,1> = "VARCHAR" ; METADATA<37,2> = "DestTerminalTollFreePhone" ; METADATA<37,3> = 0           ; * JMK11
      METADATA<38,1> = "VARCHAR" ; METADATA<38,2> = "DestTerminalFax" ; METADATA<38,3> = 0           ; * JMK11
      METADATA<39,1> = "VARCHAR" ; METADATA<39,2> = "DestTerminalEmail" ; METADATA<39,3> = 0         ; * JMK11
      METADATA<40,1> = "VARCHAR" ; METADATA<40,2> = "DestTerminalContactName" ; METADATA<40,3> = 0   ; * JMK11
      METADATA<41,1> = "VARCHAR" ; METADATA<41,2> = "DestTerminalContactTitle" ; METADATA<41,3> = 0  ; * JMK11
      METADATA<42,1> = "VARCHAR" ; METADATA<42,2> = "FscAmt" ; METADATA<42,3> = 0          ; * JMK18
      METADATA<43,1> = "VARCHAR" ; METADATA<43,2> = "AccessCode1" ; METADATA<43,3> = 0     ; * JMK18
      METADATA<44,1> = "VARCHAR" ; METADATA<44,2> = "AccessAmt1" ; METADATA<44,3> = 0      ; * JMK18
      METADATA<45,1> = "VARCHAR" ; METADATA<45,2> = "AccessCode2" ; METADATA<45,3> = 0     ; * JMK18
      METADATA<46,1> = "VARCHAR" ; METADATA<46,2> = "AccessAmt2" ; METADATA<46,3> = 0      ; * JMK18
      METADATA<47,1> = "VARCHAR" ; METADATA<47,2> = "AccessCode3" ; METADATA<47,3> = 0     ; * JMK18
      METADATA<48,1> = "VARCHAR" ; METADATA<48,2> = "AccessAmt3" ; METADATA<48,3> = 0      ; * JMK18
      METADATA<49,1> = "VARCHAR" ; METADATA<49,2> = "AccessCode4" ; METADATA<49,3> = 0     ; * JMK18
      METADATA<50,1> = "VARCHAR" ; METADATA<50,2> = "AccessAmt4" ; METADATA<50,3> = 0      ; * JMK18
      METADATA<51,1> = "VARCHAR" ; METADATA<51,2> = "CarrierDataDate" ; METADATA<51,3> = 0           ; * JMK21
      METADATA<52,1> = "VARCHAR" ; METADATA<52,2> = "TrueCost" ; METADATA<52,3> = 0        ; * JMK25
      METADATA<53,1> = "VARCHAR" ; METADATA<53,2> = "InfoMessage" ; METADATA<53,3> = 0     ; * JMK30

      BEGIN CASE                         ; * JMK67
         CASE USER.TYPE='PROGRAMMER'     ; * JMK67
            CONVERT @AM TO CHAR(13):CHAR(10) IN METADATA     ; * JMK67
         CASE 1                          ; * JMK67
            CONVERT @AM TO CHAR(30) IN METADATA
      END CASE                           ; * JMK67
*      CRT "%METADATA:":METADATA

      NUM.CARRIERS = DCOUNT(CARRIER.EST.ARRAY<1>,@VM)

      IF NUM.CARRIERS = 0 THEN
         BEGIN CASE                      ; * JMK28
            CASE CLIENT.STATUS='I'       ; * JMK62
               MESSAGE='Cannot estimate for this client. Call AFS at 318-798-2111 Ext 8300.'         ; * JMK62
            CASE VALID.ORIG.ZIP=0
               MESSAGE='Origin Zip Code was invalid.'        ; * JMK28
            CASE VALID.DEST.ZIP=0
               MESSAGE='Destination Zip Code was invalid.'   ; * JMK28
            CASE VALID.ORIG.ZIP=2
               MESSAGE="Cannot Estimate LTL Shipments from Hawaii"
            CASE VALID.DEST.ZIP=2
               MESSAGE="Cannot Estimate LTL Shipments to Hawaii"
            CASE VALID.ORIG.ZIP=3
               MESSAGE="Cannot Estimate LTL Shipments from Alaska"
            CASE VALID.DEST.ZIP=3
               MESSAGE="Cannot Estimate LTL Shipments to Alaska"
               MESSAGE='Destination Zip Code was invalid.'   ; * JMK28
            CASE VALID.CL=0
               MESSAGE='No valid freight classification was provided.'           ; * JMK28
            CASE VALID.WT=0
               MESSAGE='No valid freight weight was provided.'         ; * JMK28
            CASE MISC.CHG.CODES#'' AND ACC.ERROR#''          ; * JMK28
               MESSAGE='Please reconfirm selection of additional services or contact Customer Service at 866-533-2111 Ext. 8300.'  ; * SWB01
            CASE TOT.WEIGHT GT MAX.LTL
               BEGIN CASE                ; * JMK79
                  CASE CLIENT.ID='01584'           ; * DRF10
                     MESSAGE = 'You have exceeded the maximum LTL weight (':MAX.LTL:' lbs) and could qualify for truckload pricing. Please remember the Max cubic feet for an LTL shipment is 750. Please contact AFS Truckload at (866)475-2374 Ext. 3'   ; * DRF10
                  CASE CLIENT.ID='02427' AND VENDOR.STATUS   ; * JMK79
                     MESSAGE='You have exceeded the maximum LTL weight (':MAX.LTL:' lbs). Please contact Vicky Fell (608-836-5391) of Danielle Pitcock (608-836-6238)'     ; * JMK79
                  CASE CLIENT.ID='05171'           ; * DRF08
                     MESSAGE = 'You have exceeded the maximum LTL weight (':MAX.LTL:' lbs). Please contact ACME Central Dispatch (dispatch@brick.com)'           ; * DRF08
                  CASE 1                 ; * JMK79
                     MESSAGE='You have exceeded the maximum LTL weight (' : MAX.LTL : ' lbs.) and could qualify for truckload pricing. Please contact AFS Truckload at (866)475-2374 Ext. 3'   ; * NPR07
               END CASE                  ; * JMK79
            CASE 1                       ; * JMK28
               MESSAGE='There are no approved carriers for this shipment.'       ; * JMK28
               LOCATE CLIENT.ID IN AG.CLIENTS<1> SETTING TEST THEN     ; * JMK48
                  MESSAGE:='  Call AFS at (866)475-2374 Ext. 3 for help.'        ; * JMK48
               END                       ; *JMK48
         END CASE                        ; * JMK28

         CARRIER.EST.ARRAY<4,1>=MESSAGE  ; * JMK28
         NUM.CARRIERS = 1                ; * JCW02
      END                                ; * JCW02
      ACT.CNT=1                          ; * JMK07 ; * JMK19

      LCC.AMT = CARRIER.EST.ARRAY<1,1>   ; * JMK36
      IF VENDOR.STATUS THEN              ; * DFP01
         IF VENDOR.QUOTE.LIMIT.PERC # 0 OR NUMBER.LIMIT # 0 THEN       ; * DFP01
            TMP.ARRAY=''                 ; * DFP01
            ACNT=DCOUNT(CARRIER.EST.ARRAY,@AM)     ; * DFP01
            VCNT=DCOUNT(CARRIER.EST.ARRAY<1>,@VM)  ; * DFP01
            TMP.ARRAY=CARRIER.EST.ARRAY  ; * DFP01
            CARRIER.EST.ARRAY=''         ; * DFP01
            TEST.VAR=LCC.AMT+(LCC.AMT*(VENDOR.QUOTE.LIMIT.PERC/10000))           ; * DFP01
            FOR X=1 TO VCNT              ; * DFP01
               IF VENDOR.QUOTE.LIMIT.PERC # 0 THEN           ; * DFP01
                  IF TMP.ARRAY<1,X> > TEST.VAR THEN GOTO 9100          ; * DFP01
               END                       ; * DFP01
               IF NUMBER.LIMIT # 0 THEN  ; * DFP01
                  IF X > NUMBER.LIMIT THEN GOTO 9100         ; * DFP01
               END                       ; * DFP01
               FOR Y=1 TO ACNT           ; * DFP01
                  CARRIER.EST.ARRAY<Y,X> = TMP.ARRAY<Y,X>    ; * DFP01
               NEXT Y                    ; * DFP01
            NEXT X                       ; * DFP01
9100:       * EXIT POINT ; * DFP01
            NUM.CARRIERS = DCOUNT(CARRIER.EST.ARRAY<1>,@VM)  ; * DFP01
         END                             ; * DFP01
      END                                ; * DFP01
      FOR X = 1 TO NUM.CARRIERS
         MESSAGES=TRIM(CARRIER.EST.ARRAY<4,X>:'|':OCONV(CARRIER.EST.ARRAY<1,X>,"MR2"):'|':CARRIER.EST.ARRAY<2,X>:'|':CARRIER.EST.ARRAY<5,X>:'|':CARRIER.EST.ARRAY<3,X>:'|':ORIG.CITY:'|':ORIG.ST:'|':DEST.CITY:'|':DEST.ST)

         QUOTE.AMT = CARRIER.EST.ARRAY<1,X>
         ERRORS = CARRIER.EST.ARRAY<4,X>
         ZIP.MESSAGE = CARRIER.EST.ARRAY<6,X>
         CLIENT.COST = CARRIER.EST.ARRAY<9,X>      ; * JMK25
         TRANSIT.TIME = CARRIER.EST.ARRAY<13,X>    ; * JMK09
         ORIG.DIRECT = CARRIER.EST.ARRAY<14,X>     ; * JMK09
         DEST.DIRECT = CARRIER.EST.ARRAY<15,X>     ; * JMK09
         COMB.DIRECT = CARRIER.EST.ARRAY<16,X>     ; * JMK09
         ORIG.TERM.NAME = CARRIER.EST.ARRAY<17,X>  ; * JMK11
         ORIG.TERM.CODE = CARRIER.EST.ARRAY<18,X>  ; * JMK11
         ORIG.TERM.ADR1 = CARRIER.EST.ARRAY<19,X>  ; * JMK11
         ORIG.TERM.ADR2 = CARRIER.EST.ARRAY<20,X>  ; * JMK11
         ORIG.TERM.CITY = CARRIER.EST.ARRAY<21,X>  ; * JMK11
         ORIG.TERM.ST = CARRIER.EST.ARRAY<22,X>    ; * JMK11
         ORIG.TERM.ZIP = CARRIER.EST.ARRAY<23,X>   ; * JMK11
         ORIG.TERM.PHONE = CARRIER.EST.ARRAY<24,X>           ; * JMK11
         ORIG.TERM.TPHONE = CARRIER.EST.ARRAY<25,X>          ; * JMK11
         ORIG.TERM.FAX = CARRIER.EST.ARRAY<26,X>   ; * JMK11
         ORIG.TERM.EMAIL = CARRIER.EST.ARRAY<27,X>           ; * JMK11
         ORIG.TERM.CNAME = CARRIER.EST.ARRAY<28,X>           ; * JMK11
         ORIG.TERM.CTITLE = CARRIER.EST.ARRAY<29,X>          ; * JMK11
         DEST.TERM.NAME = CARRIER.EST.ARRAY<30,X>  ; * JMK11
         DEST.TERM.CODE = CARRIER.EST.ARRAY<31,X>  ; * JMK11
         DEST.TERM.ADR1 = CARRIER.EST.ARRAY<32,X>  ; * JMK11
         DEST.TERM.ADR2 = CARRIER.EST.ARRAY<33,X>  ; * JMK11
         DEST.TERM.CITY = CARRIER.EST.ARRAY<34,X>  ; * JMK11
         DEST.TERM.ST = CARRIER.EST.ARRAY<35,X>    ; * JMK11
         DEST.TERM.ZIP = CARRIER.EST.ARRAY<36,X>   ; * JMK11
         DEST.TERM.PHONE = CARRIER.EST.ARRAY<37,X>           ; * JMK11
         DEST.TERM.TPHONE = CARRIER.EST.ARRAY<38,X>          ; * JMK11
         DEST.TERM.FAX = CARRIER.EST.ARRAY<39,X>   ; * JMK11
         DEST.TERM.EMAIL = CARRIER.EST.ARRAY<40,X>           ; * JMK11
         DEST.TERM.CNAME = CARRIER.EST.ARRAY<41,X>           ; * JMK11
         DEST.TERM.CTITLE = CARRIER.EST.ARRAY<42,X>          ; * JMK11
         FSC.QUOTE.AMT = CARRIER.EST.ARRAY<43,X>   ; * JMK18
         ACC.CODES = CARRIER.EST.ARRAY<44,X>       ; * JMK18
         ACC.QUOTE = CARRIER.EST.ARRAY<45,X>       ; * JMK18
         CARR.DATA.DATE = CARRIER.EST.ARRAY<46,X>  ; * JMK21
         INFOMESSAGE = CARRIER.EST.ARRAY<47,X>     ; * JMK30
         CCLIENT.ID = CARRIER.EST.ARRAY<48,X>      ; * JMK38
         CONTR.BILL.TYPE=CARRIER.EST.ARRAY<49,X>   ; * JMK58
         BENCH.BILL.TYPE=CARRIER.EST.ARRAY<50,X>   ; * JMK58

         IF USER.NAME='WARDKRAFT' THEN   ; * JMK32
            QUOTE.AMT=CLIENT.COST        ; * JMK43
            IF X=1 THEN                  ; * JMK32
               BEGIN CASE                ; * JMK32
                  CASE QUOTE.AMT>= 75001           ; * JMK32 ; * JMK43
                     QUOTE.INC=1.15      ; * JMK32 ; * JMK42 ; * JMK43
                     QUOTE.INC.PERC=15   ; * JMK32 ; * JMK42 ; * JMK43
                  CASE QUOTE.AMT>= 50001           ; * JMK32 ; * JMK43
                     QUOTE.INC=1.3       ; * JMK32 ; * JMK42
                     QUOTE.INC.PERC=30   ; * JMK32 ; * JMK42
                  CASE QUOTE.AMT>= 30001           ; * JMK42 ; * JMK43
                     QUOTE.INC=1.5       ; * JMK42
                     QUOTE.INC.PERC=50   ; * JMK42
                  CASE 1                 ; * JMK32
                     QUOTE.INC=2.0       ; * JMK32 ; * JMK42
                     QUOTE.INC.PERC=100  ; * JMK32 ; * JMK42
               END CASE                  ; * JMK32
            END                          ; * JMK32
            LOG.COMM = LOG.COMM + NEW.LOG.COMM
            QUOTE.AMT = QUOTE.AMT + LOG.COMM
            QUOTE.INCR.AMT=(QUOTE.AMT*QUOTE.INC.PERC/100)'R0'          ; * JMK32 ; * JMK43
            IF QUOTE.INCR.AMT NE "0" THEN          ; * JMK32
               QUOTE.AMT=(QUOTE.AMT + QUOTE.INCR.AMT)'R0'    ; * JMK32 ; * JMK43
            END                          ; * JMK32
         END                             ; * JMK32

         IF QUOTE.AMT # "" OR ERRORS # "" THEN
            IF VENDOR.STATUS THEN        ; * JMK40
               IF COMBINE.RATE THEN      ; * JMK40
                  IF LCC.AMT+0=0 THEN    ; * JMKXXX
                     INFOMESSAGE='0% (':CCLIENT.ID:')'       ; * JMKXXX
                  END ELSE               ; * JMKXXX
                     INFOMESSAGE=(((QUOTE.AMT-LCC.AMT)*10000/LCC.AMT)'R26'):'% (':CCLIENT.ID:')'     ; * JMK36
                  END                    ; * JMKXXX
               END ELSE                  ; * JMK40
                  IF LCC.AMT+0=0 THEN    ; * JMKXXX
                     INFOMESSAGE='0%'    ; * JMKXXX
                  END ELSE               ; * JMKXXX
                     INFOMESSAGE=(((QUOTE.AMT-LCC.AMT)*10000/LCC.AMT)'R26'):'%'  ; * JMK40
                  END                    ; * JMKXXX
               END                       ; * JMK40
               QUOTE.AMT=0               ; * JMK36
               CLIENT.COST=0             ; * JMK36
               FSC.QUOTE.AMT=0           ; * JMK36
               ACC.QUOTE=0               ; * JMK36
            END                          ; * JMK36

            IF USER.NAME='EVERYDAY1' AND CARRIER.EST.ARRAY<2,X>#'99982' THEN     ; * JMK70
               QUOTE.AMT=0               ; * JMK70
               CLIENT.COST=0             ; * JMK70
               FSC.QUOTE.AMT=0           ; * JMK70
               ACC.QUOTE=0               ; * JMK70
            END                          ; * JMK70
            IF USER.NAME='ROYSTON' AND CARRIER.EST.ARRAY<2,X>#'99982' THEN       ; * JMK70
               QUOTE.AMT=0               ; * JMK70
               CLIENT.COST=0             ; * JMK70
               FSC.QUOTE.AMT=0           ; * JMK70
               ACC.QUOTE=0               ; * JMK70
            END                          ; * JMK70
            ROW=""
            ROW<1> = CARRIER.EST.ARRAY<4,X>        ; * Errors
            ROW<2> = OCONV(QUOTE.AMT,'MR2')        ; * Quote Amount ; * JMK32
            ROW<3> = CARRIER.EST.ARRAY<2,X>        ; * Carrier ID
            ROW<4> = CARRIER.EST.ARRAY<5,X>        ; * Carrier SCAC
            ROW<5> = CARRIER.EST.ARRAY<3,X>        ; * Carrier Name
            ROW<6> = ORIG.CITY
            ROW<7> = ORIG.ST
            ROW<8> = DEST.CITY
            ROW<9> = DEST.ST
            ROW<10> = MESSAGES
            ROW<11> = ZIP.MESSAGE
            ROW<12> = TRANSIT.TIME       ; * JMK09
            ROW<13> = ORIG.DIRECT        ; * JMK09
            ROW<14> = DEST.DIRECT        ; * JMK09
            ROW<15> = COMB.DIRECT        ; * JMK09
            ROW<16> = ORIG.TERM.NAME     ; * JMK11
            ROW<17> = ORIG.TERM.CODE     ; * JMK11
            ROW<18> = ORIG.TERM.ADR1     ; * JMK11
            ROW<19> = ORIG.TERM.ADR2     ; * JMK11
            ROW<20> = ORIG.TERM.CITY     ; * JMK11
            ROW<21> = ORIG.TERM.ST       ; * JMK11
            ROW<22> = ORIG.TERM.ZIP      ; * JMK11
            ROW<23> = ORIG.TERM.PHONE    ; * JMK11
            ROW<24> = ORIG.TERM.TPHONE   ; * JMK11
            ROW<25> = ORIG.TERM.FAX      ; * JMK11
            ROW<26> = ORIG.TERM.EMAIL    ; * JMK11
            ROW<27> = ORIG.TERM.CNAME    ; * JMK11
            ROW<28> = ORIG.TERM.CTITLE   ; * JMK11
            ROW<29> = DEST.TERM.NAME     ; * JMK11
            ROW<30> = DEST.TERM.CODE     ; * JMK11
            ROW<31> = DEST.TERM.ADR1     ; * JMK11
            ROW<32> = DEST.TERM.ADR2     ; * JMK11
            ROW<33> = DEST.TERM.CITY     ; * JMK11
            ROW<34> = DEST.TERM.ST       ; * JMK11
            ROW<35> = DEST.TERM.ZIP      ; * JMK11
            ROW<36> = DEST.TERM.PHONE    ; * JMK11
            ROW<37> = DEST.TERM.TPHONE   ; * JMK11
            ROW<38> = DEST.TERM.FAX      ; * JMK11
            ROW<39> = DEST.TERM.EMAIL    ; * JMK11
            ROW<40> = DEST.TERM.CNAME    ; * JMK11
            ROW<41> = DEST.TERM.CTITLE   ; * JMK11
            ROW<42> = OCONV(FSC.QUOTE.AMT,'MR2')   ; * JMK18
            TEMP.MISC.CHG.CODES = ACC.CODES
            FOR VAL=1 TO 4               ; * JMK18
               TEMP.CODE=TEMP.MISC.CHG.CODES<1,1,VAL>        ; * JMK18
               IF TEMP.CODE='LIFT' THEN TEMP.CODE='L25'      ; * JMK18
               LOCATE TEMP.CODE IN ACC.CODES<1,1> SETTING MPOS THEN    ; * JMK18
*****                  ROW<42+(VAL*2)-1> = TEMP.MISC.CHG.CODES<1,VAL>       ; * JMK18
                  ROW<42+(VAL*2)-1> = ACC.CODES<1,1,VAL>     ; * JMK18
                  ROW<43+(VAL*2)-1> = OCONV(ACC.QUOTE<1,1,VAL>,'MR2')  ; * JMK18
               END                       ; * JMK18
            NEXT VAL                     ; * JMK18
            ROW<51> = CARR.DATA.DATE     ; * JMK21
            ROW<52> = OCONV(CLIENT.COST,'MR2')     ; * JMK25
            ROW<53> = INFOMESSAGE        ; * JMK30
            **       ROW<54> =OCONV(CONTR.AMT,'MR2')
            ACTIVITY.REC<13,ACT.CNT> = CARRIER.EST.ARRAY<4,X>          ; * Errors
            ACTIVITY.REC<14,ACT.CNT> = CARRIER.EST.ARRAY<1,X>          ; * Quote Amount
            ACTIVITY.REC<15,ACT.CNT> = CARRIER.EST.ARRAY<2,X>          ; * Carrier ID
            ACTIVITY.REC<16,ACT.CNT> = CARRIER.EST.ARRAY<5,X>          ; * Carrier SCAC
            ACTIVITY.REC<17,ACT.CNT> = CARRIER.EST.ARRAY<3,X>          ; * Carrier Name
            ACTIVITY.REC<18,ACT.CNT> = ORIG.CITY
            ACTIVITY.REC<19,ACT.CNT> = ORIG.ST
            ACTIVITY.REC<20,ACT.CNT> = DEST.CITY
            ACTIVITY.REC<21,ACT.CNT> = DEST.ST
            ACTIVITY.REC<22,ACT.CNT> = MESSAGES
            ACTIVITY.REC<23,ACT.CNT> = ZIP.MESSAGE
            ACTIVITY.REC<24,ACT.CNT> = TRANSIT.TIME          ; * JMK09
            ACTIVITY.REC<25,ACT.CNT> = ORIG.DIRECT           ; * JMK09
            ACTIVITY.REC<26,ACT.CNT> = DEST.DIRECT           ; * JMK09
            ACTIVITY.REC<27,ACT.CNT> = COMB.DIRECT           ; * JMK09
            ACTIVITY.REC<28,ACT.CNT> = ORIG.TERM.NAME        ; * JMK11
            ACTIVITY.REC<29,ACT.CNT> = ORIG.TERM.CODE        ; * JMK11
            ACTIVITY.REC<30,ACT.CNT> = ORIG.TERM.ADR1        ; * JMK11
            ACTIVITY.REC<31,ACT.CNT> = ORIG.TERM.ADR2        ; * JMK11
            ACTIVITY.REC<32,ACT.CNT> = ORIG.TERM.CITY        ; * JMK11
            ACTIVITY.REC<33,ACT.CNT> = ORIG.TERM.ST          ; * JMK11
            ACTIVITY.REC<34,ACT.CNT> = ORIG.TERM.ZIP         ; * JMK11
            ACTIVITY.REC<35,ACT.CNT> = ORIG.TERM.PHONE       ; * JMK11
            ACTIVITY.REC<36,ACT.CNT> = ORIG.TERM.TPHONE      ; * JMK11
            ACTIVITY.REC<37,ACT.CNT> = ORIG.TERM.FAX         ; * JMK11
            ACTIVITY.REC<38,ACT.CNT> = ORIG.TERM.EMAIL       ; * JMK11
            ACTIVITY.REC<39,ACT.CNT> = ORIG.TERM.CNAME       ; * JMK11
            ACTIVITY.REC<40,ACT.CNT> = ORIG.TERM.CTITLE      ; * JMK11
            ACTIVITY.REC<41,ACT.CNT> = DEST.TERM.NAME        ; * JMK11
            ACTIVITY.REC<42,ACT.CNT> = DEST.TERM.CODE        ; * JMK11
            ACTIVITY.REC<43,ACT.CNT> = DEST.TERM.ADR1        ; * JMK11
            ACTIVITY.REC<44,ACT.CNT> = DEST.TERM.ADR2        ; * JMK11
            ACTIVITY.REC<45,ACT.CNT> = DEST.TERM.CITY        ; * JMK11
            ACTIVITY.REC<46,ACT.CNT> = DEST.TERM.ST          ; * JMK11
            ACTIVITY.REC<47,ACT.CNT> = DEST.TERM.ZIP         ; * JMK11
            ACTIVITY.REC<48,ACT.CNT> = DEST.TERM.PHONE       ; * JMK11
            ACTIVITY.REC<49,ACT.CNT> = DEST.TERM.TPHONE      ; * JMK11
            ACTIVITY.REC<50,ACT.CNT> = DEST.TERM.FAX         ; * JMK11
            ACTIVITY.REC<51,ACT.CNT> = DEST.TERM.EMAIL       ; * JMK11
            ACTIVITY.REC<52,ACT.CNT> = DEST.TERM.CNAME       ; * JMK11
            ACTIVITY.REC<53,ACT.CNT> = DEST.TERM.CTITLE      ; * JMK11
            ACTIVITY.REC<54,ACT.CNT> = FSC.QUOTE.AMT         ; * JMK18
            TEMP.MISC.CHG.CODES = ACC.CODES
            FOR VAL=1 TO 4               ; * JMK18
               ****    TEMP.CODE=TEMP.MISC.CHG.CODES<1,VAL>          ; * JMK18
               TEMP.CODE=TEMP.MISC.CHG.CODES<1,1,VAL>
               IF TEMP.CODE='LIFT' THEN TEMP.CODE='L25'      ; * JMK18
               LOCATE TEMP.CODE IN ACC.CODES<1,1> SETTING MPOS THEN    ; * JMK18
                  **      ACTIVITY.REC<55,ACT.CNT,VAL> = TEMP.MISC.CHG.CODES<1,VAL>      ; * JMK18
                  ***      ACTIVITY.REC<56,ACT.CNT,VAL> = ACC.QUOTE<1,1,MPOS>   ; * JMK18
                  ACTIVITY.REC<55,ACT.CNT,VAL> = ACC.CODES<1,1,VAL>    ; * JMK18
                  ACTIVITY.REC<56,ACT.CNT,VAL> = OCONV(ACC.QUOTE<1,1,VAL>,'MR2')           ; * JMK18

               END                       ; * JMK18
            NEXT VAL                     ; * JMK18
            ACTIVITY.REC<57,ACT.CNT> = ICONV(CARR.DATA.DATE,'D')       ; * JMK21
            ACTIVITY.REC<58,ACT.CNT> = CLIENT.COST
            ACTIVITY.REC<59,ACT.CNT> = INFOMESSAGE           ; * JMK30
            ACTIVITY.REC<60,ACT.CNT> = CONTR.BILL.TYPE       ; * JMK58
            ACTIVITY.REC<61,ACT.CNT> = BENCH.BILL.TYPE       ; * JMK58
            ACTIVITY.REC<63,ACT.CNT> = RW.TARIFF   ; * NKH04
            ACTIVITY.REC<64,ACT.CNT> = RW.EFF.DATE           ; * NKH04
            ACT.CNT+=1                   ; * JMK07 ; * JMK21
         END

         BEGIN CASE                      ; * JMK67
            CASE USER.TYPE='PROGRAMMER'  ; * JMK67
               CONVERT @AM TO CHAR(13):CHAR(10) IN METADATA  ; * JMK67
            CASE 1                       ; * JMK67
               CONVERT @AM TO CHAR(30) IN ROW
         END CASE                        ; * JMK67
****         CRT ROW
* For testing - Used with FBBP TIME.ESTIMATOR
*READV SEQ.NO FROM NKM.TEMP, 'SEQ', 1 ELSE SEQ.NO = '99'
*SEQ.NO += 1
*WRITEV SEQ.NO ON NKM.TEMP, 'SEQ', 1
*WRITE ROW ON NKM.TEMP, SEQ.NO

      NEXT X
      VOUT = ''
****DEBUG
      VOUT<1> = A1
      VOUT<2> =A2
      VOUT<3> =A3
      VOUT<4> =A4
      VOUT<5> =A5
      VOUT<6> =A6
      VOUT<7> = QUOTE.AMT
      VOUT<8> = NEW.LOG.COMM
      VOUT<9> = LOG.COMM+ NEW.LOG.COMM
      VOUT<10> = GBB.CONTRACT.ACC
      VOUT<11> = GBB.BENCH.ACC
      VOUT<12> = GB.LOG.AMT
      VOUT<13> = DCOUNT(TEMP.MISC.CHG.CODES,@VM)
      IF MISROUTE = 1 THEN
***DEBUG
      END
      RETURN
      IF ACTIVITY.ID#'' THEN             ; * JMK17
         WRITE ACTIVITY.REC ON F.ACTIVITY,ACTIVITY.ID        ; * JMK07

         IF XREF.OPEN = "Y" THEN
            ID.XREF = CLIENT.ID:"*":DATE()
            READ XREF.REC FROM F.IEFA.XREF, ID.XREF ELSE XREF.REC = ""
            LOCATE ACTIVITY.ID IN XREF.REC SETTING POS ELSE
               XREF.REC<-1> = ACTIVITY.ID
               WRITE XREF.REC ON F.IEFA.XREF, ID.XREF
            END
         END

      END                                ; * JMK17
      STOP
