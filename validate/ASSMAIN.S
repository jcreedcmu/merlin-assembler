
ASM       JSR BNK1
          LDA #0
          LDX #MX
]LOOP     STA MPASS-1,X  ;Init macro passes
          STA LVPNT+MX-1,X ;For err checking
          DEX
          BNE ]LOOP
          STX ABORTFLG
          STX ORGFLG
          STA WRITE.AUX
          STX SYMADR
          STA WRITE.MAIN
          STX DIRFLG
          STX RELFLAG
          STX EXTCNT
          STX DUPCNT
          STX FENCE
          STX DICPNT
          POKE FENCE+1   ;$C0
          STA DICPNT+1
          STX OBJPNT
          ASL            ;$80
          STA OBJPNT+1
          POKE OBJTYPE   ;6 ;Default to bin obj
          INX
]LOOP     LDA SOURCE,X
          STA SWAPPNT,X
          STA SWAPPNT+4,X
          DEX
          BEQ ]LOOP
          TXA
          INX
          STA (ENDSRC,X)
          STA OVERIDE

* 2nd pass starts here

STPT      STX DOFL
          STX ZMDO
          STX LUPDO
          STX LINNUM
          STX LINNUM+1
          STX LSTFLG
          STX EXPFLG
          STX ERCOUNT
          STX LUPCNT
          STX LUPCNT+1
          STX XCFLAG     ;65C02 mode off
          STX AXFLAG
          STX CYCFLG
          STX LASTSYM
          STX ADRS
          LDA LSTDODFT
          STA LSTDOFLG
          LDA #>SYMADR
          STA LASTSYM+1
          LDA #>$8000
          STA ADRS+1
          INX
]LOOP     LDA ADRS,X
          STA ADRSV,X
          LDA SOURCE,X
          STA SPNT,X
          LDA FPHI,X
          STA HIMEM,X
          DEX
          BEQ ]LOOP
          STX DUMFLAG
          BNE RES        ;Always

* Returns here after a "SAV"

RESTART   ADDD OBLEN     ;ADRSV
RES       TRDB OBJPNT    ;ASMPNT
          JSR REHOOK
          STX OBLEN
          STX OBLEN+1
          STX ABSFLAG
          STX ORGOFF
          STX ORGOFF+1
          STX WASORG
          STX STARTFL
          STX CHKBYT

* Each line starts here

START     LDX #-1
          TXS
          STX OPSAV      ;Flag invalid ops
          LDA KEY        ;Must do here for space
          ASL            ; bar pause to work
          EOR #6
          BEQ EXIT
          EOR #8!6
          BNE :IX        ;Branch if not ^D
          BCC :IX        ;Branch if strobe cleared
          LDA #'F'!' '
          EOR LSTFLG
          STA LSTFLG
          BIT STROBE
:IX       INX
          STX ISERR
          STX CHRCNT     ;Just in case
          STX FLAGS
          JSR GTLIN
          JSR ADDSPACE
          LDA LSTDOFLG
          LSR            ;Discard bit 0
          BEQ :SLD
          LDA #-1
          STA LSTDOFLG
:SLD      STA LSTDOZ
          LDA LABEL
          BPL PACK
          JMP PRNTLIN    ;It is a comment

EXIT      STX ORGFLG
          JMP GOQU

MVLA      LDX #14
]LOOP     LDA LABEL-1,X
          STA WORKSP-1,X
          DEX
          BNE ]LOOP
          RTS

PACK      LDA OPCODE
          ASL
          ASL
          ASL
          STA PACKL
          LDA OPCODE+1
          LUP 2
          ROR
          ROR PACKR
          --^
          AND #7
          ORA PACKL
          STA PACKL
          LDA OPCODE+3
          AND #%1011111
          BEQ :IS@       ;Branch if space
          CMP #'D'
          BEQ :BIT0
          JSR MVOC
          LDA PASNUM     ; aborting
          PHA
          STX PASNUM
          JSR FINDLAB
          BEQ :DML       ;Branch if not macro
          LDA #1         ;Defeat recognition
          STA PACKL      ; as regular opcode
:DML      DEC MACLEV     ;Fix things
          PLA
          STA PASNUM
:IS@      CLC
:BIT0     LDA OPCODE+2
          AND #%11111
          ROL
          ORA PACKR
          STA PACKR
          LDA #STRING
          LDY #>STRING
          JSR GETOPC
          ROR ASCFLG     ;Tabbing
          JSR NXOPS      ;Conditionals
          PHP
          BCC :NC        ;Branch if not condl, A=0
          LDA #0         ;Must process condls
          STA LSTDOZ     ;To force list if a label
          BEQ :LL
:NC       BIT ZMDO       ;In macro def?
          BPL :LD        ;Branch if not
          STA PACKL      ;To force exit from PUTLAB
          LDA LABEL      ; if label already there
          CMP #']'
          BNE :LL
:LD       LDA DOFL
          BNE :PL
:LL       JSR SETLAB
          LDA PACKL
          BNE MVOPR
:PL       JMP PRNTLIN    ;Only a label

MVOPR     LDY OPNDLEN    ;Replace operand
          INY            ; + 2 chrs beyond
          INY
]LOOP     LDA OPERAND,Y
          STA WORKSP,Y
          DEY
          BPL ]LOOP
          PLP
          BCS GGO        ;Branch if condl
          LDX #3         ;Onebyte
          JSR NXOPS
          BCC ONEC
COK       LDA (TBLP),Y
          BCC JGPR       ;Branch if not 65C02
          STA OPSAV
JGPR      JMP GOPR

ONEC      LDA XCFLAG     ;Regular mode?
          BEQ SKIPIT     ;Branch if so
          JSR NXOPS
          BCC ONE8
          LDA (TBLP),Y
          CMP #$10       ;SW16 code clears carry
          LDA #1         ;Set to test SW16
          BIT XCFLAG
          BCS NOTSW      ;Branch if not a sw16 code
          BNE COK        ;Branch if sw16 up
          LSR            ;Force branch to TSTMAC
NOTSW     BMI COK        ;Branch if 65C02 enabled
          BPL TSTMAC     ;Always

ONE8      BIT XCFLAG     ;65802 mode?
          BVC SKIPIT     ;Branch if not
          JSR NXOPS
          BCS COK
SKIPIT    LDA #RELOP-1
          STA TBLP
          BCC RELTV      ;Always

GGO       LDY #2         ;Process condl
GO        LDA (TBLP),Y
          PHA
          INY
          LDA (TBLP),Y
          PHA
          LDA #0         ;Go to routine with
          TAY            ; A=X=Y=0 and carry set
          TAX
          RTS

GEXTE     JMP EXTERR

SW?       JSR NXOPS
          BCC TWOBY
          JSR CHK@
          STA OFFSET     ;Reg specified
          LDY #2
          LDA (TBLP),Y
          LDX SIG        ;@ present?
          BEQ :NSH       ;Branch if not
          LUP 4
          ASL
          --^
:NSH      AND #$F0
          BEQ JAE
          ORA OFFSET
          BNE JGPR       ;Always

CHKPSO    LDY #'''-1
          CPY OPERAND
          ROR            ;A=0
          STA HIBIT      ;Set delimiter type
          LDA #PSEUDO
          LDY #>PSEUDO
          BIT XCFLAG     ;65802 mode?
          BVC :GOP       ;Branch if not
          LDA #XCODES    ;Look for those codes
:GOP      JSR GETOPC
          BCS GO
TSTMAC    JMP TESTMAC

JAE       JMP ADRERR

RELTV     JSR NXOPS
          BCC SW?
          LDA (TBLP),Y
          BNE :X0        ;Else = BRA
          ROR            ;= LDA #$80
          AND XCFLAG
          BEQ TSTMAC     ;Branch if no 65C02
:X0       LDX #0
          PHA
          CMP #$10       ;SW16 branch?
          BGE :DOREL     ;Branch if not
          LDA XCFLAG
          LSR
          BCC TSTMAC     ;Branch if sw16 not up
          HEX 2C
:DOREL    STA OPSAV
          LDA PASNUM
          BEQ PT
          JSR CHOP
          BIT EXTFLAG    ;Branch to ext?
          BMI GEXTE      ;Error if so
          DEY
          BNE JAE        ;Must be space
          LDY PL+1
          LDX PL
          BNE :ND
          DEY
:ND       DEX
          TXA
          SBC ADRS       ;Carry is clear
          STA PL         ;Branch byte
          BPL :NI
          INY
:NI       TYA
          SBC ADRS+1     ;In range?
          BNE BRNCHERR
          PLA
PT        JSR PRCODE
          JMP ZE

TWOBY     INX
          JSR NXOPS
          BCC CHKPSO
          LDA OPERAND
          CMP #'#'
          BNE NNU
          LDX #IMM
          JSR GETCODE
          BEQ JAE
          JSR MAKNUM0
          JMP ZE

BRNCHERR  JMP BRERR

ISST      INX
          INX
          LDA OPERAND+1,X
          LDY #SR+1
          BNE DONEW      ;Always

RBR       BIT PARFLG
          BMI JAE
          BVC JAE
          LDY #DP
          LDA OPERAND+1,X
          CMP #' '
          BEQ NEWBAK
          INY
DONEW     CMP #','
          BNE :GAD
          LDA OPERAND+2,X
          AND #%1011111
          CMP #'Y'
:GAD      BNE ADRERR
NEWBAK    TYA
          TAX
          BNE NOTJMP     ;Always

JIMP      JMP IMPLIED

NNU       CMP #' '
          BEQ JIMP
          CMP #'         ;'
          BEQ JIMP
          AND #%1011111
          CMP #'A'
          BNE :COP
          LDA OPERAND+1  ;Syntax ASL A ?
          CMP #' '
          BEQ JIMP
:COP      JSR CHKOPND
          LDA NOTFND
          BEQ :OV
          LDA ADRS+1
          STA PL+1
:OV       LDA OPCODE+3   ;Non z-page requested
          EOR #' '       ;(if 4th op chr not space)
          ORA PL+1       ; or required?
          PHP
          CPY #3
          BEQ RBR        ;It is ]
          TYA            ;0,1,2,3 as nxchr=) ,]
          LDY #3
          BIT PARFLG
          CMP #1
          BVC NOPAR
          BEQ ADRERR     ;Err if space, ok if ","
          LDA OPERAND+1,X
          BLT RPA        ;Branch if ")"
          AND #%1011111
          CMP #'X'
          BEQ :CHKB
          EOR #'S'       ;Must be (-,X) here
          BNE ADRERR
:CHKB     LDA OPERAND+2,X
          EOR #')'
          BNE ADRERR
          BCC ISST
          LDX #INDX
          LDA (TBLP),Y
          CMP #$20
          BEQ :JU
          EOR #$4C
          BNE NOTJMP
          CLC
:JU       LDA #$7C*2
          ROR            ;FC=JSR (--,X)  7C=JMP(--,X)
          JSR ISVAL
          BNE GGPR       ;Always

NOTJMP    LDA #0
IND       ORA PL+1       ;Must be z-page
          BNE ADRERR
          JSR GETCODE
          BNE ZE
ADRERR    ERX add
          HEX 2C         ;Skip
BRERR     ERX br
          JMP TWOERR

RPA       CMP #' '
          BNE CC
          DEY
          AND (TBLP),Y
          BEQ ADRERR     ;Err if () not allowed
          INY
          ORA (TBLP),Y
          CMP #$6C       ;JMP ()?
          BEQ JPRL0
          PLP
          BNE ADRERR     ;Must be z-page
          LDA (TBLP),Y   ;Support for 65C02 here
          EOR #%00010011 ;65C02 conv for X2 codes
          JSR CHKCODE    ;Check XC mode
          JMP PT

AB1       LDA PACKL      ;Opnd is -- or - here
          SBC #$53
          CMP #2         ;JSR or JMP?
          BGE AB2        ;Branch if not
          LDA (TBLP),Y
JPRL0     STA OPSAV
JPRL      JSR PRCODE
GGPR      JSR MAKDIC0    ;Make dict entry
GGPRA     JSR PRPL       ;Send opnd low
          LDA PL+1       ; and high
          HEX 2C
CHK       LDA CHKBYT
GOPR      JSR PRCODE
JPR       JMP PRNTLIN

NOPAR     BEQ AB1        ;Space
          BLT ADRERR     ;Err if ")"
          LDA OPERAND+1,X
          AND #%1011111  ;Must be -,X or -,Y
          LDX #SR
          CMP #'S'
          BEQ NOTJMP
          LDX #RELX      ; or --,X or --,Y here
          CMP #'X'
          BEQ RELV
          CMP #'Y'
GAD       BNE ADRERR
          LDX #RELY
RELV      PLP
          BEQ :Z         ;Branch if z-page
:NZ       DEX
          JSR GETCODE    ;Check valid & send opcode
          BNE GGPR
          BEQ ADRERR
:Z        JSR GETCODE    ;Z-page legal?
          BEQ :NZ        ;Branch if not
ZE        LDA PL         ;Send opnd low
          JMP GOPR

IMPLIED   LDX #IMP       ;No opnd or A opnd
          JSR GETCODE
          BNE JPR
          BEQ ADRERR

CC        CMP #','       ;(-),Y  here
          BNE GAD
          LDA OPERAND+2,X
          AND #%1011111
          LDX #INDY
          EOR #'Y'
          JMP IND

AB2       LDX #ABS       ;Abs and not JSR, JMP
          PLP
          PHP
          BEQ ABZ        ;Z-page
          DEX
ABZ       JSR GETAB      ;Check valid & send opcode
          PLP
          BEQ ZE         ;Branch if z-page
          BNE GGPR       ;Not z-page

SET       JSR CHK@
          ORA #$10
          PHA
          JSR CHOP0
          PLA
          BNE JPRL       ;Always

ISMAC     JMP TESTMAC

BADOPN    JMP OPDERR

CHK@      LDA XCFLAG     ;Sw16 enabled?
          LSR
          BCC ISMAC      ;Branch if not
          LDX #-1
:BY@      INX
          LDA OPERAND,X
          CMP #'@'
          BEQ :BY@
          STX SIG        ;Flag if @
          CMP #'R'
          BNE :VAL
          LDA OPERAND+1,X
          CMP #':'       ;Is it a label?
          BGE :VAL
          INX            ;Skip the "R" if not
:VAL      JSR CHOP
          LDA PL
          CMP #$10
          BGE BADOPN
          RTS

DEND      LDA DADD
          LDY DADD+1
:IW       INC WASORG
          BEQ :IW
          ROR DUMFLAG
          BMI AYAD       ;Always
DUM       BIT DUMFLAG
          BPL DOORG
          TRDB ADRS      ;DADD
          DEC WASORG
          JSR ABSOPND
          LSR DUMFLAG
          BPL AYAD       ;Always

ORG       BIT RELFLAG
          BPL :ISREO     ;Skip if not rel file
          ROR            ;= LDA #$80
          LDY PASNUM
          BEQ :ABS
          LDY STARTFL
          BEQ ORGERR     ;Err if no code yet
:ABS      STA ABSFLAG    ;Signal abs section
:ISREO    LDA OPERAND
          CMP #'         ;'
          BEQ :REORG
          CMP #' '
          BNE DOORG
:REORG    LDA ADRS
          SBC ORGOFF
          PHA
          LDA ADRS+1
          SBC ORGOFF+1
          TAY
          STX ABSFLAG    ;Back to rel on reorg
          STX ORGOFF
          STX ORGOFF+1
          JMP YAD

ORGERR    ERX org
          JMP ERR2

DOORG     TRDB ADRS      ;ORGOFF
          JSR ABSOPND    ;Support DUM in REL
          PHA
          SEC
          SBC ORGOFF
          STA ORGOFF
          TYA
          SBC ORGOFF+1
          STA ORGOFF+1
YAD       PLA
AYAD      STA ADRS
          STY ADRS+1
          TAX
          LDA RELFLAG    ;REL mode or
          ORA WASORG     ; not first ORG?
          BMI :PL        ;Branch if so
          STX ADRSV      ;Obj save uses only the
          STY ADRSV+1    ; 1st ORG for the adrs.
          DEC WASORG     ;To enable adjoining ORGs
          LDA STARTFL    ;Defeat obj save if started
          STA ORGFLG
:PL       JMP PRNTLIN

NOCLS     RTS

CLOSE     BIT DIRFLG
          BPL NOCLS      ;Exit if no DSK file
          JSR ADDREL     ;Do rel stuff if active
          JSR LENOBJ
          JSR SWAP       ;Recall file name
          LDA DSKREF
          STA MRKREF
          STA CLSREF
          TRDB OBLEN     ;MRKPOS
          STX OBLEN      ;X=0 from REHOOK
          STX OBLEN+1
          STX DIRFLG
          JMLI seteof    ;MRK
          JMLI close     ;CLS
          LDA #10
          STA INFPARMS
          JMLI getinfo   ;INF
          LDA ADRSV
          LDX ADRSV+1
          BIT RELFLAG
          BPL :SINF
          LDA CODELEN
          LDX CODELEN+1
:SINF     STA INFAUX
          STX INFAUX+1
          LDA #7
          STA INFPARMS
          JMLI setinfo   ;INF
SWAP      LDY #$40
]LOOP     LDX DOSFNAM-1,Y
          LDA DSKNAMSV-1,Y
          STA DOSFNAM-1,Y
          TXA
          STA DSKNAMSV-1,Y
          DEY
          BNE ]LOOP
                         ;Fall into REHOOK
REHOOK    LDX #4
]LOOP     LDA HOOKSV-1,X
          STA CSWL-1,X
          DEX
          BNE ]LOOP
          RTS

OBJ       LDA STARTFL
          BNE OBJERR
          LDA PASNUM
          BNE JMPRN
          JSR ABSOPND
          CPY #$40
          BLT OBJERR
          CPY #$BF
          BLT :SOB
          BNE OBJERR
          CMP #$E1
          BGE OBJERR
:SOB      STA OBJPNT
          STY OBJPNT+1
JMPRN     JMP PRNTLIN

REL       LDA PASNUM
          BNE JMPRN
          STA READ.AUX
          LDA SYMADR     ;Must come before =
          STA READ.MAIN
          BNE RELERR
          ROR RELFLAG
          BMI JMPRN      ;Always

ENT       ROR
EXT       ROR
          ROR
          STA FLAGS
          LDA MACLEV
          BNE EXTERR     ;Err if in mac
          JSR CHKLAB     ;Must have a label
          LDA PASNUM     ;Do on first pass only
          BNE JMPRN
          LDA ADRS+1
          LDX ADRS
          BIT FLAGS      ;Ext?
          BVC :NE        ;Skip if not
          LDA #$80       ;Set val to $8000 +
          LDX EXTCNT     ;EXT number
          INC EXTCNT
          BEQ EXTFUL     ;Err if too many
:NE       STA PL+1
          STX PL
          JMP GPT        ;Fix flag & adrs

EXTFUL    ERX extful
          HEX 2C
RELERR    ERX rel
          HEX 2C
EXTERR    ERX badext
          HEX 2C
OBJERR    ERX obj
          HEX 2C
SAVERR    ERX sav
          JMP GOER

SAV       JSR SAVOK?
          ORA ORGFLG
          ORA RELFLAG    ;SAV & REL incompatible
          ORA DIRFLG
          BNE SAVERR
          JSR FIXNAME
          JSR ADDLEN
          JSR GOSAVE
JRS       JMP RESTART

SAVOK?    LDA PASNUM
          BEQ JRS
          JSR DOPRINT
          BCC :LMF       ;If from list check
          JSR CROUT
:LMF      LDA MACFLG     ;Illegal in macro
          RTS

DSK       JSR SAVOK?
          BIT RELFLAG    ;REL file?
          BPL :AY        ;Branch if not
          ORA DIRFLG     ;Err if DSK active
:AY       TAY
          BNE SAVERR
          JSR CLOSE
          JSR FIXNAME
          STA DIRFLG
          STY DOSFNAM
]LOOP     LDA WORKSP,Y
          STA DOSFNAM+1,Y
          DEY
          BPL ]LOOP
          JSR JOPEN
          JSR SWAP       ;Save file name
          JSR ADDLEN     ;Update byte count
          JMP RESTART

TYP       JSR ABSOPND
          LDY #TYPEND-TYPES-1
]LOOP     CMP TYPES,Y
          BEQ :SETYP
          DEY
          BPL ]LOOP
          ERX typ
          JMP ERR2
:SETYP    STA OBJTYPE
          JMP PRNTLIN

NOTREL    BIT EXTFLAG
          BMI EXTERR
          RTS

TYPES     HEX 00,06,F0,F1,F2,F3,F4,F5,F6,F7,FF
TYPEND

*-----------------------------------------
* Bytes in dictionary (4 per entry):
*
* 0: Flag byte, upper 4 bits if on mean:
*    two byte;  high 8; inverted; external
* 1: Offset in code, low
* 2: Offset in code, high
* 3: Low byte of opnd or ext sym #
*-----------------------------------------

MAKDIC0   LDA #%10001111 ;Ord 2 byte ref
MAKDIC    LSR RELCNT     ;Parity of rels
          BCC NOTREL     ;Branch if even
          STA FLAGS
          LDA ASMPNT
          SBC OBJPNT
          STA SPL
          LDA ASMPNT+1
          SBC OBJPNT+1
          STA SPL+1
MAKDIC2   LDA PASNUM     ;Assume FLAGS was set up
          BEQ NOREL      ;Skip on first pass
          LDA RELFLAG
          AND DUMFLAG
          BPL NOREL      ;Branch if abs mode
          LDA DICPNT
          SEC
          SBC #4
          STA DICPNT
          BCS :MEM
          DEC DICPNT+1
:MEM      CMP SYMEND     ;This is allowed to overwrite
          LDA DICPNT+1   ; object code (& vv) since
          SBC SYMEND+1   ; save is allowed only if DSK
          BLT OOMEM      ; active (no obj put to mem).
          TYA            ;Must preserve Y
          PHA
          LDA EXTFLAG    ;0 or $FF
          AND #%00010000 ;Set bit if EXT ref
          ORA FLAGS
          LDY #0
          STA WRITE.AUX
          STA (DICPNT),Y ;Store flag byte
          INY
          LDA SPL        ;Get offset low
          STA (DICPNT),Y
          INY
          LDA SPL+1
          STA (DICPNT),Y
          LDA PL         ;Last entry = opnd low
          BIT EXTFLAG    ; unless external
          BPL :STDP
          LDY #0
          STA READ.AUX
          LDA (EXTPNT),Y ;Get sym length
          AND #$F        ;Strip flags
          TAY
          INY            ;Point to value low
          INY            ; = ext sym #
          LDA (EXTPNT),Y
          STA READ.MAIN
:STDP     LDY #3
          STA (DICPNT),Y ;Last dic byte
          STA WRITE.MAIN
          PLA
          TAY
NOREL     RTS

OOMEM     ERX dicmem
          JMP GOER

ADDREL    BIT RELFLAG    ;Do nothing if not rel
          BPL NOREL
          JSR LENOBJ     ;Find code length & save it
          STA CODELEN+1
          MOV OBLEN      ;CODELEN
          LDA LSTFLG     ;Save list flag
          PHA
          LDA #'F'       ; and defeat list
          STA LSTFLG
          LDY #0
NXDE      LDA DICPNT+1
          EOR #$C0       ;Table all sent?
          BEQ DICDONE    ;Branch if so, A must = 0
]LOOP     STA READ.AUX
          LDA (DICPNT),Y ;Send dict
          STA READ.MAIN
          JSR PRCODE
          INC DICPNT
          BNE ]LOOP
          INC DICPNT+1
          BNE NXDE       ;Always

DICDONE   JSR PRCODE     ;Send end byte
          STADR SYMADR   ;SYMPNT
GETEE     JSR GTLEN
          BEQ ALLDONE
          STA SLEN       ;Save sym len
          TAY            ;Point to flag byte
          LDA ASV
          AND #%00110000 ;Macro?
          BNE NOTEE      ;Branch if so
          JSR GETSYM     ;Get flag
          ASL            ;Strip rel bit
          AND #%11110000 ; and others (2 extras left)
          BEQ NOTEE      ;Ignore if not ent/ext
          ORA SLEN       ;Add length
          LDY #0
]LOOP     JSR PRCODE     ;Send flag and symbol
          JSR GETSYM
          DEC SLEN
          BPL ]LOOP
          LUP 2
          JSR GETSYM     ;Send value
          JSR PRCODE
          --^
NOTEE     JSR NXTSYM
          JMP GETEE

ALLDONE   JSR PRCODE     ;Send end mark
          PLA
          STA LSTFLG     ;Replace list flag
          RTS

SEND0     LDY #-1
SEND      INY
          LDA (TBLP),Y
          PHP
          JSR PRINT
          PLP
          BPL SEND
          RTS

]LOOP     JSR INSP
OVRSPC    LDY #0
          LDA (SPNT,X)
          AND #$7F
          CMP #$D
          BEQ INSP
          CMP #' '
          BEQ ]LOOP
          RTS

GTSRC     LDA (SPNT,X)
GTSRC0    AND #$7F
INSP      INCD SPNT
          CMP #$D
          BNE GOTSRC
          PLA
          PLA
GOTSRC    RTS

FIXSPNT   DECD SPNT
]LOOP     LDA (SPNT),Y
          JSR GTSRC0
          BNE ]LOOP      ;Always

MAKNUM0   LDX #1         ;Set to skip "#"
          BIT XCFLAG
          BVC MAKNUM     ;Branch if not 65802 mode
          BIT AXFLAG
          BVS :XY        ;Branch if long X
          BPL MAKNUM     ;Skip if short M,X
:XY       LDA OPCODE+2
          AND #%1011110  ;Check for both X,Y
          CMP #'X'       ;Check for LDX, CPY, etc
          BEQ :LX
          BIT AXFLAG     ;It is acc, check mode
          BPL MAKNUM     ;Skip if short M
:LONG     JSR CHOP
          JMP GGPR

:LX       BVS :LONG      ;Branch if long X

MAKNUM    LDA OPERAND,X
          CMP #'>'
          BEQ HIB
          CMP #'/'
          BEQ HIB
          CMP #'<'
          BNE :GC
          INX
:GC       JSR CHOP
LOWDIC    LDA #%00001111 ;Low byte
          JMP MAKDIC
HIB       JSR CHOP0
          LDA PASNUM
          BEQ MVPL       ;Ignore on 1st pass
          LDA RELFLAG
          AND EXTFLAG
          BPL STDHI      ;Branch if not ext ref
          LDA PL         ;Get offset from
          ADC #7         ; value ($8000) of ext
          PHA            ;Carry was set by CHOP
          LDA PL+1
          ADC #$80
          BNE GILREL     ;Err if offset > 7
          PLA
          CMP #15
          BGE GILREL     ; "
          LDA PL         ;Get offset again
          AND #%00001111 ;Strip flag bits
          ORA #%01000000 ;Add hi byte flag
          HEX 2C
STDHI     LDA #%01001111 ;High byte
          JSR MAKDIC     ;Must do before
MVPL      MOV PL+1       ;PL ; bytes reversed
          RTS

GILREL    JMP ILLREL
BADOPND   JMP OPDERR

LIST?     BIT ZMDO
          BMI LMP
          LDA DOFL
          AND LSTDOZ
          BNE LD
LMP       LDA MPASS      ;Outer macro flag
          EOR PNFLG      ;Treat >>> special
          AND EXPFLG     ;Only bit 2 is significant
          ORA LSTFLG
LD        RTS

PER       LDA #$62!$82
BRL       EOR #$82
          PHA
          JSR CHKOPND
          LDA PL
          SEC
          SBC #3
          BCS :OK
          DEC PL+1
          SEC
:OK       SBC ADRS
          STA PL
          LDA PL+1
          SBC ADRS+1
          STA PL+1
          INC RELCNT
          PLA
JJP       JMP JPRL0

PEA       JSR CHKOPND
          LDA #$F4
          BNE JJP

COP       LDA #2!$D4
PEI       EOR #$D4
          JSR VALOPND
          JSR LOWDIC
          JMP ZE

REP       ADC #$C2!$E2-1 ;Clears carry
SEP       EOR #$E2
          PHP
          JSR ISVAL
          JSR ABSOPND
          JSR PRCODE
          LDA PL
          ASL
          ASL            ;M,X flags to top
          PLP
          BCC :WASRE
          AND AXFLAG
          EOR AXFLAG
          BCS SAX        ;Always
:WASRE    ORA AXFLAG
          BCC SAX        ;Always

MVP       LDA #$44!$54
MVN       EOR #$54
          JSR VALOPND
          CPY #2
          BNE BADOPND
          LDA PL
          PHA
          JSR CHOP0
          LDA PL
          STA PL+1
          PLA
          STA PL
          JMP GGPRA

MXOP      JSR ABSOPND
INVRT     EOR #%11
          LSR
          ROR
          ROR
SAX       STA AXFLAG
          JMP PRNTLIN

XCE       LDA #$FB
          JSR ISVAL
          BNE INVRT      ;Always
