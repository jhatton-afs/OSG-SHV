      SUBROUTINE FB.2.1.AUDIT.TL(VIN,VOUT,CONTR.DFSC,BENCH.DFSC,AVAL.ACC.CODES,F.AUDIT.ZIPS,F.PCIN,F.PCOUT,F.AUDIT,F.PTP,EQUIP.TYPES,F.MILEAGE,F.TABLES)
*
 UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'FB.2.1.AUDIT.TL' ; UPL.VOUT = ''                    ;* NPR_UPL 04/23/2010
 CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010
* FREIGHT BILLING PACKAGE
*
* AUTHOR:      OWEN HOLMAN & TAMI SEAGO
* DATE:        JANUARY, 2000
* DESCRIPTION: THIS PROGRAM ALLOW THE ENTRY OF SPECIFIC INFORMATION
*              NEEDED TO AUDIT FREIGHT BILLS DURING DATA ENTRY
*
* THIS PROGRAM IS A PROPRIETARY PRODUCT OF AUTOMATED FREIGHT SYSTEMS
* AND MAY NOT BE USED, COPIED OR MODIFIED WITHOUT THE EXPRESS
* WRITTEN CONSENT OF SAME.
*
* 033105 - JMK01 - ADD CLIENT AND CARRIER FOR ARTCO BELL AND CRETE
* 121708 - JMK02 - T082703 - Truckload OLA ; benchmark amount incorrect
*********************************************************************
*
      $INCLUDE PROG.ADMIN INC_OPTIONS
      $INCLUDE FILE.DEFS INC_FB.AUDIT
*
* Initialize variables
*
      PROMPT ''
      VALID.CLASSES=50:@VM:55:@VM:60:@VM:65:@VM:70:@VM:77:@VM:85:@VM:92:@VM:100:@VM:110:@VM:125:@VM:150:@VM:175:@VM:200:@VM:250:@VM:300:@VM:400:@VM:500
      FSC.LOGISTICS.AMT=0
      GTOT.CONTR.AMT=0
      GTOT.BENCH.AMT=0
      WHY=''
      BENCH.DOUT=''                      ; * In case of no logistics
      NULL=''                            ; * Used for Mass Change back to CRT Command
      SENT.TO.PC=0
      TESTING=0
      X.EX.FLAG=''
      BACK.FLAG=0
      OPT = VIN<1>
      MAX.OVC.AMT=-1
      DOT.OVC.AMT=-100
      CUT.DESC='Tariff Error'
      IF OPT = 'I' THEN
         INQUIRE = 1
         ZIP.MODE = 'EDIT'
         MC.MODE = 'EDIT'
      END ELSE
         INQUIRE = 0
         ZIP.MODE = 'INPUT'
         MC.MODE = 'INPUT'
      END
      CALL FB.CLEAR.WINDOW
      TRANS.MODE=''
      BILL.DATE=VIN<3>
      TRANS.MODE=VIN<4>
      PIECES=VIN<5>
      TOT.WEIGHT=VIN<6>
      AIR.MISC.CHARGE=VIN<7>             ; * Not Used -> Passed Through
      AMT.ON.BILL=VIN<8>
      CARRIER=VIN<10>
      CLIENT=VIN<11>
      IN.OUT=VIN<12>
      ORIG.ZIP=VIN<13,1>
      ORIG.CITY=VIN<13,2>
      ORIG.STATE=VIN<13,3>
      DEST.ZIP=VIN<14,1>
      DEST.CITY=VIN<14,2>
      DEST.STATE=VIN<14,3>
      CL.ZIP.DEF=VIN<15>
      USER=VIN<16>
      IF USER='OWEN' OR USER = 'TAMI' THEN OWEN=1 ELSE OWEN=0

      IF USER='NPRATT' THEN DEBUG ;* ZZ Remove

      MISROUTE=VIN<17>
      CC=VIN<25>                         ; * Character Count
      MISC.CHG=''
      MISC.CHG<1>=VIN<21>                ; * Mv Charge Codes
      MISC.CHG<2>=VIN<22>                ; * Mv Contract  Charge Amounts
      MISC.CHG<3>=VIN<23>                ; * Mv Benchmark Charge Amounts
      LOGISTICS=VIN<24>                  ; * Logistics Switch 1=Logistics 0=None
      LOGISTICS.QUESTION=LOGISTICS       ; * Save Original Value
      ZIP.LEN=VIN<26>
      IF ZIP.LEN='N' THEN ZIP.LEN=5
      IF ZIP.LEN='C' THEN
         CANADIAN=1
         MAX.LEN=6
      END ELSE
         CANADIAN=0
         MAX.LEN=ZIP.LEN
      END
      PROG.NAME=VIN<27>
      PROG.DESC=VIN<28>
      PACK.NAME=VIN<29>
      CO.NAME=VIN<30>
      SCREEN.DSP=VIN<31>
      DATA.DSP=VIN<32>
      BILL.DATA=VIN<33>                  ; * Only get Class/Wt/Misc Chg for Misroutes
      AUTO.MISROUTE=VIN<34>              ; * 1=Auto Misroute, 0=Act Like OLA
      NO.LOG.FSC=VIN<35>                 ; * 1=Do not Calculate/ADD FSC to Log/Bench Amt
      PRE.AUDIT.DATE=VIN<36>
      PRO.ID=VIN<37>
      ZIP.ARR = VIN<38>
      CH.NUM = VIN<39>
      MILEAGE = VIN<40>
      USER.TYPE=VIN<43>
      ORIG.AMT.ON.BILL=VIN<44>
      ORIG.CARRIER = VIN<47>
      MILEAGE = MILEAGE'R0'              ; * 07/16/02 Owen, Rounded Mileage
      BENCH.BILL.TYPE = ''
      CUR.BENCH.DISC = ''
      IF NOT(LOGISTICS) THEN AUTO.MISROUTE=0       ; * No Misroutes on Non Log
      LOGISTICS.AMT=0
      OVERCHARGE.AMT=0
      AMT.TO.PAY=''
      REDRAW.SCR=0
      LOGISTICS.AMT=0
      AUDIT='Y'
      IF LOGISTICS THEN
         AUDIT.POS=@(60,6)
      END ELSE
         AUDIT.POS=@(65,6)
      END
      GOSUB 6000
      NUM.E.TYPES = DCOUNT(EQUIP.TYPES<1>,@VM)

*
* Get Audit Y/N
*
100: ***
*
      IF NUM.E.TYPES = 1 THEN
         IF BACK.FLAG THEN RETURN
      END
      HELP = 'What type of Bill is this? '
      FOR X = 1 TO NUM.E.TYPES
         A.TYPE = EQUIP.TYPES<2,X>
         LEN.TYPE = LEN(A.TYPE)
         HELP:= '[':A.TYPE[1,4]:']':A.TYPE[2,LEN.TYPE-1]:' '
      NEXT X
      MASK=' TL Type: ':EQUIP.TYPES<1,1>
*    IF NUM.E.TYPES = 1 THEN
*      DATA EQUIP.TYPES<1,1>
*    END
      CALL GEN.IN(50,6,MASK,'',Q,0,4,'L','',2,60,6,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI = ICONV(QI,'MCU')
      IF USER.TYPE='A' AND QI='0' THEN QI='NO'
      BEGIN CASE
         CASE QI =''
            QI=EQUIP.TYPES<1,1>
         CASE QI = 'X'
            X.EX.FLAG='X'
            GO 9000
         CASE QI='EX'
            X.EX.FLAG='EX'
            GO 9000
*DF       CASE QI = 0 OR QI = 'N'
         CASE QI = 'NO'
            AUDIT='N'
            MISROUTE=0
            GO 9000
      END CASE
      LOCATE QI IN EQUIP.TYPES<1> SETTING POS THEN
         SEL.EQUIP.TYPE = EQUIP.TYPES<1,POS>
         EQUIP.DESC = EQUIP.TYPES<2,POS>
         AUDIT.ID = CARRIER:'*':SEL.EQUIP.TYPE
         READ DAUDIT FROM F.AUDIT,AUDIT.ID ELSE
            DAUDIT = ''
            CALL ELINE('Equipment Type : ':EQUIP.DESC:' is not setup, please try again')
            CC+=1
            GO 100
         END
      END ELSE
         EQUIP.DESC = QI
         CALL ELINE('Equipment Type : ':EQUIP.DESC:' is not setup, please try again')
         CC+=1
         GO 100
      END

      IF AUDIT='U' THEN AUDIT='Y'
      PRINT AUDIT.POS:SEL.EQUIP.TYPE:

200: *** Get Bill Date
*
*IF USER = "NPRATT" THEN DEBUG
      IF BILL.DATE='' THEN
         MASK='MM/DD/YY'
      END ELSE
         MASK=BILL.DATE'D2/'
      END
      HELP="Enter the Pro Date (Shipment Date) [P]rnt Addr Ltr"
      CALL GEN.IN(5,7,MASK,'DATE',Q,0,8,'L','',2,5,7,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI = OCONV(QI,'MCU')
      IF QI='X' THEN GO 100
      IF QI='EX' THEN
         X.EX.FLAG='EX'
         GO 9000
      END
      IF QI='P' THEN
         GOSUB PRINT.CARRIER.ADDRESS.LETTER
         GOTO 200
      END
      IF QI='' THEN
         IF BILL.DATE#'' THEN Q=BILL.DATE ELSE
            CALL ELINE('Entry is Required')
            CC+=1
            GO 200
         END
      END
      IF Q > DATE() THEN
         CALL ELINE('Cannot Be in the Future')
         CC+=1
         GO 200
      END
      IF Q < PRE.AUDIT.DATE THEN
VERIFY.SELECTION: ***
         CRT @(0,21):"[YES] I understand that this bill is Earlier than Client Pre-Audit Start Date!"
         HELP="X=Change. EX=Exit. [YES]=Continue."
         CALL GEN.IN(0,22,'Enter selection please. ---','',Q,0,3,'','',0,-3,22,1,QI,HELP,0,23)
         QI=OCONV(QI,'MCU')
         BEGIN CASE
            CASE QI='X'
               CRT @(0,21):@(-3):
               GOTO 200
            CASE QI='EX'
               STOP
            CASE QI='YES'
               NULL
            CASE 1
               CALL ELINE('Invalid entry. Must be [X], [EX], or [YES].')
               GOTO VERIFY.SELECTION
         END CASE
         CRT @(0,21):@(-3):
*       CALL ELINE("WARNING!! Bill Date is Earlier than Client Pre-Audit Start Date!!!!")
*       CC+=1; GOSUB PRINT.CC
      END
      IF Q < DATE()-182 THEN
         CALL ELINE("Warning - Date is older than 6 months")
         CC+=1
      END
      BILL.DATE=Q
      PRINT @(5,7):(BILL.DATE'D2/')'L#8':

300: *** Get Inbound or Outbound
      MASK = IN.OUT'L#2'
      HELP = 'Enter [I]=Inbound [O]Outbound. [X]=Back to Bill date [EX]=Exit'
      CALL GEN.IN(5,8,MASK,'',Q,0,2,'','',2,-2,8,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI = OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI = 'X'
            CRT @(5,7):IN.OUT:
            BACK.FLAG = 1
            GO 200
         CASE QI = 'EX'
            X.EX.FLAG='EX'
            GO 9000
         CASE QI = 1 ! QI = 'I'
            Q = 'I'
         CASE QI = 0 ! QI = 'O'
            Q = 'O'
         CASE QI = 3 ! QI = 'T'
            Q = 'T'
         CASE QI = ''
            IF IN.OUT # '' THEN Q = IN.OUT ELSE
               CALL ELINE('Entry is Required')
               CC+=1
               GO 300
            END
         CASE 1
            CALL ELINE('Must be <I>nbound, <O>utbound, or <T>hird Party')
            CC+=1
            GO 300
      END CASE
      IN.OUT = Q
      PRINT @(5,8):IN.OUT'L#2':
      IF IN.OUT='O' AND CL.ZIP.DEF#'' AND ZIP.ARR<1,1> = '' THEN
         ZIP.ARR<1,1> = CL.ZIP.DEF
      END


400: *** Get Zip Codes
      LN=0
      ZIP.SEL = 0
      BACK.FLAG = 0
*
450: *** Enter Line Number for Class Weight
*
      IF ZIP.MODE='INPUT' THEN
         ZIP.SEL=ZIP.SEL+1
         QI=ZIP.SEL
         IF ZIP.SEL GT 6 THEN
            ZIP.MODE='EDIT'
            GO 475
         END
      END ELSE
         HELP = "Enter Line Num. ''=End. 'X'=Back 'EX'=Exit."
         CALL GEN.IN(36,16,'Enter line number. ###','',Q,0,3,'','',0,-3,16,0,QI,HELP,0,23)
         CC+=LEN(QI)+1
      END
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI=''
            GO 475                       ; *** Done with Zip Codes
         CASE QI='X'
            GO 300
         CASE QI='EX'
            X.EX.FLAG='EX'
            GO 9000
         CASE NUM(QI)
            IF INQUIRE THEN
               CALL ELINE('Can not access detail in inquiry!')
               CC+=1
            END ELSE
               IF QI > 1 THEN
                  IF ZIP.ARR<1,QI-1>='' THEN
                     CALL ELINE("Cannot Skip a line.  You must select the next blank line")
                     CC+=1
                     GO 450
                  END
               END
               IF QI > 6 THEN
                  CALL ELINE("Maximum line number is 6")
                  CC+=1
                  GO 475
               END
               ZIP.SEL=QI
               GOSUB 460
               IF QI='X' AND ZIP.SEL=1 THEN GO 300
               IF QI='X' THEN ZIP.SEL=ZIP.SEL-1
               IF OPT='V' & QI='' THEN GO 475      ; ** Done with Zip Codes
            END
      END CASE
      GO 450

460:  LINE = ZIP.SEL + 9
      HELP = "Enter Zip Code. "
      IF OPT = 'V' THEN
         MASK = SPACE(6)
         HELP := "''=End. 'S'=Search. 'X'=Back. 'EX'=Exit."
      END ELSE
         HELP := "''=Accept. 'D'=Delete. 'S'=Search. 'X'=Back. 'EX'=Exit."
         MASK = ZIP.ARR<1,ZIP.SEL>'L#6'
      END

      CALL GEN.IN(36,LINE,MASK,'',Q,0,MAX.LEN,'','',2,-MAX.LEN,LINE,0,QI,HELP,0,23)

      IF QI=' ' THEN
         DEL ZIP.ARR<1,ZIP.SEL>
         DEL ZIP.ARR<2,ZIP.SEL>
         DEL ZIP.ARR<3,ZIP.SEL>
      END
      QI = OCONV(QI,'MCU')
      Q=OCONV(Q,'MCU')
      IF QI MATCHES '5N"-"' THEN
         QI=CHANGE(QI,'-','M')
         Q=QI
         CRT @(36,LINE):QI'L#6'
      END
      BEGIN CASE
         CASE QI='S'
            HELP="Enter city and state for zip code search. Separate with comma(,)."
            CALL GEN.IN(36,LINE,STR('-',30),'',Q,0,30,'','',1,-30,LINE,0,QI,HELP,0,23)
            CC+=LEN(QI)
            VIN=CC
            CALL ZIPS.DISPLAY.NEW(VIN,VOUT,Q,'ZIPS.CODES','ZIPS.CITY','1,2,3',ITEM.LIST)
            CC=VOUT<1>
            BEGIN CASE
               CASE DCOUNT(ITEM.LIST<1>,@VM) GT 1 OR ITEM.LIST=''
                  GOTO 100
               CASE ITEM.LIST NE ''
                  GOSUB 8100
                  GOSUB 6000
                  DATA ITEM.LIST<1,1>
                  GO 460
            END CASE
         CASE QI = 'EX'
            X.EX.FLAG = 'EX'
            RETURN TO 9000
         CASE QI = 'X'
            CRT @(36,LINE):ZIP.ARR<1,ZIP.SEL>'L#5'
            IF ZIP.SEL = 1 THEN
               RETURN TO 300
            END ELSE
               ZIP.SEL = ZIP.SEL-1
               LINE=ZIP.SEL+9
               GO 460
            END
         CASE QI='' AND OPT NE 'V'
            Q=ZIP.ARR<1,ZIP.SEL>
            IF Q='' THEN
               IF ZIP.ARR<1,1>='' AND ZIP.ARR<1,2>='' THEN
                  CALL ELINE('ERROR! YOU MUST ENTER AT LEAST AN ORIG AND DEST ZIP CODE')
                  CC+=1
                  ZIP.SEL = ZIP.SEL-1
                  RETURN TO 460
               END
               RETURN TO 475
            END

         CASE QI = 'D' & OPT NE 'V'
            DEL ZIP.ARR<1,ZIP.SEL>
            DEL ZIP.ARR<2,ZIP.SEL>
            DEL ZIP.ARR<3,ZIP.SEL>
            GOSUB 7000
            RETURN
         CASE QI = 'E' & OPT NE 'V'
            ZIP.MODE = 'EDIT'
            CRT @(36,LINE):ZIP.ARR<1,ZIP.SEL>'L#5'
            RETURN
         CASE QI = '' & OPT NE 'V'
            Q = ZIP.ARR<1,ZIP.SEL>
            IF Q = '' & ZIP.MODE = 'INPUT' THEN
               ZIP.MODE = 'EDIT'
               RETURN
            END
            IF Q = '' THEN RETURN TO 475
         CASE QI = ''
            X = DCOUNT(ZIP.ARR<1>,CHAR(253))
            FOR I = 1 TO X
               IF ZIP.ARR<4,I> NE '*' THEN
                  CALL ELINE('All zip codes have not been verified.')
                  CC+=1
                  GOTO 460
               END
            NEXT I
            RETURN
         CASE OPT = 'V'
            IF QI # ZIP.ARR<1,ZIP.SEL> THEN
               CALL ELINE('INVALID ZIP CODE.')
               CC+=1
               GOTO 460
            END
            ZIP.ARR<4,ZIP.SEL> = '*'
         CASE CANADIAN AND QI MATCHES '1A1N1A1N1A1N'
            ZIP.ARR<1,ZIP.SEL> = Q
         CASE CANADIAN AND QI MATCHES '1A1N1A'
            ZIP.ARR<1,ZIP.SEL> = Q
         CASE CANADIAN AND QI MATCHES '5N"M"'
            ZIP.ARR<1,ZIP.SEL> = Q
         CASE CANADIAN AND LEN(QI) NE 5
            CALL ELINE('INVALID ZIP CODE.')
            CC+=1
            GOTO 460
         CASE NOT(CANADIAN) AND LEN(QI) NE MAX.LEN
            CALL ELINE('INVALID ZIP CODE.')
            CC+=1
            GOTO 460
*DF         CASE NUM(QI) AND LEN(QI) < 6
         CASE NUM(QI)
            ZIP.ARR<1,ZIP.SEL> = Q
         CASE 1
            CALL ELINE('INVALID ZIP CODE.')
            CC+=1
            GOTO 460
      END CASE

      IF OPT NE 'V' THEN
         CODE = ZIP.ARR<1,ZIP.SEL>
         GOSUB 8560
         IF ACK = 'ERR' THEN GOTO 460
         CRT @(36,LINE):ZIP.ARR<1,ZIP.SEL>'L#6'
      END
      RETURN




475: *Finished getting zip

      ORIG.ZIP = ZIP.ARR<1,1>
      ORIG.CITY = ZIP.ARR<2,1>
      ORIG.STATE = ZIP.ARR<3,1>
      NUM.ZIPS = DCOUNT( ZIP.ARR<1>, @VM )
      DEST.ZIP = ZIP.ARR<1,NUM.ZIPS>
      DEST.CITY = ZIP.ARR<2,NUM.ZIPS>
      DEST.STATE = ZIP.ARR<3,NUM.ZIPS>


      IF ORIG.CITY # '' THEN
         DESC = ORIG.CITY:', ':ORIG.STATE
      END ELSE
         DESC = ORIG.STATE
      END
      CRT @(5,10):ORIG.ZIP'L#5':' ':DESC'L#20'

      IF DEST.CITY # '' THEN
         DESC = DEST.CITY:', ':DEST.STATE
      END ELSE
         DESC = DEST.STATE
      END
      CRT @(5,11):DEST.ZIP'L#5':' ':DESC'L#20'
      IF DEST.ZIP = ORIG.ZIP THEN
         CALL ELINE('Warning - Origin and destination zip are the same.')
         CC+=1
      END
      MILE.REC = ZIP.ARR
      VIN='SEND'
      VIN<2>=CH.NUM
      VIN<3>=MILE.REC
      VIN<4>=0                           ; * 1 to Skip File Lookup and go to PC
      VIN<5>=PROG.NAME
      VIN<6>=CLIENT:' - ':CLIENT
      VIN<8>=CLIENT                      ; * JMK01
      VIN<9>=CARRIER                     ; * JMK01
      SENT.TO.PCMILER=1
      CALL PCMILER.BETA(VIN,VOUT,F.PCIN,F.PCOUT,F.MILEAGE)
      IF VOUT<2>='FOUNDINFILE' OR VOUT<2>[1,5]='ERROR' THEN
         MILEAGE=OCONV(VOUT<1>,'MR0')
         SENT.TO.PCMILER=0
      END
      MILEAGE = MILEAGE'R0'              ; * 07/16/02 Owen, Rounded Mileage
      IF SENT.TO.PCMILER THEN
         VIN='READ'
         VIN<2>=CH.NUM
         CALL PCMILER.BETA(VIN,VOUT,F.PCIN,F.PCOUT,F.MILEAGE)
         SENT.TO.PCMILER=0
         MILEAGE=VOUT<1>
      END
      MILEAGE = MILEAGE'R0'              ; * 07/16/02 Owen, Rounded Mileage
      CRT @(5,15):MILEAGE'L1,#10'

525: *** See if the Routing Guide is on file - If Not Cannot Audit
*CRT @(0,23):'Press Break if you you want to see the Table Lookup ':;INPUT NUL:
      IF IN.OUT='O' THEN
         ROUTE.ZIP=ORIG.ZIP
         SHIP.ZIP=DEST.ZIP[1,3]
      END ELSE
         ROUTE.ZIP=DEST.ZIP
         SHIP.ZIP=ORIG.ZIP[1,3]
      END
      IF DAUDIT='' THEN
         AUDIT='U'
         CALL ELINE('Cannot Audit!  This Carrier is not set up for On-Line Audit!')
         CC+=1
         GO 590
      END
      LOOKUP.ZIP='ALL'
      LOCATE 'ALL' IN DAUDIT<FBA.ROUTE.ZIP> SETTING GUIDE.POS ELSE
         LOOKUP.ZIP=ROUTE.ZIP
         LOCATE LOOKUP.ZIP IN DAUDIT<FBA.ROUTE.ZIP> SETTING GUIDE.POS ELSE
            LOOKUP.ZIP='OTHER'
            LOCATE LOOKUP.ZIP IN DAUDIT<FBA.ROUTE.ZIP> SETTING GUIDE.POS ELSE
*** See if 1st three digits are there (Must Be Unique)
               CK.TIMES=DCOUNT(DAUDIT<FBA.ROUTE.ZIP>,@VM)
               CK.RZIP=''                ; * Put the Routing Zips Found Here
               FOR CK = 1 TO CK.TIMES
                  FIND.RT.ZIP=DAUDIT<FBA.ROUTE.ZIP,CK>
                  IF FIND.RT.ZIP[1,3]=ROUTE.ZIP[1,3] THEN
                     GUIDE.POS=CK
                     SUBST.ZIP=DAUDIT<FBA.BASE.ROUTE.ZIP,CK>
                     IF SUBST.ZIP#'' THEN
                        LOCATE SUBST.ZIP IN DAUDIT<FBA.ROUTE.ZIP> SETTING GUIDE.POS ELSE
                           CALL ELINE("Error Ship Zip ":SHIP.ZIP:" points to Base zip ":LOOKUP.ZIP:" Which is missing!")
                           CC+=1
                           GO 400
                        END
                        FIND.RT.ZIP=SUBST.ZIP
                     END
                     LOCATE FIND.RT.ZIP IN CK.RZIP SETTING POS ELSE
                        CK.RZIP<-1>=FIND.RT.ZIP
                        LOOKUP.ZIP=FIND.RT.ZIP
                     END
                  END
               NEXT CK
               IF CK.RZIP='' OR CK.RZIP<2>#'' THEN
                  CALL ELINE('Cannot Audit!  Unable to locate routing guide ':LOOKUP.ZIP:' in setup.')
                  CC+=1
                  AUDIT='U'
                  MISROUTE=1
                  IF LOGISTICS ELSE GOSUB 8000
                  GO 590
               END
            END
         END
         IF DAUDIT<FBA.BASE.ROUTE.ZIP,GUIDE.POS> # '' THEN   ; ** Get BASE Routing Zip POS
            LOOKUP.ZIP=DAUDIT<FBA.BASE.ROUTE.ZIP,GUIDE.POS>
            LOCATE LOOKUP.ZIP IN DAUDIT<FBA.ROUTE.ZIP> SETTING GUIDE.POS ELSE
               CALL ELINE("Error Ship Zip ":SHIP.ZIP:" points to Base zip ":LOOKUP.ZIP:" Which is missing!")
               CC+=1
               GO 400
            END
         END
      END
***************************************************************
* Check to See if Routing Zip is Enabled or Disabled
***************************************************************
      IF DAUDIT<FBA.ROUTE.ZIP.STATUS,GUIDE.POS>='DISABLE' THEN
         CALL ELINE("Cannot Audit! Route Zip is set to DISABLE")
         CC+=1
         AUDIT='U'
         MISROUTE=1
         GOSUB 8000
         GO 590
      END
* Get Effective Date
      FIRST.DATE=DAUDIT<FBA.BEG.EFF.DATE,GUIDE.POS,1>
      LAST.DATE=DAUDIT<FBA.END.EFF.DATE,GUIDE.POS,DCOUNT(DAUDIT<FBA.BEG.EFF.DATE,GUIDE.POS>,@SVM)>
      IF BILL.DATE < FIRST.DATE THEN     ; * Is bill Before Beginning Date
         CALL ELINE('Cannot Audit! Bill date is before 1st effective date.')
         CC+=1
         AUDIT='U'
         MISROUTE=1
         GOSUB 8000
         GO 590
      END
      IF LAST.DATE#'' AND (BILL.DATE > LAST.DATE) THEN
         CALL ELINE('Cannot Audit Bill!  Bill Date is after Last Effective Date.')
         CC+=1
         AUDIT='U'
         MISROUTE=1
         GOSUB 8000
         GO 590
      END
      LOCATE BILL.DATE IN DAUDIT<FBA.BEG.EFF.DATE,GUIDE.POS> BY 'AR' SETTING DT.POS ELSE
         DT.POS=DT.POS-1
         IF DT.POS < 1 THEN
            CALL ELINE('Serious error Contract Carrier Date POS is less than 1, Call Owen')
            CC+=1
            GO 525
         END
      END
      EFF.DATE=DAUDIT<FBA.BEG.EFF.DATE,GUIDE.POS,DT.POS>
      END.DATE=DAUDIT<FBA.END.EFF.DATE,GUIDE.POS,DT.POS>
      IF END.DATE#'' AND (BILL.DATE > END.DATE) THEN
         CALL ELINE('Cannot Audit Bill!  Bill Date is out of range of Effective dates')
         CC+=1
         AUDIT='U'
         MISROUTE=1
         GOSUB 8000
         GO 590
      END
***************************************************************
* Check to See if Effective Date is Enabled or Disabled
***************************************************************
      IF DAUDIT<FBA.EFF.DATE.STATUS,GUIDE.POS,DT.POS> = 'DISABLE' THEN
         CALL ELINE("Cannot Audit! Effective Date is set to DISABLE")
         CC+=1
         AUDIT='U'
         MISROUTE=1
         GOSUB 8000
         GO 590
      END

      AUDIT.ZIPS.ID=CARRIER:"*":LOOKUP.ZIP:"*":EFF.DATE:"*TLALL*":IN.OUT:"*":SEL.EQUIP.TYPE
      READ DAUDIT.ZIPS FROM F.AUDIT.ZIPS,AUDIT.ZIPS.ID ELSE
         IF 1 AND IN.OUT = 'T' THEN
            AUDIT.ZIPS.ID=CARRIER:"*":LOOKUP.ZIP:"*":EFF.DATE:"*TLALL*":"I*":SEL.EQUIP.TYPE
            READ DAUDIT.ZIPS FROM F.AUDIT.ZIPS,AUDIT.ZIPS.ID ELSE
               CALL ELINE("Cannot Audit! Zip Table Not On File ":AUDIT.ZIPS.ID)
               CC+=1
               AUDIT='U'
               MISROUTE=1
               GOSUB 8000
               GO 590
            END
         END ELSE
            IF IN.OUT = 'T' THEN
               CALL ELINE("Cannot Audit! Third Party Setup date has passed and Zip Table Not On File ":AUDIT.ZIPS.ID)
               CC+=1
            END ELSE
               CALL ELINE("Cannot Audit! Zip Table Not On File ":AUDIT.ZIPS.ID)
               CC+=1
            END
            CC+=1
            AUDIT='U'
            MISROUTE=1
            GOSUB 8000
            GO 590
         END
      END
      IF DAUDIT.ZIPS<2,1>='' THEN
         CALL ELINE('Cannot Audit! Shipping Points have not been setup!')
         CC+=1
         AUDIT='U'
         MISROUTE=1
         GOSUB 8000
         GO 590
      END
      IF SHIP.ZIP < DAUDIT.ZIPS<2,1> THEN
         CALL ELINE('Cannot Audit!  This bill is a misroute! (Shipping Point is < Lowest)')
         CC+=1
         AUDIT='U'
         MISROUTE=1
         GOSUB 8000
         GO 590
      END
      LOCATE SHIP.ZIP IN DAUDIT.ZIPS<2> BY 'AR' SETTING SHIP.POS ELSE
         SHIP.POS=SHIP.POS-1
         IF SHIP.POS < 1 THEN
            CALL ELINE('Serious error, SHIP.POS is less than 1, Call Owen')
            CC+=1
            GO 525
         END
         IF SHIP.ZIP > DAUDIT.ZIPS<3,SHIP.POS> THEN
            CALL ELINE('Cannot Audit!  This bill is a misroute! (Shipping Point is > Highest)')
            CC+=1
            AUDIT='U'
            MISROUTE=1
            GOSUB 8000
            GO 590
         END
      END
      GOOD.SHIP.POINT=DAUDIT.ZIPS<4,SHIP.POS>
      CONTR.PER.MILE = DAUDIT.ZIPS<9,SHIP.POS>
      BENCH.PER.MILE = DAUDIT.ZIPS<10,SHIP.POS>
      CONTR.MIN = DAUDIT.ZIPS<11,SHIP.POS>
      BENCH.MIN = DAUDIT.ZIPS<12,SHIP.POS>
*IF OWEN THEN CALL ELINE('NOW CHECKING MISROUTES')
      IF GOOD.SHIP.POINT#'Y' THEN
         IF CONTR.PER.MILE#'' AND BENCH.PER.MILE # '' THEN
            MISROUTE=1
*DF         GO 525 ; * GO TO 525 anyway Misroute or Not!
         END ELSE
* Bill is a misroute but CANNOT be audited (No Table #)
            CALL ELINE('Cannot Audit! This bill is a misroute (Shp.Pnt=N No Table to Rate Bill)')
            CC+=1
            AUDIT='U'
            MISROUTE=1
            GOSUB 8000
            GO 590
         END
      END

      WHY=''
      WHY:=@(0,02):@(-3):'Origin : ':ORIG.ZIP:' ':ORIG.CITY:', ':ORIG.STATE:NULL
      WHY:=@(0,03):'Dest   : ':DEST.ZIP:' ':DEST.CITY:', ':DEST.STATE:NULL
      WHY:=@(0,04):'Mileage: ':MILEAGE:NULL
      CONTR.STRING='|':STR('-',34):'|'
      L.CONTR.STRING=LEN(CONTR.STRING)
      CONTR.WORDS="Contr Per Mile-":CONTR.PER.MILE'L26#6'
      L.CONTR.PER.MILE=LEN(CONTR.WORDS)
      CONTR.START=INT((L.CONTR.STRING-L.CONTR.PER.MILE)/2)
      CONTR.STRING[CONTR.START+1,L.CONTR.PER.MILE]=CONTR.WORDS
      WHY:=@(7,5):CONTR.STRING:NULL
      IF LOGISTICS THEN
         BENCH.STRING='|':STR('-',33):'|'
         L.BENCH.STRING=LEN(BENCH.STRING)
         BENCH.WORDS="Bench Per Mile-":BENCH.PER.MILE'L26#6'
         L.BENCH.PER.MILE=LEN(BENCH.WORDS)
         BENCH.START=INT((L.BENCH.STRING-L.BENCH.PER.MILE)/2)
         BENCH.STRING[BENCH.START+1,L.BENCH.PER.MILE]=BENCH.WORDS
         WHY:=@(45,5):BENCH.STRING:NULL
      END


************************************************************************
* Get Freight Bill Details (Class & Weights) of each line item
************************************************************************
*CALL ELINE('PRESS BREAK AT ???  (START OF LINE ITEM ENTRY)')
590: *** Just Enter The Data for Misroutes
      MC.SEL = 0
      PRINT @(41+OFFSET,LINE):Q'R(#5 )'

*
* Start input
*
* Display Data
*
      FOR X=1 TO 6
         LINE=REM(X,3)
         IF LINE=0 THEN LINE=3
         LINE=LINE+18
         IF X < 4 THEN OFFSET=0 ELSE OFFSET=23
         IF MISC.CHG<1,X>='' OR OPT='V' THEN
            IF OPT='V' THEN
               PRINT @(37+OFFSET,LINE):SPACE(18):
            END ELSE
               PRINT @(37+OFFSET,LINE):SPACE(18):
            END
         END ELSE
            PRINT @(37+OFFSET,LINE):MISC.CHG<1,X>'R(#4 )':   ; * Charge Code
            PRINT @(42+OFFSET,LINE):MISC.CHG<2,X>'R26(#6 )':           ; *Contr Amount
            PRINT @(49+OFFSET,LINE):MISC.CHG<3,X>'R26(#6 )':           ; *Bench Amount
         END
      NEXT X
*
700: *** Get Line Number for Misc Charge Entry
*
      IF MC.MODE='INPUT' THEN
         MC.SEL=MC.SEL+1
         QI=MC.SEL
         IF MC.SEL GT 6 THEN
            MC.MODE='EDIT'
            GO 800
         END
      END ELSE
         HELP="Enter Misc Charge Line Number, <RETURN>=Done, 'X'=Back, 'EX'=Exit."
         CALL GEN.IN(0,22,'Enter Misc Charge line number. ##','',Q,0,2,'','',
0        ,-2,22,0,QI,HELP,0,23)
         CC+=LEN(QI)+1
      END
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI=''
            GO 800                       ; *** Done with Line Items
         CASE QI='X'
            GO 400
         CASE QI='EX'
            X.EX.FLAG='EX'
            GO 9000
         CASE NUM(QI)
            IF INQUIRE THEN
               CALL ELINE('Can not access detail in inquiry!')
               CC+=1
            END ELSE
               IF QI > 1 THEN
                  IF MISC.CHG<1,QI-1>='' THEN
                     CALL ELINE("Cannot Skip a line.  You must select the next blank line")
                     CC+=1
                     GO 700
                  END
               END
               IF QI > 6 THEN
                  CALL ELINE("Maximum line number is 6")
                  CC+=1
                  GO 700
               END
               MC.SEL=QI
               GOSUB 720
               IF QI='X' AND MC.SEL=1 THEN GO 800
               IF OPT='V' & QI='' THEN GO 800      ; ** Done with Line Items
            END
      END CASE
      GO 700
*
* Enter Line Item Code
*
720: *** Get Charge Code, Contract Amount, & Benchmark Amount
      IF MC.SEL LT 1 ! MC.SEL GT 6 THEN
         CALL ELINE('Invalid entry.')
         CC+=1
         RETURN
      END
      LINE=REM(MC.SEL,3)
      IF LINE=0 THEN LINE=3
      IF MC.SEL < 4 THEN OFFSET=0 ELSE OFFSET=23
      LINE=LINE+18
*
740: *** Enter the Misc Charge Code
*
      HELP="Enter the Misc Charge Code ''=ACCEPT 'X'=Back 'EX'=Exit"
      IF OPT='V' THEN MASK=SPACE(4) ELSE MASK=MISC.CHG<1,MC.SEL>'L#4'
      IF MC.MODE='EDIT' AND MISC.CHG<1,MC.SEL>='' THEN MC.MODE='INPUT'
      CHOICE.STR=''
      MAX.CHOICE=DCOUNT(DAUDIT<19>,@VM)
      FOR X=1 TO MAX.CHOICE
         CHOICE.STR:=" ":X:"=":DAUDIT<19,X>
      NEXT X
      BEGIN CASE
         CASE MAX.CHOICE=1
            CRT @(0,22):@(-4):("Choices:":CHOICE.STR)[1,79]
         CASE MAX.CHOICE>1
            CRT @(0,22):@(-4):("Choices: 1-":MAX.CHOICE:CHOICE.STR)[1,79]
         CASE 1
            NULL
      END CASE
      CALL GEN.IN(37+OFFSET,LINE,MASK,'',Q,0,4,'','',2,-4,LINE,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      CRT @(0,22):@(-4):
      QI=OCONV(QI,'MCU')
      IF QI#'' AND QI MATCHES '0N' THEN
         IF QI > 0 AND QI LE MAX.CHOICE THEN
            Q=DAUDIT<19,QI>
            QI=DAUDIT<19,QI>
            IF QI='' THEN
               CALL ELINE("Invalid Choice")
               CC+=1
               GO 740
            END
            CRT @(37+OFFSET,LINE):QI:
         END
      END
      BEGIN CASE
         CASE QI='' & OPT NE 'V'
            Q=MISC.CHG<1,MC.SEL>
            IF Q='' THEN
               MC.SEL=MC.SEL-1
               RETURN TO 800
            END
         CASE QI='X'
            CRT @(37+OFFSET,LINE):MISC.CHG<1,MC.SEL>'L(#4 )'
            IF MC.SEL=1 THEN
               MC.SEL=MC.SEL-1
               RETURN TO 400
            END ELSE
               MC.SEL=MC.SEL-1
               LINE=REM(MC.SEL,3)
               IF LINE=0 THEN LINE=3
               IF MC.SEL < 4 THEN OFFSET=0 ELSE OFFSET=23
               LINE=LINE+18
               GO 720                    ; * Previous Code Line
            END
         CASE QI='EX'
            X.EX.FLAG='EX'
            RETURN TO 9000
         CASE QI='-'
            IF MISC.CHG<1,MC.SEL+1>#'' THEN
               CALL ELINE('CAN NOT DELETE THIS LINE')
               CC+=1
            END ELSE
               DEL MISC.CHG<1,MC.SEL>
               DEL MISC.CHG<2,MC.SEL>
               DEL MISC.CHG<3,MC.SEL>
               CRT @(37+OFFSET,LINE):'''L(#18)'
               GO 740
            END
      END CASE
      LOCATE Q IN DAUDIT<19> SETTING POS ELSE
         CALL ELINE("Invalid Code - Code not in Setup:  ":AUDIT.ID)
         CC+=1
         GO 740
      END
      CUR.CONTR.MISC.AMT=DAUDIT<20,POS>
      CUR.BENCH.MISC.AMT=DAUDIT<21,POS>
      IF LOGISTICS AND CUR.BENCH.MISC.AMT<CUR.CONTR.MISC.AMT THEN
         CALL ELINE("Unable to Use this code! Benchmark is Less that Contract")
         CC+=1
         GO 740
      END
      MISC.CHG<1,MC.SEL>=Q
      CRT @(37+OFFSET,LINE):MISC.CHG<1,MC.SEL>'L(#4 )'
      IF CUR.CONTR.MISC.AMT='ASK' THEN GO 760      ; * Get Contract Amount
      IF CUR.BENCH.MISC.AMT='ASK' THEN GO 780      ; * Get Benchmark Amount
      MISC.CHG<2,MC.SEL>=CUR.CONTR.MISC.AMT
      MISC.CHG<3,MC.SEL>=CUR.BENCH.MISC.AMT
      CRT @(37+OFFSET,LINE):MISC.CHG<1,MC.SEL>'L(#4 )'
      CRT @(42+OFFSET,LINE):CUR.CONTR.MISC.AMT'R26(#6 )'
      CRT @(49+OFFSET,LINE):CUR.BENCH.MISC.AMT'R26(#6 )'
      RETURN                             ; * Go Get Next Code
*
760: *** Enter the Misc Charge Contract Amount
*
      HELP="Enter Contract (Carrier) Amount for this code ''=ACCEPT 'X'=Back 'EX'=Exit"
      IF OPT='V' THEN MASK=SPACE(6) ELSE MASK=MISC.CHG<2,MC.SEL>'R26#6'
      CALL GEN.IN(42+OFFSET,LINE,MASK,'AMT2',Q,0,6,'','',2,-6,LINE,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='' & OPT NE 'V'
            Q=MISC.CHG<2,MC.SEL>
            IF Q='' THEN
               CALL ELINE("Entry is required")
               CC+=1
               GO 760
            END
         CASE QI='X'
            CRT @(42+OFFSET,LINE):MISC.CHG<2,MC.SEL>'R26(#6 )'
            GO 740
         CASE QI='EX'
            X.EX.FLAG='EX'
            RETURN TO 9000
         CASE NOT(NUM(QI))
            CALL ELINE("Must be Numeric")
            CC+=1
            GO 760
         CASE Q < 1 OR Q > 99999
            CALL ELINE("Must be Greater than 0 and less than 1000.00")
            CC+=1
            GO 760
      END CASE
      MISC.CHG<2,MC.SEL>=Q
      PRINT @(42+OFFSET,LINE):Q'R26(#6 )'
      IF LOGISTICS ELSE RETURN
*
780: *** Enter the Misc Charge Benchmark Amount
*
      HELP="Enter Benchmark (Logistics) Amount for this code ''=ACCEPT 'X'=Back 'EX'=Exit"
      IF MISC.CHG<3,MC.SEL>='' THEN MISC.CHG<3,MC.SEL>=MISC.CHG<2,MC.SEL>        ; * Default to Contr
      IF OPT='V' THEN MASK=SPACE(6) ELSE MASK=MISC.CHG<3,MC.SEL>'R26#6'
      CALL GEN.IN(49+OFFSET,LINE,MASK,'AMT2',Q,0,6,'','',2,-6,LINE,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI=OCONV(QI,'MCU')
      BEGIN CASE
         CASE QI='' & OPT NE 'V'
            Q=MISC.CHG<3,MC.SEL>
            IF Q='' THEN
               CALL ELINE("Entry is required")
               CC+=1
               GO 780
            END
         CASE QI='X'
            CRT @(49+OFFSET,LINE):MISC.CHG<3,MC.SEL>'R26(#6 )'
            GO 760
         CASE QI='EX'
            X.EX.FLAG='EX'
            RETURN TO 9000
         CASE NOT(NUM(QI))
            CALL ELINE("Must be Numeric")
            CC+=1
            GO 780
         CASE Q < 1 OR Q > 99999
            CALL ELINE("Must be Greater than 0 and less than 1000.00")
            CC+=1
            GO 780
         CASE Q < MISC.CHG<2,MC.SEL>     ; * Less than Contract
            CALL ELINE("Cannot Be Less than Contract Amount!")
            CC+=1
            GO 780
      END CASE
      MISC.CHG<3,MC.SEL>=Q
      PRINT @(49+OFFSET,LINE):Q'R26(#6 )'
      RETURN




************************************************************************
* End of Details
************************************************************************
      CC+=1
800: *** Get the Weight of the Shipment
      HELP="Enter the Total Weight of the shipment"
      MASK=TOT.WEIGHT'R#6'
      CALL GEN.IN(1,19,MASK,'',Q,0,6,'R','',2,1,19,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI = OCONV(QI,'MCU')
      IF QI='' THEN QI=MASK
      IF QI='X' THEN
         IF MC.SEL > 14 THEN MC.MODE='EDIT'
         CRT @(1,19):TOT.WEIGHT'R#6'
         GO 700
      END
      IF QI='EX' THEN
         X.EX.FLAG='EX'
         GO 9000
      END
      BEGIN CASE
         CASE NOT(NUM(QI))
            CALL ELINE('Must be a whole number greater than 0')
            CC+=1
            GO 800
         CASE QI < 1 OR INT(QI)#QI
            CALL ELINE('Must be a whole number greater than 0')
            CC+=1
            GO 800
      END CASE
      TOT.WEIGHT=QI
      PRINT @(1,19):TOT.WEIGHT'R#6':
      IF AUDIT='U' THEN
*      Have all the important information at this point.... EXIT PROGRAM
         GO 9000
      END
      POINT.TO.POINT = 0
      NUM.ZIPS = DCOUNT(ZIP.ARR<1>,@VM)
      IF NUM.ZIPS LE 2 THEN
         PP.ID = '"':CARRIER'R%5':'*':TRIM(ORIG.CITY):'*':TRIM(ORIG.STATE):'*':TRIM(DEST.CITY):'*':TRIM(DEST.STATE):'*':SEL.EQUIP.TYPE:'"'
         PP.ID = OCONV(PP.ID,'MCU')
         READ PP.REC FROM F.PTP,PP.ID ELSE PP.REC = ''
         IF PP.REC # '' THEN
            PP.BEG.EFF.DATES = PP.REC<1>
            PP.END.EFF.DATES = PP.REC<2>
            PP.EFF.DATE.STATUS = PP.REC<5>
            LOCATE BILL.DATE IN PP.BEG.EFF.DATES BY 'AR' SETTING PP.DT.POS ELSE
               PP.DT.POS=PP.DT.POS-1
               IF PP.DT.POS < 1 THEN
                  GO 850
               END
            END
            PP.EFF.DATE=PP.BEG.EFF.DATES<1,PP.DT.POS>
            PP.END.DATE=PP.END.EFF.DATES<1,PP.DT.POS>
            IF PP.END.DATE#'' AND (BILL.DATE > PP.END.DATE) THEN
               GO 850
            END
***************************************************************
* Check to See if Effective Date is Enabled or Disabled
***************************************************************
            IF PP.EFF.DATE.STATUS<1,PP.DT.POS> = 'DISABLE' THEN
               GO 850
            END
            TOT.CONTR.AMT = PP.REC<3,PP.DT.POS>
            TOT.BENCH.AMT = PP.REC<4,PP.DT.POS>
            POINT.TO.POINT = 1
            GO 1225
         END
      END

850: **Calculate Totals

      CONTR.ABS.MIN=0                    ; * Contract Absolute Minimum Flag
      BENCH.ABS.MIN=0                    ; * Benchmark Absolute Minimum Flag

      TOT.CONTR.AMT = 0
      IF CONTR.PER.MILE # '' THEN
         TOT.CONTR.AMT = OCONV(CONTR.PER.MILE * MILEAGE,'MR0')
         WHY:=@(3,6):"CONTRACT FREIGHT AMT":NULL
         WHY:=@(35,6):TOT.CONTR.AMT'R26#8':NULL
      END
      IF LOGISTICS THEN
         IF BENCH.PER.MILE # '' THEN
            TOT.BENCH.AMT = OCONV(BENCH.PER.MILE * MILEAGE,'MR0')
            WHY:=@(45,6):"BENCHMARK FREIGHT AMT":NULL
            WHY:=@(73,6):TOT.BENCH.AMT'R26#7':NULL
         END
      END

      IF TOT.CONTR.AMT < CONTR.MIN THEN
         TOT.CONTR.AMT = CONTR.MIN
         CONTR.ABS.MIN = 1
      END
      IF LOGISTICS THEN
         IF TOT.BENCH.AMT < BENCH.MIN THEN
            TOT.BENCH.AMT = BENCH.MIN
            BENCH.ABS.MIN = 1
         END
      END
      WHY.LINE = ''
      IF CONTR.ABS.MIN OR BENCH.ABS.MIN THEN
         WHY.LINE+=1
         IF CONTR.ABS.MIN THEN
            WHY:=@(3,6):"CONTRACT MINIMUM":NULL
            WHY:=@(35,6):TOT.CONTR.AMT'R26#8':NULL
         END
         IF BENCH.ABS.MIN THEN
            WHY:=@(45,6):"BENCHMARK MINIMUM":NULL
            WHY:=@(73,6):TOT.BENCH.AMT'R26#7':NULL
         END
      END
      WHY.LINE = 6


*******************************************************************
1225: * Fuel Surcharge Calculations
*******************************************************************
*DF     FSC.PERC=0
*DF     FSC.PER.MILE=0
*DF     FSC.MIN=0
*DF     IF DFSC='' THEN GO 1250
*DF     FIRST.DATE=DFSC<2,1>
*DF     IF BILL.DATE < FIRST.DATE THEN GO 1250
*DF     LAST.DATE=DFSC<3,DCOUNT(DFSC<3>,@VM)>
*DF     IF LAST.DATE#'' AND (BILL.DATE > LAST.DATE) THEN GO 1250
*DF     LOCATE BILL.DATE IN DFSC<2> BY 'AR' SETTING FS.POS ELSE
*DF       FS.POS=FS.POS-1
*DF       IF FS.POS < 1 THEN
*DF         CALL ELINE('Serious error FSC Date Date POS is less than 1, Call Owen')
*DF         CC+=1
*DF         GO 1225
*DF       END
*DF     END
*DF     CONTR.FSC.MIN = 0
*DF     BENCH.FSC.MIN = 0
*DF     FSC.BEG.DATE=DFSC<2,FS.POS>
*DF     FSC.END.DATE=DFSC<3,FS.POS>
*DF     IF FSC.END.DATE#'' AND (BILL.DATE > FSC.END.DATE) THEN GO 1250
*DF     FSC.PERC=DFSC<7,FS.POS>
*DF     FSC.PER.MILE=DFSC<8,FS.POS>
*DF     FSC.MIN=DFSC<9,FS.POS>
*     IF USER='MKERBOW' THEN DEBUG
      CALC.FSC = 0
      CONTR.FSC.MIN = 0
      BENCH.FSC.MIN = 0
      CONTR.FSC.AMT=0
      BENCH.FSC.AMT=0
1250: *** Have FSC.PERC Calculate Charge
      IF BENCH.DFSC='' OR CONTR.DFSC='' THEN
         CONTR.FSC.AMT=0
         BENCH.FSC.AMT=0
         GO 1275
      END
      VIN=BILL.DATE
      VIN<2>=TOT.WEIGHT
*     VIN<3>=MILES ; * Dont have miles at this point
      VIN<3>=MILEAGE                     ; * JMK02
      VIN<5>=CC
      VIN<6>=TOT.CONTR.AMT
      VIN<7>=ORIG.STATE                  ; * Special for Xpedx & AFS
      VIN<8>=DEST.STATE                  ; * Special for AFS
      CALL CALC.FSC(VIN,VOUT,CONTR.DFSC,F.TABLES)
      CONTR.FSC.AMT=VOUT<1>
      CONTR.FSC.MIN=VOUT<2>
      CONTR.FSC.PERC=VOUT<3>
      CALC.FSC=VOUT<1>
      IF LOGISTICS THEN
         VIN=BILL.DATE
         VIN<2>=TOT.WEIGHT
*        VIN<3>=MILES ; * Dont have miles at this point
         VIN<3>=MILEAGE                  ; * JMK999
         VIN<5>=CC
         VIN<6>=TOT.BENCH.AMT
         VIN<7>=ORIG.STATE               ; * Special for Xpedx & AFS
         VIN<8>=DEST.STATE               ; * Special for AFS
         CALL CALC.FSC(VIN,VOUT,BENCH.DFSC,F.TABLES)
         BENCH.FSC.AMT=VOUT<1>
         BENCH.FSC.MIN=VOUT<2>
         BENCH.FSC.PERC=VOUT<3>
         IF NO.LOG.FSC THEN BENCH.FSC.AMT=0        ; * Set to Zero
      END
*DF     IF FSC.PERC # '' AND FSC.PERC # 0 THEN
*DF       CONTR.FSC.AMT=OCONV(TOT.CONTR.AMT*FSC.PERC/10000,'MR0')
*DF       IF LOGISTICS THEN
*DF         BENCH.FSC.AMT=OCONV(TOT.BENCH.AMT*FSC.PERC/10000,'MR0')
*DF       END
*DF     END ELSE
*DF       IF FSC.PER.MILE # '' AND FSC.PER.MILE # 0 THEN
*DF         CONTR.FSC.AMT=MILEAGE * FSC.PER.MILE
*DF         IF LOGISTICS THEN
*DF           BENCH.FSC.AMT = CONTR.FSC.AMT
*DF         END
*DF       END ELSE
*DF         CONTR.FSC.AMT = 0
*DF         IF LOGISTICS THEN BENCH.FSC.AMT = 0
*DF       END
*DF     END
*DF     IF CONTR.FSC.AMT LT FSC.MIN THEN
*DF       CONTR.FSC.AMT = FSC.MIN
*DF       CONTR.FSC.MIN = 1
*DF     END
*DF     IF LOGISTICS THEN
*DF       IF BENCH.FSC.AMT LT FSC.MIN THEN
*DF         BENCH.FSC.AMT = FSC.MIN
*DF         BENCH.FSC.MIN = 1
*DF       END
*DF       IF NO.LOG.FSC THEN BENCH.FSC.AMT=0 ; * Set to Zero
*DF     END
      IF CONTR.FSC.PERC#0 THEN
         WHY.LINE+=1
         IF CONTR.FSC.MIN THEN
            WHY:=@(3,WHY.LINE):'Fuel Sur Charge Min':NULL
         END ELSE
*DF         WHY:=@(3,WHY.LINE):CONTR.FSC.PERC'R26':'% Fuel Sur Charge':NULL
            WHY:=@(3,WHY.LINE):CONTR.FSC.PERC'R17':'% Fuel Sur Charge':NULL
         END
         WHY:=@(35,WHY.LINE):CONTR.FSC.AMT'R26#8':NULL
         IF LOGISTICS THEN
            BEGIN CASE
               CASE NO.LOG.FSC
*DF           WHY:=@(45,WHY.LINE):BENCH.FSC.PERC'R26':'Logistics FSC = N':NULL
                  WHY:=@(45,WHY.LINE):BENCH.FSC.PERC'R17':'Logistics FSC = N':NULL
               CASE BENCH.FSC.MIN
                  WHY:=@(45,WHY.LINE):'Fuel Sur Charge Min':NULL
               CASE 1
*DF           WHY:=@(45,WHY.LINE):BENCH.FSC.PERC'R26':'% Fuel Sur Charge':NULL
                  WHY:=@(45,WHY.LINE):BENCH.FSC.PERC'R17':'% Fuel Sur Charge':NULL
            END CASE
            WHY:=@(73,WHY.LINE):BENCH.FSC.AMT'R26#7':NULL
         END
      END
*******************************************************************
1275: * Assessorial Charge Calculations
*******************************************************************
      TOT.CONTR.MISC.CHG=0
      TOT.BENCH.MISC.CHG=0
      MISC.CHG.TIMES=DCOUNT(MISC.CHG<1>,@VM)
      FOR MISC.CHG.COUNT=1 TO MISC.CHG.TIMES
         WHY.LINE+=1
         CUR.MISC.CHG.CODE=MISC.CHG<1,MISC.CHG.COUNT>
         LOCATE CUR.MISC.CHG.CODE IN AVAL.ACC.CODES<1> SETTING POS THEN
            CUR.MISC.CHG.DESC=AVAL.ACC.CODES<2,POS>
         END ELSE
            CUR.MISC.CHG.DESC='Not On File'
         END
         CUR.CONTR.MISC.CHG=MISC.CHG<2,MISC.CHG.COUNT>
         LEN.CHG=LEN(CUR.CONTR.MISC.CHG)
         IF CUR.CONTR.MISC.CHG[LEN.CHG,1]='%' THEN
            PERC=CUR.CONTR.MISC.CHG[1,LEN.CHG-1]
            CUR.CONTR.MISC.CHG=OCONV(TOT.CONTR.AMT*PERC/100,'MR0')
         END
         TOT.CONTR.MISC.CHG+=CUR.CONTR.MISC.CHG
         IF LOGISTICS THEN
            CUR.BENCH.MISC.CHG=MISC.CHG<3,MISC.CHG.COUNT>
            IF CUR.BENCH.MISC.CHG[LEN.CHG,1]='%' THEN
               PERC=CUR.BENCH.MISC.CHG[1,LEN.CHG-1]
               CUR.BENCH.MISC.CHG=OCONV(TOT.BENCH.AMT*PERC/100,'MR0')
            END
            TOT.BENCH.MISC.CHG+=CUR.BENCH.MISC.CHG
         END
         WHY:=@(03,WHY.LINE):CUR.MISC.CHG.CODE'L(#4- )':CUR.MISC.CHG.DESC
         WHY:=@(35,WHY.LINE):CUR.CONTR.MISC.CHG'R26#8'
         IF LOGISTICS THEN
            WHY:=@(45,WHY.LINE):CUR.MISC.CHG.CODE'L(#4- )':CUR.MISC.CHG.DESC
            WHY:=@(73,WHY.LINE):CUR.BENCH.MISC.CHG'R26#7'
         END
      NEXT MISC.CHG.COUNT
*******************************************************************
* Print Grand Totals
*******************************************************************
*CRT @(0,14):'Press Break for Total Discount Calculation': ; INPUT NUL:
      GTOT.CONTR.AMT=TOT.CONTR.AMT+CONTR.FSC.AMT+TOT.CONTR.MISC.CHG
      IF LOGISTICS THEN
         GTOT.BENCH.AMT=TOT.BENCH.AMT+BENCH.FSC.AMT+TOT.BENCH.MISC.CHG
      END
*********************************************************
* Adjust Benchmark Amount if Less than Contract Amount
*********************************************************
      IF LOGISTICS AND GTOT.BENCH.AMT < GTOT.CONTR.AMT THEN
         GTOT.BENCH.AMT=GTOT.CONTR.AMT
         WHY.LINE+=1
         WHY:=@(45,WHY.LINE):"ADJ! Less than Contract Amt":NULL
         WHY:=@(73,WHY.LINE):GTOT.BENCH.AMT'R26#7':NULL
      END
      WHY.LINE+=1
      WHY:=@(3,WHY.LINE):'CONTRACT TOTAL':NULL
      WHY:=@(35,WHY.LINE):GTOT.CONTR.AMT'R26#8':NULL
      IF LOGISTICS THEN
         WHY:=@(45,WHY.LINE):'BENCHMARK TOTAL':NULL
         WHY:=@(73,WHY.LINE):GTOT.BENCH.AMT'R26#7':NULL
      END
      IF LOGISTICS THEN
         WHY.LINE+=2
         WHY:=@(3,WHY.LINE):"Logistics Amount: ":NULL
         WHY:=@(35,WHY.LINE):(GTOT.BENCH.AMT-GTOT.CONTR.AMT)'R26,#8':NULL
      END
*******************************************************************
      FIRST.TIME=1
1300: *** Get Carrier Charge Amount
      IF FIRST.TIME THEN
         HELP="Enter Carrier Charge (Amount To Be Paid on Freight Bill)"
      END ELSE
         HELP="Re-Enter Carrier Charge (Amount To Be Paid on Freight Bill)"
      END
      IF AMT.ON.BILL='' THEN REQ=1 ELSE REQ =0
      MASK=AMT.ON.BILL
      IF MASK#'' THEN MASK=MASK'R26#8'
      CALL GEN.IN(16,19,MASK,'AMT2',Q,REQ,8,'','',2,16,19,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI = OCONV(QI,'MCU')
      IF QI='X' THEN
         CRT @(16,19):AMT.ON.BILL'R26#8'
         GO 800
      END
      IF QI='EX' THEN
         X.EX.FLAG='EX'
         GO 9000
      END
      IF Q='' THEN Q=AMT.ON.BILL ; QI=AMT.ON.BILL
      IF NOT(NUM(QI)) THEN
         CALL ELINE('Must be a number 0 or greater')
         CC+=1
         GO 1300
      END
      IF QI < 0 THEN
         CALL ELINE('Must be a number 0 or greater')
         CC+=1
         GO 1300
      END
      IF QI = '0' THEN
         AUDIT='U'
         GOSUB 8000
         GOTO 9000
      END
      IF USER.TYPE='A' THEN
         IF Q > ORIG.AMT.ON.BILL THEN
            CALL ELINE('Amount must be equal or less than the amount keyed by freight payment')
            CC+=1
            GO 1300
         END
      END
      AMT.ON.BILL=Q
      PRINT @(16,19):AMT.ON.BILL'R26#8':
      IF FIRST.TIME THEN
         WHY.LINE +=1
         WHY:=@(3,WHY.LINE):"Amount on Bill : ":NULL
         WHY:=@(35,WHY.LINE):(AMT.ON.BILL)'R26#8':NULL
      END

1400: *** Compare Calculated Charges to Entered Charges to see if OK
*CRT @(0,22):"PRESS BREAK if you want to see the DIFFERENCE Routine": ; INPUT NUL: ; * Owen

      PERC.TOL =-DAUDIT<18,1>/10000
      MILES.TOL =-DAUDIT<18,2>/100
      MAX.TOL.AMT = 0
      TOL.AMT = 0

      IF PERC.TOL # 0 AND POINT.TO.POINT # 1 THEN
         MAX.TOL.AMT = TOT.CONTR.AMT * PERC.TOL
         IF FIRST.TIME THEN
            WHY.LINE+=1
            WHY:= @(3,WHY.LINE):"Maximum Tolerance Percentage : %":NULL
            WHY:=@(35,WHY.LINE):PERC.TOL'R26#8':NULL
         END
      END ELSE
         IF MILES.TOL # 0 AND POINT.TO.POINT # 1 THEN
            MAX.TOL.AMT = MILES.TOL*CONTR.PER.MILE
            IF FIRST.TIME THEN
               WHY.LINE+=1
               WHY:= @(3,WHY.LINE):"Maximum Tolerance Miles : ":NULL
               WHY:=@(35,WHY.LINE):(MILES.TOL)'R0#6':NULL
            END
         END
      END
      IF MAX.TOL.AMT # 0 THEN
         IF FIRST.TIME THEN
            WHY.LINE+=1
            WHY:= @(3,WHY.LINE):"Maximum Tolerance Amount: ":NULL
            WHY:=@(35,WHY.LINE):(MAX.TOL.AMT)'R26,#8':NULL
         END
      END
      DIFFERENCE = GTOT.CONTR.AMT-AMT.ON.BILL
      IF FIRST.TIME THEN
         WHY.LINE += 1
         WHY:=@(3,WHY.LINE):"Difference    : ":NULL
         WHY:=@(35,WHY.LINE):(DIFFERENCE)'R26#8':NULL
      END
      IF LOGISTICS THEN
         LOGISTICS.AMT=GTOT.BENCH.AMT-GTOT.CONTR.AMT
         IF LOGISTICS.AMT<0 THEN
            CALL ELINE("Error! Benchmark Amount is LESS than Contract Amount")
            CC+=1
            GO 1300
         END
      END ELSE
         LOGISTICS.AMT=0
      END
      LOGISTICS.AMT=LOGISTICS.AMT'R0'
      IF ABS(DIFFERENCE) < 2 THEN
         AMT.TO.PAY=AMT.ON.BILL
         OVERCHARGE.AMT=0
         GOTO 9000
      END
      IF FIRST.TIME ELSE
         IF SAVE.CHARGE # AMT.ON.BILL THEN
            FIRST.TIME=1
         END
      END
      IF FIRST.TIME THEN
         SAVE.CHARGE = AMT.ON.BILL
         AMT.ON.BILL = ''
         PRINT @(16,19):SPACE(8)
         FIRST.TIME=0
         CALL ELINE('Press Return To Re-Enter Carrier Charge')
         CC+=1
         GOTO 1300
      END ELSE
         IF AMT.ON.BILL = SAVE.CHARGE THEN
            IF DIFFERENCE> MAX.TOL.AMT THEN        ; * Were Going to Pay It
               AMT.TO.PAY=AMT.ON.BILL
               OVERCHARGE.AMT=0
               IF USER = 'JENNIFER' OR USER = 'KATHY' THEN GOSUB 8000
               GO 9000
            END
         END
      END

      CALL ELINE('Cannot Audit! Carrier Charge does not calculate')
      CC+=1
      AUDIT='U'
      GOSUB 8000
      IF QI#'' OR QI#'OK' THEN GOTO 9000
      FIRST.TIME=1
      GO 800
*
* Display Prompts
6000: *** Display screen
      CALL FB.CLEAR.WINDOW
      CRT @(34,6):"|":@(78,6):"|":
      CRT @(34,7):STR('-',45):
      CRT @(34,8):"  Zip Code":@(46):"City and State"
      CRT @(34,9):STR('-',45):
      STARTLINE=17
      FOR OFFSET= 0 TO 23 STEP 23
         CRT @(34+OFFSET,STARTLINE):'Ln':
         CRT @(34+OFFSET,STARTLINE+1):'--':
         CRT @(37+OFFSET,STARTLINE):'Code':
         CRT @(37+OFFSET,STARTLINE+1):'----':
         CRT @(42+OFFSET,STARTLINE):'Contr':
         CRT @(42+OFFSET,STARTLINE+1):'------':
         CRT @(49+OFFSET,STARTLINE):'Bench':
         CRT @(49+OFFSET,STARTLINE+1):'------':
      NEXT OFFSET
7000: *** Display Data on Audit Screen
*
* Display Data
*
      PRINT AUDIT.POS:EQUIP.TYPES<1,1>
      PRINT @(5,7):(BILL.DATE'D2/')'L#8':
      PRINT @(5,8):IN.OUT'L#2':
      IF ORIG.CITY # '' THEN
         DESC = ORIG.CITY:', ':ORIG.STATE
      END ELSE
         DESC = ORIG.STATE
      END
      CRT @(5,10):ORIG.ZIP'L#5':' ':DESC'L#20'
      IF DEST.CITY # '' THEN
         DESC = DEST.CITY:', ':DEST.STATE
      END ELSE
         DESC = DEST.STATE
      END
      CRT @(5,11):DEST.ZIP'L#5':' ':DESC'L#20'
      FOR X = 1 TO 6
         STARTLINE=REM(X,6)
         IF STARTLINE = 0 THEN STARTLINE = 6
         STARTLINE = STARTLINE+9
         IF OPT NE 'V' THEN
            IF ZIP.ARR<1,X> = '' THEN
               CRT @(34,STARTLINE):X:@(-4):
            END ELSE
               CRT @(34,STARTLINE):X:' ':ZIP.ARR<1,X>'L#5':
               IF ZIP.ARR<2,X> = '' AND ZIP.ARR<3,X> = '' THEN
                  CODE = ZIP.ARR<1,X>
                  ZIP.SEL = X
                  LINE = ZIP.SEL + 9
                  GO 8560
               END ELSE
                  CRT @(46,STARTLINE):ZIP.ARR<2,X>:' ':ZIP.ARR<3,X>:@(-4):
               END
            END
         END
      NEXT X

      FOR X=1 TO 6
         STARTLINE=REM(X,3)
         IF STARTLINE=0 THEN STARTLINE=3
         STARTLINE=STARTLINE+18
         IF X < 4 THEN OFFSET=0 ELSE OFFSET=23
         IF MISC.CHG<1,X>='' OR OPT='V' THEN
            IF OPT='V' THEN
               PRINT @(39+OFFSET,STARTLINE):SPACE(16):
            END ELSE
               PRINT @(34+OFFSET,STARTLINE):X'R%2':SPACE(17):
            END
         END ELSE
            PRINT @(34+OFFSET,STARTLINE):X'R(%2 )':          ; * Selection
            PRINT @(37+OFFSET,STARTLINE):MISC.CHG<1,X>'L(#4 )':        ; * Charge Code
            PRINT @(42+OFFSET,STARTLINE):MISC.CHG<2,X>'R26(#6 )':      ; *Contr Amount
            PRINT @(48+OFFSET,STARTLINE):MISC.CHG<3,X>'R26(#6 )':      ; *Bench Amount
         END
      NEXT X
      RETURN
8000: *** Exit program or Retry
      HELP = ''
      CALL GEN.IN(0,22,'Any key to Skip Bill or press [Enter] to enter AUDITED Amounts:   ','',Q,0,3,'','',3,-2,22,0,QI,HELP,0,23)
      CC+=LEN(QI)+1
      QI = OCONV(QI,'MCU')
      CRT @(0,22):@(-4):
      IF QI='.' OR QI='+' THEN QI='WHY'
      IF QI='WHY' AND INDEX('-DARLENE-OWEN-JENNIFER-DAVID-TERESA-CHARLIE-WAYNE-KATHY-BRIAN-SCOTT-',USER,1) THEN
         REDRAW.SCR='REDRAW'             ; ** Tell calling program to redraw screen
****************************************************************
* Controlled Screen Scroll
****************************************************************
         CRT @(0,23)
         PRINT
         PRINT
         PRINT WHY:
****************************************************************
         CRT @(0,23):"Press <Enter> to Continue: ":
         INPUT NUL:
         QI=''                           ; * Act as if null Was Entered
      END
      IF QI#'' AND QI#'OK' THEN          ; * Skip Bill
         AUDIT='S'
         RETURN TO 9000
      END
      IF LOGISTICS AND AUTO.MISROUTE ELSE
         AUDIT='U'
         RETURN TO 9000
      END
      RETURN
*----
8100:
*---- Display screen
*
      CALL AFS.SCR.REFRESH(PROG.NAME, PROG.DESC, PACK.NAME, CO.NAME,TIME.DATE, 1)
      CRT SCREEN.DSP
      CRT DATA.DSP
      RETURN

*
* Check for valid zip code
*
8560: IF CODE # '' THEN
         CITY='' ; STATE=''
         CALL FB.READ.ZIP( CODE, CITY, STATE )
         IF CITY='' THEN ACK='ERR' ; RETURN
         IF STATE='' OR CODE='99999' THEN
            BEGIN CASE
               CASE MAX.LEN=5 OR MAX.LEN=6
210:              HELP="Enter different city, state. ''=Accept. 'X'=Back. 'EX'=Stop."
                  MASK=CITY:', ':STATE
                  CALL GEN.IN(46,LINE,MASK'L#24','',Q,0,24,'','',2,-24,LINE,0,QI,HELP,0,23)
                  CC+=LEN(QI)+1
                  QI=OCONV(QI,'MCU')
                  BEGIN CASE
                     CASE QI='X'
                        CRT @(46,LINE):SPACE(24)
                        RETURN
                     CASE QI='EX'
                        STOP
                     CASE QI=''
                        Q=MASK
                  END CASE
                  X=0
                  X=INDEX(Q,',',1)
                  IF X THEN
                     CITY=FIELD(Q,',',1)
                     CITY=OCONV(CITY,'MCT')
                     STATE=FIELD(Q,',',2)
                     STATE=OCONV(STATE,'MCU')
                  END ELSE
                     CALL ELINE('Invalid entry.')
                     CC+=1
                     GOTO 210
                  END
*
               CASE MAX.LEN=3
                  HELP="Enter different state. ''=Accept. 'X'=Back. 'EX'=Stop."
                  CALL GEN.IN(46,LINE,STATE'L#2','',Q,0,2,'','',2,-2,LINE,0,QI,HELP,0,23)
                  CC+=LEN(QI)+1
                  QI=OCONV(QI,'MCU')
                  BEGIN CASE
                     CASE QI='X'
                        RETURN
                     CASE QI='EX'
                        STOP
                     CASE QI=''
                        Q=STATE
                  END CASE
            END CASE
         END
         CITY=TRIM(CITY)
         STATE=TRIM(STATE)
         ZIP.ARR<2,ZIP.SEL> = CITY
         ZIP.ARR<3,ZIP.SEL> = STATE
      END
      CRT @(46,LINE) : ZIP.ARR<2,ZIP.SEL> : ' ' : ZIP.ARR<3,ZIP.SEL>:@(-4):
      ACK = ''
*
      RETURN




9000: *** Return to calling Program
      IF NOT(TESTING) THEN CALL FB.CLEAR.WINDOW
      VOUT=''
      VOUT<1>=X.EX.FLAG
      VOUT<2>=AUDIT
      VOUT<3>=BILL.DATE
      VOUT<4>=TRANS.MODE
      VOUT<5>=PIECES
      VOUT<6>=TOT.WEIGHT
      VOUT<7>=AIR.MISC.CHARGE            ; * Not Used -> Passed Through
      IF AMT.TO.PAY='' THEN AMT.TO.PAY=AMT.ON.BILL
      VOUT<8>=AMT.TO.PAY
      VOUT<9>=AMT.TO.PAY+OVERCHARGE.AMT+LOGISTICS.AMT
      IF VOUT<9>=0 THEN VOUT<9>=''
      VOUT<10>=CARRIER
      VOUT<11>=CLIENT
      VOUT<12>=IN.OUT
      VOUT<13,1>=ORIG.ZIP
      VOUT<13,2>=ORIG.CITY
      VOUT<13,3>=ORIG.STATE
      VOUT<14,1>=DEST.ZIP
      VOUT<14,2>=DEST.CITY
      VOUT<14,3>=DEST.STATE
* Misroute flag may have to be expanded upon
      VOUT<17>=MISROUTE
      VOUT<20>=REDRAW.SCR                ; * Flag to tell calling program to redraw scr
      VOUT<25>=CC
      IF TESTING THEN
         CRT@(0,22):'TESTING Mode - Press <ENTER> to Continue: ':
         INPUT NUL:
      END
      VOUT<21>=MISC.CHG<1>
      VOUT<22>=MISC.CHG<2>
      VOUT<23>=MISC.CHG<3>
      VOUT<26>=LOGISTICS.AMT
      VOUT<27>=OVERCHARGE.AMT
      VOUT<28>=CUT.DESC
      VOUT<30>=''
      VOUT<31>=ZIP.ARR
      VOUT<32>=MILEAGE

*IF USER = 'TAMI' THEN CALL ELINE('RETURNING TO FB.2.1.MR')
      RETURN

PRINT.CARRIER.ADDRESS.LETTER:
      RVIN = ORIG.CARRIER
      RVIN<2> = CLIENT
      RVIN<3> = PRO.ID
      RVOUT=''
      CALL FB.2.1.CARRIER.LETTER(RVIN, RVOUT)
      RETURN
