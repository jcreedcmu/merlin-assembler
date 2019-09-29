SENDMSG   PLA
          STA ]1
          PLA
          STA ]1+1
          BNE NXTCHAR    ;Always
PCHR      JSR ]2
NXTCHAR   LDY #0
          INCD ]1
          LDA (]1),Y
          BNE PCHR
          LDA ]1+1
          PHA
          LDA ]1
          PHA
          RTS
