      CRT TIMEDATE():' started.'
      CALL GET.USER(USER)
      GET (ARG.,1) OBEG.DATE THEN
         BEG.DATE=ICONV(OBEG.DATE,'D')
      END ELSE
         EXECUTE "BBSEND MIKE NO BEGIN DATE FOR PUSH.SQL"
         GOTO 9000
      END
      GET (ARG.,2) OEND.DATE THEN
         END.DATE=ICONV(OEND.DATE,'D')
      END ELSE
         EXECUTE "BBSEND MIKE NO END DATE FOR PUSH.SQL"
         GOTO 9000
      END
      SQL.STMT='UPD.SQL.FBHIST.PX ':BEG.DATE'D2/':' ':END.DATE'D2/'
      CRT SQL.STMT
      EXECUTE SQL.STMT
      CRT @(0,20):'Sleeping...zzz...zzz...':
      EXECUTE "SLEEP 15"
      CRT @(0,20):@(-4):
      CRT TIMEDATE():' completed.'
      EXECUTE "BBSEND MIKE PUSH.SQL ":BEG.DATE'D2/':" ":END.DATE'D2/':" HAS COMPLETED."
9000: CHAIN "OFF"
      END
