*****************************************************
      *******
* Program name : FEDEX.RED
* Author       : Greg Bino
* Date written : 12-04-20
* Library      : EDIBP
* COPYRIGHT (C) 2020 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
* EDI DUPLICATE RESOLUTION
*
* Last updated by afs (AFSLOGISTICS\gbino) at 06:45:08 on 12/04/2020.
*
* Start modification history
* 07/11/06 : JCW01 : USED EDI.BILLS.HIST,CLIENT.ID
* 08/20/14 : DRF01 : SysAid 11565 - Gave Haley the same access as Elisa
* 02/26/15 : DRF02 : SysAid 15591 - Gave Laura Metz the same access as Elisa
* 03/16/16 : GRB01 - SysAid 22964 - Gave user MWYNN access
**************************************************************

* Initialize variables
*
$OPTIONS HEADER.EJECT

$OPTIONS EXEC.EQ.PERF
$OPTIONS INFO.ABORT
      ERRMSG=''
      PROMPT''
      CALL GET.USER.NEW(USER.NAME,CH.NUM)
      PROG.NAME='FEDEX.RES'
      PROG.DESC='INVOICE INQUIRY'
      PACK.NAME='FREIGHT BILLING'
      CO.NAME='AFS Logistics, LLC'
      UPL.VIN = 'EDIBP' ; UPL.VIN<2> = 'FEDEX.RES' ; UPL.VOUT = ''
      UPL.VIN<3> = USER.NAME
      UPL.VIN<4> = CH.NUM
      ****    CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)
      CLIENT.ID='' ; CLIENT.NAME='' ; CARRIER.ID=''
      CARRIER.NAME=''
      HLA = '' ; HLB = ''
      DIM FEDEX.REC(200)
      MAT FEDEX.REC=''
      DIM FEDEX.RECC(200)
      MAT FEDEX.RECC=''
      MATCH.CNT = 0
      NOT.MATCH = 0
      DELETE.CNT = 0
      CNT =0
      EXECUTE "CLEAR-FILE DATA FEDEX.TEMP"
*
* Open general files
*
      OPEN '','CLIENTS' TO F.CLIENTS ELSE CALL OPEN.ABORT("CLIENTS",PROG.NAME)
      OPEN '','CARRIERS' TO F.CARRIERS ELSE CALL OPEN.ABORT("CARRIERS",PROG.NAME)
*     OPEN '','FB.CHECKS' TO F.CHECKS ELSE CALL OPEN.ABORT("FB.CHECKS",PROG.NAME) ; * JCW 09/08/06
      OPEN '','FB.BILLS.CRX' TO F.CRX ELSE
         EXECUTE 'CREATE-FILE FB.BILLS.CRX 1 103' PASSLIST CAPTURING OUTPUT
         OPEN '','FB.BILLS.CRX' TO F.CRX ELSE CALL OPEN.ABORT("FB.BILLS.CRX",PROG.NAME)
      END
      OPEN '','FB.TABLES' TO F.TABLES ELSE CALL OPEN.ABORT("FB.TABLES",PROG.NAME)
      OPEN '','FED.INV.XREF' TO F.INV.XREF ELSE CALL OPEN.ABORT("FED.INV.XREF",PROG.NAME)
      OPEN '','FEDEX.RES' TO F.FEDX ELSE CALL OPEN.ABORT("FEDEX.RES",PROG.NAME)
      OPEN '','BCTRL' TO F.BCTRL ELSE
         CALL OPEN.ABORT('BCTRL',PROG.NAME)
      END
      OPEN 'FEDEX.TEMP' TO F.TEMP ELSE
         CALL OPEN.ABORT('FEDEX.TEMP',PROG.NAME)
      END
      OPEN 'DAV.TEMP' TO F.DAV ELSE
         CALL OPEN.ABORT('DAV.TEMP',PROG.NAME)
      END
      READ DBCTRL FROM F.BCTRL,USER.NAME ELSE DBCTRL=''
  ****    DEBUG
      **************************************************************** ****   EXECUTE "SSELECT FEDEX.RES"
   *****    EXECUTE "GET-LIST DAV.00015"
           EXECUTE "GET-LIST DAV.01075"

      EOJ = 0
      LST.INV = ""
      IF @SELECTED GT 0 THEN
         LOOP
            READNEXT ID ELSE EOJ = 1     ; * RECORDS DELETED BEFORE THE ID IS READ write to temp
            READ TST FROM F.TEMP,ID THEN
               GO NEXT.INV
            END ELSE
               WRITEV "" ON F.TEMP,ID,1
            END
         UNTIL EOJ DO
            **  	DEBUG
            OLDEST.CK.DT =""
            OLDEST.PROC.DT = ""
            MATREAD FEDEX.REC FROM F.FEDX,ID THEN
               CNT+=1
               INV.NO = FEDEX.REC(1)

               INV.NO = INV.NO[1,1]:"-":INV.NO[2,3]:"-":INV.NO[5,5]
               WRITEV INV.NO ON F.TEMP,ID,1
               READ DINV.XREF FROM F.INV.XREF,INV.NO THEN    ; * GET TOTAL FROM CRX/FB.BILLS
                  NUM.PROS=DCOUNT(DINV.XREF,CHAR(254))
                  OLD.CLIENT.ID=''
                  INV.AMT=0
                  AMT.TO.PAY=0
                  DARRAY=""
                  FOR I = 1 TO NUM.PROS
                     READ PRO.REC FROM F.CRX,DINV.XREF<I> ELSE
                     ****   CALL ELINE(DINV.XREF<I>:' Is not on file - Skipping')
                        DARRAY<I,1>=FIELD(DINV.XREF<I>,'*',2)
                        ****GOTO GET.NEXT.RECORD
                        CONTINUE
                     END
                     INV.AMT=INV.AMT+PRO.REC<8>-PRO.REC<10>-PRO.REC<11>
                     AMT.TO.PAY=AMT.TO.PAY+PRO.REC<8>
                     DARRAY<I,1>=FIELD(DINV.XREF<I>,'*',2)
                     DARRAY<I,2>=PRO.REC<2>
                     DARRAY<I,3>=PRO.REC<8>-PRO.REC<10>-PRO.REC<11>
                     DARRAY<I,4>=PRO.REC<8>
                     DARRAY<I,5>=PRO.REC<41,2>:' ':PRO.REC<41,1>
                     DARRAY<I,5>=TRIM(DARRAY<I,5>)
                     DARRAY<I,6>=PRO.REC<37>       ; * PROC DT
                     DARRAY<I,7>=PRO.REC<15>       ; * CHECK DT
                     DARRAY<I,8>=PRO.REC<14>       ; * CHECK NO
                     DARRAY<I,9>=PRO.REC<1>
                     DARRAY<I,10>=FIELD(DINV.XREF<I>,'*',1)
                     IF PRO.REC<39>='R' THEN
                        DARRAY<I,5>='REJECTED BILL'
                        DARRAY<I,4>=0
                        AMT.TO.PAY=AMT.TO.PAY-PRO.REC<8>
                     END
                     CLIENT.ID=PRO.REC<1>
                     IF OLD.CLIENT.ID='' THEN OLD.CLIENT.ID=CLIENT.ID
                     IF CLIENT.ID#OLD.CLIENT.ID THEN
                        CALL ELINE('More than one client for this invoice - Using the first one')
                        CONTINUE
                     END
                     IF OLDEST.CK.DT = "" THEN
                        OLDEST.CK.DT = PRO.REC<15>
                     END ELSE
                        IF PRO.REC<15> LT OLDEST.CK.DT THEN
                           OLDEST.CK.DT = PRO.REC<15>
                        END
                     END
                     IF OLDEST.CK.DT GE (DATE() - 35) THEN
                        CK.DT.DEL =1
                     END ELSE
                        CK.DT.DEL = 0
                     END

                     IF OLDEST.PROC.DT = "" THEN
                        OLDEST.PROC.DT = PRO.REC<37>
                     END ELSE
                        IF PRO.REC<37> LT OLDEST.PROC.DT THEN
                           OLDEST.PROC.DT = PRO.REC<30>
                        END
                     END
                     IF OLDEST.PROC.DT GE (DATE() - 35) THEN
                        CK.PROC.DEL =0
                     END ELSE
                        CK.PROC.DEL = 0
                     END

                  NEXT I
               END ELSE
                  CRT "RECORD NOT PAID  **************"
               END
               **            DEBUG

               OPEN '','EDI.BILLS.HIST,':CLIENT.ID TO F.EDI.HIST ELSE CALL OPEN.ABORT("EDI.BILLS.HIST,":CLIENT.ID,PROG.NAME)
NOW.THE.TEMP:
* BUILD TOTALS FOR INV NO
               CMD = 'SELECT FEDEX.RES WITH INV.NO = "' :FEDEX.REC(1) :'"'
               EXECUTE CMD RTNLIST CORP.LIST CAPTURING STUFF RETURNING JUNK
               INV.LIST = "GB"
               EXECUTE "SAVE-LIST ":INV.LIST PASSLIST CORP.LIST CAPTURING OUTPUT
               CMD = 'GET-LIST GB'

               EXECUTE CMD RTNLIST CORP.LIST CAPTURING OUTPUT
               EOJ2 = 0
               INV.ARRY=''
               LOOP
                  READNEXT ID2 FROM CORP.LIST ELSE EOJ2 =1
               UNTIL EOJ2 DO
                  MATREAD FEDEX.RECC FROM F.FEDX,ID2 THEN
                     VERS = FIELD(ID2,"*",4)
                     LOCATE(VERS,INV.ARRY<1>,1;POS) THEN
                        INV.ARRY<2,POS> = INV.ARRY<2,POS> + FEDEX.RECC(67)
                        INV.ARRY<3,POS,-1> = ID2
                     END ELSE
                        INV.ARRY<1,POS> = VERS
                        INV.ARRY<2,POS> = FEDEX.RECC(67)
                        INV.ARRY<3,POS,-1> = ID2
                     END
                  END
               REPEAT
               * CHECK INV TOTALS AGAINST BILLS TOTAL

               VER.CNT = DCOUNT(INV.ARRY<1>,@VM)
               FOR J = 1 TO VER.CNT
                  ****      VER.TOT = SUM(INV.ARRY<2,J>)
                  VER.TOT = SUM(INV.ARRY<2>)
****DEBUG
                  IF (VER.TOT = AMT.TO.PAY AND CK.DT.DEL) OR (VER.TOT = AMT.TO.PAY AND CK.PROC.DEL) THEN
                     ***          DEBUG

                     * CHECK DATE IS WITHIN 10 DAYS OF CURRENT DATE THEN DELETE
                     * IN NO CHECK AND PROC DATE IS WITHIN 15 DAYS OF CURRENT DATE DELETE

                     * NOW LOOP THROUGH IDS IN INV.ARRY<3> AND DELETE
                     ID.CNT = DCOUNT(INV.ARRY<3,J>,@SVM)
                     FOR JJ = 1 TO ID.CNT
                        **   IF J GT 1 THEN DEBUG
                        IDD = INV.ARRY<3,J,JJ>

                        CRT "EDI ":VER.TOT:" Bills TOT ":AMT.TO.PAY:"    INV ":INV.NO:"   ID ":IDD

                        EDIH.ID = FIELD(IDD,"*",2,3)
                        READ TST FROM F.EDI.HIST,EDIH.ID THEN
                           **     	CRT "FOUND EDI"
                        END ELSE
                           **    	CRT "*************************EDI NOT FOUND"
                        END
                        **   CRT EDIH.ID
                        DELETE F.EDI.HIST,EDIH.ID
                        DELETE F.FEDX,IDD
                        DELETE F.DAV,IDD
                        WRITEV "*" ON F.TEMP,IDD,2
* update temp
                        DELETE.CNT +=1
                     NEXT JJ

                     MATCH.CNT +=1
                  END ELSE
                     CRT " Inv.no NOT matched  ":INV.NO:"  ID  ":ID
                     NOT.MATCH +=1
                  END
               NEXT J
            END
NEXT.INV:
         REPEAT
         ***      RETURN
      END
      CRT "TOTAL ":CNT
      CRT "MATCH ":MATCH.CNT
      CRT "NOT MATCH ":NOT.MATCH
      CRT "DELETE ":DELETE.CNT

   END
