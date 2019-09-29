POKE      MAC
          MOV #]2        ;]1
          <<<

HTAB      MAC
          LDA #]1
          JSR DOHTAB
          <<<

STADR     MAC
          POKE ]2        ;]1
          POKE ]2+1      ;]1/$100
          <<<

STIND     MAC
          MOV ]1         ;(]2),Y
          INY
          MOV ]1+1       ;(]2),Y
          <<<

INCD      MAC
          INC ]1
          BNE NC
          INC ]1+1
NC        <<<

DECD      MAC
          LDA ]1
          BNE NDH
          DEC ]1+1
NDH       DEC ]1
          <<<

TRDB      MAC
          MOV ]1+1       ;]2+1
MOV       MAC
          LDA ]1
          STA ]2
          <<<

ADDD      MAC
          CLC
          LDA ]1
          ADC ]2
          STA ]2
          LDA ]1+1
          ADC ]2+1
          STA ]2+1
          <<<

ADAY      MAC
          CLC
          ADC ]1
          STA ]1
          TYA
          ADC ]1+1
          STA ]1+1
          <<<

PAS?      MAC
          LDA PASNUM
          ORA PNFLG
          <<<

SVPNT     MAC
          MOV ]1         ;]2,Y
          MOV ]1+1       ;]2+MX,Y
          <<<

GETPNT    MAC
          MOV ]1,Y       ;]2
          MOV ]1+MX,Y    ;]2+1
          <<<

ERX       MAC
          LDX #]1-ERRTBL/2
          <<<

JMLI      MAC
          LDX #]2PARMS
          LDA #]1
          JSR ENTRY
          <<<
