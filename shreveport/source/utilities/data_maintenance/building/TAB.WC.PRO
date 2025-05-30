      OPEN 'WC.PRO.XREF' TO FILE.VEND ELSE STOP
      OPEN 'GRB' TO FILE.EXP ELSE STOP

*this will take a list and generate a xls file of mailing info
* from the NAME.ADDRESS file
      CRT @(-1)
      DATA.REC = ""
      CNT = 0
      TAB=CHAR(9)
      TAB = ","
      LF = CHAR(10)
      AM = CHAR(254)
      EOJ=0
      GOSUB BUILD.HEADER
      EXECUTE "GET-LIST WC.CK"
      LOOP
         READNEXT ID ELSE EOJ = 1
      UNTIL EOJ DO
         CODE = FIELD(ID,"*",3)
         GOSUB UPDATE.RECORD
      REPEAT

      WRITE DATA.REC TO FILE.EXP,"GB.ADD"
      READ DATA1 FROM FILE.EXP,"GB.ADD" ELSE NULL
      CONVERT AM TO LF IN DATA1
      WRITE DATA1 ON FILE.EXP,"WC.PRO.txt"
      STOP
UPDATE.RECORD:
      IF DATA.REC = "" THEN
         GOSUB BUILD.HEADER
      END
      DATA.REC<-1> = CODE

      RETURN
BUILD.HEADER:
      DATA.REC<-1> = "PRO":TAB:"DESCRIPTION"
      RETURN
