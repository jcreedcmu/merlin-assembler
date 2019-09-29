************************
*                      *
* EXECUTIVE & SWEET 16 *
*                      *
*     from MERLIN      *
*                      *
*       8/30/85        *
*                      *
*   //e 128K ProDOS    *
*                      *
************************

          DATE

SAVOBJ    KBD
          TR
          EXP OFF
          SW             ;Enable sw16 code

* Opcode BNM1 is not used and has been changed to CPI
* here, which is used as a compare immediate in the
* EDITOR.

* Opcode D has been defined to JSR SETPTRS in EDITOR.

* The sweet 16 subroutine call has been changed so that
* the return address is saved in RETADR ($DA).  This means
* that subs cannot be nested but that R12 is not destroyed
* by a BS.

*  In MENU: If 80-col card is in effect then:
*
* HEX 81 gives an extra 20 HTAB,
* HEX 82 does a CR and HTAB 20

* Externals:

ASS       = $E5F0
EDITOR    = $D100

* Misc:

PL        = 6            ;Must be compatible
SPNT      = 8            ;with asm
SOURCE    = $A
HIMEM     = $C
ENDSRC    = $E
CH        = $24
IRQASAV   = $30
INVFLG    = $32
PROMPT    = $33
CSWL      = $36
PCL       = $3A
PCH       = $3B
A2L       = $3E
WNDWDTH   = $21
WNDBOT    = $23
OURWDTH   = $7E
OURBOT    = $7F
VIDVEC    = $C0          ;80 col I/O vector save
ZSLOT     = $C4
OBJPNT    = $E2          ;Set by ass
OBLEN     = $E4          ; "
ADRSV     = $E6          ; "
ORGFLG    = $E8          ; "
REALCHR   = $F1
TABCHAR   = $F3
TABS      = $F4
IN        = $200
BRKVEC    = $3F0
YVEC      = $3F8
SRC       = $901
HIM       = $AA00
BASIC     = $E000
RDKEY     = $FD0C
GETLN2    = $FD6F
SETNORM   = $FE84
SETKBD    = $FE89
OUTPORT   = $FE95
HOME      = $FC58
COUT      = $FDED
CROUT     = $FD8E
PRNTAX    = $F941
INIT      = $FB2F
STROBE    = $C010

* DOS stuff:

INT       = $B200        ;Interpreter start
JPRTYP    = INT
JEXIT     = INT+$03
JCMD      = INT+$06
JCAT      = INT+$09
JCLOSE    = INT+$0C
JLOAD     = INT+$0F
JSAVE     = INT+$12
JERROR    = INT+$15
JPREFIX   = INT+$1E
JPRDATE   = INT+$21
WRMVEC    = INT+$2A
MOADR     = INT+$2E
ERRTN     = INT+$2C
ERRSAVE   = INT+$3D
UCURS     = INT+$3E      ;No longer used
ERRFLAG   = INT+$3F
RWBUF     = $BE08
RWCNT     = $BE0A
RWGOT     = $BE0C
OBJTYPE   = $BE52
DOSFNAM   = $BE80        ;Used for all disk access
FILENAME  = $BEC0        ;In Merlin global page
DATE      = $BF90

* Ramcard & aux mem equates:

CONTROL   = $C080
ENABLE    = %11
BANK1     = %1000
KEY       = $C000
MAINREAD  = $C002
AUXREAD   = $C003
MAINWRT   = $C004
AUXWRT    = $C005
CLR80VID  = $C00C
CLRALTCH  = $C00E
CARDID    = $C30C

          AST 35

PRINT     MAC
          JSR SENDMSG
          IF "=]1
          ASC ]1
          ELSE
          HEX ]1
          ASC ]2
          FIN
          BRK
          <<<

PRHEX     MAC
          LDX ]1
          LDA ]1+1
          JSR PRNTAX
          <<<

INCD      MAC
          INC ]1
          BNE NC
          INC ]1+1
NC
          <<<

POKE      MAC
          MOV #]2        ;]1
          <<<

STADR     MAC
          POKE ]2        ;]1
          POKE ]2+1      ;]1/$100
          <<<

MOV       MAC
          LDA ]1
          STA ]2
          <<<

MOVD      MAC
          MOV ]1         ;]2
          MOV ]1+1       ;]2+1
          <<<

CPI       MAC
          DFB 9,]1
          <<<

PRTAB     MAC
          LDA #]1
          JSR TABMSG
          <<<

          AST 30

SETPTRS   = $D27F
R13L      = $1A
R13H      = $1B
PRIOR     = $FF          ;R14 free for use
R15L      = $1E
R15H      = $1F
RETADR    = $DA
MONSAVE   = $FF4A
RESTORE   = $FF3F


          ORG $DD95

MENU      NOP
          NOP
          PRTAB 11
          HEX 81
          INV " MERLIN-8 "
          INV " 2.59 "8D8D00
          PRTAB 12
          HEX 81
          ASC "By Glen Bredon"
          HEX 8D8D82
          ASC "C :Catalog"82
          ASC "L :Load source"82
          ASC "S :Save source"82
          ASC "A :Append file"82
          ASC "D :Disk command"82
          ASC "E :Enter ED/ASM"82
          ASC "O :Save object code"82
          ASC "@ :Set date"82
          ASC "Q :Quit"8D00
          PRTAB 14
          HEX 81
          ASC "Source: A$"00
          PRHEX SOURCE
          PRINT ",L$"
          SEC
          LDA ENDSRC
          SBC SOURCE
          TAX
          LDA ENDSRC+1
          SBC SOURCE+1
          JSR PRNTAX
          JSR CROUT
          JSR TEST       ;Valid obj?
          BNE :NOB
          PRTAB 14
          HEX 81
          ASC "Object: A$"00
          JSR TAIL1
:NOB      PRINT 82       ;"Prefix: "
          JSR JPREFIX
          JSR CROUT
          JMP CROUT

* Sweet 16:

SWEET     JSR MONSAVE    ;Returns with DEC clear
          PLA
          STA R15L
          PLA
          STA R15H
:SWL      JSR :SW
          JMP :SWL
:SW       INCD R15L
          LDA #>SET      ;common high byte
          PHA
          LDY #0
          LDA (R15L),Y
          AND #$F
          ASL
          TAX
          LSR
          EOR (R15L),Y
          BEQ :TOBR
          STX PRIOR
          LSR
          LSR
          LSR            ;Carry is clear for all
          TAY            ; register ops.
          LDA OPTBL-2,Y
          PHA
          RTS

:TOBR     INCD R15L
          LDA OPTBL+1,X
          PHA
          LDA PRIOR      ;Last result and relevant reg.
          LSR            ;Retrieve carry
          PHP
          ASL
          TAX            ;Point to last CPR register etc.
          PLP
          RTS

OPTBL     DFB SET-1,RTN-1,LD-1
          DFB BR-1,ST-1,BNC-1
          DFB LDAT-1,BC-1,STAT-1
          DFB BP-1,LDDAT-1,BM-1
          DFB STDAT-1,BZ-1,POP-1
          DFB BNZ-1,STPAT-1,BM1-1
          DFB ADD-1,CPIMM-1,SUB-1
          DFB BK-1,POPD-1,RS-1
          DFB CPR-1,BS-1,INR-1
          DFB NEWOP-1,DCR-1

* The following must be contained on one page:

SET       MOV (R15L),Y   ;1,X
          DEY
          MOV (R15L),Y   ;0,X
          LDX #R15L
          JSR INR
          BCC INR        ;Always

RTN       PLA
          PLA
          JSR RESTORE
          JMP (R15L)

BK        = *+1
LD        MOV 0,X        ;0
          MOV 1,X        ;1
          RTS

ST        MOV 0          ;0,X
          MOV 1          ;1,X
          RTS

STAT      MOV 0          ;(0,X)
          LDY #0
STAT3     STY PRIOR
INR       INC 0,X
          BNE :RET
          INC 1,X
:RET      RTS

LDAT      MOV (0,X)      ;0
          LDY #0
          STY 1
          BEQ STAT3
POP       LDY #0
          BEQ POP2
POPD      JSR DCR
          LDA (0,X)
          TAY
POP2      JSR DCR
          MOV (0,X)      ;0
          STY 1
POP3      LDY #0
          STY PRIOR
          RTS

LDDAT     JSR LDAT
          MOV (0,X)      ;1
          BCC INR        ;Always

STDAT     JSR STAT
          MOV 1          ;(0,X)
          BCC INR        ;Always

STPAT     JSR DCR
          MOV 0          ;(0,X)
          BCC POP3       ;Always

NEWOP     JSR SETPTRS
          LDX #R15L      ;convert to one byte opcode
DCR       LDA 0,X
          BNE :DC
          DEC 1,X
:DC       DEC 0,X
          RTS

CPIMM     STY R13H       ;Y=0
          LDA (R15L),Y
          STA R13L
          LDX #R13L
          LDY #R13L
          HEX 2C         ;Branch
SUB       LDY #0
CPR       SEC            ;Difference left in R13
          LDA 0          ; for CPR and CPI.
          SBC 0,X
          STA 0,Y
          LDA 1
          SBC 1,X
SUB2      STA 1,Y
          TYA
          ADC #0
          STA PRIOR      ;Save carry and register used.
          RTS

ADD       LDA 0
          ADC 0,X
          STA 0
          LDA 1
          ADC 1,X
          LDY #0
          BEQ SUB2

BS        MOVD R15L      ;RETADR
BR        CLC
BNC       BCS BNC2
          LDA (R15L),Y
          BPL :BR2
          DEY
:BR2      ADC R15L
          STA R15L
          TYA
          ADC R15H
          STA R15H
BNC2      RTS

BC        BCS BR
          RTS

BP        LDA 1,X
          BPL BR
          RTS

BM        LDA 1,X
          BMI BR
          RTS

BZ        LDA 0,X
          ORA 1,X
          BEQ BR
          RTS

BNZ       LDA 0,X
          ORA 1,X
          BNE BR
          RTS

BM1       LDA 0,X
          AND 1,X
          EOR #$FF
          BEQ BR
          RTS

RS        MOVD RETADR    ;R15L
END       RTS

ENDHI     = END/$100
SETHI     = SET-1/$100
          ERR ENDHI-SETHI

          AST 50
*
* Mac executive:

          ERR *-BASIC

          AND $E103      ;Fake for ID
WARM      JMP REPLACE
          JMP START      ;Entry from Editor

* The VIDEO editor cmd (except slot 0) inverts the $80
* bit so VIDEO 3 is the correct form as is VIDEO 0.

SLOT      DFB $83        ;Slot+$80 of 80 col card here

PNTSAV    DA SRC
          DA HIM         ;No longer used in ed
          DA SRC

          DFB #"^"       ;Editor's wild card
          DFB 4          ;Numcol for symbol printout
          DFB #"/"       ;"UPDATE SOURCE" chr
                         ; (defeated if +)
TABDFLT   DFB 14,20,31

BYTLINE   DFB 8          ;#bytes/line after 1st

ASSERR    DFB 5          ;- forces key wait on ass error
                         ;V set = defeat bell
                         ;Low nibble is ULTRATERM mode

CURBYT    DFB 0          ;Pascal cursor used if $40
                         ; block cursor if 0

LSTDOFLG  DFB 0          ;DO off not listed if >1
                         ;Bit 0 clear: PRTR1
                         ; switches to 40 col

HORIZ     DFB 80-8       ;HTAB for cycle count

WARMDIS   JMP DISWARM
COLDIS    JMP DISCOLD

          JMP READAS     ;Read entry for ASM
          JMP SAVFILE    ;Save entry for ASM

JBELL     JMP BELL
          JMP WAITL      ;Used by LINKER

SNDMSG    JSR HOMEX
          HEX 2C         ;Skip
TABMSG    STA CH

          VAR PL         ;OUTPUT
          PUT LIB/SENDMSG

SETVEC    LDX #2
LOOP      LDA GOWARM,X   ;Replaces pointers,
          STA YVEC,X     ; resets hooks.
          LDA JED,X      ;Pointers at $A-$F are used,
          STA 0,X        ; retains hooks.
          DEX
          BPL LOOP
SAVPNT    BIT CONTROL!ENABLE!BANK1
          BIT CONTROL!ENABLE!BANK1
          LDX #5         ;Set up byte for bank
          STX BASIC-1    ; recognition in PRTR command
SVLP      MOV SOURCE,X   ;PNTSAV,X
          DEX
          BPL SVLP
          BIT CONTROL
          RTS

OUTPUT    CMP #$81
          BEQ TABMORE
          CMP #$82
          BEQ CRTAB
EXECOUT   STA REALCHR    ;Entry for editor's use
          BIT REALCHR    ;For external use
          BMI SNDCHR
          ORA #$80
          LSR INVFLG
          BVS SNDCHR
          LSR INVFLG
          CLC
          ADC #$20
          EOR #%01100000
SNDCHR    JSR COUT
          JMP SETNORM

NEWIRQ    STA IRQASAV
          PLA
          PHA
          LUP 4
          ASL
          --^
          LDA IRQASAV
          BCS ISBRK
          JMP *
          DS -2
OLDIRQ    DA 0           ;To be set up

ISBRK     PLP
          JSR MONSAVE
          PLA
          STA PCL
          PLA
          STA PCH
          JMP (BRKVEC)

* Labels after OLDIRQ are not
* used by other modules.

CRTAB     JSR CROUT
TABMORE   BIT ZSLOT      ;Move over 18 for 80 col.
          BPL NOTAB
          CLC
          LDA CH
          ADC #18
          STA CH
NOTAB     RTS

DISCOLD   JSR SETKBD     ;Force cold init
          LDA $C058      ;For Ultraterm
          BIT CONTROL    ;For call from Editor
          STA CLRALTCH   ;Norm chr set
          JSR INIT       ;Set 40 col wnd
          LDA SLOT       ;Init 80 col card
          BPL TRAY
          ORA CURBYT
TRAY      TAY
:ZSL      TYA
          STA ZSLOT
          JSR OUTPORT
          LDA (CSWL),Y   ;Is there a card there?
:VAL      CMP (CSWL),Y
          BNE :ZSL       ;Do SETVID if not
          INX
          BPL :VAL
          JSR CROUT
          LDA ZSLOT
          BPL :SETWND
          AND #7
          CMP #3
          BNE :SETWND
          LDA CARDID     ;Ultraterm?
          CMP #$87
          BNE :SETWND    ;Branch if not
          LDA ASSERR
          AND #$F
          TAY
          BNE :NI
          INY
:NI       LDA #"V"&$9F
          JSR COUT
          TYA
          ORA #"0"
          JSR COUT
:SETWND   MOV WNDWDTH    ;OURWDTH ;Editor will
          MOV WNDBOT     ;OURBOT ; correct if Ultraterm
          LDX #3
:VIDHK    MOV CSWL,X     ;VIDVEC,X
          DEX
          BPL :VIDHK
HOMEX     JSR CROUT
          JMP HOME

NAME      JSR CURFILE
SETNAME   BIT RET        ;Set V flag
SETN      LDX #-1
          LDY #-1
:NL       INY
          LDA IN+$80,Y
          CMP #" "
          BEQ :NL
          INX
          CPX #$3C
          BGE COLD
          BVC :DFN
          STA FILENAME,X
:DFN      STA DOSFNAM+1,X
          CMP #$8D
          BNE :NL
          STX DOSFNAM
          RTS

QUES      TXA
          BEQ GETNAME
          JSR SENDMSG
          INV "?"
          HEX 88,00
:GK       LDA KEY
          BPL :GK
          CMP #" "
          BEQ :BS
          AND #%11011111
          EOR #"Y"
          BNE :C1
:BS       BIT STROBE
:C1       CMP #1
          PHP
          LDA #" "
          JSR COUT
          PLP
          BLT GN2
:GOBK     LDA #$88
          JSR COUT
          DEX
          BPL :GOBK
GETNAME   JSR GETLN2
GN2       TXA
          BEQ REPLACE
LOP       LDA IN,X
          CMP #$E0
          BLT :ST
          AND #%11011111
          STA IN,X
:ST       STA IN+$80,X
          DEX
          BPL LOP
          RTS

CURFILE   LDX #0
:L        LDA FILENAME,X
          STA IN,X       ;Simulate input
          CMP #$8D
          BEQ QUES
          JSR COUT
          INX
          CPX #$3E
          BLT :L
COLD      POKE IN+$80    ;$8D
          JSR SETNAME

REPLACE   BIT CONTROL    ;Make sure sweet is up
          STA MAINREAD
          JSR SWEET
          SET R1,PNTSAV
          LDD @R1
          DCR R0
          ST SOURCE/2
          LDD @R1
          ST HIMEM/2
          LDD @R1
          ST ENDSRC/2
          LD @SOURCE/2
          CPI $8D
          BZ :OK
          LD SOURCE/2
          ST ENDSRC/2
:OK       RTN

START     CLD            ;Just in case
          STA MAINWRT
          STA MAINREAD
          JSR SETHOOK
          TXS            ;X=$FF
          LSR ERRFLAG
          STADR $E006    ;WRMVEC ;Must do to protect ptrs
          POKE TABCHAR   ;" "
          JSR SETPRMT
          JSR JCLOSE     ;Printfiler support
          JSR MENU

WNDUP     PRINT 81       ;"%"
          JSR JCLOSE
:BL       JSR BELL
          JSR RDKEY
          AND #%11011111 ;Convert to uc
          LDX #ADRHI-CMDTBL
:NX       DEX
          BMI :BL
          CMP CMDTBL,X
          BNE :NX
          LDA ADRHI,X
          PHA
          LDA ADRLO,X
          PHA
          RTS

DISKCMD   STX CH         ;X=0
:DISK     PRINT 81       ;"Disk command:"
          JSR GETLN2
          TXA
          BEQ START
          JSR LOP
          CMP #" "       ;Control char?
          BLT WNDUP      ;Go to % prompt if so
          JSR JCMD
          JMP :DISK

CAT       PRINT A088     ;"Pathname:"
          JSR GETLN2
          LDA ZSLOT
          PHA
          JSR LOP
          CMP #"1"
          BNE :CLV
          JSR OUTPORT
          LDA #" "
          STA IN+$80
          LDA #$83
          STA ZSLOT
:CLV      CLV
          JSR SETN
          JSR JCAT
          PLA
          STA ZSLOT
          JSR DISWARM
          JMP WNDUP

ADDEXT    LDA #"."
          STA DOSFNAM+1,X
          LDA #"S"
          STA DOSFNAM+2,X
          INX
          INX
          STX DOSFNAM
          RTS

LOAD      PRINT "Load:"
          JSR NAME
          JSR ADDEXT
          JSR SWEET      ;Init validity byte on load
          LD SOURCE/2    ;and read only.
          ST ENDSRC/2
          DCR ENDSRC/2
          SET R0,$8D
          ST @ENDSRC/2
          RTN
LDFILE    MOVD ENDSRC    ;RWBUF
          JSR JLOAD
          LDA #-1
          STA ORGFLG     ;Defeat obj save
          JSR SWEET
          SET R1,RWGOT
          LDD @R1
          ADD ENDSRC/2
          ST ENDSRC/2
          SET R0,$8D
          STP @ENDSRC/2  ;For safety
          INR ENDSRC/2
          LD SOURCE/2
          ST SPNT/2
          LD @SPNT/2     ;1st byte to loc 0
          DCR SPNT/2
          RTN
:LOOK     LDY #0         ;Check all lines < 256 chars
:GETS     LDA (SPNT),Y
          BIT 0          ;First byte + ?
          BPL :SH        ;Convert ALL if so
          CMP #' '
          BEQ :NOCON
:SH       ORA #$80
          STA (SPNT),Y
          CMP #$8D
          BEQ :NXSP
:NOCON    INY
          BNE :GETS
:DY       DEY
          LDA #$8D
          STA (SPNT),Y
          DEY
:NXSP     INY
          BEQ :DY
          TYA
          CLC
          ADC SPNT
          STA SPNT
          TAY
          LDA SPNT+1
          ADC #0
          STA SPNT+1
          CPY ENDSRC
          SBC ENDSRC+1
          BLT :LOOK
STAB      LDX #-3
:STL      LDA TABDFLT-$100+3,X
:ZTL      STA TABS+3,X
          INX
          BMI :STL
          LDA #0
          CPX #9-3
          BLT :ZTL
          JSR SETHOOK
          PRINT "Editor"8D
          JSR BELL
JED       JMP EDITOR

APPEND    PRINT "Append:"
          JSR GETNAME
          CLV
          JSR SETN
          JSR ADDEXT
          JMP LDFILE

OBJSAV    JSR TEST
          BNE GOST
          JSR SAVOB
GOST      JMP START

SAVE      PRINT "Save:"
          JSR NAME
          JSR ADDEXT
          JSR SWEET
          SET R3,RWCNT
          LD ENDSRC/2
          SUB SOURCE/2
          BZ :IGNOR
          STD @R3
          RTN
          LDA #4         ;Text file
          JSR JSAVE
          HEX 24
:IGNOR    RTN
          JMP START

QUIT      PRINT "Quit? "
          JSR RDKEY
          AND #%11011111
          CMP #"Y"
          BNE GOST
          BIT ZSLOT
          BPL :JE
          JSR SENDMSG    ;Turn off card if so
          DFB $8D,$9F&"U",0
:JE       JMP JEXIT

SAVFILE   JSR TEST
          BNE RET
          PRINT 8D       ;"Object saved as "
          JSR SENDIN
          PRINT ",A$"
          JSR TAIL1
          JSR CROUT
          JSR CROUT
          JSR DISWARM
          JMP SAVFIL2

DISWARM   LDX #3
:L        MOV VIDVEC,X   ;CSWL,X
          DEX
          BPL :L
RET       RTS

BELL      BIT ASSERR
          BVS RET
          SEI
          JSR $FF3A
          CLI
          RTS

SAVOB     PRINT "Object:"
          JSR CURFILE
SAVFIL2   CLV
          JSR SETN
          JSR SWAP
          LSR PROMPT     ;Flag the swap for dsk err
          MOVD OBLEN     ;RWCNT
          LDA OBJTYPE
          JSR JSAVE
SWAP      LDX OBLEN+1
          INX
          LDY #0
          LDA SOURCE+1
          PHA
          LDA OBJPNT+1
          PHA
:L        STA AUXREAD
          LDA (OBJPNT),Y ;Get obj byte
          PHA
          STA MAINREAD
          LDA (SOURCE),Y ;Get source byte
          STA AUXWRT
          STA (OBJPNT),Y ;Swap into obj space
          PLA
          STA MAINWRT
          STA (SOURCE),Y ;Obj byte to source space
          INY
          BNE :L
          INC OBJPNT+1
          INC SOURCE+1
          DEX
          BNE :L         ;Swap full pages
          PLA
          STA OBJPNT+1
          PLA
          STA SOURCE+1
SETPRMT   LDA #">"       ;So ULTRA will convert and
          STA PROMPT     ; for DOS error handling
          STADR WAIT     ;ERRTN
          RTS

TEST      LDA OBLEN
          LSR            ;Disallow length 1
          ORA OBLEN+1
          BEQ :AD
          LDY #0         ;Legally assembled?
          LDA (ENDSRC),Y
          CLC
:AD       ADC #1
          ORA ORGFLG
          RTS

TAIL1     PRHEX ADRSV
          PRINT ",L$"
          LDX OBLEN
          LDA OBLEN+1
          JSR PRNTAX
          LDA #","
          JSR COUT
          LDA OBJTYPE
          JMP JPRTYP

SENDIN    LDA IN+$80,Y   ;Y=0 on entry
          ORA #$80       ;For asm use
          CMP #$8D
          BEQ :SENT
          JSR COUT
          INY
          BPL SENDIN
:SENT     RTS

SETHOOK   JSR DISCOLD    ;Turn off DOS
          JMP SAVPNT     ;Leaves X=$FF

CMDTBL    ASC "DQE"
          ASC "COS"
          ASC "AL"8D
          ASC "@"

ADRHI     DFB >DISKCMD-1,>QUIT-1,>STAB-1
          DFB >CAT-1,>OBJSAV-1,>SAVE-1
          DFB >APPEND-1,>LOAD-1,>START-1
          DFB >SETDATE-1

ADRLO     DFB DISKCMD-1,QUIT-1,STAB-1
          DFB CAT-1,OBJSAV-1,SAVE-1
          DFB APPEND-1,LOAD-1,START-1
          DFB SETDATE-1

WAITL     JSR CROUT
          JSR DISWARM
WAIT      PRINT 8D8D     ;"Hit a key"
          JSR BELL
:BST      BIT STROBE     ;Clear type ahead buff
          DEY
          BNE :BST
          BIT PROMPT     ;Err while src swapped out?
          BMI :RK        ;Branch if not
          JSR SWAP       ;Set it right
:RK       JSR RDKEY
GOWARM    JMP WARM

GETMO     MOVD MOADR     ;PL
          LDY #0
:LIN      LDA IN,X
          AND #%11011111
          CMP (PL),Y
          BNE :Y4
          INY
          LDA IN+1,X
          AND #%11011111
          CMP (PL),Y
          BNE :Y3
          INY
          LDA IN+2,X
          AND #%11011111
          CMP (PL),Y
          BNE :Y2
          INY
          INY
          TYA
          RTS
:Y4       INY
:Y3       INY
:Y2       INY
          INY
          CPY #11*4+1
          BLT :LIN
          PLA            ;Pop stack & fall into:
PCRDATE   PLA
CRDATE    LDA #$82
          JSR OUTPUT
SETDATE   PRINT "Date: "
          JSR JPRDATE
          LDX #9
]LOOP     LDA #$88
          JSR COUT
          DEX
          BNE ]LOOP
          JSR GETLN2
          TXA
          BEQ :STRT
          LDX #0
          LDA IN
          CMP #" "
          BNE :DAY
          INX
:DAY      JSR MAKBYT
          BEQ CRDATE
          CMP #32
          BGE CRDATE
          STA A2L+1
          INX
          JSR GETMO
          ASL
          ASL
          ASL
          PHP
          ORA A2L+1
          TAY
          LUP 4
          INX
          --^
          JSR MAKBYT
          CMP #100
          BGE PCRDATE
          PLP
          ROL
          STA DATE+1
          STY DATE
:STRT     JMP START

MAKBYT    LDA #0
]LOOP     STA A2L
          LDA IN,X
          EOR #"0"
          CMP #10
          BGE :GOTBYT
          PHA
          ASL A2L
          LDA A2L
          ASL
          ASL
          ADC A2L
          STA A2L
          PLA
          ADC A2L
          INX
          BNE ]LOOP
:GOTBYT   LDA A2L
          RTS

GOERR     JMP JERROR

READAS    JSR WARMDIS
          LDA #0
          STA ERRSAVE
          MOVD SPNT      ;RWBUF
          SEC
          ROR ERRFLAG    ;Set ONERR
          CLV
          JSR SETN
          JSR ADDEXT
          JSR JLOAD
          LDY #0
          LDA (SPNT),Y   ;Negative ascii?
          BMI :LS        ;Skip if so
          LDA RWGOT
          EOR #-1
          STA PL
          LDA RWGOT+1
          EOR #-1
          STA PL+1
:LP       INCD PL
          BEQ :X5
          LDA (SPNT),Y
          ORA #$80
          STA (SPNT),Y
          INC SPNT
          BNE :LP
          INC SPNT+1
          BNE :LP        ;Always

:LS       LDA SPNT
          CLC
          ADC RWGOT
          STA SPNT
          LDA SPNT+1
          ADC RWGOT+1
          STA SPNT+1
:X5       LDX #5
          LSR ERRFLAG
          LDA ERRSAVE
          BEQ :OK
          CMP #14        ;Too large (let ASS handle this)
          BNE GOERR      ;Abort if not
          TAX
:OK       TYA            ;=0
          STA (SPNT),Y
          DEY
          DEC SPNT+1
          LDA #$8D       ;A safety measure
          STA (SPNT),Y
          INC SPNT+1
          RTS

* Added to ensure match to standard
          HEX D0CED4ABB1
*

          ERR \ASS

          DO SAVOBJ
          SAV ASMOBJ/EX
          FIN
