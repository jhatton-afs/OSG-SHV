* FREIGHT BILLING PACKAGE
*---- PROGRAM: VERIFY.VCZ.I
* AUTHOR: JAY WEBERT
* DATE: MARCH 21, 2007
* DESCRIPTION: VERIFY THE CROSS REFERENCES BETWEEN VEND.CUST.ZIPS AND VEND.CUST
*
* THIS PROGRAM IS A PROPRIETARY PRODUCT OF AUTOMATED FREIGHT SYSTEMS
* AND MAY NOT BE USED, COPIED OR MODIFIED WITHOUT THE EXPRESS
* WRITTEN CONSENT OF SAME.
*-----------------------------------------------------------------------
      CLIENT.ID = ''
      PROG.NAME = 'VERIFY.VCZ.I'
      OPEN 'CLIENTS' TO F.CLIENTS ELSE
        CALL OPEN.ABORT('CLIENTS',PROG.NAME)
      END
      ******************************
      *** CHECK FOR SPECIFIED CLIENT
      ******************************
      CLIENT.ID = FIELD(@SENTENCE,' ',2)
      IF CLIENT.ID NE '' THEN
        READ TEST FROM F.CLIENTS, CLIENT.ID ELSE
          CRT CLIENT.ID:' is not a valid client number; program stopped.'
          STOP
        END
      END
      ********************
      *** SELECT CLIENT ID'S
      ********************
      IF CLIENT.ID = '' THEN
        STMT = 'SELECT VOC "VEND.CUST.ZIPS" *A7'
        EXECUTE STMT RTNLIST CAPTURING MSG
        IF @SELECTED < 1 THEN
          CRT 'NO CLIENTS SELECTED.'
          STOP
        END
        STMT = 'SELECT CLIENTS'
        EXECUTE STMT PASSLIST RTNLIST CLIENT.LIST CAPTURING MSG
        IF @SELECTED < 1 THEN
          CRT 'NO CLIENT RECORDS SELECTED.'
          STOP
        END
      END ELSE
        STMT = 'SELECT CLIENTS ':CLIENT.ID
        EXECUTE STMT RTNLIST CLIENT.LIST CAPTURING MSG
        IF @SELECTED < 1 THEN
          CRT 'NO CLIENT RECORDS SELECTED.'
          STOP
        END
      END
      ********************
      *** LOOP THROUGH ALL CLIENTS
      ********************
      DONE = 0
      LOOP UNTIL DONE DO
        READNEXT CLIENT.ID FROM CLIENT.LIST THEN
          CRT 'Now processing client ':CLIENT.ID:'...'
          STMT = 'SELECT VEND.CUST.ZIPS,':CLIENT.ID
          EXECUTE STMT RTNLIST VCZ.LIST CAPTURING MSG
          IF @SELECTED < 1 THEN GOTO NEXT.CLIENT
          REC.CNT = @SELECTED
          CNT = 0
          OPEN 'VEND.CUST,':CLIENT.ID TO F.VC ELSE
            CRT 'COULD NOT OPEN VEND.CUST,':CLIENT.ID
            GOTO NEXT.CLIENT
          END
          OPEN 'VEND.CUST.ZIPS,':CLIENT.ID TO F.VCZ ELSE
            CRT 'COULD NOT OPEN VEND.CUST.ZIPS,':CLIENT.ID
            GOTO NEXT.CLIENT
          END
          ***
          DONE1 = 0
          LOOP UNTIL DONE1 DO
            READNEXT VCZ.ID FROM VCZ.LIST THEN
              READV VC.IDS FROM F.VCZ, VCZ.ID, 1 THEN
                ID.CNT = DCOUNT(VC.IDS,CHAR(253))
                FOR I = 1 TO ID.CNT
                  VC.ID = VC.IDS<1,I>
                  READ VC.REC FROM F.VC, VC.ID THEN
                    ZIP = VC.REC<7>
                    BEGIN CASE
                      CASE VCZ.ID = ZIP
*                      CASE VCZ.ID = ZIP[1,5]
*                      CASE VCZ.ID = ZIP'R%5'
*                      CASE VCZ.ID[1,5] = ZIP
                      CASE 1
                        CRT 'MISMATCH! VCZ.ID = ':VCZ.ID:' ZIP = ':ZIP
                    END CASE
                  END
                NEXT I
              END
            END ELSE
              DONE1 = 1
            END
          REPEAT
        END ELSE
          DONE = 1
        END
NEXT.CLIENT:
      REPEAT
STOP

