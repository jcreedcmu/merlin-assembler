
* Symbol printout:

          LDY LSTFLG
          BEQ SND
OUT       JSR CROUT
          LSR
          LDY VIDVEC+1
          CPY CSWH
          BEQ :JC
          CPY PAGVEC+1
          BEQ :JC
          CLC
:JC       ROL            ;FF if prtr, CR if not
          STA LSTFLG     ;Paginator use
          JSR COUT
          JSR WARMDIS
          BIT STROBE
          BIT CONTROL
          JMP EDITOR

SND       DEY
          STY ALFLAG
          JSR SY
          JSR SENDMSG
          ASC "alphabet"00
NXTBL     JSR SENDMSG
          ASC "ical order:"8D00

BEGIN     JSR CROUT
          MOV NUMCOL     ;TAB

KEY?      JSR KEYCHK
          CMP #$83
          BEQ OUT

BYL       STADR SYMADR   ;SYMPNT
          BNE SSP        ;Always

NXSYM     JSR NXTSYM
SSP       LDX #-1
          TXS
          JSR GTLEN
          BNE STOFF      ;Branch if not done
          INC ALFLAG     ;Go to numer
          BNE OUT        ;or out.
          JSR SY
          JSR SENDMSG
          ASC "numer"00

          ERR *-2&$FF/$FF ;Must not be on page bdry
          BNE NXTBL      ;Always

GONUM     ASL            ;Was this sym done?
          BPL NXSYM
          INY
          STA READ.AUX
          LDA (SYMPNT),Y
          DEY
          CMP #':'
          BEQ BYES
NUMER     JSR NQ
          BPL NUMER      ;Ignore if was done
          ASL
          BPL :T         ;Branch if not mac def
          LDX #$80       ;Fake "value"
:T        TXA
          AND #$F
          BEQ :LY        ;Branch if mac def
          TAY
          INY
          INY
          INY
          LDA (PNTSV),Y  ;Value high
          TAX
          DEY
          LDA (PNTSV),Y  ;Low
:LY       LDY SLEN
          INY
          INY
          CMP (SYMPNT),Y
          TXA
          INY
          SBC (SYMPNT),Y
          BCS NUMER      ;Loop if have smaller
                         ;Otherwise point to other
SKIP      TRDB PNTSV     ;SYMPNT
          JSR GTLEN
STOFF     STA SLEN
          TRDB SYMPNT    ;PNTSV
          LDA ASV
          BIT ALFLAG     ;Active mode?
          BEQ GONUM
          ASL            ;Symbol done?
          BMI NXSYM
          STA READ.AUX
ALPHA     JSR NQ
          BMI ALPHA      ;Ignore if was done
          TXA
          AND #$F
          STA QLEN
          CMP SLEN
          BLT :AX
          LDA SLEN
:AX       TAX            ;Get smaller length
]LOOP     INY
          LDA (SYMPNT),Y
          CMP (PNTSV),Y
          BLT ALPHA      ;Reject if have smaller
          BNE SKIP       ;Replace if other less
          DEX
          BNE ]LOOP
          CPY QLEN       ;Have shorter one?
          BNE ALPHA      ;Reject other if so
          BEQ SKIP       ;Replace if not

NQ        LDY #0         ;Bump ptr to other sym
          LDA (PNTSV),Y
          AND #$F
          CLC
          ADC #4
          ADC PNTSV
          STA PNTSV
          BCC :NI
          INC PNTSV+1
          CLC
:NI       LDA (PNTSV),Y
BYES      BEQ YES        ;Branch if no more
          TAX            ; to check
          ASL            ;Used flag to carry
          RTS

SY        JSR SENDMSG
          HEX 8D8D8D
          ASC "Symbol table - "00
          RTS

BNX       JMP BYL

* Symbol printing routine:

* Flag as done, & check flags.

YES       LDA ASV
          EOR #$40       ;Invert found flag
          STA WRITE.AUX
          STA (SYMPNT),Y
          STA WRITE.MAIN
          STA READ.MAIN
          BCS BNX
          AND #%10110000
          STA FLGG
          LDX #3         ;Set for 3 blanks
          ASL
          ORA FLGG
          STA FLGG
          AND #$20
          BEQ :CHB
          LDA #"M"
          DEX
          JSR COUT
:CHB      JSR GETSYM
          CMP #']'
          BNE :RR
          LDA #"V"
          BNE :CO
:RR       BIT FLGG
          BVC :R1
          LDA #"D"
:CO       DEX
          JSR COUT
          LDY #0
          BEQ :R3
:R1       LDA ASV
          AND #$F
          TAY
          JSR GETSYM     ;Get flag byte
          LDY #0
          ASL
          BPL :R2
          LDA #"X"       ;EXT
:SFL      JSR COUT
          DEX
          TYA            ;Force branch
:R2       ASL
          BPL :R3
          LDA #"E"       ;ENT
          BNE :SFL       ;Always
:R3       LDA #" "
          BIT FLGG
          BMI :BLNK
          LDA #"?"
:BLNK     JSR PRBL3
          LDX SLEN
]LOOP     JSR GETSYM
          JSR PRINT
          DEX
          BNE ]LOOP
          LDA TABS
          SEC
          SBC #7
          SBC SLEN
          BCC :EQ
          TAX
          INX            ;Has tab index
          JSR PRBL2
:EQ       JSR SENDMSG
          ASC "=$"00

* Print number

          STY PL         ;In case a mac def
          LDY SLEN
          INY
          LDX #5
          LDA ASV
          ASL
          ASL
          AND #$80
          BMI :JP        ;Branch if mac def
          JSR GETVL      ;Returns with PL+1 in A
          BEQ :ONEBY     ;Branch if z-page
:JP       DEX
          DEX
          STA PL+1       ;In case mac def
          JSR PRBYTE
:ONEBY    LDA PL
          JSR PRBYTE
          DEC TAB
          BEQ :BEGIN
          JSR PRBL2
          JMP KEY?
:BEGIN    JMP BEGIN
