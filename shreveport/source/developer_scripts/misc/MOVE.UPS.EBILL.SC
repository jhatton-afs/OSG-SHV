****************************************************
* Program name : MOVE.UPS.EBILL.SC
* Author       : Nicole Hennick
* Date written : 05/24/2023
* Library      : FBBP
* COPYRIGHT (C) 2016 - AFS LOGISTICS LLC - ALL RIGHTS RESERVED.
*
* Move UPS Supply Chain Ebills
*
* Last updated by afs (AFSLOGISTICS\nmeddaugh) at 13:32:36 on 05/24/2023.
*
* Start modification history
* 052423 - NKH00 - ACCU-1299 New program
* 061923 - NKH01 - ACCU-1299 Changed to BILLDATA.EBILL.SC
* End modification history
****************************************************

      PROG.NAME='MOVE.UPS.EBILL.SC'
      PROG.DESC='UPS EBILL SC MOVE'
      PACK.NAME='FREIGHT BILLING'
      
      EQU TB TO CHAR(9)
      CALL GET.USER(USER)      
      
      UPL.VIN = 'FBBP' ; UPL.VIN<2> = 'CONVERT.UPS.EBILL' ; UPL.VOUT = ''      
      *CALL UPD.PROGRAM.LOG(UPL.VIN,UPL.VOUT)     

      VIN1=""
      VIN1<1> = UPL.VIN<2>
      VIN1<2> = USER
      VIN1<3> = SYSTEM(18)
      VIN1<4> = "S"
      CALL PROGTRACK(VIN1,VOUT1)
      
      OPEN '','BILLDATA.EBILL.DATA.IMPORT' TO F.EBILL.DATA.IMPORT ELSE
         CALL OPEN.ABORT('BILLDATA.EBILL.DATA.IMPORT',PROG.NAME)
      END

      STMT='SSELECT BILLDATA.EBILL.DATA.IMPORT WITH @ID = "[.csv" OR WITH @ID = "Invoice_]"' 
      EXECUTE STMT CAPTURING RESULTS
      IF @SELECTED > 0 THEN
         NUM.ITMS=@SELECTED
         EOF=0
         LOOP
            READNEXT EBILL.ID ELSE EOF=1
         UNTIL EOF DO
            ERR.ARRAY = ''
            OPENSEQ 'BILLDATA.EBILL.SC', EBILL.ID TO OUTSEQ.FILE ELSE   ; * NKH01
               CREATE OUTSEQ.FILE ELSE            
                  ERR.ARRAY = "Could not open BILLDATA EBILL"
                  GO SKIP.EBILL
               END
            END
            OPENSEQ 'BILLDATA.EBILL.DATA.IMPORT', EBILL.ID TO INSEQ.FILE ELSE
               ERR.ARRAY = 'Could not open BILLDATA EBILL DATA IMPORT'
               GO SKIP.EBILL
            END

            INSEQ.DONE1 = 0
            LOOP
            UNTIL INSEQ.DONE1 DO
               READSEQ EBILL.REC FROM INSEQ.FILE ELSE INSEQ.DONE1 = 1
               WRITESEQ EBILL.REC ON OUTSEQ.FILE ELSE NULL
            REPEAT       
            CLOSESEQ OUTSEQ.FILE
            CLOSESEQ INSEQ.FILE
            DELETE F.EBILL.DATA.IMPORT,EBILL.ID                               
            
SKIP.EBILL:
            IF ERR.ARRAY > "" THEN
               EMAIL.OUT = ''
               EMAIL.OUT<1> = 'pick@afs.net' 
               EMAIL.OUT<2>='' 
               EMAIL.OUT<3>=''
               EMAIL.OUT<4>='EbillConversion@afs.net'
               EMAIL.OUT<5>=EBILL.ID:' UPS SC File Move Error'
   
               EMAIL.OUT<6>=EBILL.ID:' experienced conversion problems from the UPS format to the AFS format.'
               EMAIL.OUT<6>:='  These problems are listed below.'
               EMAIL.OUT<6,-1>=' '
               EMAIL.OUT<6,-1>=ERR.ARRAY
               CALL SENDMAIL(EMAIL.OUT,RESULTS)
            END
                     
            CLOSESEQ INSEQ.FILE              
                            
         REPEAT
      END
      
      STOP

