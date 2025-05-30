      SUBROUTINE GET.FB.INFO(VIN,VOUT,CLIENT.REC,CARRIER.REC,PRO.REC,F.TABLES)
************************************************************************
* PROGRAM NAME : GET.FB.INFO 
 UPL.VIN = 'FBBP' ;  UPL.VIN<2> = 'GET.FB.INFO' ; UPL.VOUT = ''                    ;* NPR_UPL 04/23/2010
 CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)                                                           ;* NPR_UPL 04/23/2010

*
************************************************************************
* MAINTENANCE:
* 052008 - JMK01 - T081318 - problem with freight bill 13036*72655510*0
* 100308 - JMK02 - C082257 - Add description to the FB Details for the MISC code
* 072016 - GRB01 - SysAid 25914 - skip detail info for rejects
************************************************************************
      CRLF=CHAR(13):CHAR(10)
      PROG.NAME=VIN<1>
      PROG.DESC=VIN<2>
      PACK.NAME=VIN<3>
      CO.NAME=VIN<4>
      TIME.DATE=VIN<5>
      CLIENT.ID=VIN<6>
      CARRIER.ID=VIN<7>
      PRO.ID=VIN<8>
      PRO=FIELD(PRO.ID,'*',2)
      VERSION=FIELD(PRO.ID,'*',3)
      PRO.LEN = LEN(PRO)
      IF PRO[PRO.LEN-1,2] = 'BD' THEN
         BAL.DUE = 1
      END ELSE
         BAL.DUE = 0
      END
      READ REJECT.CODES FROM F.TABLES,'REJECT.CODES' ELSE REJECT.CODES=''
* SET VARIABLES FROM CLIENT
      CLIENT.NAME = CLIENT.REC<2>
      CLIENT.CITY = CLIENT.REC<4>
      CLIENT.STATE = CLIENT.REC<5>
      ZIP.LEN = CLIENT.REC<17>
      IF ZIP.LEN = 'C' THEN ZIP.DIGITS=6 ELSE ZIP.DIGITS=5
      ZIP.MASK='L#':ZIP.DIGITS
      IF CLIENT.REC<71>='' THEN
         AUDITOR.TEXT=''
      END ELSE
         AUDITOR.TEXT='Auditor: ':CLIENT.REC<71>
      END
      CL.VAR.DEF=CLIENT.REC<23>
* SET VARIABLES FROM CARRIER
      CARRIER.NAME = CARRIER.REC<1>
      CARRIER.STREET = TRIM(CHANGE(CARRIER.REC<2>,@VM,' '))
      CARRIER.CITY = CARRIER.REC<3>
      CARRIER.STATE = CARRIER.REC<4>
      XREF.CARRIERS = CARRIER.REC<28>
      CARRIER.MODE=CARRIER.REC<44>
      PRO.FORMAT=CARRIER.REC<47>
      CARRIER.MODE.WGT=CARRIER.REC<70>
      CARRIER.MODE.BY.WGT=CARRIER.REC<71>
* SET VARIABLES FROM FBILL
      NUM.OF.PRO=''
      TOT.NUM.OF.PRO=''
      BILL.DATE=PRO.REC<1>
      IN.OUT=PRO.REC<2>
      ORIG.ZIP=PRO.REC<3>
      DEST.ZIP=PRO.REC<4>
      EXP.CODE=PRO.REC<5>
      EXP.CODE.DESC=OCONV(EXP.CODE,'TEXPENSE.CODES,':CLIENT.ID:';X;;1')
      WEIGHT=PRO.REC<6>
      CARRIER.CHG=PRO.REC<7>
      ACTUAL.CHG=PRO.REC<8>
      VARIANCE=CARRIER.CHG-ACTUAL.CHG
      DIVISION=PRO.REC<9>
      VAR.ARR=''
      VAR.ARR<1>=-PRO.REC<10>
      VAR.ARR<2>=-PRO.REC<11>
      VAR.ARR<3>=-PRO.REC<12>
      VAR.ARR<7>=PRO.REC<41>
      VAR.ARR<8>=PRO.REC<42>
      VAR.ARR<9>=PRO.REC<43>
      BOL=PRO.REC<16>
      VC.ID=PRO.REC<17>
      VC.DESC=''                         ; * JMK01
      IF VC.ID#'' THEN                   ; * JMK01
         VC.DESC=OCONV(VC.ID,'TVEND.CUST,':CLIENT.ID:';X;;1')
      END                                ; * JMK01
      MILEAGE=PRO.REC<19>
      DISC.DET=''
      DISC.DET<1>=PRO.REC<22>
      DISC.DET<2>=PRO.REC<23>
      DISC.PERC=PRO.REC<24>
      ORIG.STATE=PRO.REC<25>
      DEST.STATE=PRO.REC<26>
      ORIG.CITY=PRO.REC<27>
      DEST.CITY=PRO.REC<28>
      ENTRY.DATE=PRO.REC<30>
      DUE.DATE=PRO.REC<38>
      REJECT.FLAG=PRO.REC<39>
      VERIFIED=PRO.REC<45>
      CLASS=''
      CLASS<1>=PRO.REC<50>
      CLASS<2>=PRO.REC<57>
      AIR.PIECES=PRO.REC<57>
      MISROUTE.AMOUNT=PRO.REC<63>
      MISROUTE.CARRIER=PRO.REC<69>
      CLASSES=PRO.REC<74>
      WEIGHTS=PRO.REC<75>
      INV.NUM=PRO.REC<94>
      DIM.WEIGHT=PRO.REC<106>
      FLAT.RATE=PRO.REC<119>
      ADDRESS.CORRECTION.CHARGE=PRO.REC<123>
      UPS.FEE.CHARGE=PRO.REC<124>
* INITIALIZE SCREEN
      SCREEN.TXT=''
      FOR LINES=1 TO 25
         SCREEN.TXT<LINES>=SPACE(80)
      NEXT LINES
*
*  CALCULATE DISPLAY POSTION OF COMPANY AND PACKAGE NAMES
*
      PROG.NAME.COL=(78-(LEN(PROG.NAME)))
      IF PROG.NAME.COL<78 THEN PROG.NAME.COL=PROG.NAME.COL+1
      PACK.COL=(78-(LEN(PACK.NAME)))
      IF PACK.COL<78 THEN PACK.COL=PACK.COL+1
      IF PROG.NAME='' & PROG.DESC='' & PACK.NAME='' THEN RETURN
      XPOS=0 ; YPOS=0 ; TXT=CO.NAME ; GOSUB INSERT.TXT
      XPOS=PROG.NAME.COL ; YPOS=0 ; TXT=PROG.NAME ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=1 ; TXT=PROG.DESC ; GOSUB INSERT.TXT
      XPOS=PACK.COL ; YPOS=1 ; TXT=PACK.NAME ; GOSUB INSERT.TXT
* BUILD SCREEN LABELS
      XPOS=0
      YPOS=3 ; TXT='Client : ' ; GOSUB INSERT.TXT
      YPOS=4 ; TXT='Carrier: ' ; GOSUB INSERT.TXT
      YPOS=5 ; TXT=STR('-',79) ; GOSUB INSERT.TXT
      YPOS=6 ; TXT='Pro..' ; GOSUB INSERT.TXT
      YPOS=7 ; TXT='Date.' ; GOSUB INSERT.TXT
      YPOS=8 ; TXT='IOT..' ; GOSUB INSERT.TXT
      YPOS=9 ; TXT='Div..' ; GOSUB INSERT.TXT
      YPOS=10 ; TXT='Orig.' ; GOSUB INSERT.TXT
      YPOS=11 ; TXT='Dest.' ; GOSUB INSERT.TXT
      YPOS=12 ; TXT='Exp..' ; GOSUB INSERT.TXT
      * Begin GRB01
   ****   YPOS=14 ; TXT='Clas.' ; GOSUB INSERT.TXT
  *****    YPOS=15 ; TXT='Mile.' ; GOSUB INSERT.TXT
    ****  YPOS=16 ; TXT='        Carrier   Actual         Misrouting Approved' ; GOSUB INSERT.TXT
   ****   YPOS=17 ; TXT='  Wght  Charges  Charges   Var    Charges    Carrier' ; GOSUB INSERT.TXT
   ****   YPOS=18 ; TXT=' ----- -------- -------- ------- ---------- --------' ; GOSUB INSERT.TXT
   ****   YPOS=20 ; TXT=' Dimensional Wgt' ; GOSUB INSERT.TXT
   * End GRB01
      IF CARRIER.ID='00015' OR CARRIER.ID='00143' OR CARRIER.ID='00365' THEN     ; * Federal Express
         XPOS=40 ; YPOS=6 ; TXT='Inv Num: ':INV.NUM'L#11' ; GOSUB INSERT.TXT
         XPOS=65 ; YPOS=6 ; TXT=NUM.OF.PRO'R#4':' of ':TOT.NUM.OF.PRO'R#4' ; GOSUB INSERT.TXT
      END
      IF CARRIER.ID='00041' OR CARRIER.ID='12810' OR CARRIER.ID='03042' THEN     ; * United Parcel Service
         XPOS=46 ; YPOS=6 ; TXT='UPS Addr Correc Chrg: ':ADDRESS.CORRECTION.CHARGE'R26,' ; GOSUB INSERT.TXT
         XPOS=46 ; YPOS=7 ; TXT='UPS Fees Charge     : ':UPS.FEE.CHARGE'R26,' ; GOSUB INSERT.TXT
      END
      IF BAL.DUE THEN XPOS=25 ; YPOS=16 ; TXT='Bal Due' ; GOSUB INSERT.TXT
* ADD DATA ELEMENTS
      XPOS=29 ; YPOS=1 ; TXT=AUDITOR.TEXT'L#25' ; GOSUB INSERT.TXT
      IF PRO.REC<116> #'' AND INDEX(TXT,'*',1) THEN
         OVERRIDE.RULES.COUNT = DCOUNT(PRO.REC<116>,@VM)
         OVERRIDE.RULES.TEXT = '*'
         FOR KM = 1 TO OVERRIDE.RULES.COUNT
            RULES.TEXT = PRO.REC<116,KM>:'_':PRO.REC<117,KM>:'_':PRO.REC<118,KM>:'__'
            OVERRIDE.RULES.TEXT := RULES.TEXT
         NEXT KM
         RULES.OUTPUT = 1
         XPOS=0 ; YPOS=2 ; TXT=OVERRIDE.RULES.TEXT[1,79] ; GOSUB INSERT.TXT
      END ELSE
         RULES.OUTPUT = 0
      END
      XPOS=9 ; YPOS=3 ; TXT=CLIENT.ID:' ':CLIENT.NAME ; GOSUB INSERT.TXT
      TEXT=CARRIER.ID:' ':CARRIER.NAME:' ':CARRIER.STREET:' ':CARRIER.CITY
      XPOS=9 ; YPOS=4 ; TXT=TEXT[1,70] ; GOSUB INSERT.TXT
      DISP=PRO
      IF VERSION#'' THEN
         DISP:=' Version ':VERSION
      END
      IF REJECT.FLAG='R' THEN DISP:=' (REJECTED)'
      XPOS=5 ; YPOS=6 ; TXT=DISP ; GOSUB INSERT.TXT
      IF CARRIER.ID='00015' OR CARRIER.ID='00143' OR CARRIER.ID='00365' THEN     ; * Federal Express
         IF INV.NUM#'' THEN
            XPOS=40 ; YPOS=6 ; TXT="Inv Num: ":INV.NUM'L#11' ; GOSUB INSERT.TXT
         END
      END
      IF CARRIER.ID='00041' OR CARRIER.ID='12810' OR CARRIER.ID='03042' THEN     ; * United Parcel Service
         XPOS=46 ; YPOS=6 ; TXT='UPS Addr Correc Chrg: ':ADDRESS.CORRECTION.CHARGE'R26,' ; GOSUB INSERT.TXT
         XPOS=46 ; YPOS=7 ; TXT='UPS Fees Charge     : ':UPS.FEE.CHARGE'R26,' ; GOSUB INSERT.TXT
      END
      IF BILL.DATE#'' THEN XPOS=5 ; YPOS=7 ; TXT=BILL.DATE'D2/' ; GOSUB INSERT.TXT
      IF DUE.DATE#'' THEN XPOS=14 ; YPOS=7 ; TXT='Due ':DUE.DATE'D2/' ; GOSUB INSERT.TXT
      XPOS=5 ; YPOS=8 ; TXT=IN.OUT'L#5' ; GOSUB INSERT.TXT
      IF DIVISION # '' THEN
         IF DIVISION # '-' THEN
            XPOS=5 ; YPOS=9 ; TXT=DIVISION'R%5' ; GOSUB INSERT.TXT
         END ELSE
            XPOS=5 ; YPOS=9 ; TXT=DIVISION:SPACE(4) ; GOSUB INSERT.TXT
         END
      END
      IF ORIG.ZIP # '' THEN
         DESC = ORIG.ZIP ZIP.MASK
         IF ZIP.LEN = '5' OR ZIP.LEN = 'C' THEN DESC = DESC:' ':ORIG.CITY:', '
         DESC = DESC:ORIG.STATE
         XPOS=5 ; YPOS=10 ; TXT=DESC ; GOSUB INSERT.TXT
      END
      IF DEST.ZIP # '' THEN
         DESC = DEST.ZIP ZIP.MASK
         IF ZIP.LEN = '5' OR ZIP.LEN = 'C' THEN DESC = DESC:' ':DEST.CITY:', '
         DESC = DESC:DEST.STATE
         XPOS=5 ; YPOS=11 ; TXT=DESC ; GOSUB INSERT.TXT
      END
      XPOS=5 ; YPOS=12 ; TXT=EXP.CODE:' ':EXP.CODE.DESC ; GOSUB INSERT.TXT
      IF VC.DESC # '' THEN
         BEGIN CASE
            CASE IN.OUT='O'
               LN = 'Cust.':VC.DESC
            CASE IN.OUT='I'
               LN = 'Vend.':VC.DESC
            CASE IN.OUT='T'
               LN = 'Shpr.':VC.DESC
         END CASE
         XPOS=0 ; YPOS=13 ; TXT=LN ; GOSUB INSERT.TXT
      END
       GO REJS       ; * GRB01
      ***************************************
            
      XPOS=5 ; YPOS=14 ; TXT=CLASS<1,1> ; GOSUB INSERT.TXT
      XPOS=5 ; YPOS=15 ; TXT=MILEAGE'L1,#10' ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=19 ; TXT=WEIGHT'R#6':CARRIER.CHG'R26#9'
      TXT:=ACTUAL.CHG'R26#9'
      IF FLAT.RATE THEN
         TXT:='F'
      END ELSE
         TXT:=' '
      END
      TXT:=VARIANCE'R26#7':MISROUTE.AMOUNT'R26#11' ; GOSUB INSERT.TXT
      LOCATE 'A' IN VERIFIED<1> SETTING NUL THEN
         XPOS=8 ; YPOS=20 ; TXT="|--From On-Line Audit--|" ; GOSUB INSERT.TXT
      END ELSE
         IF ENTRY.DATE#'' AND ENTRY.DATE < "11140" THEN
            XPOS=8 ; YPOS=20 ; TXT="|-Entered on ":ENTRY.DATE'D2/':" -|" ; GOSUB INSERT.TXT
         END
      END
      XPOS=37 ; YPOS=13 ; TXT="Class: " ; GOSUB INSERT.TXT
      XPOS=37 ; YPOS=14 ; TXT="Weight:" ; GOSUB INSERT.TXT
      FOR XX = 1 TO 5
         XPOS=37+XX*7 ; YPOS=13 ; TXT=CLASSES<1,XX>'R#7' ; GOSUB INSERT.TXT
         XPOS=37+XX*7 ; YPOS=14 ; TXT=WEIGHTS<1,XX>'R#7' ; GOSUB INSERT.TXT
      NEXT XX
      IF CLASSES<1,6>#'' THEN XPOS=75 ; YPOS=15 ; TXT='more'
      IF MISROUTE.CARRIER#'' THEN
         MISROUTE.NAME=OCONV(MISROUTE.CARRIER,'TCARRIERS;X;;1')
         IF MISROUTE.NAME='' THEN
            MISROUTE.NAME='Unknown Carrier'
         END
         XPOS=46 ; YPOS=19 ; TXT=MISROUTE.CARRIER'R%5':' ':MISROUTE.NAME'L#20' ; GOSUB INSERT.TXT
      END ELSE
         XPOS=46 ; YPOS=19 ; TXT=SPACE(26) ; GOSUB INSERT.TXT
      END
      XPOS=0 ; YPOS=21 ; TXT=AIR.PIECES'R#7' ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=21 ; TXT=DIM.WEIGHT'R#7' ; GOSUB INSERT.TXT
* START ADDING LINES TO THE INITIAL FB SCREEN
      YPOS=21
      XPOS=0 ; YPOS=YPOS+1 ; TXT="----------- Bill of Ladings ----------" ; GOSUB INSERT.TXT
      NVAL=DCOUNT(BOL,@VM)
      FOR VAL=1 TO NVAL
         XPOS=0 ; YPOS=YPOS+1 ; TXT=VAL'L#3':' ':BOL<1,VAL>'L#25' ; GOSUB INSERT.TXT
      NEXT VAL
      XPOS=0 ; YPOS=YPOS+1 ; TXT='' ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=YPOS+1 ; TXT="---------------- Discounts ----------------" ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=YPOS+1 ; TXT="Lin         Gross   Discount            Net" ; GOSUB INSERT.TXT
      NATT=DCOUNT(DISC.DET,@AM)
      FOR ATT=1 TO NATT
         GROSS=0
         D.GROSS=0
         M.GROSS=0
         IF DISC.DET<ATT,2>='Regular' THEN
            D.GROSS=D.GROSS+DISC.DET<ATT,1>
         END ELSE
            M.GROSS=M.GROSS+DISC.DET<ATT,1>
         END
         GROSS=GROSS+DISC.DET<ATT,1>
         XPOS=0 ; YPOS=YPOS+1 ; TXT=ATT'L#3':' ':DISC.DET<ATT,1>'R26,#13':' ':DISC.DET<ATT,2> ; GOSUB INSERT.TXT
      NEXT ATT
      XPOS=0 ; YPOS=YPOS+1 ; TXT="Tot" ; GOSUB INSERT.TXT
      DISC.AMT=D.GROSS*(DISC.PERC/10000)
      DISC.AMT=OCONV(DISC.AMT,'MR0')
      NET=D.GROSS-DISC.AMT+M.GROSS
      XPOS=7 ; TXT=GROSS'R26,#10':DISC.PERC'R26,#11':NET'R26,#15' ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=YPOS+1 ; TXT='' ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=YPOS+1 ; TXT='Variance to Distribute : $':VARIANCE'R26#12' ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=YPOS+1 ; TXT=STR('-',79) ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=YPOS+1 ; TXT='Ln  Desc         Cut Back Info       Amount' ; GOSUB INSERT.TXT
      XPOS=0 ; YPOS=YPOS+1 ; TXT=STR('-',79) ; GOSUB INSERT.TXT
      IF CL.VAR.DEF='D' THEN
         XPOS=0 ; YPOS=YPOS+1 ; TXT='*' ; GOSUB INSERT.TXT
         XPOS=50 ; TXT='Default Discount Variance' ; GOSUB INSERT.TXT
      END ELSE
         XPOS=0 ; YPOS=YPOS+1 ; TXT='1)  Discount   ' ; GOSUB INSERT.TXT
      END
      IF BAL.DUE THEN
         XPOS=14 ; TXT=VAR.ARR<1>'R26#12' ; GOSUB INSERT.TXT
      END ELSE
         XPOS=31 ; TXT=VAR.ARR<1>'R26#12' ; GOSUB INSERT.TXT
      END
      NVAL=DCOUNT(VAR.ARR<7>,@VM)
      FOR VAL=1 TO NVAL
         XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):VAR.ARR<7,VAL> ; GOSUB INSERT.TXT
      NEXT VAL
      IF CL.VAR.DEF='O' THEN
         XPOS=0 ; YPOS=YPOS+1 ; TXT='*' ; GOSUB INSERT.TXT
         XPOS=50 ; TXT='Default Overcharge Variance' ; GOSUB INSERT.TXT
      END ELSE
         XPOS=0 ; YPOS=YPOS+1 ; TXT='2)  Overcharge ' ; GOSUB INSERT.TXT
      END
      IF BAL.DUE THEN
         XPOS=14 ; TXT=VAR.ARR<2>'R26#12' ; GOSUB INSERT.TXT
      END ELSE
         XPOS=31 ; TXT=VAR.ARR<2>'R26#12' ; GOSUB INSERT.TXT
      END
      NVAL=DCOUNT(VAR.ARR<8>,@VM)
      FOR VAL=1 TO NVAL
         XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):VAR.ARR<8,VAL> ; GOSUB INSERT.TXT
      NEXT VAL
      IF CL.VAR.DEF='C' THEN
         XPOS=0 ; YPOS=YPOS+1 ; TXT='*' ; GOSUB INSERT.TXT
         XPOS=50 ; TXT='Default Consulting Variance' ; GOSUB INSERT.TXT
      END ELSE
         XPOS=0 ; YPOS=YPOS+1 ; TXT='3)  Consulting ' ; GOSUB INSERT.TXT
      END
      IF BAL.DUE THEN
         XPOS=14 ; TXT=VAR.ARR<3>'R26#12' ; GOSUB INSERT.TXT
      END ELSE
         XPOS=31 ; TXT=VAR.ARR<3>'R26#12' ; GOSUB INSERT.TXT
      END
      IF PRO.REC<151>#'' THEN            ; * JMK02
         TOT.DTL=0                       ; * JMK02
         XPOS=0 ; YPOS=YPOS+2 ; TXT=SPACE(5):"---- F r e i g h t   B i l l   D e t a i l s ---" ; GOSUB INSERT.TXT       ; * JMK02
         XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):"LN Code Charges   Additional Information        " ; GOSUB INSERT.TXT       ; * JMK02
         XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):"-- ---- --------- ------------------------------" ; GOSUB INSERT.TXT       ; * JMK02
         NDVAL=DCOUNT(PRO.REC<151>,@VM)  ; * JMK02
         FOR DVAL=1 TO NDVAL             ; * JMK02
            CODE=PRO.REC<151,DVAL>       ; * JMK02
            AMT=PRO.REC<152,DVAL>        ; * JMK02
            REASON=PRO.REC<218,DVAL>     ; * JMK02
            XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):DVAL'R#2 ':CODE'L#4 ':AMT'R26#9 ':REASON'L#30' ; GOSUB INSERT.TXT        ; * JMK02
            TOT.DTL+=AMT                 ; * JMK02
         NEXT DVAL                       ; * JMK02
         XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):"        ---------" ; GOSUB INSERT.TXT        ; * JMK02
         XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):'''R#2 ':'''L#4 ':TOT.DTL'R26#9 ' ; GOSUB INSERT.TXT    ; * JMK02
      END                                ; * JMK02

**********************************
REJS:   ; * GRB01
**********************************
      IF PRO.REC<39>='R' THEN
         IF PRO.REC<59>#'' OR PRO.REC<61>#'' THEN
            XPOS=0 ; YPOS=YPOS+2 ; TXT=SPACE(5):"----------------- Reject Reasons ---------------" ; GOSUB INSERT.TXT
            XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):"  Date      User    Code   Description           " ; GOSUB INSERT.TXT
            XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):"-------- ---------- ----- -----------------------" ; GOSUB INSERT.TXT
            IF PRO.REC<59>#'' THEN
               NUM.OF.REJ = DCOUNT(PRO.REC<59>,@VM)
               FOR NREJ = 1 TO NUM.OF.REJ
                  REJ.DATE = OCONV(PRO.REC<60,NREJ,2>,'D2/')
                  REJ.USER = PRO.REC<60,NREJ,1>
                  REJ.CODE = PRO.REC<59,NREJ>
                  LOCATE REJ.CODE IN REJECT.CODES<1> SETTING YY.POS THEN
                     IF REJECT.CODES<3,YY.POS>#'' THEN REJ.CODE=REJ.CODE:'*'
                     REJ.DESC = REJECT.CODES<2,YY.POS>
                  END ELSE
                     REJ.DESC='Unknown Code'
                  END
                  FIRST.LINE=1
                  REJ.DESC=TRIM(REJ.DESC)
GET.NEXT.LINE:***
                  STRING.BREAK=49
                  ORG.STR.BREAK=STRING.BREAK
                  IF LEN(REJ.DESC) <= STRING.BREAK THEN
                     IF FIRST.LINE THEN
                        XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):REJ.DATE:' ':REJ.USER'L#10':' ':REJ.CODE'L#6':' ':REJ.DESC'L#49' ; GOSUB INSERT.TXT
                     END ELSE
                        XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(31):REJ.DESC'L#49' ; GOSUB INSERT.TXT
                     END
                   END ELSE
                     DONE=0
                     LOOP
                     UNTIL (DONE)
                        IF (REJ.DESC[STRING.BREAK,1])=' ' THEN
                           STR.OUT=REJ.DESC[1,STRING.BREAK-1]
                           DONE=1
                        END ELSE
                           STRING.BREAK=STRING.BREAK-1
                           IF STRING.BREAK <3 THEN
                              STR.OUT=REJ.DESC[1,ORG.STR.BREAK]
                              STRING.BREAK=ORG.STR.BREAK
                              DONE = 1
                           END
                        END
                     REPEAT
                     IF FIRST.LINE THEN
                        FIRST.LINE=0
                        XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):REJ.DATE:' ':REJ.USER'L#10':' ':REJ.CODE'L#6':' ':STR.OUT'L#49' ; GOSUB INSERT.TXT
                     END ELSE
                        XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(31):STR.OUT'L#49' ; GOSUB INSERT.TXT
                     END
                     REJ.DESC=REJ.DESC[STRING.BREAK,999]
                     GOTO GET.NEXT.LINE
                  END
               NEXT NREJ
            END
           
            IF PRO.REC<61>#'' THEN
               NUM.OF.REJ = DCOUNT(PRO.REC<61>,@VM)
               FOR NREJ = 1 TO NUM.OF.REJ
                  REJ.DATE = OCONV(PRO.REC<62,NREJ,2>,'D2/')
                  REJ.USER = PRO.REC<62,NREJ,1>
                  REJ.CODE='NONE'
                  REJ.DESC = PRO.REC<61,NREJ>
                  FIRST.LINE=1
                  REJ.DESC=TRIM(REJ.DESC)
GET.NEXT.LINE.2:***
                  STRING.BREAK=49
                  ORG.STR.BREAK=STRING.BREAK
                  IF LEN(REJ.DESC) <= STRING.BREAK THEN
                     IF FIRST.LINE THEN
                        XPOS= 0 ; YPOS=YPOS+1 ; TXT=SPACE(5):REJ.DATE:' ':REJ.USER'L#10':' ':REJ.CODE'L#6':' ':REJ.DESC'L#49' ; GOSUB INSERT.TXT
                     END ELSE
                        XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(31):REJ.DESC'L#49' ; GOSUB INSERT.TXT
                     END
                   END ELSE
                     DONE = 0
                     LOOP
                     UNTIL (DONE)
                        IF (REJ.DESC[STRING.BREAK,1])=' ' THEN
                           STR.OUT=REJ.DESC[1,STRING.BREAK-1]
                           DONE=1
                        END ELSE
                           STRING.BREAK=STRING.BREAK-1
                           IF STRING.BREAK <3 THEN
                              STR.OUT=REJ.DESC[1,ORG.STR.BREAK]
                              STRING.BREAK=ORG.STR.BREAK
                              DONE = 1
                           END
                        END
                     REPEAT
                     IF FIRST.LINE THEN
                        FIRST.LINE=0
                        XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(5):REJ.DATE:' ':REJ.USER'L#10':' ':REJ.CODE'L#6':' ':REJ.DESC'L#49' ; GOSUB INSERT.TXT
                     END ELSE
                        XPOS=0 ; YPOS=YPOS+1 ; TXT=SPACE(31):REJ.DESC'L#49' ; GOSUB INSERT.TXT
                     END
                     REJ.DESC=REJ.DESC[STRING.BREAK,999]
                     GOTO GET.NEXT.LINE.2
                  END
               NEXT NREJ
            END
         END
      END
* PASS BACK TO CALLING PROCESS
      VOUT=CHANGE(SCREEN.TXT,@AM,@VM)
      RETURN
INSERT.TXT:
      LTXT=LEN(TXT)
      IF TRIM(SCREEN.TXT<YPOS+1>)='' THEN SCREEN.TXT<YPOS+1>=SPACE(80)
      SCREEN.TXT<YPOS+1>[XPOS+1,LTXT]=TXT
      RETURN
   END
