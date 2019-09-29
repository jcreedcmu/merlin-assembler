
          ERR *-$F7D0

PRINTENT  LDA #" "
          STA JUST
          JSR SENDMSG
          HEX 8D
          ASC "Entry addresses:"8d8d00
          STADR SYMADR-2 ;SYMPNT
          JSR FINDENT
]LOOP     BEQ :LINKED
          JSR SPACE
          LDA #"="
          JSR COUT
          JSR SPACE
          JSR GETSYM
          CLC
          ADC OFFSET
          TAX
          JSR GETSYM
          ADC OFFSET+1
          EOR #$80
          JSR PRNTAX
          JSR CROUT
          JSR KEYCHK
          JSR NXSY
          JMP ]LOOP
:LINKED   LSR JUST
          RTS

PRNENT    STA LENGTH
:PENT     JSR GETSYM
          ORA #$80
          JSR COUT
          DEX
          BNE :PENT
          DEX
          RTS
