*----------------------------------------
* Assembler routines to go on $D000 bank1
*----------------------------------------

PRNTAX    JSR PRBYTE
          TXA
PRBYTE    INC CHRCNT
          INC CHRCNT
          JMP $FDDA

CROUT     LDA #0
          STA CHRCNT
          JMP $FD8E

HTABX     LDA TABS,X
          CLC
          ADC #30-14
DOHTAB    CLC
          SBC CHRCNT
          BMI TABBED
          TAX
          INX
PRBL2     LDA #" "
PRBL3     JSR PRINT
          DEX
          BNE PRBL2
TABBED    RTS

ADDSPACE  LDY OPNDLEN
          LDA #' '
          STA OPERAND,Y
          STA OPERAND+1,Y ;Possible 2nd quote
          STA OPERAND+2,Y ;In case no opnd
          RTS

DOPRINT   JSR LIST?
          CLC            ;Flag exit point
          BNE RET
PREST     LDA SPCNT      ;If SPCNT activated then
          BEQ :HT
          LSR ASCFLG     ; don't use ASCFLG
:HT       HTAB 15
          JSR SNDLNU
          HTAB 21
          LDY #-1
          LDA LABEL
          BPL O1
          CMP #"         ;"
          BEQ O2
          CMP #$8D
          BNE O4         ;If not, it is "*"
          RTS            ;Carry is set

PRLAB0    INY
PRLAB     LDA LABEL,Y
          JSR PRINT
          EOR #" "
          BNE PRLAB0
RET       RTS

O1        JSR PRLAB0
          TAX            ;=0
          JSR HTABX
          LDY #OPCODE-LABEL
          JSR PRLAB
O2        LDX #1
EQ1       = *-1
          JSR HTABX
          LDY #0
          BIT ASCFLG
          BMI CYL
          LDA OPERAND
          CMP #'         ;'
          BNE :ISSP
          BEQ O3
]LOOP     JSR PRINT
          INY
          LDA OPERAND,Y
:ISSP     CMP #' '
          BNE ]LOOP
          DEC SPCNT
          BPL ]LOOP
          INY
          JSR SPACE
O3        LDX #2
          JSR HTABX
          JMP CYL        ;Not really needed
]LOOP     LDA OPERAND,Y
          JSR PRINT
O4        INY
CYL       CPY OPNDLEN
          BLT ]LOOP
          LDA CYCFLG
          BNE DOCYC
O5        RTS            ;Carry is set

DOCYC     LDY OPSAV
          INY            ;Valid opcode?
          BEQ O5         ;Exit if not
          LDA TIMETBL-1,Y ;Get time and flags
          BIT XCFLAG
          BPL :SOS       ;Skip if 6502
          BVS :SOS       ; or 65802
          TAX            ;Save it
          AND #8         ;Test irreg flag
          BEQ :XOS       ;Skip if not irreg
          LDX #6         ;Set 6 cycles
          CPY #$6C+1     ;Is it JMP ()?
          BEQ :XOS       ;Branch if so
          LDX #$86       ;Set extra cyc bit if not
:XOS      TXA
:SOS      AND #%11110111 ;Strip irreg bit
          STA OPSAV      ;Keep in OPSAV
          BIT OPSAV      ;Check branch flag
          BVC :MSK       ;Skip if not branch
          LDX #0
          LDA PL
          BPL :CC
          DEX
:CC       CLC
          ADC ADRS
          TXA
          ADC #0
          BNE :GT        ;Branch if page crossed
          LDA OPSAV      ;Strip flag if not
          BMI :NOTBR     ;Branch if not BRA
          LDA #3
:NOTBR    AND #%10001111
          STA OPSAV
:GT       LDA OPSAV
:MSK      AND #%00001111 ;Strip flags
          TAY
          LDA CYCFLG     ;Ave requested?
          CMP #' '!'F'
          BEQ :NOAVE     ;Skip if not
          EOR #1
          TAX            ;Do every other time
          LSR            ;This time? (to carry)
          TYA            ;Get count
          BIT OPSAV      ;Cycles to add?
          BPL :SETD      ;Skip if not
          STX CYCFLG     ;Toggle bit 1
          BVC :AVE       ;Branch if 1 cycle
:ADD1     INY            ;Always add 1 if 2 cycles
:NOAVE    TYA
          BNE :SETD      ;Always
:AVE      BCS :ADD1      ;Taken every other time
:SETD     SED
          CLC
          ADC ACCTIM     ;Add to accum time
          STA ACCTIM
          LDA #0
          ADC ACCTIM+1
          STA ACCTIM+1
          CLD
          LDA HORIZ
          JSR DOHTAB
          LDA OPSAV
          JSR PRHEX      ;Print time
          LDA #" "
          BIT OPSAV
          BPL :SFLG
          LDA #"""
          BVS :SFLG
          LDA #"'"
:SFLG     JSR PRCHR      ;Print flag
          LDA #","
          JSR PRCHR
          LDX ACCTIM
          LDA ACCTIM+1
          JSR PRNTAX     ;Print accum time
          SEC            ;Must set to exit DOPRINT
ABK       TYA            ;For exit from CHKCODE
R1        RTS

CHKCODE   TAY
          STA OPSAV      ;Save for CYC
          LDA #$20       ;Set to test bit
          BIT XCFLAG
          BPL :REG       ;Branch if 6502
          BVS ABK        ;Exit if 65802
          LSR            ;Test $10 bit for 65C02
:REG      AND TIMETBL,Y
          BNE ABK        ;Branch if valid
          JMP BADOPC     ;(9/4/84 was ADRERR)

GETCODE   LDA BITS-1,X
          LDY #2
          AND (TBLP),Y   ;Exit with Z true if
          BEQ R1         ; not valid
          INY
GETAB     LDA (TBLP),Y   ;Get opcode base #
          DEX
          BNE :NI        ;Branch if not imm mode
          CMP #$20       ;Support BIT # for 65C02
          BEQ :LS
          BIT EQ1        ;Test bit 0
          BEQ ISVAL      ;If 0 then have code
:NI       ORA MASK,X     ;Add mode bits
          CMP SPECIAL,X  ;Convert the oddballs
          BNE :NEWIMP
:LS       LDA SPECIAL+1,X
:NEWIMP   CMP #$CA       ;DEC imp
          BEQ :SPEC
          CMP #$EA       ;INC imp
          BNE ISVAL
:SPEC     EOR #$F0
ISVAL     JSR CHKCODE    ;Check valid if not XC mode
          HEX 2C         ;Skip
PRPL      LDA PL
PRCODE    LDX PASNUM
          BEQ INAD
          STA TEMP
          STY SIG
          BIT DUMFLAG
          BPL JL
          STX STARTFL    ;Flag code started
          EOR CHKBYT
          STA CHKBYT
          LDA ASMPNT
          BIT DIRFLG
          BMI DODSK
          LDX #0
          CMP FENCE
          LDA ASMPNT+1
          BEQ GME        ;Err if OBJ on page 0
          SBC FENCE+1    ;Don't write OBJ if
          LDA TEMP       ;above FENCE
          BLT :PUTBYT
          ROR ORGFLG     ;and defeat OBJ save.
          BMI JL         ;Always
:PUTBYT   STA WRITE.AUX
          STA (ASMPNT,X)
          STA WRITE.MAIN
JL        JSR LIST?
          BNE INAS
          LDA TABCNT
          BEQ :P1        ;Branch on 1st entry
          CMP #3         ;Rest of line now?
          BLT :P2
          BNE :BT        ;Skip if done before
          JSR PREST      ;Print rest of line
          LDA BYTLINE
          ORA #$80
          STA TABCNT
:BT       BIT TRFL
          BMI INAS       ;Branch if no more wanted
          SBC BYTLINE
          BPL :P2
          STA TABCNT     ;Starts with $80
          JSR CROUT      ;Do CR & print new adrs
:P1       LDA ADRS+1
          LDX ADRS
          JSR PRNTAX
          LDA #":"
          LDX #2
          JSR PRBL3
:P2       LDA TEMP
          JSR PRBYTE
          JSR SPACE      ;Don't just inc CH
          INC TABCNT
INAS      BIT DUMFLAG
          BPL :LYS
          INCD ASMPNT
:LYS      LDY SIG
INAD      INCD ADRS
          LDA #$FF       ;To clear z-flag
          RTS

GME       JMP MEMERR

DODSK     SEC
          SBC OBJPNT
          STA MRKPOS
          LDA ASMPNT+1
          SBC OBJPNT+1
          STA MRKPOS+1
          LDA ODREF
          STA MRKREF
          LDA TEMP
          STA BYTE
          JMLI setmark   ;MRK
          JMLI write     ;DSK
          JMP JL

NXOPS     LDA #1
          BNE NX
GETOPC    LDX #4
          STA TBLP
          STY TBLP+1
CLCAR     CLC
COMPR     LDY #0
          LDA (TBLP),Y
          BEQ R2         ;Branch if this tbl done
          CMP PACKL
          BEQ IY
NEXT      TXA            ;No match, add X to TBLP
NX        CLC
          ADC TBLP
          STA TBLP
          BCC COMPR
          INC TBLP+1
          BNE CLCAR      ;Always
IY        INY
          LDA (TBLP),Y
          CMP PACKR
          BNE NEXT
          INY            ;Point to byte after opcode
R2        RTS            ;Carry set iff found

XC        BIT XCFLAG
          BVS PRNTLIN    ;Branch if now on
          ROR XCFLAG     ;Turn xc on
          BCC PRNTLIN    ;Branch if sw off
SW        LSR XCFLAG
          SEC
          ROL XCFLAG
          BNE PRNTLIN    ;Always

PRNTLIND  BIT LSTDOFLG   ;Print do off requested?
          BPL PRNTLIN    ;Branch if so
          BIT ZMDO       ;In mac def do on?
          BMI PRNTLIN    ;Print condl if so
PRLUP     LDA #' '       ;Print line only
          CMP LABEL      ; when labeled.
          BEQ JPST

PRNTLIN   LDA PASNUM
OUTPUT    BEQ JPST
          BIT TABCNT
          BMI WASDON
          JSR DOPRINT
          BCC JPST       ;If from LIST check
WASDON    JMP ENDLIN

PAUSE     JSR PAU
JPST      JMP START

* Main symbol table build routine
* (first decide if time to do it)

SETLAB    LDA LABEL
          EOR #' '
          BEQ R3
          JSR MVLA       ;Leaves LABEL in A
          EOR #']'
          PHA
          LDX PASNUM
          BEQ :FL
          PLA            ;Varl?
          BNE ISZP       ;Branch if not
          TAX
          PHA            ;Set to branch
:FL       JSR FINDLAB
          TYA
          BEQ PA         ;Branch if not in table yet
          PLA
          BEQ CHVAR
          LDA ZMDO
          BNE R3         ;Exit if dup lab in mac def
          LDY MACLEV     ;In macro copy?
          BEQ DUP        ;Err if not
          LDA PACKL
          EOR #$68       ;MAC
          BEQ JPST       ;Branch nested mac def, DO off
          BNE PUTLAB     ;Always

ISLOC     CMP #':'!']'
          BEQ INMAC
          LDX MACFLG
          BNE R3
          STX PASNUM
          INC MACLEV
          JSR GETLAST
          BIT OVERIDE    ;Set V flag
:AGAIN    JSR FINDLAB0
          CLV
          TYA
          TAX
          BEQ :AGAIN
          INC PASNUM
          DEC MACLEV
SETLS     TRDB SYMPNT    ;LASTSYM
          RTS

ISZP      LDX ADRS+1     ;On zp? (DUM)
          BNE ISLOC
          JSR FINDLAB
          BIT ASV        ;Used?
          BMI ILLFOR     ;Error if so
R3        RTS

INMAC     LDA MACFLG
          BNE MLERR
          RTS

DUP       INC DUPCNT
          ERX dup
          BNE GOERR

CHVAR     LDA PACKL
          EOR #$E8       ;=?
          BEQ R3
          EOR #$2C!$E8   ;EQU?
          BNE PUTLAB
          RTS
PA        PLA
          BEQ :NOTGLO    ;Treat varl as local
          CMP #':'!']'
          BNE :GLO
          LDA MACFLG
          BNE MLERR
          LDA #$40
          STA MACFLG
          BNE :NOTGLO
:GLO      JSR SETLS      ;Set LASTSYM
:NOTGLO   TYA
PUTLAB    PHA
          LDY #0
          LDA LEN
          TAX
          ORA MACFLG
          STA WRITE.AUX
          STA (SYMPNT),Y
          AND #$30
          STA MACFLG     ;Strip loc flag
          INY
]LOOP     LDA LABEL-1,Y
          STA (SYMPNT),Y
          INY
          DEX
          BNE ]LOOP
          LDA DUMFLAG    ;Flag labels in dummy
          EOR #$80       ; as absolute
          ORA ABSFLAG    ;Same for ORGed section
          AND #$80
          STA (SYMPNT),Y
          INY
          STIND ADRS     ;SYMPNT
          INY
          PLA            ;Don't put the end 0
          BNE :SM        ;if variable re-defn
          STA (SYMPNT),Y
:SM       STA WRITE.MAIN
          TYA
          ADC SYMPNT
          TAY
          TXA            ;=0
          ADC SYMPNT+1
          CPY OBJPNT
          SBC OBJPNT+1
          BLT R5
MEMERR    ERX mem
          JMP GOER
ILLFOR    ERX forward
          HEX 2C
MLERR     ERX lab
          HEX 2C
OPDERR    ERX opnd
GOERR     JMP ERR2

ABSOP     JSR EVLOPND
          LSR RELCNT
          BCC R5         ;Return if opnd is abs
ILLREL    ERX illrel
          BNE GOERR
ABSOPND   BIT RELFLAG
          BMI ABSOP      ;Branch if rel mode
EVLOPND   JSR CHKOPND
          LDA NOTFND     ;All labels found?
          ORA EXTFLAG    ; or an external
          BMI ILLFOR     ;Err if not
          LDA PL
          LDY PL+1
R5        RTS

ASCHEX    EOR #'0'
          CMP #10
          BLT R5
          ADC #$88
          ORA #$20       ;Enable lower case ascii
          CMP #$FA
          BLT OPDERR
          EOR #$F0
          RTS

FLAG      PAS?
          BEQ GETVL
          LDA ADRS+1
          BEQ GETVL      ;Don't flag if on 0 pg
          STY TEMP
          LDY #0
          LDA ASV
          ORA #$80       ;Used flag
          STA WRITE.AUX
          STA (SYMPNT),Y
          STA WRITE.MAIN
          LDY TEMP
GETVL     JSR GETSYM
          STA PL
          JSR GETSYM
          STA PL+1
          RTS

FINDLAB   CLV
FINDLAB0  STX OFFSET     ;Pointer to 1st label chr
          LDA WORKSP,X
          CMP #':'
          PHP
]LOOP     LDA WORKSP,X   ;Find 1st non-label character
          INX
          CMP #'0'
          BGE ]LOOP
          LDA WORKSP-2,X
          CMP #']'
          BNE :CC
          DEX
:CC       CLC
          TXA
          DEX
          STX OFF        ;Remember next ptr
          SBC OFFSET
          STA LENGTH     ;Length of sym
          PLP
          BEQ FINDLL     ;Branch if local
          LDY #SYMADR    ;=0
          BVS LBV        ;Branch if short search
          STY SYMPNT
          LDA #>SYMADR
          STA SYMPNT+1
          BNE LBV        ;Always

]LOOP     INX
          CPY LENGTH
          BGE FOUND0
CMPR      INY
          STA READ.AUX
          LDA (SYMPNT),Y
          STA READ.MAIN
          CMP WORKSP,X
          BEQ ]LOOP
          LDA LENGTH
          LDY #0
REJECT    CLC
          ADC #4
          ADC SYMPNT
          STA SYMPNT
          BCC LBV
          INC SYMPNT+1
LBV       STA READ.AUX
          LDA (SYMPNT),Y ;Y=0
          STA READ.MAIN
          BEQ ENDSYM
          AND #$1F
          CMP #$10
          BGE :MC
          CMP LENGTH
          BNE REJECT
:LX       LDX OFFSET
          BCS CMPR       ;Always
:MC       EOR MACFLG     ;In a macro?
          CMP LENGTH     ; and correct length
          BEQ :LX        ;Check it if so
          AND #$F        ;Reject if not
          BPL REJECT

FOUND0    JSR GTLEN
          LDY LENGTH
FOUND     INY
          LDA ASV
          AND #$20       ;Macro def?
          BEQ R6         ;Leave if not
          LDA MACLEV     ;From a PMC?
          BEQ JLE        ;Error if not
R6        RTS

JLE       JMP LABERR

FINDLL    JSR GETLAST
          BEQ ENDSYM
          INX            ;Force branch to REJECTL
CMPRL     CPX LENGTH
          BNE REJECTL
          LDX OFFSET
]LOOP     INX
          CPY LENGTH
          BGE FOUND
          JSR GETSYM
          CMP WORKSP,X
          BEQ ]LOOP
REJECTL   JSR NXTSYM
          JSR GTLEN
          BEQ ENDSYM
          TAX
          JSR GETSYM
          CMP #':'
          BEQ CMPRL
          CMP #']'
          BEQ REJECTL
                         ;Drop into:
ENDSYM    DEC NOTFND
          LDX OFF
          PAS?
          TAY
          BEQ R6

* On exit from FINDLAB, Y=0 if not found,
* and Z-status is true if not found OR
* if not a MACRO defn.

          ERX unknown
          JMP TWOERR

DIV       LDA #0
          STA XTND
          LDY #$10
]LOOP     ASL SPL
          ROL SPL+1
          ROL
          ROL XTND
          PHA
          CMP PL
          LDA XTND
          SBC PL+1
          BCC :D
          STA XTND
          PLA
          SBC PL
          PHA
          INC SPL
:D        PLA
          DEY
          BNE ]LOOP
          TRDB SPL       ;PL
JNXO      JMP NXOPTR

DIVMUL    BEQ DIV
          JSR MULT
          BEQ JNXO       ;Always

VALOPND   JSR ISVAL      ;Fall into CHKOPND
CHKOPND   LDX #0
          STX PARFLG
          LDA OPERAND
          CMP #'\'       ;Support check of this
          BEQ CHOP0      ; from ABSOPND
          CMP #'('
          BEQ :DP
          CMP #'['
          BNE CHOP
          CLC
:DP       DEC PARFLG     ;Flag address mode
          ROR PARFLG     ;FF=(, 7F=[
CHOP0     INX
CHOP      LDA #0
          STA NOTFND     ;Init not found flag,
          STA RELCNT     ; rel sym count,
          STA EXTFLAG    ; external flag,
          STA DMFLAG     ; and div/mult flag
          DEX
          STA INDEX
CHOPLOOP  TRDB PL        ;SPL ;Save last result
          TRDB ADRS      ;PL ;Default next to adrs
          CLC
:RM       ROR MINUS
          INX
          LDA OPERAND,X
          CMP #'-'
          BEQ :RM
          LDY #RTBLEND-ROUTBL
]LOOP     DEY
          CMP ROUTBL,Y
          BLT ]LOOP
          BEQ :OK
:C0       CMP #'0'
:OK       LDA ROUTADR,Y
          STA :GO+1
          LDY #0
          BLT :C0
:GO       JSR BIN        ;Address changed!
          BIT MINUS
          BPL :ARITH
          BVS JOD
          POKE ACL       ;-1
          JSR MULT2
:ARITH    LDY INDEX      ;First time?
          BEQ NXOPTR     ;Skip math if so
          CPY #LOGIC-OPTBL
          BLT :ISM
          ROR DMFLAG
          CPY #DVML-OPTBL
          BGE DIVMUL
:ISM      CPY #MATHOP-OPTBL+1 ;Get correct carry
          LDA CODE-MATHOP+OPTBL,Y
          STA :OP1
          STA :OP2
          LDA SPL
:OP1      ADC PL
          STA PL
          LDA SPL+1
:OP2      ADC PL+1
          STA PL+1
NXOPTR    LDA OPERAND,X  ;Next operator
          LDY #ENDTBL-OPTBL+1
NXY       DEY
          BMI JOD
          CMP OPTBL,Y
          BNE NXY
          STY INDEX
          CPY #MATHOP-OPTBL
          BGE CHOPLOOP   ;Another label & arith
          PHA
          LDA RELFLAG    ;If REL mode
          AND DMFLAG     ; and had a div/mult
          AND OVERIDE    ; and check not defeated
          BPL :XCHOP
          LDA RELCNT     ; then check # of rels
          LSR
          BCS DMERR      ; and err if this odd
:XCHOP    PLA
          RTS

* Legal exit from CHOP, carry is clear,
* X points to next character:
* ')', ' ' or ',' as Y=0,1,2.

DMERR     JMP ILLREL
JOD       JMP OD

MULTEN    POKE ACL       ;10
          LDA #0
          BEQ MULT2

MULT      MOV SPL        ;ACL
          LDA SPL+1
MULT2     STA ACL+1
          LDA #0
          STA XTND
          LDY #$11
]LOOP     LSR XTND
          ROR
          ROR PL+1
          ROR PL
          BCC :M
          CLC
          ADC ACL
          PHA
          LDA ACL+1
          ADC XTND
          STA XTND
          PLA
:M        DEY
          BNE ]LOOP
          RTS

VAR       MOV OPNT       ;LVPNT
          MOV OPNT+1     ;LVPNT+MX
          BNE GONXL

DDB       CLC
DA        ROR LEVEL
]LOOP     TAX
          JSR CHOP
          DEY
          PHP
          TXA
          TAY
          BIT LEVEL      ;DA or DDB?
          BMI :ISDA      ;Branch if DA
          LDA PL
          LDX PL+1
          STA PL+1
          STX PL
          LDA #%10101111 ;2 byte reversed
          HEX 2C
:ISDA     LDA #%10001111 ;2 byte ord
          JSR MAKDIC
          JSR PRPL
          LDA PL+1
          JSR PRCODE
          PLP
          BEQ GONXL
          INY
          TYA
          BNE ]LOOP

NY        INY
DFB       LDA OPERAND,Y
          CMP #'#'
          BEQ NY
          TYA
          TAX
          JSR MAKNUM
          DEY
          PHP
          TXA
          TAY
          JSR PRPL
          PLP
          BNE NY         ;Was not a space
GONXL     JMP PRNTLIN

CYC       STA ACCTIM
          STA ACCTIM+1
          LDX #CYCFLG-EXPFLG
          LDA #'F'!' '
          HEX 2C
LSTD      LDX #LSTDOFLG-EXPFLG
          HEX 2C
LST       LDX #LSTFLG-EXPFLG
          EOR #' '
EXP       EOR OPERAND+2  ;Only 2 bit
          STA EXPFLG,X   ;is significant
          BCS JS         ;Always

TRUNC     LDA PASNUM
          BEQ JS
          LDA OPERAND+2
          ASL
          ASL
          STA TRFL
JS        JMP START

ERRADR    JSR ABSOPND
          STA SPL
          STY SPL+1
          LDA #%11101111
          STA FLAGS
          JSR MAKDIC2
          BIT RELFLAG
          BMI GONXL
          LDA PL
          CMP ADRS
          LDA PL+1
          SBC ADRS+1
          BGE GONXL
          BLT BRKERR

USERR     LDA OPERAND
          CMP #'\'
          BEQ ERRADR
          JSR CHKOPND
          TYA            ;Syntax ERR (...)...?
          BNE :UE        ;Branch if not
          LDA (PL),Y     ;Get (...)
          STA PL
          STY PL+1
          INX
          JSR NXOPTR     ;Do following arith if any
:UE       LDA PL
          ORA PL+1
          BEQ GONXL
BRKERR    ERX break
          BIT PARFLG
          BPL ERROR
          JMP GOER

CHKLAB    LDA LABEL      ;Used by EQU, MAC, EXT, ENT
          CMP #':'
          BEQ BADLAB
          CMP #' '
          BEQ BADLAB
          RTS
BADLAB    ERX lab

ERR2      LDA FENCE+1
          BNE :YZ
          ERX unknown
          BNE ERR3       ;Always
:YZ       LDY #0
          JSR FIXSPNT
          LDY MACLEV
          BEQ ERR3
          LDA PNSV       ;Real pass
          BEQ ERR3
          LDA PNSV-1,Y
          BEQ JS
ERROR     LDA PASNUM
          BEQ JS
ERR3      STX ORGFLG
          STX ISERR      ;Flag for XREF
          STADR ERRTBL   ;TBLP
          JSR CROUT
          CPX #mem-ERRTBL/2
          BGE :LP
          JSR SEND0
:LP       TXA
          BPL :OK
          INC TBLP+1
:OK       ASL
          TAY
          LDA (TBLP),Y
          BMI :ND
          DEY
:ND       JSR SEND
          LDA FENCE+1
          BEQ GOQU
          JSR ADDSPACE
          JSR SENDMSG
          ASC " in line:"00
          JSR JBELL
          LDA PLIN
          ORA PLIN+1
          AND PUTFLG
          BEQ :SLN
          JSR REGLN
:SLN      JSR SNDLNU
          JSR CROUT
          INC ERCOUNT
          JSR LIST?
          ORA ABORTFLG   ;List off or asm abort?
          BEQ BST        ;Branch if not
          JSR PREST
          JSR CROUT
          LDA ABORTFLG
          BEQ BST
GOQU      SEC
          ROR LSTFLG     ;To bypass sym printing
          JMP QUIT
BST       BIT STROBE
          BIT ASSERR
          JMP ERRWAIT

SNDLNU    BIT PUTFLG
          BPL REGLN
          LDA PLIN
          TAX            ;Save for later
          ORA PLIN+1
          BEQ REGLN
          LDA #">"
          JSR PRINT
          LDA PLIN+1
          BPL SNDLN      ;Always
REGLN     JSR SPACE
          LDX LINNUM
          LDA LINNUM+1
SNDLN     JMP PRDEC

* Follg have A=Y=X=0, and carry set on entry:

FINDLEN   LDA OPERAND
]LOOP     INY
          CPY OPNDLEN
          BGE JOPD
          CMP OPERAND,Y
          BNE ]LOOP
          RTS

REV       JSR FINDLEN
]LOOP     DEY
          BEQ BJNL
          LDA OPERAND,Y
          ORA HIBIT
          JSR PRCODE
          BNE ]LOOP      ;Always

FLS       LDA #$40
INV       STA FLSH
          STX HIBIT
          STX DCMSK
          LDX #$3F
          BNE ASC1
STR       JSR FINDLEN
          DEY
          TYA
          JSR PRCODE
          LDA #0
          TAY
          TAX
          CLC
DCI       ROR            ;= LDA #$80
ASC       STA DCMSK
          STX FLSH
          DEX
ASC1      STX INVFL
          INY            ;1
]LOOP     LDA OPERAND,Y
          AND INVFL
          ORA FLSH
          ORA HIBIT
          INY
          CPY OPNDLEN
          BGE JOPD
          LDX OPERAND,Y
          CPX OPERAND
          BEQ CNG
          JSR PRCODE
          BNE ]LOOP      ;Always

]LOOP     LDA OPERAND,Y
          CMP OPERAND    ;2nd delimiter?
          BEQ COLON
          JSR PRINT      ;Print spec string
OPNDMSG   INY
          CPY OPNDLEN
          BLT ]LOOP
JOPD      JMP OPDERR

HEX       LDA OPERAND,Y
          CMP #' '
BJNL      BEQ JNL
          CMP #','
          BEQ HX2
          JSR ASCHEX
          LUP 4
          ASL
          --^
          STA DCMSK
          INY
          LDA OPERAND,Y
          JSR ASCHEX
CNG       EOR DCMSK
          JSR PRCODE
HX2       INY
          BNE HEX        ;Always

KBDERR    ERX input
          JMP GOER

REALPAS   LDA PASNUM
]LOOP     BNE JNL
          DEY
          BEQ GPT
          LDA PNSV,Y
          BPL ]LOOP      ;Always
VARL      LDY MACLEV
          BNE REALPAS
GPT       JSR PTADR
JNL       JMP PRNTLIN

KBD       LDA OPERAND
          EOR #'         ;'
          BNE :PAS
          STA ASCFLG
:PAS      LDY PASNUM
          BNE JCL
          PHA
          JSR WARMDIS
          PLA
          BEQ REGMSG
          CMP #' '!'     ;'
          BNE OPNDMSG    ;Branch if so
REGMSG    JSR SENDMSG
          ASC "Give value for "00
          JSR PRLAB
COLON     JSR SENDMSG
          DFB ":",0
          JSR JBELL
          JSR GETLN2
          TXA
          TAY
          DEX
          CPX #LABEL-1   ;No input or too long?
          BGE KBDERR
          JSR REHOOK
          LDA #' '
          BNE :SO
]LOOP     LDA IN,Y
          AND #$7F
:SO       STA OPERAND,Y
          STA WORKSP,Y   ;Enable labels
          DEY
          BPL ]LOOP
                         ;Fall into EQU
EQU       JSR EVLOPND
          LSR RELCNT
          LDA #0         ;Flag sign bit on
          ROR            ; if abs, off if rel
          EOR #$80
          STA FLAGS
JCL       JSR CHKLAB
          CMP #']'
          PHP
          JSR MVLA
          JSR FINDLAB
          PLP
          BEQ VARL
          LDA PASNUM
          BEQ GPT
          JSR GETVL      ;Page 0?
          BNE JNL        ;OK if not.
          BIT ASV        ;Used?
          BPL JNL
          JMP ILLFOR     ;Err if so

PTADR     JSR GTLEN
          TAY
          INY
          LDA FLAGS
          STA WRITE.AUX
          STA (SYMPNT),Y
          INY
          STIND PL       ;SYMPNT
          STA WRITE.MAIN
          RTS

PAG       LDX CSWH       ;Printer?
          CPX VIDVEC+1
          BEQ GST        ;Ignore if not
          CLC
SKP       ADC #$8C       ;Carry is set for SKP
          HEX 2C         ;Skip
AST       LDA #"*"
          LDX PASNUM
          BEQ GST
          LDX LSTFLG
          BNE GST
          CMP #$8C
          BEQ JCO
          PHA
          JSR CHKOPND
          HTAB 21
          PLA
]LOOP     JSR COUT
          DEC PL
          BNE ]LOOP
          AND #$20
          BNE ENDLIN
          BEQ GST

DATE      LDA PASNUM
          BEQ GST        ;Ignore on 1st pass
          JSR LIST?
          BNE GST        ; or not listing
          JSR HTABX      ;Tab to opnd col
          JSR JPRDATE    ;Print date
ENDLIN    LDA #$8D
JCO       JSR COUT
          JSR KEYCHK
GST       JMP START

NEWPAG    SBC ADRS       ;A=Y=0 here, carry is set
          INX            ;=1
FILL      STY PNTSV+1    ;Save amount of fill
          STA PNTSV
          LDA OPERAND,X
          EOR #' '       ;Fill with?
          STA PL
          BEQ :REL       ;Branch if not specified
          JSR CHOP0      ;Get fill chr
:REL      PLA
          BNE :FIL
          BIT RELFLAG
          BPL :FIL
          LDA #%11001111
          STA RELCNT     ;Force dic entry
          JSR MAKDIC
          JMP PRNTLIN
:FIL      LDA PNTSV
          BNE :ND
          DEC PNTSV+1
          BMI JPL
:ND       DEC PNTSV
          JSR PRPL
          BNE :FIL       ;Always

DS        LDA OPERAND
          EOR #'\'
          PHA
          BEQ NEWPAG
          JSR ABSOPND
          LDY PL+1
          BPL FILL
          ADAY ADRS
          LDA PASNUM
          BEQ GST        ;In case in macro
          BIT DUMFLAG
          BPL JPL
          LDA PL
          ADAY ASMPNT
JPL       JMP PRNTLIN

MAC       JSR CHKLAB
          LDA DOFL
          BNE :BPF
          LDX MACLEV     ;Skip to next line if
          BNE GST        ; called by PMC
          ROR DOFL
:BPF      LDA #$80
          STA ZMDO
          LDA SPNT
          CMP HIMEM
          LDA SPNT+1
          SBC HIMEM+1
          BGE :XP        ;Allow USE macro def.
          BIT PUTFLG
          BMI PUTER
:XP       LDX PASNUM
          BNE SPS
          TRDB SPNT      ;PL
          JSR PTADR      ;Src adrs in sym tbl
          STA READ.AUX
          LDA (SYMPNT,X)
          STA READ.MAIN
          AND #%11101111 ;Strip "in mac" flag
          ORA #$20       ;Flag len byte
          STA WRITE.AUX
          STA (SYMPNT,X)
          STA WRITE.MAIN
SPS       LDA #$10       ;For flagging & err check
SPS2      STA MACFLG
          LDA EXPFLG
          AND #8         ;EXP ONLY
          ORA LABEL      ; and no label?
          EOR #' '.8
          BEQ :OUT       ;Defeat list if so
          TXA
:OUT      JMP OUTPUT     ;Avoid pasnum check

IF        ROR ASCFLG
          LDA OPERAND
          CMP OPERAND+2
          BEQ RDO
          CLC
          BCC RDO

ELSE      LDA DOFL
          EOR #$80
          STA DOFL
          HEX 2C
FIN       ASL DOFL
          JMP PRNTLIND

DO        LDA DOFL       ;If DO is off then avoid
          BNE RDO        ; eval (so can use loc var)
          JSR ABSOPND
          ORA PL+1
          CMP #1
RDO       ROR DOFL
          BCC ELSE

NESTERR   ERX nest
          HEX 2C         ;Skip
BADOPC    ERX opc
          HEX 2C
PUTER     ERX put
          HEX 2C
NOTMAC    ERX notmac
GOER      STX ABORTFLG
          JMP ERR3

MVOC      LDX #14
]LOOP     LDA OPCODE-1,X
          STA WORKSP-1,X
          DEX
          BNE ]LOOP
          INC MACLEV     ;Defeat err abort
          RTS

TESTMAC   JSR MVOC
          DEC PACKL      ;Already found?
          BEQ :DML       ;Branch if so
          JSR FINDLAB
          BEQ BADOPC
:DML      DEC MACLEV
          LDX #0
          STX PACKL      ;Flag mode

PMC       LDY MACLEV
          INC MACLEV
          CPY #MX-1
          BGE NESTERR
          LDA PASNUM
          STA PNSV,Y
          STA PNFLG
PMC2      LDA MPASS,Y    ;Fake the pasnum
          STA PASNUM     ;(3 passes for macros)
          ADC #1
          STA MPASS,Y
          CMP #2
          BEQ FAKE
          JSR FINDLAB    ;X=0
          BEQ NOTMAC
          TAX            ;Holds MACLEV
          JSR FLAG
          STA MADSV+MX-1,X
          LDA PL
          STA MADSV-1,X
          LDA PACKL
          CMP #1
          LDA OPNT
          BCC :NL        ;Branch if mac = opcode
          ADC LENGTH
:NL       STA LVPNT,X
          LDA OPNT+1
          ADC #0
          STA LVPNT+MX,X
          LDY MACLEV
          DEY
          SVPNT SPNT     ;MSAV
          SVPNT ADRS     ;ADSV
          LDX PNSV,Y
FAKE      GETPNT MADSV   ;SPNT
JSPS      JMP SPS        ;Go thru macro source

USR       JSR USRADR     ;DOFL = 0 if here
PRTALW    ASL DOFL
          JMP PRNTLIN

CHMDO     ASL ZMDO
          BCS PRTALW     ;Branch if end of defn
          JMP PRNTLIND

EOM       LDY MACLEV     ;A subtle routine to
          BEQ :P         ;decide when to drop
          DEY            ;through and when to
          LDA MPASS,Y    ;go back for next pass.
:P        PHP
          CPY #0
          BNE :NST
          STY MACFLG
:NST      PLP
          BEQ CHMDO
          CMP #2
          BEQ :WNDUP0
          LDA PNSV,Y
          BEQ :WNDUP
          GETPNT ADSV    ;ADRS
          JMP PMC2
:WNDUP0   INX            ;1
:WNDUP    GETPNT MSAV    ;SPNT
          LDA #0
          STA MPASS,Y
          CPX #0
          BEQ :SPS
          BIT EXPFLG
          BVC :SPS
          DEX
:SPS      DEC MACLEV
          BNE JSPS
          JMP SPS2

PUTERR    JMP PUTER

JMPR0     JMP PRNTLIN

USE       DEY            ;Clear Z-flag
PUT       PHP
          LDA MACFLG
          ORA PUTFLG
          BNE PUTERR
          DEC PUTFLG
          DEX            ;-1
]LOOP     LDA SPNT+1,X
          STA SPSAV+1,X
          LDA ENDSRC+1,X
          ADC #0         ;Carry is set
          STA SPNT+1,X
          STA PUTSP+1,X
          INX
          BEQ ]LOOP
          JSR FIXNAME
          JSR GOREAD
          PLP
          BEQ WASPUT
          INY            ;=0
]LOOP     DECD HIMEM     ;Move to below current HIMEM
          MOV (PUTSP),Y  ;(HIMEM),Y
          LDA SPNT
          CMP PUTSP
          LDA SPNT+1
          SBC PUTSP+1
          DECD PUTSP
          BLT ]LOOP      ;At exit HIMEM->bottom
          TRDB HIMEM     ;SPNT ;Set source ptr to USE file
WASPUT    CPX #14
          JSR REHOOK
          STX PLIN
          STX PLIN+1
          BLT JMPR0
          STX PUTFLG     ;So err gives reg line #
          JMP MEMERR

KEYCHK    LDA KEY
          CMP #$85       ;Don't clear strobe
          BLT RT1        ;for cntr C or D.
          BIT STROBE
          CMP #" "
          BNE RT1
PAU       PAS?
          BEQ RT1
          JSR LMP
          BNE RT1
WAIT      LDA KEY
          BPL WAIT
RT1       RTS

TWOERR    TXA            ;Must do this way
          PHA            ; in case of DSK.
          LUP 2
          LDA #0
          JSR PRCODE
          --^
          PLA
          TAX
          JMP ERROR

GETSYM    INY
GETSYM0   STA READ.AUX
          LDA (SYMPNT),Y
          STA READ.MAIN
          RTS

GETLAST   TRDB LASTSYM   ;SYMPNT
GTLEN     LDY #0
          JSR GETSYM0
          STA ASV
          AND #$F
          RTS

          AST 40

* These must all fall on same page:

BIN       CLC
          STY PL
          STY PL+1
]LOOP     ROL PL
          ROL PL+1
          INX
          LDA OPERAND,X
          CMP #'2'
          BGE OD
          EOR #'0'
          LSR
          BEQ ]LOOP
GOT       RTS

GETHEX    TYA
          STA PL+1
]LOOP     STA PL
          INX
          LDA OPERAND,X
          CMP #']'
          BEQ GOT
          CMP #'0'
          BLT GOT
          JSR ASCHEX
          LDY #4
:SHIFT    ASL PL
          ROL PL+1
          DEY
          BNE :SHIFT
          ORA PL
          BCC ]LOOP
                         ;Fall into err if > 4 dig
OD        ERX illchr
          JMP ERR2

LITLOW    CLC
LITHI     INX
          TYA
          STA PL+1
          ROR
          ORA OPERAND,X
          STA PL
          INX
          LDA OPERAND-2,X
          CMP OPERAND,X  ;Bypass 2nd delim if any
          BEQ DOHERE
          RTS

HERE      BIT DUMFLAG
          BPL DOHERE
          BIT ABSFLAG    ;Abs mode?
          BMI DOHERE     ;Branch if so
          INC RELCNT
DOHERE    INX
R4        RTS

DECIMAL   TYA            ;0
          DEY            ;-1
          STY PL+1
]LOOP     INC PL+1
:NXDIG    STA PL
          LDA OPERAND,X
          EOR #'0'
          CMP #10
          BGE R4
          INX
          PHA
          JSR MULTEN
          PLA
          ADC PL         ;carry is clear
          BCC :NXDIG
          BCS ]LOOP

SYMBOL    JSR FINDLAB
          TYA            ;Bypass FLAG if
          BEQ :IR        ;label not found
          JSR FLAG       ;Flag used
          DEY
          DEY
          JSR GETSYM0    ;Test if rel sym
          BMI :CEXT      ;Branch if absolute
:IR       INC RELCNT
:CEXT     ASL            ;EXT bit to sign bit
          BPL :RT        ;Branch if not ext
          LDA EXTFLAG    ;2nd one?
          AND OVERIDE    ; and test not defeated?
          BNE :TE        ;Error if so
          STA PL         ;Fix low byte of value
          TRDB SYMPNT    ;EXTPNT
          DEC EXTFLAG    ;Flag it
:RT       RTS

:TE       ERX twoext
          JMP TWOERR

          ERR BIN!SYMBOL&$FF00

          AST 40

ROUTBL    BRK            ;Invalid stuff
          ASC ."$%'*0:.  ;In ascending ascii order!
RTBLEND

ROUTADR   DFB OD,LITHI,GETHEX
          DFB BIN,LITLOW,HERE
          DFB DECIMAL,SYMBOL
