*
* FREIGHT BILLING PACKAGE
*
* AUTHOR: OWEN HOLMAN
* DATE: JUNE 15, 2001
*
* THIS PROGRAM IS A PROPRIETARY PRODUCT OF AUTOMATED FREIGHT SYSTEMS
* AND MAY NOT BE USED, COPIED OR MODIFIED WITHOUT THE EXPRESS
* WRITTEN CONSENT OF SAME.
*
****************************************************************
* MODIFICATIONS:
* 103108 - JMK01 - T081156 - Change BLS column heading from Benchmark to Gross Charges
****************************************************************
* Initialize variables
****************************************************************
      CRT @(0,20):@(-3):
      TEXT='Reviewing Rates...'
      CALL CENTER(TEXT,80)
      CRT @(0,20):TEXT
      DATA.START=2                       ; * Line number that 1st line of data is on
      BILLDATA.USER='MKERBOW'            ; * Name of BILLDATA FILE THAT DATA IS IN
      INPUT.NAME='MERCHANT METALS AFS RATES.TXT'   ; * Name of "File" in BILLDATA
      OUTPUT.NAME='RR-MERCHANT METALS AFS RATES.XLS'
      CLIENT.OPT='01276'                 ; * 'OLA' Client Number (Rating Files)
      RR.EFF.DATE=DATE()
      CARRIER.OPT='00212':@VM:'02653'    ; * Rate all (Least Cost) or a specific carrier
      FAK.OPT=''
      ZIP.OPT=''

      FAK.ARRAY=''
      NVAL=DCOUNT(FAK.OPT<1>,@VM)
      FOR VAL=1 TO NVAL
         FAK.LVL=FAK.OPT<1,VAL>
         CLASS.RANGE=FIELD(FAK.LVL,';',1)
         CLASS.LOW=FIELD(CLASS.RANGE,'-',1)
         CLASS.HIGH=FIELD(CLASS.RANGE,'-',2)
         IF CLASS.HIGH='' THEN CLASS.HIGH=CLASS.LOW
         CLASS.FAK=FIELD(FAK.LVL,';',2)
         FAK.ARRAY<1,VAL>=CLASS.LOW
         FAK.ARRAY<2,VAL>=CLASS.HIGH
         FAK.ARRAY<3,VAL>=CLASS.FAK
      NEXT VAL

      CALL CHANNEL(CH.NUM)
      CALL GET.USER(USER)

      CLIENT.AUDIT=1
      ERROR=''
      PROG.NAME='RERATE.MM'
      PROG.DESC="(Re) Rate freight on shipments using OLA setups"
      PACK.NAME="Freight Billing"
      CONTR.AMT=''
       UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'RERATE.MM' ; UPL.VOUT = ''                    ;* NPR_UPL 04/23/2010
       CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010
      BENCH.AMT=''
      CARRIER.EST.ARRAY=''
      ERROR.ARRAY=''
      ADDZIP.ARRAY=ZIP.OPT
      ADDZIP.NVAL=DCOUNT(ZIP.OPT<1>,@VM)


*
* Open general files
*
      OPEN 'BILLDATA.':BILLDATA.USER TO F.BILLDATA ELSE
         CALL OPEN.ABORT("BILLDATA.":BILLDATA.USER,PROG.NAME)
      END
      OPEN '','CLIENTS' TO F.CLIENTS ELSE
         ERROR = "CANNOT OPEN FILE CLIENTS"
         GO 9000
      END
      OPEN '','FB.TABLES' TO F.TABLES ELSE
         ERROR = "CANNOT OPEN FILE F.TABLES"
         GO 9000
      END
      OPEN '','CARRIERS' TO F.CARRIERS ELSE
         ERROR = "CANNOT OPEN FILE CARRIERS"
         GO 9000
      END
      OPEN '','FB.NFSC' TO F.NFSC ELSE
         ERROR = "CANNOT OPEN FILE FB.NFSC"
         GO 9000
      END
      OPEN '','FB.TABLES' TO F.TABLES ELSE
         ERROR = "CANNOT OPEN FILE FB.TABLES"
         GO 9000
      END

*---- Open mileage input and output files

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
      OPEN '','CAN.ZIP.CODES' TO F.CAN.ZIPS ELSE
         ERROR = "CANNOT OPEN CAN.ZIP.CODES FILE "
         GO 9000
      END

*
* Read Source Data
*

      READ DA FROM F.BILLDATA,INPUT.NAME ELSE
         CALL ELINE('BILLDATA.':BILLDATA.USER:' ':INPUT.NAME:' is not on file.. Aborting!')
         ABORT
      END
*     DA=@AM:DA

      TAB=CHAR(9)
      DA=CHANGE(DA,TAB,@VM)
      NEW.DA=''
      NROWS=DCOUNT(DA,@AM)
      ORGCOLVAL=DCOUNT(DA<4>,@VM)
      HDG.LINE=DA<1>
      HDG.LINE<1,5>='FedEx Gross FRT'
      HDG.LINE<1,6>='FedEx Bench FRT'
      HDG.LINE<1,7>='FedEx AFS FRT'
      HDG.LINE<1,8>='FedEx Errors'
      HDG.LINE<1,9>='Con-Way Gross FRT'
      HDG.LINE<1,10>='Con-Way Bench FRT'
      HDG.LINE<1,11>='Con-Way AFS FRT'
      HDG.LINE<1,12>='Con-Way Errors'
*
* Process the data
*
      BRK.CARRIER=''
      PRV.CLIENT.ID=''
      BRK.PRO=''
      ROW.PER=''
      FOR ROW = 1 TO NROWS
         CALL PROG.BAR(22,ROW,NROWS,ROW.PER)
         IF ROW < DATA.START THEN
            NEW.DA<ROW>=DA<ROW>
            IF ROW='1' THEN
               NEW.DA<ROW>=HDG.LINE
            END
            GO SKIP.LINE
         END
         LINE=DA<ROW>
         LINE<1,7>=''
         LINE<1,10>=''
         CLIENT.ID=CLIENT.OPT
         IF CLIENT.ID#PRV.CLIENT.ID THEN
*
* Open client's files.
*
            AUDIT.CLIENT=1
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
               NEW.DA<-1>=LINE
            END
            OPEN '','FB.AUDIT.TABLES,':AUDIT.CLIENT.ID TO F.AUDIT.TABLES ELSE
               ERROR = "Cannot open file FB.AUDIT.TABLES,":AUDIT.CLIENT.ID
               NEW.DA<-1>=LINE
            END
            OPEN '','FB.AUDIT.ZIPS,':AUDIT.CLIENT.ID TO F.AUDIT.ZIPS ELSE
               ERROR = "Cannot open FB.AUDIT.ZIPS,":AUDIT.CLIENT.ID:" No On-Line Audit Allowed!"
               NEW.DA<-1>=LINE
            END
            OPEN '','FB.BILLS.HIST,':AUDIT.CLIENT.ID TO F.BILLS ELSE
               ERROR = "Cannot open FB.BILLS.HIST,":AUDIT.CLIENT.ID:" No On-Line Audit Allowed!"
               NEW.DA<-1>=LINE
            END
            PRV.CLIENT.ID=CLIENT.ID
         END

         FOR TIMES=1 TO 2
            CARRIER.ID=CARRIER.OPT<1,TIMES>
            IOT='O'
            OSHIP.DATE=DATE()'D2/'
            ORIG.ZIP=LINE<1,1>
            IF NUM(ORIG.ZIP) AND ORIG.ZIP#'' THEN ORIG.ZIP=ORIG.ZIP'R%5'
            DEST.ZIP=LINE<1,2>
            IF NUM(DEST.ZIP) AND DEST.ZIP#'' THEN DEST.ZIP=DEST.ZIP'R%5'
* Classes, Weights, & Codes
            PRV.CLASS=''
            CLASSES=LINE<1,4>
            WEIGHTS=LINE<1,3>
            MISC.CHG.CODES=''
            MISC.CHG.AMTS=''
            ERROR=''
            A.VOUT=''
            FSC.CVOUT=''
            FSC.BVOUT=''
            MODE='EFF'
            IF RR.EFF.DATE='S' THEN
               ORATE.DATE=OSHIP.DATE
            END ELSE
               ORATE.DATE=OCONV(RR.EFF.DATE,'D2/')
            END
            VIN.ARRAY=''
            GOSUB RATE.SHIPMENT
            EFF.BENCH.AMT=BENCH.AMT
            EFF.CONTR.AMT=CONTR.AMT
            EFF.BENCH.FRT.AMT=BENCH.AMT-BENCH.FSC.AMT
            EFF.BENCH.FSC.AMT=BENCH.FSC.AMT
            EFF.CONTR.FRT.AMT=CONTR.AMT-CONTR.FSC.AMT
            EFF.CONTR.FSC.AMT=CONTR.FSC.AMT
            EFF.CONS.FRT.AMT=EFF.BENCH.FRT.AMT-EFF.CONTR.FRT.AMT
            EFF.CONS.FSC.AMT=EFF.BENCH.FSC.AMT-EFF.CONTR.FSC.AMT
*            IF EFF.BENCH.AMT+0=0 AND EFF.CONTR.AMT+0=0 THEN
*               EFF.CARRIER.ID='None'
*               EFF.CARRIER.NAME='No Approved Carriers for this Route'
*            END

*            NVAL=DCOUNT(LINE<1>,@VM)
*            IF TIMES = 1 AND NVAL>4 THEN
*               FOR VAL=5 TO NVAL
*                  DEL LINE<1,5>
*               NEXT VAL
*            END
            IF TIMES=1 THEN
               LINE<1,5>=BENCH.GRS'R26'
               LINE<1,6>=EFF.BENCH.FRT.AMT'R26'
               LINE<1,7>=EFF.CONTR.FRT.AMT'R26'
               IF ERROR#'' THEN
                  LINE<1,8>=ERROR
               END
            END ELSE
               LINE<1,9>=BENCH.GRS'R26'
               LINE<1,10>=EFF.BENCH.FRT.AMT'R26'
               LINE<1,11>=EFF.CONTR.FRT.AMT'R26'
               IF ERROR#'' THEN
                  LINE<1,12>=ERROR
               END
            END
         NEXT TIMES
         NEW.DA<-1>=LINE
SKIP.LINE:****
      NEXT ROW
      NEW.DA=CHANGE(NEW.DA,@VM,TAB)
      WRITE NEW.DA ON F.BILLDATA,OUTPUT.NAME
      ERROR=''
      STOP
RATE.SHIPMENT:***
*    X=LEN(OSHIP.DATE)
*    CALL DATE.IN(OSHIP.DATE,"",1)
      RATE.DATE=ICONV(ORATE.DATE,'D')
      IF RATE.DATE='' THEN
         ERROR='Invaid Ship Date of ':ORATE.DATE
         RETURN
      END
      IF RATE.DATE > DATE() THEN
         ERROR='Ship date cannot be in the future. Use today as the date.'
         RETURN
      END
*     IF CARRIER.OPT='L' THEN CARRIER.ID='ALL'
      NUM.WEIGHTS = DCOUNT(WEIGHTS,@VM)
      TOT.WEIGHT = 0
      TOT.WEIGHT = SUM(WEIGHTS)
      IF TOT.WEIGHT GT 15000 THEN
         ERROR = "Total weight exceeds program limits. Please contact AFS"
         RETURN
      END
*----
* READ TABLES THAT MAY BE NEEDED
*----
      READ DTARIFF.DATE.XREF FROM F.TABLES,'TARIFF.DATE.XREF' ELSE DTARIFF.DATE.XREF=''
      READ DTARIFFS FROM F.TABLES,'TARIFFS' ELSE DTARIFFS=''
      READ LI.CODES FROM F.TABLES,'LI.CODES' ELSE LI.CODES=''
      READ DCLIENTS FROM F.CLIENTS,CLIENT.ID ELSE
         ERROR = "Client ":CLIENT.ID:" not on file."
         RETURN
      END
      CL.LOG.FSC=DCLIENTS<111>
      LOGISTICS=DCLIENTS<93>='Y'
      CARR.ONLY.FSC=DCLIENTS<189>
      MAX.LTL=15000
      IF DCLIENTS<150>#'' THEN MAX.LTL=DCLIENTS<150>
      IN.QUOTE.PERC = DCLIENTS<136>
      OUT.QUOTE.PERC = DCLIENTS<137>
      TP.QUOTE.PERC = DCLIENTS<138>
      BEGIN CASE
         CASE IOT = "I"
            IOT.DESC = "Inbound"
            SAVINGS.QUOTE.PERC=IN.QUOTE.PERC
         CASE IOT = "O"
            IOT.DESC = "Outbound"
            SAVINGS.QUOTE.PERC=OUT.QUOTE.PERC
         CASE IOT = "T"
            IOT.DESC = "Third Party"
            SAVINGS.QUOTE.PERC=TP.QUOTE.PERC
      END CASE
      IF SAVINGS.QUOTE.PERC = 'NO' THEN
         ERROR="Cannot Rate! Quote percent has not been set up."
         RETURN
      END


*
* Select Carrier(s) (Even if only one) to Loop thru
*
      STMT= 'SELECT FB.AUDIT,':AUDIT.CLIENT.ID
      STMT:=' WITH 1 = "LTLALL"'
      IF CARRIER.ID # 'ALL' THEN
         STMT:=" AND WITH CARRIER# '":CARRIER.ID:"'"
      END ELSE
         STMT:=' AND WITH 11 = "ENABLE"'
         STMT:=' AND WITH 13 = "Y"'      ; * Core Carrier Flag = "Y"
      END
      EXECUTE STMT RTNLIST CHECK.LIST CAPTURING OUTPUT
      IF @SELECTED < 1 THEN
         IF CARRIER.ID # 'ALL' THEN
            ERROR='Carrier ':CARRIER.ID:' is not set up for freight estimates'
         END ELSE
            ERROR='There are no core carriers set up for freight estimates'
         END
         RETURN
      END
*
* Setup AUDIT.VIN
*
*    SHIP.DATE=OSHIP.DATE
*    IF SHIP.DATE='' THEN
*      ERROR='Invaid Ship Date of ':OSHIP.DATE
*      RETURN
*    END

      READ O.ZIP.REC FROM F.ZIPS,ORIG.ZIP ELSE
         READ O.ZIP.REC FROM F.CAN.ZIPS,ORIG.ZIP ELSE
            ERROR=ORIG.ZIP:' ZIP NOT ON FILE, PLEASE TRY ANOTHER ZIP'
            RETURN
         END
      END
      ORIG.CITY = O.ZIP.REC<1>
      ORIG.ST = O.ZIP.REC<2>

      READ D.ZIP.REC FROM F.ZIPS,DEST.ZIP ELSE
         READ D.ZIP.REC FROM F.CAN.ZIPS,DEST.ZIP ELSE
            ERROR=DEST.ZIP:' ZIP NOT ON FILE, PLEASE TRY ANOTHER ZIP'
            RETURN
         END
      END
      DEST.CITY = D.ZIP.REC<1>
      DEST.ST = D.ZIP.REC<2>

      A.VIN=''
      A.VIN<3>=RATE.DATE
      A.VIN<11>=AUDIT.CLIENT.ID
      A.VIN<12>=IOT
      A.VIN<13,1>=ORIG.ZIP
      A.VIN<13,2>=ORIG.CITY
      A.VIN<13,3>=ORIG.ST
      A.VIN<14,1>=DEST.ZIP
      A.VIN<14,2>=DEST.CITY
      A.VIN<14,3>=DEST.ST
      A.VIN<16>=USER

*     A.VIN<17>=1                        ; *Misroute Flag to Ignore Misc Charge Code Errors
      A.VIN<18>=CLASSES
      A.VIN<19>=WEIGHTS
      A.VIN<21>=MISC.CHG.CODES
      A.VIN<22>=MISC.CHG.AMTS
      A.VIN<23>=MISC.CHG.AMTS
      A.VIN<24>=LOGISTICS
      A.VIN<25>=''
      A.VIN<35>=CL.LOG.FSC='N'           ; * Flag to NOT Calculate Log FSC
      A.VIN<46>=MAX.LTL                  ; * JMK02
      A.VIN<48>=DCLIENTS<188>            ; * JMK03 Forced Benchmark Minimum Flag Y/N
      A.VIN<49>=CARR.ONLY.FSC            ; * JMK05
*
**** Begin "Loop" of all Carriers *****
*
      CARRIER.EST.ARRAY=''
*<1>=Amount (MV Lowest to Highest)
*<2>=Carrier #
*<3>=Carrier Name
*<4>=Carrier Address
*<5>=Carrier City
*<6>=Carrier State
*<7>=Error (If Any)
*<8>=Flag
GET.NEXT.CARRIER:
      READNEXT CHECK.CARRIER.ID FROM CHECK.LIST ELSE
         RETURN
      END
      ERROR=''
      IF AUDIT.CLIENT.ID='01505' THEN
         CARR.ONLY.FSC=DCLIENTS<189>
         IF CARR.ONLY.FSC='Y' OR CARR.ONLY.FSC='C' THEN
            BEGIN CASE
               CASE CHECK.CARRIER.ID='00124'
                  CARR.ONLY.FSC='N'
               CASE CHECK.CARRIER.ID='01786'
                  CARR.ONLY.FSC='N'
               CASE CHECK.CARRIER.ID='05156'
                  CARR.ONLY.FSC='N'
               CASE CHECK.CARRIER.ID='08924'
                  CARR.ONLY.FSC='N'
            END CASE
         END
         A.VIN<49>=CARR.ONLY.FSC
      END
      GOSUB GET.CARRIER.INFO
      IF ERROR#'' AND CARRIER.ID # 'ALL' THEN
         ERROR='Carrier ':CARRIER.ID:' is not set up for freight estimates'
         RETURN
      END
**********************************************************************
      A.VIN<10>= CHECK.CARRIER.ID        ; * Add "Current" Carrier to AUDIT.VIN
      A.VIN<50>= CHECK.CARRIER.SCAC      ; * JMK26
      A.VIN<51>= CHECK.CARRIER.TYPE      ; * JMK26
      VIN=A.VIN
      A.VOUT=''
      TEST.VIN=CHANGE(A.VIN,@AM,@VM)
      CALL FB.AUTO(VIN,A.VOUT,D.AUDIT,CONTR.DFSC,BENCH.DFSC,DTARIFFS,DTARIFF.DATE.XREF,LI.CODES,F.AUDIT.TABLES,F.AUDIT.ZIPS,F.PCIN,F.PCOUT,F.TABLES)
      WHY=A.VOUT<24>                     ; * Save for Debugging purposes
      A.VOUT<24>=''                      ; * Kill Why So you can look at A.VOUT with Debugger
      CONTR.AMT = A.VOUT<8>
      BENCH.AMT = A.VOUT<9>
      CONTR.GRS = A.VOUT<84>
      BENCH.GRS = A.VOUT<85>
      OLA.ERROR = A.VOUT<1>
      CONTR.FSC.AMT=A.VOUT<46,7>
      BEGIN CASE
         CASE A.VIN<49>='Y'
            BENCH.FSC.AMT=A.VOUT<47,7>
         CASE A.VIN<49>='C'
            BENCH.FSC.AMT=A.VOUT<47,7>
         CASE A.VIN<49>='O'
            BENCH.FSC.AMT=A.VOUT<83,7>
         CASE 1
            BENCH.FSC.AMT=A.VOUT<48,7>
      END CASE
      IF USER='MKERBOW' THEN
         BEGIN CASE
            CASE OLA.ERROR#''
               TEST.VIN<1,-1>=OLA.ERROR
            CASE A.VOUT<2>='MA'
               TEST.VIN<1,-1>='Shipping Point Set to N'
            CASE CONTR.AMT#''
               TEST.VIN<1,-1>='BA=':BENCH.AMT'R26'
               TEST.VIN<1,-1>='BF=':BENCH.FSC.AMT'R26'
               TEST.VIN<1,-1>='CA=':CONTR.AMT'R26'
               TEST.VIN<1,-1>='CF=':CONTR.FSC.AMT'R26'
         END CASE
         VIN.ARRAY<-1>=TEST.VIN
      END
      AUDIT=A.VOUT<2>
      IF OLA.ERROR # "" THEN
         IF CARRIER.ID # 'ALL' AND CONTR.AMT+0=0 THEN
            ERROR=OLA.ERROR
            RETURN
         END
      END
      IF AUDIT # "Y" AND CARRIER.ID="ALL" THEN GO GET.NEXT.CARRIER
      IF AUDIT = "MA" THEN OLA.ERROR = "Not an approved carrier for this shipment!"
      IF CONTR.AMT+0=0 THEN GO GET.NEXT.CARRIER
      IF LOGISTICS AND BENCH.AMT+0=0 THEN GO GET.NEXT.CARRIER
*
*** Add Quote Percentage Logic Here ***
**********************************************************************

*** Locate and set percentages for quotes and commissions

      IF LOGISTICS THEN
         LOCATE RATE.DATE IN DCLIENTS<84> BY 'AR' SETTING POS ELSE
            POS=POS-1
         END
         COMM.PERC = DCLIENTS<85,POS>
         SAVINGS = BENCH.AMT-CONTR.AMT
         LOG.COMM = SAVINGS*COMM.PERC/100
         CL.SAVINGS = SAVINGS - LOG.COMM
         SAVINGS.QUOTE.AMT = CL.SAVINGS*(1-SAVINGS.QUOTE.PERC/10000)
         QUOTE.AMT=OCONV(CONTR.AMT + LOG.COMM + SAVINGS.QUOTE.AMT,'MR0')
      END ELSE
         QUOTE.AMT=CONTR.AMT
      END
      QUOTE.AMT=CONTR.AMT
*********************************************************************
* Special deal for BFG Quincy Compressor
*********************************************************************
*    IF CLIENT.ID='00981' THEN
*      BEGIN CASE
*        CASE CLIENT.ID='00981' AND IOT='O' AND ORIG.ZIP='62305'; * Quincy
*          QUOTE.AMT=(QUOTE.AMT*1.1)'R0'
*        CASE CLIENT.ID='00981' AND IOT='O' AND ORIG.ZIP='36507'; * Bay Minette
*          QUOTE.AMT=(QUOTE.AMT*1.12)'R0'
*        CASE CLIENT.ID='00761' AND IOT='O'
*          QUOTE.AMT=(QUOTE.AMT*1.12)'R0'
*      END CASE
*    END
*********************************************************************
**********************************************************************
*

      LOCATE (QUOTE.AMT:'_':BENCH.AMT) IN CARRIER.EST.ARRAY<1> BY 'AR' SETTING POS ELSE NULL
      INS (QUOTE.AMT:'_':BENCH.AMT) BEFORE CARRIER.EST.ARRAY<1,POS>
      INS CHECK.CARRIER.ID BEFORE CARRIER.EST.ARRAY<2,POS>
      INS CHECK.CARRIER.NAME BEFORE CARRIER.EST.ARRAY<3,POS>
      INS CHECK.CARRIER.STREET BEFORE CARRIER.EST.ARRAY<4,POS>
      INS CHECK.CARRIER.CITY BEFORE CARRIER.EST.ARRAY<5,POS>
      INS CHECK.CARRIER.STATE BEFORE CARRIER.EST.ARRAY<6,POS>
      INS OLA.ERROR BEFORE CARRIER.EST.ARRAY<7,POS>
      INS BENCH.AMT BEFORE CARRIER.EST.ARRAY<8,POS>
      INS BENCH.FSC.AMT BEFORE CARRIER.EST.ARRAY<9,POS>
      INS CONTR.AMT BEFORE CARRIER.EST.ARRAY<10,POS>
      INS CONTR.FSC.AMT BEFORE CARRIER.EST.ARRAY<11,POS>
      INS CONTR.GRS BEFORE CARRIER.EST.ARRAY<12,POS>
      INS BENCH.GRS BEFORE CARRIER.EST.ARRAY<13,POS>
      GO GET.NEXT.CARRIER
GET.CARRIER.INFO:***
      READ CHECK.CARRIER.REC FROM F.CARRIERS,CHECK.CARRIER.ID ELSE
         ERROR = "Carrier ":CHECK.CARRIER.ID:" not on file."
         RETURN
      END
      CHECK.CARRIER.NAME = CHECK.CARRIER.REC<1>
      CHECK.CARRIER.STREET = TRIM(CHANGE(CHECK.CARRIER.REC<2>,@VM,' '))
      CHECK.CARRIER.CITY = CHECK.CARRIER.REC<3>
      CHECK.CARRIER.STATE = CHECK.CARRIER.REC<4>
      CHECK.CARRIER.SCAC = CHECK.CARRIER.REC<12>   ; *Added By ROB GAUDET 9/23/2003
      CHECK.CARRIER.STATUS = CHECK.CARRIER.REC<89>           ; * JMK14
      IF CHECK.CARRIER.STATUS = "I" THEN           ; * JMK14
         ERROR = "CARRIER IS NOT ACTIVE - CARRIER# ":CHECK.CARRIER.ID  ; * JMK14
         RETURN                          ; * JMK14
      END                                ; * JMK14
      CHECK.CARRIER.TYPE = 'A'           ; * JMK09
      IF CHECK.CARRIER.REC<44>='6' THEN  ; * JMK09
         CHECK.CARRIER.TYPE='B'          ; * JMK09
      END                                ; * JMK09
      CHECK.CARRIER.TEXT=TRIM(CHECK.CARRIER.ID:' ':CHECK.CARRIER.NAME:' ':CHECK.CARRIER.STREET:' ':CHECK.CARRIER.CITY)
      READ D.AUDIT FROM F.AUDIT, CHECK.CARRIER.ID ELSE
         ERROR = "CARRIER NOT SETUP FOR AUTO AUDIT - CARRIER#":CHECK.CARRIER.ID
         RETURN
      END
      IF D.AUDIT<11>#'ENABLE' THEN
         ERROR='Not Considered in On-Line Audit - Carrier Disabled'
         RETURN
      END
      READ BENCH.DFSC FROM F.NFSC,CHECK.CARRIER.ID ELSE BENCH.DFSC=''
      IF BENCH.DFSC<30>='DISABLE' THEN
         BENCH.DFSC=''                   ; ** No Effect
         CONTR.DFSC=''
      END ELSE
         READ CONTR.DFSC FROM F.NFSC,CHECK.CARRIER.ID:"*":AUDIT.CLIENT.ID ELSE CONTR.DFSC=BENCH.DFSC
         IF CONTR.DFSC<30>='DISABLE' THEN CONTR.DFSC=''
      END
      RETURN

9000: ****

      IF ERROR#'' THEN RVOUT<1>=ERROR

      STOP
