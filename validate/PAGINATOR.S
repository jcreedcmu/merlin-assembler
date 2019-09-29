*---------------
*   Paginator
*---------------

* External:

LISTFLG   = $D1          ;Minus at end of assembly

* Usage by this program:

PAGVEC    = $A0          ;Holds old COUT adrs
PAGFLAG   = $A2          ;Minus if ASM cmd found
XSAV      = $A3
YSAV      = $A4
LINCNT    = $A5          ;Line counter, each page
PAGE      = $A6          ;Page count
DIGFLG    = $A8          ;Decimal print usage
CHRCNT    = $A9
HEADLEFT  = $AA
TITLE     = $110         ;Users file name goes here

NUMLINES  DFB 60
PAGSKIP   DFB 0
NUMCHRS   DFB 81         ;Number of columns + 1
PRNTRCR   DFB $80        ;- if printer will do CR

PAGINATE  BIT PAGFLAG    ;Has asm started?
          BMI DOPAG      ;Branch if so
GOVID     JMP (VIDVEC)

* Main output routine after assembly has begun:

DOPAG     STX XSAV
          STY YSAV
PUSHA     PHA
          CMP #$8C
          BNE CR?
          DEC LINCNT
          BIT LISTFLG    ;Assembly done?
          BPL NEWPG      ;Branch if not
          PLA            ;Pop stack and
          JMP NOACTION   ; avoid printing header.
CR?       CMP #$8D       ;Carriage return?
          BNE NOTRTN     ;Branch if not
SETCNT    MOV NUMCHRS    ;CHRCNT
          DEC LINCNT     ;Count down lines if so
          BNE LENOK      ;Branch if page not full
NEWPG     LDA PAGSKIP
          BNE DUMBPRTR
          LDA VIDVEC+1
          CMP PAGVEC+1
          BEQ LRT        ;If not printer
          CLC            ; then substitute CR.
LRT       LDA #$8D/2
          ROL
          LDX #2
          BNE JPR        ;Always

DUMBPRTR  SEC
          ADC LINCNT
          TAX
PRSPC     JSR SPACE
JPR       JSR SNDCHR
          DEX
          BNE PRSPC
          LDA NUMLINES
          SEC
          SBC #3
          STA LINCNT     ;Reset line count if page full
          MOV NUMCHRS    ;CHRCNT
          SED            ;Update page count, decimal mode
          TXA            ;X=0, carry is set
          ADC PAGE
          STA PAGE
          TXA
          ADC PAGE+1
          STA PAGE+1
          CLD            ;Clear decimal flag
          LSR DIGFLG     ;Init leading digit flag
          LDX HEADLEFT
HEADTAB   JSR SPACE
          DEX
          BNE HEADTAB
          JSR PRHEAD
          JSR PRPAG
          LDA TITLE      ;User supplied name?
          BEQ REST       ;Branch if not
          INX
          JSR PRHEAD
          TAY
SNDNAM    LDA TITLE,Y
          BEQ REST       ;Rest of header
          JSR SNDCHR
          INY
          BNE SNDNAM     ;Always
REST      LDX #WNDUP-PAGMSG
          JSR PRHEAD
NOTRTN    CMP #" "
          BLT LENOK
          DEC CHRCNT
          BNE LENOK
          BIT PRNTRCR    ;Will printer do CR?
          BMI SETCNT     ;Yes, let it
          LDA #$8D       ;No, do it for the idiot
          JSR PUSHA
LENOK     PLA            ;Wind up
          CMP #$8C       ;Formfeed?
          BNE NOACTION
          JSR SPACE      ;Substitute CR, ff was sent
NOACTION  LDY YSAV
          LDX XSAV
SNDCHR    JMP (PAGVEC)

PAGMSG    ASC "===== Page "00
          ASC " - "00
WNDUP     ASC " ====="8DA000

SPACE     LDA #" "       ;Dumb printers require this
          JSR SNDCHR
          LDA #$8D
          RTS

JP        JSR SNDCHR
          INX
PRHEAD    LDA PAGMSG,X
          BNE JP
RTN       RTS

PRPAG     LDA PAGE+1
          JSR PR2DIG
          LDA PAGE
PR2DIG    PHA            ;Save byte
          LUP 4          ;Shift high nibble down
          LSR
          --^
          JSR PRDIG      ;Go to send routine
          PLA            ;Get byte back
          AND #$F        ;Mask low nibble
PRDIG     BNE DODIG      ;Always send if not 0
          BIT DIGFLG     ;Has a digit been sent?
          BPL RTN        ;Exit if not (leading 0)
DODIG     ORA #"0"       ;Add numeric offset
          STA DIGFLG     ;Show printing has started
          BNE SNDCHR     ;Send it; always taken
          ASC "GEB"
