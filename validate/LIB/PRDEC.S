* This routine prints a space after the number

PRDEC     STA NH
          STX NL
          LDX #9
          STX NFL
:L0       LDY #"0"
:LUP      LDA NL
          CMP NUMTBL-1,X
          LDA NH
          SBC NUMTBL,X
          BCC :MD
          STA NH
          LDA NL
          SBC NUMTBL-1,X
          STA NL
          INY
          BNE :LUP
:MD       TYA
          DEX
          BEQ :DIG
          CMP #"0"
          BEQ :MODE
          STA NFL
:MODE     BIT NFL
          BMI :DIG
          LDA JUST
          BPL :NX
:DIG      JSR PRCHR
:NX       DEX
          BPL :L0
SPACE     LDA #" "
PRINT     ORA #$80
PRCHR     INC CHRCNT
          JMP COUT

NUMTBL    DA 1,10,100,1000,10000
