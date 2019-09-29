*************************
*                       *
* ASSEMBLER from MERLIN *
*                       *
* Glen Bredon  8/15/85  *
*                       *
*   //e  128K  ProDOS   *
*                       *
*************************

          DATE

* BRUN PACKOP before ASM!

USRADR    = $B6DA
ASM16     KBD "Assemble from M-16"
          DO ASM16
          TR ADR
          ERR ($390)-$8D
          ERR ($396)-$A
          ERR (USRADR+1)-$90
          ELSE
          ERR ($8A0)-$8D
          ERR ($8A6)-$A
          ERR (USRADR+1)-$A0
          FIN

SAVOBJ    KBD
          TR
          EXP OFF

NUMCOL    = $E011
BYTLINE   = $E016
ASSERR    = $E017
LSTDODFT  = $E019
HORIZ     = $E01A        ;Htab for CYC
WARMDIS   = $E01B
GOREAD    = $E021
GOSAVE    = GOREAD+3
JBELL     = $E027
SENDMSG   = $E033
EDITOR    = $D100
PAGINATE  = $D009

* ProDOS interpreter stuff:

          PUT MLI/CODES

INT       = $B200        ;Interpreter start
JCLOSE    = INT+$0C
JRLOAD    = INT+$18
JOPEN     = INT+$1B      ;Open DSK file
JPRDATE   = INT+$27
ENTRY     = INT+$40
PARMADR   = INT+$50
ORDBUF    = INT-$400
DSKBUF    = INT-$800
DSKNAMSV  = $BDC0        ;File name save for DSK

          DUM $BE00
          PUT MERLIN.GP
          DEND

* EDITOR sets 0-5 zero:

MACLEV    = 0            ;Macro depth counter
MACFLG    = 1            ;$10 when in macro
PASNUM    = 2
BYTCNT    = 3            ;Byte count includes DS areas
PUTFLG    = 5            ;Minus if in a PUT
PUTSP     = 8            ;=execs SPNT
SOURCE    = $A
HIMEM     = $C
ENDSRC    = $E
LEVEL     = $10          ;Used by var substitution
MINUS     = $11          ;Unary minus flag
TBLP      = $12          ;Opcode table & text pointer
ADRS      = $14          ;True (ORG) address of code
ASV       = $16          ;Unmasked sym length byte
DOFL      = $17          ;DO condition
TEMP      = $19          ;Misc. use
MF        = $1A          ;Enables var redefn
SPSAV     = $1B          ;Source pointer save for PUT
ERCOUNT   = $1D
CSWL      = $36
CSWH      = $37
MONWAIT   = $FCA8
GETLN2    = $FD6F
PRHEX     = $FDE3
COUT      = $FDED
KEY       = $C000
STROBE    = $C010
SPKR      = $C030
IN        = $200
LABEL     = $220
OPCODE    = $22E
OPERAND   = $23C
WORKSP    = $280         ;Workspace for label evaluation
PAR       = $53          ;Quote flag in var repl
INVFL     = $50          ;Used by ASC
FLSH      = $51          ; routines.
ACL       = $50          ;Multiply and
XTND      = $54          ;divide usage.
PL        = $55          ;Main accumulator
SPCNT     = $57          ;For tabbing
LVAR      = $58          ;Pointer to local var names
HOOKSV    = $5A          ;Hooks saved here on entry
EXPFLG    = $5E          ;EXP condition
TRFL      = $5F          ;TRunc " (set in ED)
FLAGS     = $70          ;Rel & link flags
ORGOFF    = $71          ;ORG offset for reorg
FPHI      = $73          ;Usually has $9853
OPSAV     = $75          ;Opcode save for cyc time
ABORTFLG  = $76          ;Flags fatal asm error
CYCFLG    = $77          ;Flags CYC
ACCTIM    = $78          ;Accumulated cycle count
LUPDO     = $7A          ;Flag to support LUP 0
LASTSYM   = $7B          ;To support local labels
ISERR     = $7D          ;Flags err for XREF
SYMEND    = $80          ;One byte above sym tbl
DICPNT    = $82          ;Rel dict. pointer
EXTPNT    = $84          ;Points to ext found by CHOP
CODELEN   = $86          ;Len of code when REL active
ABSFLAG   = $88          ;Flags an ORGed section in REL
DUPCNT    = $89          ;Counts dup errors
DMFLAG    = $8A          ;Flags a DIV or MULT
OVERIDE   = $8B          ;To defeat some errors
EXTCNT    = $8C          ;Counts extls in sym tbl
EXTFLAG   = $8D          ;Flags EXT found in CHOP
RELCNT    = $8E          ;Rel symbol count in CHOP
RELFLAG   = $8F          ;Flags rel code
PAGVEC    = $A0          ;Chrout adrs for paginator
XCFLAG    = $AC          ;- asm 65C02, v asm 65802
DUMFLAG   = $AD          ;Flags dummy section
DADD      = $B0          ;Adrs save in dummy
DIRFLG    = $B2          ;Flags asm to disk
LUPLN     = $B3          ;LINNUM save in LUP
LUPPLIN   = $B5          ;PLIN "
LUPCNT    = $B7          ;Loop count
LUPADR    = $B9          ;Adrs in source of loop start
OPNDLEN   = $BB          ;Operand length
SPNT      = $BC          ;Source pointer
OPNT      = $BE          ;Pointer to opnd or var names
VIDVEC    = $C0          ;"Slot" hook save
AXFLAG    = $C5          ;Flags M,X modes in 65802
LSTDOFLG  = $C6
FENCE     = $C7          ;Highest legal write location
NL        = $C9          ;PRDEC usage
NH        = $CA
NFL       = $CB
INDEX     = $CC          ;Math pointer
ASCFLG    = $CD          ;For tabbing
SPL       = $CE          ;Secondary accum for arith
CHRCNT    = $D0          ;For tabbing
LSTFLG    = $D1
OFFSET    = $D2          ;Multi-purpose
DCMSK     = OFFSET       ;Used by HEX, FLS, INV, DCI.
TABCNT    = $D3          ;Scratch for 3 obj byte printout
PLIN      = $D4          ;Linnum for PUT
LINNUM    = $D6
CHKBYT    = $D9
PNFLG     = $DA          ;Nonzero on a >>> line only
OFF       = $DB          ;Secondary punct. offset
SIG       = $DC          ;Offset in sweet opnd
HIBIT     = $DD          ;Used by ASC etc
PNTSV     = $DE          ;Misc use
STARTFL   = $E0          ;Detects multiple orgs
WASORG    = $E1          ;Flags 1st org
OBJPNT    = $E2          ;Obj beginning for exec use
OBLEN     = $E4          ;Len of obj code for exec use
ADRSV     = $E6          ;Org adrs for exec use
ORGFLG    = $E8          ;Non 0 if more than 1 org
LSTDOZ    = $E9
PACKL     = $EA          ;Holds packed opcode
PACKR     = $EB
ASMPNT    = $EC          ;Pntr to where code is placed
LEN       = $EE          ;Sym length
JUST      = LEN          ;Always + in asm
LENGTH    = $EF          ;Symbol length in search
PARFLG    = $F0          ;Flags a "("
ZMDO      = $F2          ;Auto DO 0 flag for macro defns
TABS      = $F4
NOTFND    = $FD          ;Used by OBJ, ORG, DS, LUP to
                         ; insure that all labels in the
                         ; operand are known on 1st pass.
SYMPNT    = $FE          ;Symbol table pointer
SYMADR    = $1000        ;Aux mem

* Indices to address mode data:

IMM       = 1
IMP       = 2
INDX      = 3
INDY      = 4
RELX      = 6
RELY      = 8
ABS       = 10
SR        = 13
DP        = 15

* Macro equates:

MX        = $10          ;Max macro level+1

          DUMMY $800
MPASS     DS MX          ;Pass counters
MSAV      DS MX*2        ;Src adrs save while in macro
ADSV      DS MX*2        ;Adrs save
MADSV     DS MX*2        ;Macro src adrs save
PNSV      DS MX          ;Real pasnum save
LVPNT     DS MX*2        ;Pntrs to names of local vars
          ERR *-$8A0
          DEND           ;$8A0-$8FF not used

* Ramcard & aux mem equates:

CONTROL   = $C080
BANK1     = %1000
ENABLE    = %11
READ      = $C002
WRITE     = $C004
MAIN      = 0
AUX       = 1

* Symbol printout equates:

ALFLAG    = 3
TAB       = 4
FLGG      = 5
QLEN      = $10
SLEN      = $12

          AST 32

          USE LIB/ASSMACROS

          ORG $D000

          PUT LINKER

          PUT ASS.BNK1

* Added to ensure match to standard
          HEX 8DA0D3D4C1
*

* Changed for additional bytes above
* ERR \$DFFF
          ERR \$E000
          DO SAVOBJ
          SAV ASMOBJ/PROASM.BANK1
          FIN

          ORG $E5F0

          JMP FINDLAB    ;For XREF
          JMP ASM
          JMP PRCODE     ;Entry points for use
          JMP CHOP       ; by USR routines
          JMP NEWCOUT    ;For paginator
          JMP EVAL       ;VAL from Editor

          PUT LIB/PRDEC

          PUT ASSMAIN

          PUT BRACKET

LUP       JSR ABSOPND    ;Require known abs label
          ORA PL+1       ;LUP 0?
          BNE :SLP       ;Branch if not
          LDA #$80
          STA LUPDO
          STA DOFL       ;Was 0 or wouldn't be here
:SLP      SEC
          LDX #-1
]LOOP     LDA #0
          SBC PL+1,X
          STA LUPCNT+1,X
          LDA SPNT+1,X
          STA LUPADR+1,X
          LDA LINNUM+1,X
          STA LUPLN+1,X
          LDA PLIN+1,X
          STA LUPPLIN+1,X
          INX
          BEQ ]LOOP
          JMP PRLUP

* NEWCOUT for PAGINATOR:

NEWCOUT   BIT $DFFF      ;Remember D000 bank
          PHP
          BIT CONTROL    ;Switch to bank 2
          JSR PAGINATE   ;Process character
          PLP            ;Recall bank
          BVS BNK2       ; and switch if necessary.
                         ;Or return if from editor

BNK1      BIT CONTROL!BANK1!ENABLE
          BIT CONTROL!BANK1!ENABLE
BNK2      RTS

ENDLUP    ASL LUPDO      ;In a LUP 0?
          BCS :FIXDO     ;Branch if so
          LDA DOFL       ;Must check do
          BNE :ST        ; and exit if off
:FIXDO    STA DOFL       ;A=0
          BIT LUPCNT+1   ;Ignore ENDLUP command if no LUP
          BPL :ST        ; is active.
          INCD LUPCNT
          BEQ :ST        ;Exit if count done
          INX            ;=1
]LOOP     LDA LUPADR,X
          STA SPNT,X
          LDA LUPLN,X
          STA LINNUM,X
          LDA LUPPLIN,X
          STA PLIN,X
          DEX
          BEQ ]LOOP
:ST       JMP START

ERRWAIT   BMI INFWAT
          LDA #$40       ;Called by assembly error
          STA TBLP
]LOOP     BIT KEY        ;Exit upon a key
          BMI RT
          DEC TBLP       ; or after ~ 20 seconds.
          BEQ RT
          TXA
          JSR MONWAIT
          LDY #$7F       ;Use a melodious beep
          SEI
:L        TYA            ; to be less annoying.
:1        TAX
:2        DEX
          BNE :2
          BIT SPKR
          EOR #$FF
          BMI :1
          DEY
          BNE :L
          CLI
          BEQ ]LOOP

INFWAT    JSR WAIT
RT        JMP PRNTLIN

* Routine used by VAL in editor:

EVAL      JSR BNK1
          STX FENCE+1    ;Flag from VAL, X=0
          STX PNFLG      ;Defeat FLAG
          STX OVERIDE    ;Defeat FLAGCHK
          JSR EVLOPND
          BIT CONTROL
          STA $16
          STY $17
          RTS

FIXNAME   LDY #-1
]LOOP     INY
          LDA WORKSP,Y
          CMP #' '
          BNE ]LOOP
          LDA #$8D
          STA WORKSP,Y
          RTS

LENOBJ    SEC
          LDA ASMPNT
          SBC OBJPNT
          STA OBLEN
          LDA ASMPNT+1
          SBC OBJPNT+1
          STA OBLEN+1
          RTS

ADDLEN    JSR LENOBJ
          ADDD OBLEN     ;BYTCNT
          RTS

NXTSYM    JSR GTLEN
          CLC
          ADC #4
BUMPSYM   ADC SYMPNT
          STA SYMPNT
          BCC :RTN
          INC SYMPNT+1
:RTN      RTS

          PUT MSGS

          PUT OPCODES

          PUT GETLINE

          PUT SYMPRINT

          ERR \$F7D0     ;Room for MON.65C02

          DS $F7D0-*

          PUT PRINTENT

          ERR \$F879

          DO SAVOBJ
          SAV ASMOBJ/AS
          FIN
