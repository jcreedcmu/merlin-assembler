*************************
*                       *
*  EDITOR from  MERLIN  *
*                       *
*    ProDOS version     *
*                       *
* Glen Bredon   8/13/85 *
*                       *
*   //e 128K required   *
*                       *
*************************

          DATE

SAVOBJ    KBD
          TR
          EXP OFF
          SW             ;Enable sweet 16

* Ramcard & aux mem equates:

CONTROL   = $C080
BANK1     = %1000
ENABLE    = %11
MAINREAD  = $C002
AUXREAD   = $C003
MAINWRT   = $C004
AUXWRT    = $C005
AUXMOVE   = $C311

* Mac externals:

SWEET     = $DEA6
SWAPPNT   = $BE63
DSKNAMSV  = $BDC0
FILENAME  = $BEC0

          DUMMY $E000
          AND $E103
EXECWRM   JMP 0
EXEC      JMP 0
SLOT      DFB $83
          DA $901
          DA $AA00
          DA $901
WILD      DFB "^"
          DFB 4
SEARCHR   DFB "/"
          DFB 14,20,31   ;Default tabs
          DFB 8          ;Bytes/line after 1st
          DFB 5          ;ASSERR
          DFB $40        ;CURBYT
LSTDOFLG  DFB 0
          DFB 80-8       ;CYC column
WARMDIS   JMP 0
COLDIS    JMP 0
          DEND

BELL      = $E027
SETVEC    = $E051        ;Saves pointers, sets rtn adrs
SAVPNT    = SETVEC+$10   ;Saves pointers
EXECOUT   = $E080        ;Flash/inverse COUT filter
ASS       = $E5F0
ASMBLER   = ASS+3
NEWCOUT   = ASS+12
EVAL      = ASS+15
PRDEC     = ASS+18
OPERAND   = $23C         ;VAL usage
WORKSP    = $280         ; "

* MAC stuff for editor only:

RNGLIST   = $800
STRINGS   = RNGLIST+$60  ;Cannot write above $89F

* Zero page usage besides SW16:

LASTCHR   = 6            ;Used in LISTLN (=R3L)
CH        = $24
CV        = $25
BASL      = $28          ;Used only for 40 col
TABCNT    = $31          ;Tab index
PROMPT    = $33
POS       = $34          ;Cursor pos in Add/Edit
CSWL      = $36
CSWH      = $37
A1L       = $3C          ;Bank move usage
ASFLAG    = A1L          ;A/S flag
A2L       = $3E
LSTFL     = $40          ;LIST or PRINT flag
IFLG      = $41          ;Edit insert mode flag
TRMSK     = $51          ;Used by TRUNC
CASEMASK  = $53
TEMP      = $54          ;Technical LIST usage
FFLG      = $56          ;"F" command usage
FCHR      = $57          ;Holds specified "F" chr
NEWCH     = $58          ;For 80 col case
TABCH     = $59          ;Count for tabbing spaces
HKSV      = $5A          ;ASS expects hooks here
TRFL      = $5F          ;Truncflag, also used by ASS
FPHI      = $73          ;Usually holds $9853
WNDWDTH   = $7E
WNDBOT    = $7F
KEYVEC    = $AE
WORDFLG   = $AC          ;Flags FW, EW & CW commands
DIRFLG    = $B2
VPOS      = $BC          ;Save for CV after printed line
SSVC      = $BD          ;Value of SAVCV when cursor sent
CURCH     = $BE          ;CH of cursor on edit line
CURCV     = $BF          ;CV " when cursor printed
VIDVEC    = $C0          ;Holds 80col or COUT1 adrs
ZSLOT     = $C4          ;Active slot on z-page
FIXFLG    = $C7          ;Flags calls to EDIT from FIXZ
SUBST     = $C8          ;Holds chr to subst. for wild
LASTLIN   = $D4          ;LINNUM save for "."
SAVLIN    = $D6          ;=LINNUM in ASS
SAVVC     = $DC          ;CV of start of line
OBJPNT    = $E2
JUST      = $EE          ;Used by PRDEC in ASS
EFLG      = $F0          ;Flags EDIT mode
TABCHAR   = $F3
TABTBL    = $F4          ;Holds 9 tabs
PG        = $FE          ;# Pages in SETPTRS

* Apple stuff:

IN        = $200
AMPER     = $3F5
KEY       = $C000
STROBE    = $C010
CARDID    = $C30C
PRNTAX    = $F941
PRBL2     = $F94A
VTAB      = $FC22
RDKEY     = $FD0C
RDCHAR    = $FD35
OUTPORT   = $FE95
MONRTS    = $FF58
MONITOR   = $FF69
COUT      = $FDED
CLREOP    = $FC42
CLREOL    = $FC9C
CROUT     = $FD8E
PRERR     = $FF2D
GETNUM    = $FFA7
PASOUT    = $C9AA        ;Pascal output routine

* Data:

MAXTAB    = 9
MASK      = $20
OVFLOW    = $FFFA/10+1

* Dedicated sweet 16 registers:

SOURCE    = 5
HIMEM     = 6
ENDSRC    = 7
TXTP      = 9
LINNUM    = 11
DATAPNT   = 12
RESULT    = 13
SWPOINT   = 15

* (R1 usually holds $200=IN; R3, $8D)

          AST 40

JUMP      MAC
          SET R0,]1-1
          ST SWPOINT
          <<<

JSUB      MAC
          RTN
          JSR ]1
          JSR SWEET
          <<<

INCD      MAC
          INC ]1
          BNE OV
          INC ]1+1
OV        <<<

NEXT      MAC
          INC ]1
          BNE ]2
          INC ]1+1
          BNE ]2
          <<<

CPI       MAC            ;Special sw16 opcode
          DFB 9,]1
          <<<

STADR     MAC
          MOV #]1        ;]2
          LDA #>]1
          STA ]2+1
          <<<

MOV       MAC
          LDA ]1
          STA ]2
          <<<

MOVD      MAC
          MOV ]1         ;]2
          MOV ]1+1       ;]2+1
          <<<

SWMOV     MAC
          LD ]1
          ST ]2
          <<<

          AST 40

          ORG $D000

GOLINK    BIT CONTROL!BANK1
          BRK
          BRK

          PUT PAGINATOR
          ERR *-$D100
          AST 40

EDITOR    STADR GETKEY   ;KEYVEC
SETSWTCH                 ;Was STA KEY
          STA MAINREAD
          STA MAINWRT
TROFF     BEQ *+2        ;Dummy (enters at RTN)
          CLC
TRON      BCC ROT        ;Enters at RTN with carry set
ROT       ROR TRFL
VALID     CLD            ;Safety for 0G reentry
          JSR SWEET      ;Source validity check
          POP @SOURCE
          ST R1
          POP @ENDSRC
          ST R2
          SET R3,$8D
          LD R3
          ST @SOURCE     ;At $900 normally
          ST @ENDSRC
          CPR R1
          BNZ NEW
          CPR R2
          BZ OLD
NEW       LD SOURCE
          ST ENDSRC
OLD       SET HIMEM,FPHI
          LDD @HIMEM
          ST HIMEM
          RTN

WARM      LSR PAGFLAG
          LSR WORDFLG
          LDA CSWH       ;Has user switched to
          CMP #>COUT     ; 40 chr mode?
          BNE :CR
          CMP VIDVEC+1
          BEQ :CR
          LDA #0         ;Do VID 0 if so
          JMP VIDCHG
:CR       JSR CR
          MOV #":"       ;TABCNT ;Just > maxtab and not too big
          JSR COUT
          LSR TRMSK
          LDX #-1
          TXS
          JSR INPUT0
          LDA IN
          CMP #"Q"
          BEQ GOEXEC
          CMP #"q"
          BEQ GOEXEC
          CMP #"$"
          BNE :CNTR
          JSR GETHEX0
          JSR PRLINUM
          LDA #"="
          JSR COUT
          LDX #2
          JSR PRBL2
          LDA #"-"
          JSR COUT
          LDX 0
          LDA 1
          LSR JUST
          JSR PRDEC
          LSR            ;Force branch to warm
:CNTR     CMP #" "
          BLT WARM
          JSR SWEET
          SET DATAPNT,RNGLIST
          SET R1,INSTBL-1
SETIN     SET R2,IN
GTINPUT   LD @R2
          CPI " "
          BZ GTINPUT
          SET R8,MASK    ;Doubles as count
          CPI $E0
          BNC :ST
          SUB R8
:ST       ST TXTP
GETTWO    LDD @R1
          BP ANALZ
          SWMOV TXTP     ;R10
          POP @R1
          CPR TXTP
          BZ GTINPUT
          CPI $E0
          BNC SKP        ;Branch if required chr
          SUB R8
          CPR TXTP       ;LC match?
          BZ GTINPUT
          BR GETTWO
SKP       LD @R1
          BNZ SKP
          INR R1
          BR SETIN

GOEXEC    JMP EXEC

ANALZ     LD R10
          CPI "W"
          BNZ :NW
          SET R4,WORDFLG
          ST @R4
:NW       POP @R1
          BNZ FRMT1

FRMT0     LD R3
          CPR TXTP
          BZ F1
          SET TXTP,CHARMSG
ERR       RTN
          JSR PRERR
          TAX            ;For tabbing
          JSR SMSG
          JMP WARM

F1        SET R0,RNGLIST
          ST R8
          ST R14
          CPR DATAPNT
          BNZ GOROUT
          SUB R0
          STD @R8
          ST @R8
          DCR R0
          STD @R8
          ST @R8
          STD @R8
          BZ *           ;Fake to skip
          DS -1          ;Back up pointers
GOROUT    ST DATAPNT
          SET R4,LASTLIN
          INR R1
          LDD @R1        ;Get routine address
          ST SWPOINT     ;Jump to routine

FRMT1     DCR R0
          BNZ FRMT2
          DCR R2
          BS GETNUMB
          BZ FRMTERR
          LD LINNUM
          STD @DATAPNT
SDP       SET DATAPNT,STRINGS
GOINPUT   BR GTINPUT

FRMTERR   SET TXTP,FMTMSG
          BR ERR
OVFLERR   SET TXTP,OVFMSG
          BR ERR

FRMT2     DCR R0
          BNZ FRMT3
          DCR R2
:L        BS GETNUMB
          DCR R8         ;Countdown $20 input length
          BZ FRMTERR
          LD LINNUM
          STD @DATAPNT
          LD @R2
          CPI ","
          LD RESULT
          ST @DATAPNT
          BZ :L
          CPI "/"-","
          BZ :L
          SUB R0
          DCR R0
          STD @DATAPNT
          DCR R2
          BR SDP

FRMT3     DCR R0
          BZ IS3
FRMT4     DCR R2
:L        POP @R2
          CPI " "
          BZ :L
          ST TXTP
          INR R2

IS3       LD TXTP
          CPI $8D
          BZ :F2
:F1       DCR R8         ;Countdown
          BZ OVFLERR
          LD @R2
          CPR TXTP
          BZ :F3
          CPI $8D
          BNZ :F4
:F2       DCR R2
:F3       SUB R0
:F4       ST @DATAPNT
          BNZ :F1
          BR GOINPUT

GETNUMB   LD @R2
          CPI " "
          BZ GETNUMB     ;Bypass spaces
          CPI "$"
          BZ HEX
          DCR R2
          SET R10,OVFLOW
          SUB R0
NXDIG     ST LINNUM
          LD @R2
          CPI ":"
          BC DONE
          CPI "0"
          BNC DONE
          LD LINNUM
          SUB R10
          BC OVFLERR
          LD LINNUM
          ADD LINNUM     ;Times 10
          ST LINNUM
          ADD R0
          ADD R0
          ADD LINNUM
          ADD RESULT
          BNC NXDIG
          BR OVFLERR

HEX       RTN
          LDY 4
          JSR GETHEX
          STY 4
          JSR SWEET
DONE      POP @R2
          CPR TXTP
          RS

SETPTRS   MOVD SOURCE*2  ;TXTP*2
          SEC
          TYA            ;Y=0
          SBC LINNUM*2
          TAX
          TYA
          SBC LINNUM*2+1
          STA PG
:S1       LDA TXTP*2
          CMP ENDSRC*2
          LDA TXTP*2+1
          SBC ENDSRC*2+1
          BGE :S3
          INX
          BNE :S2
          INC PG
          BEQ :RTS       ;No adjust of LINNUM needed
:S2       LDA (TXTP*2),Y
          INCD TXTP*2
          CMP #$8D
          BNE :S2
          BEQ :S1
:S3       TXA            ;Carry is set
          ADC LINNUM*2
          STA LINNUM*2
          LDA PG
          ADC LINNUM*2+1
          STA LINNUM*2+1
:RTS      RTS

          PUT COMMANDS

PRINTIN   LDY SAVVC
          JSR SWEET
          LD R1
          ST TXTP
          SET RESULT,SAVLIN
          LDD @RESULT
          SUB LINNUM
          BZ LX0-1
          RTN
          LDY: VPOS      ;Not z-page!
LX0       LDX #0
          JSR GOXY
SHOWLIN   CLV
LSTORPR   LDX #0
          BVS LSTLN
LISTLN    JSR PRLINUM
          LDX #6
LSTLN     STX NEWCH
          LDX #-1
SMSG      STX TABCNT
SENDMSG   LDX #0
          LDA LASTCHR    ;Must hold $8D on exit.
          TAY
          EOR TABCHAR    ;Is cursor at tabchar?
          EOR #$60!" "
          PHP
          LDA (TXTP*2,X)
          CMP #'         ;'.$40 ;Cursor
          BEQ LSTCHR?
          CMP #"         ;"
          BNE CHKTAB
LSTCHR?   INX
          PLP
          PHP
          BEQ :BTR
          INX
          CPY TABCHAR
          BEQ :BTR
          CPY #$8D
          BNE CHKTAB
:BTR      BIT TRMSK
          BPL AC
          LDA #$8D
CHKTAB    LDX TABCNT
          CMP TABCHAR
          BNE AC
          INX
AC        STA LASTCHR
          PLP            ;If cursor get
          BNE :A2
          LDY TEMP       ; real chr.
          CPY TABCHAR
          BNE :A2
          INX            ;Simulate tab
:A2       CPX TABCNT
          STX TABCNT
          BEQ CKIV
          CPX #MAXTAB
          BGE CKIV
          LDY TABTBL,X
          CMP TABCHAR
          BEQ :A3
          INY
:A3       CPY NEWCH
          BLT CKIV
          CPY WNDWDTH
          BGE CKIV
          STY TABCH
          PHA
          LDA #" "
          BNE LCH

JO        JSR OUTPUT2
          NEXT TXTP*2    ;SENDMSG

PSP       JSR SEND
LCH       LDY NEWCH
          CPY TABCH
          BLT PSP
          PLA
CKIV      CMP #' '
          BNE :CMRT
          ORA #$80
:CMRT     CMP #$8D       ;Predict scroll
          BEQ :VERT
          LDX NEWCH
          INX
          CPX WNDWDTH
          BNE CHROUT
:VERT     LDX CV
          INX
          CPX WNDBOT
          BLT CHROUT
          DEC SAVVC
CHROUT    CMP #$8D
          BNE JO
          JSR CLEOL
          LDY #0
          STY NEWCH
          SEC
          JSR SWEET
:L        LD @TXTP       ;Find end of line
          SUB R3         ; in case of trunc
          BNZ :L
          RTN
          RTS

* Upon exit from LISTLN, carry must be set and
* Z-flag must be true.  SENDMSG should not disturb
* R1 & R2 and should exit with R0=0.

PRLINUM   MOV #" "       ;JUST ;Right justify
          MOV CV         ;SAVVC
          LDX LINNUM*2
          STX SAVLIN
          LDA LINNUM*2+1
          STA SAVLIN+1
          JMP PRDEC

VAL       SET R2,OPERAND-1
          SET R8,WORKSP-1
:MVL      CPI $80
          LD RESULT
          ST @R2
          ST @R8
          LD @DATAPNT
          BNZ :MVL
          ST R1          ; Zero stuff for the assembler
          ST R10         ;ADRS in ASS
          SET R0,' '
          ST @R2         ;Ass wants a space at end
          ST @R8
          RTN
          LDX #0
          STX DIRFLG
          JSR EVAL       ;X must be 0
          JMP DCHEX

WHERE     NUL
          LD TXTP
          SET LINNUM,0   ;Fake
          DS -2          ;Back up
MINUS     SUB R0
          SUB LINNUM
          ST LINNUM
DECHEX    RTN
DCHEX     LDA #"$"
          JSR COUT
          LDA LINNUM*2+1
          LDX LINNUM*2
          JSR PRNTAX

          BEQ *+2        ;Skip
          DS -1
RESTART   RTN
          JMP WARM

GTRANGE   JSR SWEET
:G1       LDD @DATAPNT
          ST LINNUM
          ST R8          ;Will hold end line #
          BM1 RESTART    ;The exit from many routines
          BNZ :G2
          INR LINNUM     ;No spec, put LINNUM=1
          DCR R8         ;and end line # = $FFFF
:G2       LD @DATAPNT
          BNZ :G4        ;Branch if no end range
          LDD @DATAPNT
          BNZ :G3        ;Branch if end range given
          DCR R0         ;Set max if not
:G3       ST R8          ;Set end line #
          INR DATAPNT
:G4       LD R8
          CPR LINNUM
          BNC GRGERR
          NUL
          LD TXTP        ;Points to start range
          CPR ENDSRC     ;If past ENDSRC then
          BC :G1         ;go back for next range
          RTN
          RTS

SWAP      SET R8,SWAPPNT
          SUB R0
          ST @ENDSRC
          DCR ENDSRC
          LD SOURCE
          ST R1
          LDD @R8
          ST SOURCE
          POPD @R8
          LD R1
          STD @R8
          CPR SOURCE
          BNC STRTOK
          LD SOURCE
          ST R1
STRTOK    LDD @R8
          LD ENDSRC
          ST R2
          LDD @R8
          ST ENDSRC
          POPD @R8
          LD R2
          STD @R8
          CPR ENDSRC
          BC ENDOK
          LD ENDSRC
          ST R2
ENDOK     RTN
          LDY #0
SWLOOP    LDA (2),Y
          PHA
          STA AUXREAD
          LDA (2),Y
          STA (2),Y
          PLA
          STA AUXWRT
          STA (2),Y
          STA MAINWRT
          STA MAINREAD
          LDA 2
          CMP 4
          LDA 3
          SBC 5
          INCD 2
          BLT SWLOOP
          STADR MONRTS   ;AMPER+1
          LDY #$40-1
]LOOP     LDA DSKNAMSV,Y
          PHA
          LDA FILENAME,Y
          STA DSKNAMSV,Y
          PLA
          STA FILENAME,Y
          DEY
          BPL ]LOOP
          JMP EDITOR

GRGERR    BR BRGERR

GETOBJ    SET R1,A1L
          SET R8,OBJPNT
          LDD @R8        ;Obj adrs
          STD @R1        ;Set FROM
          ST TXTP        ; & save
          LDD @R8        ;Get OBLEN
          DCR R0
          ST R2          ;Save length
          ADD TXTP       ;End obj
          STD @R1        ;End move adrs
          LDD @R1        ;Double incr. pnt to A4L
          LDD @DATAPNT   ;Get dest adrs
          BNZ :OV        ;Branch if adrs given
          LDD @R8        ;Else use ADRSV
:OV       CPR ENDSRC     ;Clobber source?
          BNC BRGERR     ;Err if so
          STD @R1        ;Dest adrs
          ADD R2         ;End of dest
          BC BRGERR
          CPR HIMEM
          BC BRGERR
          BZ BRGERR
          RTN
          CLC            ;Move to main
          JSR AUXMOVE
          JMP SETSWTCH

BRGERR    BR RGERR

VIDEO     LD LINNUM
          CPI 8
          BC RGERRC
          RTN
          LDA LINNUM*2
VIDCHG    JSR DOVID
          JMP VALID

DOVID
          LUP 2
          BIT CONTROL!ENABLE
          --^
          ASL
          BEQ :SS
          SEC
          ROR
:SS       STA SLOT
          LDA #"U"&$9F
          JSR GOVID
          JMP COLDIS     ;Resets ZSLOT

CONT      LDD @R4        ;Double incr

RPTLST    LDD @R14       ;Was a number
          BNZ :RP        ;specified?
          POPD @R14      ;No, then
          LDD @R4        ;get old one.
          STD @R14
:RP       SUB R0         ;Simulate comma
          ST @R14
          DCR R0
          STD @R14
          ST @R14
          STD @R14

LIST      SET R4,LASTLIN
          LDD @DATAPNT
          STD @R4
          POPD @DATAPNT  ;Double decr
          RTN

PRINT     LDA #0         ;Enters at PRINT+1 (RTN)
          LSR            ;V-bit significant
          STA LSTFL
          LDA TRFL
          STA: TRMSK     ;Not zero page!
NXRNG     JSR GTRANGE
          JSR CROUT
          STA PAGFLAG
          LSR LISTFLG
:JK       JSR KEYCHK
          BIT LSTFL      ;Establish V-flag
          JSR LSTORPR
          JSR SWEET
          LD LINNUM
          INR LINNUM
          CPR R8
          BC NXRNG-1
          LD TXTP
          CPR ENDSRC
          BC NXRNG-1
          RTN
          BEQ :JK        ;Always

PR        LD LINNUM
          CPI 8
RGERRC    BC RGERR
          RTN
          LDA LINNUM*2
          JSR OUTPORT
          JMP WARM

LINK      LD SOURCE
          SUB ENDSRC
          BNZ RGERR
          RTN
          JSR SAVPNT
          JMP GOLINK

RGERR     SET TXTP,RNGMSG
GOERR     JUMP ERR

COPNT     JSR GTRANGE
          JSR SWEET
          SWMOV R8       ;LINNUM
          SWMOV TXTP     ;R1 ;Start range
          INR LINNUM
          NUL
          LD TXTP        ;End range
          SUB R1
          ST R2          ;Length
          SET DATAPNT,STRINGS
          LDD @DATAPNT
          ST LINNUM      ;Dest. line #
          NUL
          LD R1
          ADD R2
          CPR TXTP       ;Holds destination
          BNC :CP
          BZ :CP
          ST R1
          SUB R2
          CPR TXTP
          BNC RGERR
:CP       DCR R2         ;Distance between CRs
          LD R1
          STD @DATAPNT   ;Start rng after COPY
          ADD R2         ; (1 past CR)
          STD @DATAPNT   ;End range (at CR)
          RTN

MOVEUP    JSR SWEET
          INR R2         ;Distance to move
MVUP      LD ENDSRC
          ST R10
          ADD R2
          CPR HIMEM
          BNC MU
GOMERR    SET TXTP,MEMFLL
          BR GOERR

MU        ST ENDSRC
          SUB R0
          ST @R10
          DCR R10
          LD R10
          CPR TXTP
          RTN
          LDX RESULT*2+1
          INX
          LDA #0
          STA RESULT*2+1
          LDY RESULT*2
          JSR SWEET
          LD R10
          SUB RESULT
          ST R10
          LD ENDSRC
          CPR RESULT     ;Diff in RESULT
          RTN
          BEQ :M2        ;Status of Y
:M1       LDA (20),Y
          STA (RESULT*2),Y
          DEY
          BNE :M1
:M2       LDA (20),Y
          STA (RESULT*2),Y
          DEC 21
          DEC RESULT*2+1
          DEY
          DEX
          BNE :M1
          JSR SWEET
:M3       SWMOV @R1      ;@TXTP
          DCR R2
          BNZ :M3
          RTN
          RTS

ASM       SET TXTP,QUESTION
          RTN
          LDX #3
SAVHK     MOV CSWL,X     ;HKSV,X
          DEX
          BPL SAVHK
          JSR WARMDIS
          LDA SEARCHR    ;Update defeated?
          BPL :ASMB      ;Branch if so
          STA STRINGS
          JSR SENDMSG
:GTANS    JSR BELLKEY
          AND #%11011111
          CMP #"N"
          BEQ :ASMB
          EOR #"Y"
          BNE :GTANS
          STA STRINGS+1
          JSR NXTRNG
          LSR FIXFLG
          JSR EDITLIN
:ASMB     JSR SWEET
          LD ENDSRC      ;Check memory, can be
          CPR HIMEM      ; bad only on a file
          BC GOMERR      ; load that is not edited.
          SET TXTP,ASMSG
          SUB R0         ;0-5 must contain 0 on
          ST R1          ; entry to assembler.
          ST R2
          RTN
          JSR SAVPNT
          JSR SENDMSG    ;Leaves R0=0, carry set
          ROR PAGFLAG
          LSR JUST
          JMP ASMBLER

PRINTER   RTN
          LDA LINNUM*2
          CMP #8
          BGE USERP
          CMP #1
          BNE :OUTP
          AND LSTDOFLG
          BNE :OUTP
          JSR DOVID
          LDA #1
:OUTP     JSR OUTPORT
SETPR     LDX NUMLINES
          DEX
          STX LINCNT
          MOV NUMCHRS    ;CHRCNT
          LDX #1
          STX PAGE
:INITPR   LDA STRINGS-1,X
          BEQ :SP
          JSR COUT
          INX
          BNE :INITPR
:SP       STA PAGE+1
          JSR CROUT
          LDY CSWH
          CPY #>NEWCOUT
          BEQ :SETOUT    ;Branch if already connected
          STY PAGVEC+1
          MOV CSWL       ;PAGVEC
:SETOUT   STADR NEWCOUT  ;CSWL
          LDY #-1
:MT       INX
          INY
          MOV STRINGS-1,X;TITLE,Y
          BNE :MT
          TYA            ;Add title length
          CLC
          ADC #20        ; to default header length
          EOR #$FF       ; subtract from
          ADC CHRCNT     ; line length
          LSR            ; /2
          STA HEADLEFT
          JMP VALID

USERP     JSR AMPER
          JMP SETPR

REPLACE   JSUB DEL
          LDD @R14
          SET LINNUM,0   ;Fake to skip 2
          DS -2          ;Back up pointers
ADD       SUB R0
          DCR R0
          ST LINNUM
INSERT    NUL
          RTN
          ROR SAVLIN+1   ;Force new posn
:I        LSR EFLG
          JSR SWEET
          SET R1,IN+1
          LD R3          ;Init empty line
          STP @R1
          SWMOV TXTP     ;R10 ;Protect txtp from PRNTLIN
          JSUB EDITIN
          SWMOV R10      ;TXTP
          INR LINNUM
          SUB R0
          ST R2
          RTN
          STY 4
          JSR MOVEUP
          BEQ :I         ;Always

DELETE    RTN
:DL       JSR DEL
          BEQ :DL        ;Always

LENGTH    LD ENDSRC
          SUB SOURCE
          ST LINNUM
          SET TXTP,BYTEMS
          JSUB LISTLN
          LD HIMEM
          SUB ENDSRC
          BC :SL
          SUB R0
:SL       ST LINNUM
          RTN
          JSR LISTLN
          BEQ GWRM       ;Always

COPY      RTN
          JSR COPNT
GWRM      JMP WARM

MOVE      JSUB COPNT
          POPD @DATAPNT
          ST TXTP
          POPD @DATAPNT
          ST R10
          DCR R10
          RTN
          JSR MVEDWN
          BEQ GWRM       ;Always

FIND      RTN
          JSR GTRANGE
:JL       JSR LOCATE
          JSR SHOWLIN
          NEXT LINNUM*2  ;:JL

NXTRNG    JSR GTRANGE
LOCATE    LDA 16         ;Compare R8=end range
          CMP LINNUM*2
          LDA 17
          SBC LINNUM*2+1
          BCC NXTRNG
LCT1      LDA TXTP*2     ;Put TXTP
          STA 8          ;in R4
          CMP ENDSRC*2   ;and check ENDSRC
          LDA TXTP*2+1
          STA 9
          SBC ENDSRC*2+1
          BCS NXTRNG
          LDY #0
          STY 1          ;Init high byte of R0
          TYA
LCT2      STA SUBST
LCT3      LDX STRINGS,Y
          STX 2
          BEQ FOUND
NXCHR     LDA (TXTP*2),Y
          ORA #$80
          CMP #$8D
          BEQ NXTL
          INY
          CMP 2
          BEQ LCT3
          CPX WILD
          BEQ LCT2
          NEXT TXTP*2    ;LCT1

NXTL      TYA
          ADC TXTP*2     ;Carry is set
          STA TXTP*2
          BCC :NC
          INC TXTP*2+1
:NC       NEXT LINNUM*2  ;LOCATE

FOUND     BIT WORDFLG
          BPL FND
          STY 0
          JSR SWEET
          ADD TXTP
          ST R10
          LD @R10
          BS ALPNUM
          POP @R4
          INR R4
          BS ALPNUM
          RTN

FND       STY 0
          JSR SWEET
          ST R10         ;Length find str
          ADD TXTP
          ST R2
          SET R0,STRINGS+1
          ADD R10        ;Point to replc str
          ST R10
:FR       POP @TXTP
          CPR R3
          BNZ :FR
          INR TXTP
          SWMOV TXTP     ;R14
          SET R1,IN
          SET RESULT,IN+$FF
          RTN
KEYCHK    LDA KEY
          BPL K2
          BIT STROBE
          JSR WHATKEY
          BNE K2
GKY       LDA KEY
          BPL GKY
K2        RTS

* After found, TXTP points to start of line,
* R4 to start of FIND string and R2 to end
* of FIND string.

GONXT     RTN
          BMI NXCHR      ;Always
ALPNUM    CPI "0"
          BNC GOOD
          CPI ":"
          BNC GONXT      ;Reject & exit
          CPI "A"
          BC GONXT       ;Reject
GOOD      RS             ;Accept

CHANGE    SET TXTP,AORS
          RTN
          JSR SENDMSG
:ANS      JSR BELLKEY
          STA SAVLIN+1   ;Force new listing
          AND #%11011111
          CMP #"S"
          BEQ :SVANS
          EOR #"A"
          BNE :ANS
:SVANS    STA ASFLAG
          JSR GTRANGE
          LDA STRINGS
          BEQ JW
ALTER     JSR LOCATE
          JSR SWEET
:A1       LD TXTP
          SUB R4
          BZ :A4
          SWMOV @TXTP    ;@R1 ;Get line up to find str
          LD R1
          SUB RESULT
          BNZ :A1
          BR :A5
:A2       RTN
          LDA 0
          CMP WILD
          BNE :A3
          LDA SUBST
          BEQ :A3
          STA 0
:A3       JSR SWEET
          ST @R1
:A4       LD R1
          SUB RESULT     ;Line too long?
          BZ :A5
          LD @R10        ;Get replacement str
          BNZ :A2
:A5       SWMOV R1       ;R10 ;Point to end replt in IN
:A6       LD R1
          SUB RESULT
          BZ :A7         ;Exit if too long
          SWMOV @R2      ;@R1 ;Get remainder of line
          SUB R3         ; until CR
          BNZ :A6
:A7       SET R1,IN
          RTN
          JSR PRINTIN    ;Carry is set on return
          BIT ASFLAG
          BPL :A9        ;Branch if "ALL"
          JSR BELLKEY
          BCS :A9
          JSR SWEET
          SWMOV R14      ;R1
          INR R4
          RTN
          JSR PRINTIN
:A8       JSR SWEET
          SWMOV R4       ;TXTP
          RTN
          BCS ALTER      ;Always

:A9       JSR FIX
          CPY 20         ;New line < end replct?
          BGE :AA
          STY 20         ;Point to end of line if so
:AA       JSR SWEET
          LD R14         ;Reset ptr to line start
          ST TXTP
          ADD R10        ;Point to end replacement
          SUB R1         ;=IN
          ST R4
          RTN
          JSR IT0        ;Does the change
          SEC            ;Force branch to ALTER
          BCS :A8

USER      RTN
          JSR AMPER
JW        JMP WARM

TEXT      SET R8," "
          BS CNV
          RTN
          BCS JW         ;Always

CNV       LD SOURCE
          ST R1
:TL       LD R1
          CPR ENDSRC
          BZ :RET
:L        LD @R1
          CPR R8
          BNZ :TL
          CPI $80
          LD RESULT
          STP @R1
          BR :L
:RET      RS

FIXZ      SET R8,' '     ;Convert to real spaces first
          BS CNV
          RTN
          HEX 2C         ;Skip next 2 lines

EDIT      RTN
          CLC
          ROR FIXFLG
          JSR GTRANGE
NXLIN     JSR LOCATE
          JSR EDITLIN
          JSR SWEET
          SWMOV R14      ;TXTP
          INR LINNUM
:FR       LD @TXTP
          CPR R3
          BNZ :FR
          RTN
          JMP NXLIN

EDITLIN   LDY #-1
          STY SAVLIN+1   ;Force new list of line
          STY EFLG
TXTP>IN   INY
          CPY #$FF
          BEQ :BFX
          LDA (TXTP*2),Y
          CMP #' '
          BEQ :STIN
          ORA #$80
:STIN     STA (2),Y
          CMP #$8D
          BNE TXTP>IN
:BFX      BIT FIXFLG
          BMI IN>TXTP
          JSR EDITIN
          JSR SWEET
          SWMOV R14      ;TXTP
          RTN
          BCC IT0
          BCS EDITLIN    ;If control R
IN>TXTP   JSR FIX
IT0       JSR SWEET
IT1       LD @TXTP
          DCR TXTP
          SUB R3
          BZ IT2         ;Branch if new>=old
          LD @R1
          CPR R3
          BZ IT4         ;Branch if old>new
          ST @TXTP       ;Move byte
          BR IT1
IT2       ST R2
          LD @R1
          SUB R3
          BZ XIT         ;Exit if new=old
          SWMOV R1       ;R10 ;Set up for move
          DCR R1
IT3       INR R2
          LD @R10
          CPR R3
          BNZ IT3
          JUMP MVUP

XIT       ST @ENDSRC
          DCR ENDSRC
          RTN
          RTS

IT4       SWMOV TXTP     ;R10
IT5       LD @TXTP
          CPR R3
          BNZ IT5
          DCR TXTP
          RTN
MVEDWN    JSR SWEET
MDWN      SUB R0
          ST @ENDSRC
          LD TXTP
          SUB ENDSRC
          ST R1
          DCR ENDSRC
          RTN
          LDX 3
          LDA #0
          STA 3
          JSR SWEET
          LD TXTP
          SUB R1
          ST TXTP
          LD R10
          SUB R1
          ST R10
          SUB TXTP
          ADD ENDSRC
          ST ENDSRC
          RTN
          LDY 2
:MD       LDA (TXTP*2),Y
          STA (20),Y
          INY
          BNE :MD
          INC 21
          INC TXTP*2+1
          INX
          BNE :MD
          RTS            ;Z-flag true on exit

DEL       JSR GTRANGE
          JSR SWEET
          SWMOV TXTP     ;R10
          SWMOV R8       ;LINNUM
          INR LINNUM
          BZ SYNERR
          NUL
          BR MDWN

SYNERR    JUMP FRMTERR

* EDITIN used by both edit & add

EDITIN    LDY #0
          STY IFLG       ;Init insert flag,
          STY CASEMASK   ; upper case,
          STY FFLG       ; find flag,
CY1       STY POS        ; and cursor position.
          INY
          BNE CY2
          DEC POS
CY2       MOV #$8D       ;IN+$FF
          LDY POS
          LDA (2),Y
          CMP #$8D
          BNE E2
          STA IN+1,Y
          LDA #" "
E2        STA TEMP       ;Save chr under cursor
          CMP #$E0
          BLT NOTL
          AND #$1F
NOTL      AND #$3F
          ORA #$40
          STA (2),Y
          JSR PRINTIN    ;Will reconvert cursor if nec.
          LDX CURCH
          LDA CURCV      ;Calculate real V-posn of cursor
          ADC SAVVC      ;Carry is set
          SBC SSVC       ;Carry is clear
          TAY
          JSR GOXY       ;Position cursor
          LDY POS
          LDA TEMP       ;Restore real chr
          STA (2),Y
INSRT     JSR GOGETKEY
          LSR FFLG       ;Shift S bit to V and reset flag
          BIT FFLG       ;F command in effect?
          BVC :CSPC      ;No, bypass
          CMP FCHR       ;Same chr?
          BEQ CI         ;Branch if so
:CSPC     CMP #$FF       ;Rub?
          CLC
          BEQ DELCHR
          CMP #" "       ;Control chr input?
          BLT CHKL
          BNE CASCON
          LDA IN         ;Convert spaces
          EOR #"*"       ; in comment lines.
          BEQ CPR1
          EOR #"         ;"!"*"

CPR1      CMP #1
          LDA #" "*2
          ROR
CASCON    CMP #"@"
          BLT NXT
          EOR CASEMASK
NXT       BIT IFLG       ;Insert mode in effect?
          BPL SIN        ;Branch if not
PUSH      PHA            ;Move stuff over for insert
          LDY #-1
CY3       DEY
          MOV (2),Y      ;IN+1,Y
          CPY POS
          BNE CY3
          PLA
SIN       STA (2),Y      ;Insert input chr
          INY
          BNE GOCY1      ;Always

CHKL      CMP #"L"&$9F
          BNE LSC
          LDA CASEMASK
          EOR #$20
          STA CASEMASK
GOCY2     JMP CY2

LSC       LSR IFLG
          CMP #"U"&$9F
          BNE LARR
          LDA (2),Y      ;Use right arrow for
          BGE CASCON     ; case conversion.

LARR      CMP #$88
          BNE CHKI
          TYA
          BEQ INSRT
          DEY
GOCY1     JMP CY1

CHKI      CMP #"I"&$9F
          BNE CHKD
DELCHR    ROR IFLG
          BMI INSRT      ;Branch if not DEL
          TYA
          BEQ GOCY2
          DEY
          DEC POS
LI        MOV IN+1,Y     ;(2),Y
          INY
          BNE LI
          BEQ GOCY2

CHKD      CMP #"D"&$9F
          BEQ LI

CHKF      CMP #"F"&$9F
          BNE CHKP
          JSR GOGETKEY
          BEQ GOCY2
          STA FCHR
CI        INY
          LDA (2),Y
          CMP #$8D
          BEQ GOCY2
          EOR FCHR
          AND #%01011111 ;Enable lc
          BNE CI
          SEC
          ROR FFLG       ;Remember mode
          BMI GOCY1      ;Always

CHKP      CMP #"P"&$9F
          BNE CHKN
          LDX #"*"
          STX IN
          STX IN+$1F
          TYA            ;1st chr in line?
          BEQ PUTAST
          LDX #' '
PUTAST    TXA
          LDY #$1E
:PA       STA (2),Y
          DEY
          BNE :PA
          INY
          LDA #$8D
          STA IN+$20
          BNE GOCY1

CHKN      CMP #"N"&$9F
          BNE CHKO
          JSR FIX
          BNE GOCY1      ;Always

CHKO      CMP #"O"&$9F
          BNE :NL
          JSR GOGETKEY
          BEQ :NL
          JMP PUSH

:NL       LDY #0
          CMP #"B"&$9F
          BEQ GOCY1
          DEY
          CMP #$8D
          PHP
          BEQ DOIT
          LDY POS
          CMP #"Y"&$9F
          BNE CHKR
          LDA #$8D
DOIT      STA (2),Y
          BNE JFX        ;Branch if cntr Q.
          BIT EFLG       ;Ignore if in
          BMI JFX        ; edit mode.
          LDY POS        ;Cursor on 1st chr?
          BNE JFX        ;Branch if not.
          JSR FIX        ;Emulate old ADD exit.
          TYA            ;Empty line?
          BNE SYP
CANCEL    LDA #"\"
          JSR COUT
          JMP JWRM

JFX       JSR FIX
SYP       STY POS
          JSR PRINTIN
          PLP            ;Was it a cntr Q?
          BEQ :LYP       ;Branch if not
          BIT ZSLOT
          BMI :CL80
          JSR CLREOP
          JMP :LYP
:CL80     LDA #$8B       ;For Ultraterm only
          JSR GOVID
:LYP      LDY POS
          CLC            ;Force replacement of line
RTS2      RTS

CHKR      PLP            ;Pop stack
          CMP #"C"&$9F   ;Give him two exit keys
          BEQ CANCEL
          CMP #"X"&$9F   ; in case he forgets.
          BEQ CANCEL
          BIT EFLG
          BPL :JNXT
          CMP #"R"&$9F
          BEQ RTS2       ;Carry set aborts change.
:JNXT     JMP NXT

* INPUT is used only for command mode

INPUT0    MOV #" "       ;PROMPT
:NX       DEX
          STA IN,X       ;Probably not needed
          BNE :NX
          STX STRINGS    ;To speed FIX cmd
          TXA
SCM       STA CASEMASK
          BPL INPUT      ;Always

NOTCR     INX
          BEQ CANCEL
          CMP #$88
          BNE SENDIT
          DEX
          BEQ INPUT
          DEX
SENDIT    JSR OUTPUT
INPUT     JSR RDCHR
          CMP #"X"&$9F
          BEQ CANCEL
          CMP #$FF
          BNE :BS
          LDA #$88
:BS       CMP #$88
          BEQ NOTCR
          CMP #"L"&$9F
          BNE :CPO
          LDA CASEMASK
          EOR #%00100000
          BPL SCM        ;Always
:CPO      CMP #"O"&$9F   ;Untypable chr command?
          BNE :CPK
          JSR GETKEY     ;Yes, get next chr (8/13/85)
          JMP :CASE
:CPK      CMP #"U"&$9F
          BNE :CASE
          LDA (BASL),Y
:CASE     CMP #"@"
          BLT :ADDIN
          EOR CASEMASK
:ADDIN    STA IN,X
          CMP #$8D
          BNE NOTCR
CLEOL     LDA ZSLOT
          BMI :CO80
:REGC     JSR CLREOL
          JMP CR
:CO80     AND #7
          CMP #3         ;Support slot 3 only
          BNE :CEOL      ; for ULTRA
          LDA CARDID     ;Is it ULTRA?
          CMP #$87
          BNE :REGC      ;Branch if not
          MOV $5F8       ;WNDWDTH ;Fix width and
          MOV $4F8       ;WNDBOT ; height for ULTRATERM
:CEOL     LDA #$9D
          JSR GOVID
CR        JSR CROUT
          LDY CV
          STY VPOS
          RTS

RDCHR     STX TEMP
          LDX #0
          JSR RDCHAR
          PHA
          LDX TEMP
          BIT ZSLOT
          BPL :PUL
          LDA #" "
          JSR OUTBACK    ;Fool Ultraterm
          LDA IN,X       ;Output 2 chrs & backspace
          JSR OUTBACK
:PUL      PLA
          LDY CH         ;Needed for slot 0
          RTS

OUTBACK   JSR OUTPUT2
          LDA #$88
          JMP COUT

GOKEYV    JMP (KEYVEC)
GOGETKEY  JSR GOKEYV
          CMP #$8D
          RTS

TABS      SET R2,TABTBL
          SET R8,MAXTAB
:T1       LDD @DATAPNT
          BM :T2
          ST @R2
          LD @DATAPNT
          DCR R8
          BNZ :T1
          BR :T4
:T2       SUB R0
:T3       ST @R2
          DCR R8
          BNZ :T3
:T4       RTN
          LDA STRINGS
          BEQ JWRM
          STA TABCHAR
JWRM      LDX #0
          LDY VPOS
          JSR GOXY
          JMP WARM

BELLKEY   JSR BELL
          JSR RDKEY
WHATKEY   CMP #"/"
          BEQ JWRM
          CMP #"C"&$9F
          BEQ JWRM
          CMP #"X"&$9F
          BEQ JWRM
          CMP #" "
          RTS

GETKEY    JSR GKY
          BIT STROBE
          RTS

* NOTE: Control chrs in source are there correctly
* (high bit set).  They are converted to inverse
* here if not being sent to a printer.

OUTPUT    CMP #$88       ;Must process backspace
          BEQ SEND2
OUTPUT2   CMP #" "       ;Control?
          BGE SEND
          CMP #$8D       ;Must process CR
          BEQ L0
          TAY            ;Test sign
          BMI CTRLMSK    ;Else it is cursor
          LDY SAVVC
          STY SSVC
          LDY NEWCH
          STY CURCH
          LDY CV
          STY CURCV
          BIT ZSLOT      ;If $40 bit clear then
          BPL SEND
          LDA TEMP
          BVC IV         ; use "inverse cursor"
          LDX ZSLOT      ;Contains $CN when V-set
          TXA            ;Must have X=$CN, Y=$N0
          LUP 4
          ASL
          --^
          TAY
          LDA #0         ;Send NULL just to
          STA $5B8,X     ;turn on cursor
          JSR PASOUT
          LDA TEMP       ;Now print real chr
          ORA #$80
          BNE OUTPUT2
CTRLMSK   LDY CSWH       ;Printer?
          CPY VIDVEC+1
          BEQ IV
          CPY #>NEWCOUT
          BNE SEND2
          BIT PAGFLAG
          BMI SEND2
IV        AND #%01111111
SEND      LDY NEWCH      ;Update NEWCH for printing chr
          INY
          CPY WNDWDTH
          BLT STYNCH
L0        LDY #0
STYNCH    STY NEWCH
SEND2     JMP EXECOUT

MON       RTN            ;Save pointers and set up
          JSR SETVEC     ; return adrs
          JMP MONITOR

GETHEX0   LDY #1
GETHEX    JSR GETNUM
          SEC
          JSR SWEET
          SET RESULT,A2L
          LDD @RESULT
          ST LINNUM
          SUB R0
          SUB LINNUM
          RTN
RTS3      RTS

GOXY      STX CH         ;Must do this way for
          STY CV         ; Apple 80 col card
          CPY #24
          BGE RTS3
          JMP VTAB

          AST 40

CHARMSG   ASC ": Extra command characters"8D
FMTMSG    ASC ": Format"8D
OVFMSG    ASC ": Overflow"8D
MEMFLL    ASC ": Memory full"8D
RNGMSG    ASC ": Range"8D
BYTEMS    DCI "Bytes "
          ASC "used"8D
          DCI "Bytes "
          ASC "left"8D
AORS      ASC "All or some (A/S)?"8D
QUESTION  ASC "Update source (Y/N)?"8D
ASMSG     ASC "Assembling"8D

          AST 40

FIX       LDY #-1
          MOV #$8D       ;(2),Y
          LDA IN
          CMP #"*"
          BEQ COMMENT
          CMP #"         ;"
          BEQ COMMENT
GOTHRU    JSR GTIN
SPACE?    CMP #" "
          BNE GOTHRU
          JSR GTIN
          CMP #"         ;"
          BEQ COMMENT
          CMP #"""
          BEQ COMMENT
          CMP #"'"
          BNE SPACE?
COMMENT   JSR GTIN
          CMP #" "
          BNE COMMENT
          MOV #' '       ;(2),Y
          BNE COMMENT
GTIN      INY
          LDA (2),Y
          CMP #$8D
          BNE :RTS
          PLA            ;Final exit,
          PLA            ; carry must be set.
:BACK     TYA
          BEQ :PR
          DEY
          LDA (2),Y
          AND #$FF!" "
          BEQ :BACK      ;Delete extra spaces
          INY
:PR       MOV #$8D       ;(2),Y
:RTS      RTS

          ERR \$DD95
          DO SAVOBJ
          SAV ASMOBJ/ED
          FIN
