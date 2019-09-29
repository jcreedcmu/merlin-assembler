          TR ADR

          ORG $380

          LDA #$4C
          STA HB6DA
          LDA #START
          STA HB6DB
          LDA #>START
          STA HB6DC
          RTS

START     STA H08D6
          LDA H0280
          ASL
          ASL
          ASL
          STA H08D5
          LDA H0281
          ROR
          ROR H08D6
          ROR
          ROR H08D6
          AND #$07
          ORA H08D5
          JSR HE5F6
          LDA H0283
          AND #$5F
          CMP #$44
          BEQ H08C9
          CLC
H08C9     LDA H0282
          AND #$1F
          ROL
          ORA H08D6
          JMP HE5F6

H08D5     BRK
H08D6     BRK

H0280     = $0280
H0281     = $0281
H0282     = $0282
H0283     = $0283
HB6DA     = $B6DA
HB6DB     = $B6DB
HB6DC     = $B6DC
HE5F6     = $E5F6
