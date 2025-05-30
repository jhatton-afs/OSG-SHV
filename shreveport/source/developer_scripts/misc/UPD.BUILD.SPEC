      OPEN "FB.BUILD.SPEC" TO FILE.SPEC ELSE STOP
      EXECUTE "GET-LIST GBAG"

      EOJ = 0
      QQ = 6
      LOOP
      UNTIL EOJ DO
         READNEXT ID ELSE EOJ = 1
         READ DAT FROM FILE.SPEC,ID THEN
            COLUMN.CNT = DCOUNT(DAT<2>,@VM)
            QQ = COLUMN.CNT + 1
            DAT<2> = INSERT(DAT<2>,1,QQ,0,"Invoice Received Date")     ; * column header
            DAT<3> = INSERT(DAT<3>,1,QQ,0,"FB")    ; * file
            DAT<4> = INSERT(DAT<4>,1,QQ,0,"246")   ; * attribute #
            DAT<5> = INSERT(DAT<5>,1,QQ,0,"1")     ; * value #
            DAT<6> = INSERT(DAT<6>,1,QQ,0,"D2\")   ; * conversion
            DAT<7> = INSERT(DAT<7>,1,QQ,0,"")
            DAT<8> = INSERT(DAT<8>,1,QQ,0,"")
            DAT<9> = INSERT(DAT<9>,1,QQ,0,"")
            DAT<10> = INSERT(DAT<10>,1,QQ,0,"")
            GOSUB COLUMN.LETTER
            DAT<11> = INSERT(DAT<11>,1,QQ,0,LETTER)          ; * column letter
            DAT<12> = INSERT(DAT<12>,1,QQ,0,"")
            DAT<13> = INSERT(DAT<13>,1,QQ,0,"")
            DAT<14> = INSERT(DAT<14>,1,QQ,0,"")

****            WRITE DAT ON FILE.SPEC,ID
         END
      REPEAT
      STOP
*****************************************************************
COLUMN.LETTER:
*****************************************************************
      BEGIN CASE
         CASE COLUMN.CNT = 236
            LETTER = "IC"
         CASE COLUMN.CNT = 257
            LETTER = "IX"
         CASE COLUMN.CNT = 196
            LETTER = "GO"
         CASE COLUMN.CNT = 245
            LETTER = "IL"
         CASE COLUMN.CNT = 238
            LETTER = "IE"
         CASE COLUMN.CNT = 244
            LETTER = "IK"
         CASE COLUMN.CNT = 237
            LETTER = "ID"
         CASE COLUMN.CNT = 221
            LETTER = "HN"
         CASE COLUMN.CNT = 227
            LETTER = "HT"
         CASE COLUMN.CNT = 209
            LETTER = "HB"
         CASE COLUMN.CNT = 198
            LETTER = "GQ"
         CASE COLUMN.CNT = 95
            LETTER = "CR"
         CASE 1
            CRT ID
            CRT "LETTER LOGIC OUT OF RANGE ":COLUMN.CNT ; INPUT ZZ

      END CASE
      RETURN
