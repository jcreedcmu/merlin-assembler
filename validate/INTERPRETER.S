********************************
*                              *
*  Merlin ProDOS  Interpreter  *
*                              *
*   Glen E. Bredon   9/20/85   *
*                              *
********************************

          DATE

SAVOBJ    KBD
          EXP OFF
          TR

* Data:

VERSION   = 2            ;Interpreter version
VERSEXT   = $59          ;Extension in BCD

* AUX zero page locations:

SOURCE    = $A
HIMEM     = $C           ;Merlin himem
PNT       = $40          ;Used by CAT
DIRTYP    = $42          ; "
ACL       = $43          ; "
LEN       = $46          ; "
ENTPER    = LEN+1        ; "
THISCNT   = $49          ; "
FPHI      = $73          ;Absolute himem
RELFLAG   = $8F          ;REL file flag
ZSLOT     = $C4          ;80-col flag
ADRSV     = $E6          ;Effective object address
ORGFLG    = $E8          ;Valid object flag
JUST      = $EE          ;PRDEC use

* MAIN zero page locations:

CMD       = $42

* Also PNT & ACL used in COMMAND, etc.

*---------------------------
*   Merlin routines used:
*---------------------------

SLOT      = $E009
ASSERR    = $E017
CURBYT    = $E018
SENDMSG   = $E033        ;Uses locs 6,7
NEWIRQ    = $E099        ;FFFE points here
OLDIRQ    = $E0A6        ;Old value put here
PRDEC     = $E602        ;Uses C9,CA,CB & JUST
          PAG
* Ramcard, aux mem and monitor equates:

FROM      = $3C
ENDMOVE   = $3E
DEST      = $42
IN        = $200
RESETV    = $3F2
AMPER     = $3F5
CONTROL   = $C080
BANK1     = %1000
ENABLE    = %0011
ROMREAD   = %0010
KEY       = $C000
MAINZP    = $C008
AUXZP     = $C009
STROBE    = $C010
READZP    = $C016
OPAPPLE   = $C061
CLDAPPLE  = $C062
CARDID    = $C30C
PRNTAX    = $F941
PRBLNK    = $F948
PRBL2     = $F94A
IDBYTE2   = $FBC0
HOME      = $FC58
RDKEY     = $FD0C
CROUT     = $FD8E
PRBYTE    = $FDDA
PRHEX     = $FDE3
COUT      = $FDED
MOVE      = $FE2C
SETKBD    = $FE89
OUTPORT   = $FE95
IRQ       = $FFFE

          AST 32

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

STADR     MAC
          LDA #]1
          STA ]2
          LDA #>]1
          STA ]2+1
          <<<

MOVD      MAC
          LDA ]1
          STA ]2
          LDA ]1+1
          STA ]2+1
          <<<

ADDNUM    MAC
          LDA #]1
          CLC
          ADC ]2
          STA ]3
          LDA #>]1
          ADC ]2+1
          STA ]3+1
          <<<

INCD      MAC
          INC ]1
          BNE NI
          INC ]1+1
NI        <<<

GOMLI     MAC
          LDA #]2PARMS
          STA EPARMADR
          LDA #]1
          JSR EXTENTRY
          <<<

GOMLIX    MAC
          LDA #]2PARMS
          STA EPARMADR
          LDA #]1
          JMP EXTENTRY
          <<<

JMLI      MAC
          LDX #]2PARMS
          LDA #]1
          JSR ENTRY
          <<<

DOS       MAC
          JSR MLI
          DFB ]1
          DA ]2PARMS
          <<<

INDEX     MAC
          IF ]2=0
          DFB ]1-ERRMSGS*2
          ELSE
          DFB ]1-ERRMSGS*2.1
          IF ]3=0
          DFB ]2-ERRMSGS*2
          ELSE
          DFB ]2-ERRMSGS*2.1,]3-ERRMSGS*2
          FIN
          FIN
          <<<

          AST 50

          PUT MLI/CODES

          ORG $2000      ;Interpreter load adrs

          PUT MLI/GP     ;Dummy section

          AST 50

          JMP START
          HEX EEEE       ;Startup id
          DFB $40        ;Reserved space for startup
STUPNAM   STR 'ED'
          DS STUPNAM+$40-*
WHEREMER  DA MERLOC      ;Address of 1st merlin
                         ; segment to be loaded in
                         ; by SAVE NEW MERLIN

          ERR WHEREMER-$2046 ;For SAVE/MERLIN

BADMACH   HEX 8D8D
          ASC "UNSUPPORTED CONFIGURATION"8D00

PRBM      JSR COUT
          INY
NOAUX     LDA BADMACH,Y
          BNE PRBM
          JSR RDKEY
          JMP CALLQUIT

START     LDA #0
          STA $C073      ;Select bank 0 of ext ram
          BIT CONTROL!ROMREAD!ENABLE
          LDA READZP     ;Flag present status in case
          STA ZPSTAT     ; returning from FILER etc.
          STA MAINZP
          JSR SETKBD
          LDA #3
          JSR OUTPORT
          JSR CROUT
          LDY #0
:MSGL     LDA GREETING,Y
          BEQ :CHKMACH
          CMP #"!"
          BNE :OUT
          LDX #25
          JSR PRBL2      ;26 spaces
:OUT      JSR COUT
          INY
          BNE :MSGL

:CHKMACH  TAY            ;=0
          SEI            ;Will clear at WARM
          STADR NOWINTER ;FROM
          STADR NOWIEND  ;ENDMOVE
          STADR INT      ;DEST
          JSR MOVE       ;Set up interface
          LDA MACHID
          AND #%11110000
          CMP #%10110000
          BNE NOAUX
          LDA #$4C
          STA AMPER
          STADR $FFCB    ;AMPER+1

* Set up our desired memory BIT MAP:

          LDY #BMEND-OURBM
]LOOP     LDA OURBM-1,Y
          STA BITMAP-1,Y
          DEY
          BNE ]LOOP
          STADR DSKBUF   ;FPHI ;Room for two buffers
          LDA #VERSION
          STA IVERSION
          INY
          STY IBAKVER    ;Min ProDOS vers compat.
          LDA DEVNUM
          AND #$F0
          ORA #$80
          STA DEVDFLT

* Set reset routine:

          STADR RESET    ;RESETV
          EOR #$A5
          STA RESETV+2

* Remove /RAM (follows Tech Note 8 of Aug. 1984):
* and, partially, Tech Note 16:

          LDX DEVADR32
          BNE :RAMDONE
          LDA DEVADR32+1
          CMP #$FF
          BNE :RAMDONE   ;RAM/ not installed or
          STX RAMDRADR   ; different if adrs not $FF00
          STA RAMDRADR+1 ;Save driver adrs (old stuff)
          LDY DEVCNT
]LOOP     LDA DEVLST,Y
          AND #%11110011
          CMP #%10110011
          BEQ :GETIT
          DEY
          BPL ]LOOP
          INY
          STY RAMDRADR+1 ;Signal no /RAM
          BEQ :RAMDONE
:GETIT    LDA DEVLST,Y
          STA RAMNUM
]LOOP     LDA DEVLST+1,Y
          STA DEVLST,Y
          BEQ :RVECOUT
          INY
          BNE ]LOOP      ;Always
:RVECOUT  MOVD DEVADR01  ;DEVADR32
          DEC DEVCNT
:RAMDONE  BIT ZPSTAT     ;If ProDOS is in main mem
          BPL :ZOK       ; don't switch
          STA AUXZP
:ZOK      LDA IN+$80
          TAY
          SEC
          SBC #14
          BMI :NOPFX
          STA IN+$80
          LDX #MERNEND-MERNAM-1
]LOOP     LDA IN+$80,Y   ;Check for "MERLIN.SYSTEM"
          EOR MERNAM,X
          ASL
          BNE :NOPFX     ;Not it, go directly to PARMS
          DEY
          DEX
          BPL ]LOOP
          DOS getpfix    ;GPX
          LDA DSKBUF     ;If pfx exists then don't set
          BNE :NP        ;Else set one
          DOS setpfix    ;SPX
:NP       INX
          CPX DOSFNAM
          BGE :SYL
          INY
          LDA DOSFNAM+1,X ;Substitute "PARMS"
          STA IN+$80,Y
          BLT :NP        ;Always
:SYL      STY IN+$80
]LOOP     LDA IN+$80,Y   ;Move full pathname of PARMS
          STA DOSFNAM,Y
          DEY
          BPL ]LOOP
:NOPFX    DOS open       ;O ;Open parms file
          JSR SETREF
          DOS newline    ;NEW
          DOS read       ;RW
          DOS close      ;CLS
          LDX #0
:ZPLUP    STA MAINZP
          LDA 0,X
          STA AUXZP
          STA 0,X
          INX
          BNE :ZPLUP     ;Leaves aux up
          LDA #$C0
          STA $100
          LDY #0
          LDA RWCNT      ;Were parms loaded?
          CMP RWGOT
          BNE :NOX       ;Leave as is if not
          LDA $909       ;Get slot
          AND #$40       ;Isolate V bit
          STA XFLAG      ;Keep it
          BEQ :NOX       ;Skip if no switch wanted
          EOR $909       ;Get slot less V bit
          STA $909       ;For moving later
          BIT ZPSTAT     ;Avoid MVDOS if returning
          BMI :FIX       ; from FILER etc.
          JSR MVDOS
:FIX      STA MAINZP     ;Main up from now on
          LDX #>$BE00-INT
          LDA #>INT
          STA 1
          STY 0
]LOOP     LDA (0),Y      ;Look for STA AUXZP
          CMP #$8D       ; and STA MAINZP
          BNE :NX2
          INY
          INY
          LDA (0),Y
          CMP #>MAINZP
          BNE :NX
          DEY
          LDA (0),Y
          EOR #9
          CMP #2
          BGE :NX
          ORA #8         ;Switch them when found
          STA (0),Y
:NX       LDY #0
:NX2      INC 0
          BNE ]LOOP
          INC 1
          DEX
          BNE ]LOOP
          STADR INTPATCH ;$3FE
:NOX      BIT CONTROL!BANK1!ROMREAD!ENABLE
          BIT CONTROL!BANK1!ROMREAD!ENABLE
          LDA #$FF
          STA ENDMOVE
          STA ENDMOVE+1
          STY FROM
          STY DEST
          LDA #$F8
          STA FROM+1
          STA DEST+1
          JSR MOVE       ;Move monitor

          MOVD WHEREMER  ;FROM
          ADDNUM $FFF    ;FROM;ENDMOVE
          STADR $D000    ;DEST
          JSR MOVE       ;Merlin bank1

          STY $DFFF      ;For startup routine

          BIT CONTROL!ENABLE
          ADDNUM $1000   ;WHEREMER;FROM
          ADDNUM $2878   ;FROM;ENDMOVE
          STADR $D000    ;DEST
          JSR MOVE       ;Merlin bank2
          MOVD IRQ       ;OLDIRQ
          LDA $FFBA      ;//c
          CMP #$4C
          BNE :BB
          STA $FFBB
          LDA #$EA
          STA $FFBA
:BB       LDA $FFBB
          CMP #$4C
          BNE :BX
          LDY #2
:FX       LDA MONFIX,Y
          STA $FFBB,Y    ;Fix GETNUM mod
          DEY
          BPL :FX
:BX       BIT XFLAG
          BVC :OV
          LDA #"+"&$3F
          STA $DDAC
:OV       LDA RWCNT
          CMP RWGOT      ;Were parms loaded?
          BNE TESTCARD   ;Skip if not
          LDY #4
]LOOP     LDA $905-1,Y
          STA $D005-1,Y
          DEY
          BNE ]LOOP
          INC $D007      ;Fix col count
          LDA $905+23-1
          STA UCURS
          LDY #18
]LOOP     LDA $909-1,Y
          STA $E009-1,Y
          DEY
          BNE ]LOOP
          LDY #6
]LOOP     LDA $90A-1,Y
          STA SWAPPNT-1,Y
          DEY
          BNE ]LOOP
          LDY #3*7
]LOOP     LDA $905+23-1,Y
          STA USRTYPES-1,Y
          DEY
          BNE ]LOOP
          BIT ASSERR     ;No bell requested?
          BVC TESTCARD
          LDA #$4C       ;If so then
          STA $FF37      ; abort ERR before bell
TESTCARD  LDA CARDID     ;Is it the Apple card?
          EOR #$88
          BNE :ISC       ;Branch if not
          STA CURBYT     ;Block cursor if so
:ISC      LDA IDBYTE2    ;Is it a //c
          BNE :JW        ;Branch if not
          BIT $C060      ;40/80 switch
          BPL :JW        ;Branch if 80
          STA SLOT       ;Set for 40
:JW       JMP WARM       ;All set up, go to MERLIN

MONFIX    HEX B0,CD,60   ;Old exit code for GETNUM

ZPSTAT    BRK

GREETING  HEX 8C8D8D
          ASC "!   MERLIN-8  version "
          DFB VERSION."0"
          ASC "."
          DFB VERSEXT/$10."0"
          DFB VERSEXT&$F."0",$8D,$8D
          ASC "!      by Glen E. Bredon"8D8D
          ASC "!     Copyright (C)  1987"8D
          ASC "!Roger Wagner Publishing, Inc."8D00

          ERR *-GREETING/$100

SPXPARMS  DFB 1
          DA IN+$80

OURBM     DDB %1100111100000000 ;$00-$0F pages
          DDB %0000000000000000 ;$10-$1F
          DDB %0000000000000000 ;$20-$2F
          DDB %0000000000000000 ;$30-$3F
          DDB %0000000000000000 ;$40-$4F
          DDB %0000000000000000 ;$50-$5F
          DDB %0000000000000000 ;$60-$6F
          DDB %0000000000000000 ;$70-$7F
          DDB %0000000000000000 ;$80-$8F
          DDB %0000000000000000 ;$90-$9F
          DDB %0000000000000000 ;$A0-$AF
          DDB %0011111111111111 ;$B0-$BF
BMEND     ERR INT-$B200


*---------------------------------
* Start of the interpreter proper:
*---------------------------------

NOWINTER  ORG $B200

INT       ERR INT&$FF    ;Must be on page bndry

JPRTYP    JMP PRTYP      ;Print obj type
JEXIT     JMP EXIT       ;Go to exit routine
JCMD      JMP COMMAND    ;Interpret user cmd
JCAT      JMP CAT        ;Catalog from Exec
JCLOSE    JMP CLOSE      ;Close all entry from MERLIN
JLOAD     JMP SRCLOAD    ;Source and PUT,USE load
JSAVE     JMP SAVE       ;Source and obj save
JERROR    JMP ERRENTRY   ;Print error msg routine
JRLOAD    JMP RLOAD      ;Load LNK file by linker
JOPEN     JMP DSKOPEN    ;Open a DSK obj file
JPREFIX   JMP PRPRFX     ;Print PREFIX
JPRDATE   JMP SNDATE     ;Print date (EXEC cmd)
JEXTLOAD  JMP EXTLOAD    ;External load entry (Srcrr)
JDATIME   JMP DATIME     ;Date & time (DATE opcode)

WRMVEC    DA STARTUP     ;Reset reentry
ERRTN     DA WARM        ;Error reentry (to be set)
MOADR     DA MONTHS      ;Ptr to month tbl for Exec

*-------------------------
* Main command processors:
*-------------------------

EXTENTRY  STA EXCMD      ;Entry to call MLI from
GOPRO     JSR MLI        ; outside Merlin,
EXCMD     DFB open       ; (maybe from interpreter)
EPARMADR  DA OPARMS      ;High byte never changed!
          BCS ERROR0
          RTS

BANK      DFB 0
ERRSAVE   DFB 0
UCURS     DFB $EC        ;Uterm cursor (not used now)
ERRFLAG   DFB 0          ;ONERR flag

ENTRY     STA ECMD       ;Save cmd from merlin
          STX PARMADR    ; and parm adr low
          JSR SETBNK     ;Set rtn flags & switch bnks
          STA MAINZP     ;Turn on ProDOS
JPRO      JSR MLI        ;Call ProDOS
ECMD      DFB open       ;The command wanted
PARMADR   DA OPARMS      ;High byte never changed!
                         ;Set low prior to call!!!
MERRTS    STA AUXZP      ;Turn on merlin
          BIT CONTROL
          BIT BANK
          BVS BNKOK      ;Branch if was bank2
          BIT CONTROL!BANK1!ENABLE
          BIT CONTROL!BANK1!ENABLE
BNKOK     BCS ERROR
GOBACK    RTS            ;Back to caller

STKBACK   LDX ERRSTK     ;Used by PUT
          TXS
RETMER    CLC
          BCC MERRTS

CLOSE     SEC            ;Called by EXEC
CLOSALL   PHP
          LDA #0
          STA LEVEL
          STA CLSREF
          LDX #CLSPARMS
          STX EPARMADR
          LDA #close
          PLP
          BCS ENTRY      ;Branch if a MERLIN call
          BCC EXTENTRY   ;If from RESET

GETVOL    STA AUXZP      ;Switch in Merlin
          PRINT 8D87     ;"Insert"
          JSR PRDOSFN    ;Print entire pathname
          BIT STROBE     ;Just in case
          JSR RDKEY
          CMP #"C"&$9F
          BEQ JERRTN     ;Abort on ^C
          STA MAINZP     ;Set to try again
          BIT FROMFLG    ;From ENTRY or EXTENTRY?
          BPL GOPRO      ;Just do the same call
          BMI JPRO       ; that gave the error.

ERRENTRY  PHA
          JSR SETBNK     ;File # assumed set up
          PLA
          BNE ERR2       ; before calling this

ERROR0    CLC
ERROR     ROR FROMFLG
          CMP #$45       ;Vol not found err?
          BNE :STES
          LDA DOSFNAM+1  ;Was a vol requested?
          EOR #'/'
          ASL
          BEQ GETVOL     ;Ask for it if so
          LDA #$45       ;Else give error
:STES     STA ERRSAVE
          BIT XEF        ;Local ONERR active?
          BMI GOBACK     ;Return if so
          BIT ERRFLAG    ;Regular ONERR?
          BMI STKBACK    ;Branch if so
          CMP #$4C       ;EOF
          BEQ GOBACK     ;Always return if so
ERR2      STA MAINZP
          SEC
          ROR XEF
          PHA            ;In case close gives err
          JSR CLOSESUB
          PLA            ;Must pop before zp switch
          LSR XEF
          STA AUXZP
          PHA
          JSR TWOCR
          PLA
          LDY #ERRINDX-ERCODES-1
]LOOP     CMP ERCODES,Y
          BEQ :GOTCODE
          DEY
          BNE ]LOOP
                         ;Make it MLI ERROR
:GOTCODE  JSR PRBYTE     ;Print err code
          JSR SPACE
          LDX #-1
:NX       INX
          LDA ERRINDX-1,X
          LSR
          BCS :NX
          DEY
          BPL :NX
:GTIND    LDA ERRINDX,X
          LSR            ;Condition carry
          TAY
:PRERR    LDA ERRMSGS,Y
          PHP
          JSR CHROUT
          INY
          PLP
          BMI :PRERR
          INX
          BCS :GTIND
JERRTN    JMP (ERRTN)

*----------------------
*   Catalog routines:
*----------------------

NOTDIR    JMP TYPMSM

CAT       JSR CROUT
          LDA #10
          STA INFPARMS   ;Set for GETINFO call
          LDA DOSFNAM    ;Pathname given?
          BEQ :JH        ;Branch if not
          LDA DOSFNAM+1
          CMP #"="
          BNE :ISN       ;Branch for regular name
          JSR ONLPFX     ;Set pfx to slot 6, dr 1
:JH       JSR HOME       ;Do home if no pathname
          JSR PRPRFX     ; and print prefix
          JSR CROUT
          LDX #$3F       ; and move prefix
]LOOP     LDA DSKBUF,X   ; to DOSFNAM
          STA DOSFNAM,X
          DEX
          BPL ]LOOP
          BMI :HAVE
:ISN      CMP #"/"       ;Vol specified?
          BEQ :NP
          JSR PRPRFX     ;Print prefix if not
:NP       JSR PDFN       ;Print file name given
:HAVE     JMLI getinfo   ;INF
          LDA INFTYPE
          EOR #$F        ;Directory file?
          BNE NOTDIR     ;Error if not
          STA RWCNT
          STA RWBUF
          LDA #2         ;Read 1 block
          STA RWCNT+1
          LDA #>DSKBUF
          STA RWBUF+1
          JMLI open      ;O
          JSR SETREF
          JMLI read      ;RW
          MOVD DSKBUF+$23;LEN
          LDA DSKBUF+4
          STA DIRTYP
          PRINT 8D       ;" Name"
          JSR TAB9MSG
          ASC "  Type  Blocks  Modified"00
          BIT ZSLOT
          BPL :NOMORE
          JSR TAB9MSG
          ASC "Created"00
          JSR TAB9MSG
          ASC "  Length Subtype"00
:NOMORE   JSR CROUT
          JSR SETPNT
ACTLOOP   DEC THISCNT
          BNE NXFIL
          JMLI read      ;RW
          BCS :CD        ;Had eof
          JSR SETPNT
          BNE ISACT      ;Always

:CD       JMP CATDONE

SETPNT    LDA ENTPER
          STA THISCNT
          STADR DSKBUF+4 ;PNT
          RTS

NXFIL     LDA PNT
          CLC
          ADC LEN
          STA PNT
          BCC ISACT
          INC PNT+1
ISACT     LDY #0
          LDA (PNT),Y
          BEQ ACTLOOP    ;Branch if file not active

* Process active file:

          AND #$F
          TAX            ;Name length
          LDY #16
          LDA (PNT),Y    ;Get file type
          BIT OPAPPLE
          BPL :NO
          DEY
:NO       BIT CLDAPPLE
          BPL :NC
          DEY
          DEY
:NC       CPY #16        ;An apple key pressed
          BGE :CR        ;All files if not
          CMP TYPES-12,Y
          BNE ACTLOOP
:CR       JSR CROUT
          LDY #$1E
          LDA (PNT),Y    ;Access code
          AND #%11000010
          EOR #%11000010
          BEQ :UNL
          LDA #"*"
:UNL      ORA #" "
          JSR COUT
          LDY #0
]LOOP     INY
          LDA (PNT),Y    ;File name
          DEX
          BPL :OK
          LDA #" "       ;Fill with spaces
          STA JUST
:OK       JSR CHROUT
          CPY #16
          BLT ]LOOP
          LDA (PNT),Y    ;File type
          JSR PRTYP
          JSR PRBLNK
          LDY #$13
          LDA (PNT),Y    ;Number of blocks in file
          TAX
          INY
          LDA (PNT),Y
          JSR PRDEC
          JSR SPACE
          LDY #$22
          JSR PRDATE     ;Modified date
          JSR TWOSPC
          LDY #$19
          JSR PRDATE     ;Created date
          JSR TWOSPC
          LDY #$17
          STY ACL        ;Just +
]LOOP     LDA (PNT),Y
          JSR PRB        ;Print length
          DEY
          CPY #$15
          BGE ]LOOP
          BIT ACL
          BMI :OV
          JSR SPACE      ;File length 0
:OV       JSR SPACE
          LDY #$10
          LDA (PNT),Y    ;Get file type
          LDY #3
]LOOP     CMP SUBT-1,Y   ;TXT, BIN, or LNK?
          BEQ :SUBVAL
          DEY
          BNE ]LOOP      ;If not, no prefix
:SUBVAL   LDA SUBP,Y     ;If so, prefix R=,A=,L=
          JSR COUT
          DEY
          BMI :NE
          LDA #"="
:NE       JSR COUT
          JSR PRDOL
          LDY #$1F
          LDA (PNT),Y    ;Subtype
          TAX
          INY
          LDA (PNT),Y
          JSR PRNTAX
GOLOOP    LDA KEY        ;Look for key
          BPL :AL
          BIT STROBE
          CMP #"C"&$9F
          BEQ CATDONE    ;Abort on ^C
          JSR RDKEY      ;Wait if another
:AL       JMP ACTLOOP

CATDONE   JMLI close     ;CLS
          LDA DIRTYP
          CMP #$F0       ;Volume dir?
          BLT :CATFIN    ;Skip if not
          PRINT 8D8D     ;"Blocks free:"
          LDA INFAUX
          SEC
          SBC INFBLKS
          TAX
          LDA INFAUX+1
          SBC INFBLKS+1
          JSR PRDEC      ;Parms for prdec ready
          JSR TAB4MSG
          ASC "Blocks used:"00
          LDX INFBLKS
          LDA INFBLKS+1
          JSR PRDEC
          BIT ZSLOT
          BPL :CATFIN
          JSR TAB4MSG
          ASC "Total blocks:"00
          LDX INFAUX
          LDA INFAUX+1
          JSR PRDEC
:CATFIN   BIT STROBE     ;Clear key too late or ^C
TWOCR     JSR CROUT
          JMP CROUT      ;CR and back to MERLIN

*-------------------------------------
* Print file type held in accumulator:
*-------------------------------------

PRTYP     LDX #TYPNAMES-TYPES-1*3
          LDY #TYPNAMES-TYPES-1
]LOOP     CMP TYPES,Y    ;Do we have a name for it?
          BEQ :TYP       ;Yes, use it
          DEX
          DEX
          DEX
          DEY
          BPL ]LOOP
          PHA
          JSR PRDOL
          PLA
          JMP PRBYTE     ;No, print it in hex
:TYP      LDY #3
]LOOP     LDA TYPNAMES,X
          JSR COUT
          INX
          DEY
          BNE ]LOOP
          RTS

PRB       PHA            ;Print byte in A with
          LSR            ; leading spaces and
          LSR            ; $ sign if not yet
          LSR            ; printed
          LSR
          JSR :NIB
          PLA
          AND #$F
:NIB      BNE :NIB2
          BIT ACL
          BMI :NIB3
          JMP SPACE
:NIB2     BIT ACL
          BMI :NIB3
          PHA
          JSR PRDOL
          STA ACL        ;Flag # started
          PLA
:NIB3     JMP PRHEX

PRDATE    TYA
          PHA
          LDA (PNT),Y
          STA ACL
          DEY
          LDA (PNT),Y
          BEQ NODATE
          JSR DATPRNT
          PLA
          TAY
          INY
          BIT ZSLOT
          BMI PRTIME
EARLYEX   PLA
          PLA
          JMP GOLOOP
PRTIME    JSR SPACE
          LDA (PNT),Y    ;Minutes
          STA ACL
          INY
          LDA (PNT),Y    ;Hours
SNDTIME   JSR PR2DIG
          LDA #":"
          JSR COUT
PRBYTDEC  LDA ACL        ;Print byte in ACL
          JSR DIV10      ; in decimal
          PHA
          TXA
CPD       JSR COUT
          PLA
          JMP COUT

NODATE    PLA
          PRINT "[no date]"
          BIT ZSLOT
          BPL EARLYEX
          LDX #6
          JMP PRBL2

PR2DIG    JSR DIV10
          PHA
          LDA FRSTDIG-"0",X
          BCS CPD        ;Always

DATIME    JMLI gettime   ;DI ;Parms don't matter
          JSR SNDATE     ;Already tabbed
          JSR TWOSPC
          LDA TIME
          STA ACL
          LDA TIME+1
          JMP SNDTIME    ;Returns to assembler

DIV10     LDX #"0"-1     ;Divide acc by 10
          SEC            ; quotient in X
]LOOP     INX            ; remainder in A
          SBC #10        ; (both in ascii)
          BCS ]LOOP
          ADC #"0"+10
          RTS

ASCNIB    EOR #"0"
          CMP #10
          BLT :HI
          ADC #$88
          CMP #$FA
          BLT :NOTHEX
:HI       ASL
          ASL
          ASL
          ASL
          SEC            ;Flag result a hex dig
:NOTHEX   RTS

TAB4MSG   LDX #4
          HEX 2C
TAB9MSG   LDX #9
          JSR PRBL2
          JMP SENDMSG

* Subroutine used prior to switch to main zp:

SETBNK0   STA TYP
SETBNK    LDA $DFFF
          STA BANK
          RTS            ;Z clear on return

TWOSPC    JSR SPACE
SPACE     LDA #" "
          HEX 2C
PRDOL     LDA #"$"
CHROUT    ORA #$80
          JMP COUT

GETINFO   LDA #10
          STA INFPARMS
          GOMLIX getinfo ;INF

SUBT      DFB 4,6,$F8    ;Types TXT,BIN,LNK
SUBP      ASC " RAL"

FRSTDIG   ASC " 123"

XEF       BRK            ;External (here) err flag
ERRSTK    BRK
FROMFLG   BRK            ;For volume not found error
TYP       BRK            ;File type wanted put here
TYP2      BRK            ;Alternate load type

MONTHS    ASC "JAN-"
          ASC "FEB-"
          ASC "MAR-"
          ASC "APR-"
          ASC "MAY-"
          ASC "JUN-"
          ASC "JUL-"
          ASC "AUG-"
          ASC "SEP-"
          ASC "OCT-"
          ASC "NOV-"
          ASC "DEC-"

TYPES     HEX 01,06,04,0F,19,1A,1B,F0,F1,F2
          HEX F3,F4,F5,F6,F7,F8,FC,FD,FE,FF

TYPNAMES  ASC "BAD"
          ASC "BIN"
          ASC "TXT"
          ASC "DIR"
          ASC "ADB"
          ASC "AWP"
          ASC "ASP"
          ASC "CMD"
USRTYPES  ASC "$F1"
          ASC "$F2"
          ASC "$F3"
          ASC "$F4"
          ASC "$F5"
          ASC "$F6"
          ASC "$F7"
          ASC "LNK"
          ASC "BAS"
          ASC "VAR"
          ASC "REL"
          ASC "SYS"

          AST 55

          ERR \$B6DA     ;USR address
          DS $B6DA-*
USRADR    RTS
          DA 0

OVRSPC    INX            ;Leading space skipper
          LDA IN,X       ; for cmd parsing
          CMP #" "
          BEQ OVRSPC
          CMP #$8D
          RTS

RESET     CLC
          LDA #0         ;For ext memory cards
          STA $C073      ; select main aux bank.
          STA MAINZP
          JSR CLOSALL
WARM      BIT CONTROL!ENABLE
          BIT CONTROL!ENABLE
          STA AUXZP
          SEI
          STADR NEWIRQ   ;IRQ
          CLI
          JMP (WRMVEC)

ZDATE     PRINT "DA-MON-YR"
          RTS

SNDATE    LDA DATE+1
          STA ACL
          LDA DATE
          BEQ ZDATE
                         ;Date ok, exit through:
DATPRNT   PHA
          AND #%11111
          JSR PR2DIG
          LDA #"-"
          JSR COUT
          PLA
          LSR ACL
          ROR
          AND #$F0
          LSR
          LSR
          TAX
          LDY #4
]LOOP     LDA MONTHS-4,X
          JSR COUT
          INX
          DEY
          BNE ]LOOP
          JMP PRBYTDEC   ;Print year

*  Exec's quit command:

EXIT      JSR MVDOS      ;Copy ProDOS to other bank
          STADR INTHAND  ;$3FE
          STX MAINZP
          BIT CONTROL!ROMREAD
          DEC RESETV+2   ;Trash power up byte
          LDY DEVCNT
]LOOP     LDA DEVLST,Y   ;If a /RAM has been connected
          AND #%11110000 ; while in Merlin then don't
          CMP #%10110000 ; connect the old one
          BEQ CLINT
          DEY
          BPL ]LOOP
          LDA RAMDRADR+1
          BEQ CLINT      ;If no /RAM on entry
          STA DEVADR32+1 ;Replace /RAM adrs
          LDA RAMDRADR
          STA DEVADR32
          INC DEVCNT
          LDY DEVCNT
]LOOP     LDA DEVLST-1,Y ; and /RAM dev in list
          STA DEVLST,Y
          DEY
          BNE ]LOOP
          STY $44
          LDA #>DSKBUF
          STA $45
          LDA RAMNUM
          STA DEVLST
          AND #%11110000
          STA $43
          LDA #3
          STA $42
          BIT CONTROL!BANK1!ENABLE
          JSR DRIVER     ;Set up /RAM
CLINT     CLI
CALLQUIT  DOS quit       ;Q ;Call quit routine
          BRK            ;If MLI miscues

QPARMS    DFB 4          ;Can use RRPARMS
          DFB 0
          DA 0
          DFB 0
          DA 0

MVDOS     LDY #0         ;Need not be done
          SEI
          BIT CONTROL!ENABLE
          BIT CONTROL!ENABLE
          LDX #$10
          JSR :MVDS
          BIT CONTROL!BANK1!ENABLE
          LDX #$30
:MVDS     LDA #$D0
          STA :L+2
          STA :S+2
:MVD      STA MAINZP
:L        LDA $D000,Y    ;Get prodos
          STA AUXZP
:S        STA $D000,Y    ; & put in aux mem
          INY
          BNE :MVD
          INC :L+2
          INC :S+2
          DEX
          BNE :MVD
          RTS

*-----------------------------------
* Disk command entry point from EXEC
*-----------------------------------

COMMAND   JSR SETBNK
          STA MAINZP
          LDY #-1
          STY CMD
          STADR CMDTBL   ;PNT
PARSE     INC CMD        ;Tentative command
          LDX #-1        ;Point to IN-1
]LOOP     JSR OVRSPC     ;Get cmd char
          BEQ SYNERR     ;Error if input over
          INY
          EOR (PNT),Y    ;Compare to tentative cmd
          BEQ ]LOOP      ;Continue if match
          ASL            ;Strip high bit
          BEQ FOUND      ;Match if this leaves 0
          DEY
]LOOP     INY
          LDA (PNT),Y
          BMI ]LOOP      ;Skip to next cmd in tbl
          BNE PARSE      ;Loop if tbl not done
SYNERR    JMP SYNE

FOUND     LDA CMD
          ASL
          TAY
          LDA ADRTBL+1,Y
          PHA
          LDA ADRTBL,Y
          PHA
          RTS

DSKOPEN   LDA OBJTYPE    ;Get current obj type
          BIT RELFLAG
          BPL :STYP      ;Use it if not REL file
          LDA #$F8       ;LNK type
:STYP     JSR SETBNK0
          STA MAINZP
          JSR OPENSUB    ;Create file if not there
          GOMLI open     ;OD ;Open using DSKBUF
          LDA ODREF
          STA DSKREF
JRETM     JMP RETMER

DIRERR    PLA
          LDA #$44       ;Dir not found
JERR      JMP ERROR

*------------------------------------------
* Source and object save and load routines:
*------------------------------------------

SAVE      JSR SETBNK0    ;A has file type on entry
          MOVD SOURCE    ;RWBUF ;Do before zp switch!
          STA MAINZP
DOSAV     JSR OPENSUB    ;Look for file and create
          JSR OPENFILE   ; it if not there
          GOMLI write    ;RW ;Assumes addr & len set
          MOVD RWGOT     ;MRKPOS ; before calling
          GOMLI seteof   ;MRK
          JSR CLOSESUB
          LDA TYP
          CMP #4
          BEQ JRETM      ;Exit if text file
          JSR GETINFO    ;Otherwise set subtype
          STA AUXZP      ; from ADRSV in aux mem
          MOVD ADRSV     ;INFAUX
          STA MAINZP
          JSR GTIME
          JMP SETINF

NOTFND    CMP #$46       ;File not found?
          BEQ LTYP       ;Make one if so
          CMP #$44       ;Dir not found?
          BNE JERR       ;Abort if not
          LDA DOSFNAM    ;Create a DIR file
          PHA            ;Save name length
          TAY
]LOOP     DEY            ;Look for previous /
          BEQ DIRERR     ;Error if none
          LDA DOSFNAM,Y
          ASL            ;Strip high bit
          CMP #"/"*2
          BNE ]LOOP
          DEY
          BEQ DIRERR
          STY DOSFNAM    ;Set length of DIR pathname
          LDA #$F        ;Directory file
          LDX #$D
          JSR CREATE     ;Make the dir
          PLA            ;Retrieve orig path length
          STA DOSFNAM    ;Try save again
LTYP      LDA TYP        ;Create ordinary file
          LDX #1
CREATE    STA CRETYPE
          STX CRESTYP
          JSR GTIME
          GOMLIX create  ;CRE

GTIME     LDA #0
          LDY #3
]LOOP     STA INFDATE,Y
          STA CREDATE,Y
          DEY
          BPL ]LOOP
          RTS

OPENSUB   SEC
          ROR XEF        ;Set local onerr
          JSR GETINFO
          LSR XEF        ;Clear it
          TAX            ;Was there an error?
          BNE NOTFND     ;Branch if so (new file)
          LDA INFTYPE
          EOR TYP
          BNE TYPMSM
          STA MRKPOS+2
          RTS

SRCLOAD   LDA LOADTYP    ;Usually holds 4 = TXT
EXTLOAD   STA TYP        ;Srccr has A=$FF for SYS
          LDA #6
          STA TYP2       ;Always accept bin load
          TSX
          STX ERRSTK
          JSR SETBNK     ;Must return with Z clear
          STA MAINZP
          CLV
          SEC
          BCC *
          DS -1
BLOAD     CLC
          JSR BLSUB0
          JMP RETMER

BSAVE     JSR GETNAMEC
          BCS SYE        ;Error if no name
          JSR ISA        ;Syntax check for adrs
          STA AUXZP
          STA RWBUF
          STA ADRSV
          STY RWBUF+1
          STY ADRSV+1
          DEX
          LDA #","
          STA ORGFLG     ;Defeat obj save since
          STA MAINZP     ; we have ruined ptrs
          JSR SYNCHR
          LDA #"L"
          JSR SYNCHR
          JSR ISDOL
          STA RWCNT
          STY RWCNT+1
          LDA #6         ;BIN type
          STA TYP
          JMP DOSAV

TYPMSM    LDA #13
          JMP ERROR
SYE       JMP SYNE

RLOAD     JSR PRNTAX     ;Print effective start
          JSR PRDOSFN    ; and name of this module
          JSR SETBNK
          STA MAINZP
          LDA #$F8       ;Demand LNK type
          STA TYP
          STA TYP2
          ADC #$80       ;Set V and C, clear Z
BLSUB0    BCS BLSUB
BLOADSUB  JSR PARSNAM
          CLV
          PHP            ;Remember if comma
          JSR MOVNAM
          BCS SYE
          LDX #$FF       ;SYS file
          STX TYP
          LDA #6         ;Binary file
          STA TYP2
          PLP            ;Recall V & carry
          LDA #>$2000    ;Default load adrs
          STA RWBUF+1    ; for SYS files
          INX            ;To set Z flag
          STX RWBUF
BLSUB     PHP
          PHP
          BCS :NOCOMMA
          JSR ISA
          STA RWBUF
          STY RWBUF+1
:NOCOMMA  JSR GETINFO
          LDX INFTYPE
          CPX TYP2
          BEQ :PP
          CPX TYP
          BNE TYPMSM
:PP       PLP
          BNE :HAVADR    ;Skip if from SRCLOAD, RLOAD or
          BCC :HAVADR    ; if adrs given (always if text)
          INX            ; or if SYS file
          BEQ :HAVADR
          MOVD INFAUX    ;RWBUF
:HAVADR   JSR OPENFILE
          GOMLI geteof   ;MRK
          LDA #0
          STA RWGOT
          STA RWGOT+1
          PLP
          PHP
          LDA MRKPOS
          STA BLEN
          BVC :SR        ;Branch if not RLOAD
          LDA INFAUX
:SR       STA RWCNT
          LDX MRKPOS+1
          STX BLEN+1
          BVC :SR1
          LDX INFAUX+1   ;RLOAD reads only code part
:SR1      STX RWCNT+1
          CLC
          ADC RWBUF      ;Find adrs of last byte
          TAY
          BNE :NI
          DEX
:NI       DEY
          TXA
          ADC RWBUF+1
          STA AUXZP
          CPY HIMEM      ;>= HIMEM?
          SBC HIMEM+1
          STA MAINZP
          BGE FTOOL      ;Mem in use err if so
          LDA MRKPOS+2
          BNE FTOOL
          DOS newline    ;NEW
          GOMLI read     ;RW
          PLP
          BVS JRETMER    ;Leave file open for RLOAD
CLOSESUB  GOMLIX close   ;CLS

OPENFILE  GOMLI open     ;O
SETREF    LDA OREF
          STA RWREF
          STA CLSREF
          STA MRKREF
          STA NEWREF
          RTS

BRUN2     JSR BLOADSUB   ;"-" command
          BIT CONTROL!ROMREAD
          JSR GOPROG     ;Go with main zp up
JRETMER   JMP RETMER     ;Back to Merlin when done

BRUN      JSR BLOADSUB   ;BRUN command
          BIT CONTROL
          STA AUXZP      ;Turn on aux zp for BRUN
GOPROG    JMP (RWBUF)    ;The program's RTS goes
                         ; back to Merlin
DELETE    JSR GETNAME
          BCS SYNE
          GOMLI destroy  ;DES
          BCC JRETMER    ;Always

FTOOL     LDA #$56
          HEX 2C
SYNE      LDA #16
          JMP ERROR

LOCKSUB   JSR GETNAME
          BCS SYNE       ;Err if no name
          JSR GETINFO
          LDA INFACC
          RTS

LOCK      JSR LOCKSUB
          AND #%00111101
          BPL SETI       ;Always

UNLOCK    JSR LOCKSUB
          ORA #%11000011
SETI      STA INFACC
SETINF    LDA #7
          STA INFPARMS
          GOMLI setinfo  ;INF
          BCC JRETMER    ;Always

ONLPFX    JSR SETBNK     ;Called by CAT "=" cmd
          STA MAINZP     ; to set pfx to sl 6, dr 1
OLPX      LSR DOSFNAM+2  ;Get bit 0 of chr after =
          LDA #0         ;To high bit of A
          ROR
          EOR DEVDFLT    ;Add slot
          JSR GETONL     ;Call online
          LDY #$10
]LOOP     LDA DSKBUF,Y   ;Set PFX to first one we get
          STA DOSFNAM+1,Y
          DEY
          BPL ]LOOP
          AND #$F
          TAY
          INY            ;To add the /
          LDA #'/'
          BNE SN

PREFIX    JSR GETNAME
          BCC SPFX       ;Branch if name given
          JSR GETPFX
          LDY #0
]LOOP     INY
          LDA DSKBUF+1,Y
          STA DOSFNAM+1,Y
          CPY #$11
          BGE MER        ;Return if no pfx
          CMP #'/'
          BNE ]LOOP
SN        STA DOSFNAM+1
          STY DOSFNAM
SPFX      CMP #'='       ;"PFX =" ?
          BEQ OLPX
SPFX2     GOMLI setpfix  ;DES
MER       JMP RETMER

GETPFX    GOMLIX getpfix ;GPX

POP       JSR GETPFX
          LDY DSKBUF
          BEQ MER        ;Safety
:PL       DEY
          BEQ MER        ;"
          LDA DSKBUF,Y
          EOR #'/'
          ASL
          BNE :PL
          STY DOSFNAM
:MV       LDA DSKBUF,Y
          STA DOSFNAM,Y
          DEY
          BNE :MV
          BEQ SPFX2

PRPRFX    JMLI getpfix   ;GPX
          LDX DSKBUF
          BEQ RET        ;Exit if no prefix
          LDY #0
PRDSKB    INY
          LDA DSKBUF,Y
          JSR CHROUT
          DEX
          BNE PRDSKB
RET       RTS

EQSLOT    JSR GETNAME
          ASL
          ASL
          ASL
          ASL
          BEQ GSYN
          LDY DEVCNT
]LOOP     PHA
          EOR DEVLST,Y
          AND #$F0
          BNE :DY
          PLA
          ORA #$80
          STA DEVDFLT
          BMI MER        ;Always
:DY       PLA
          DEY
          BPL ]LOOP
          BMI MER

PRDOSFN   JSR SPACE
PDFN      LDY #0
:SN       INY
          LDA DOSFNAM,Y
          JSR CHROUT
          CPY DOSFNAM
          BLT :SN
          JMP CROUT

GSYN      JMP SYNE

RENAME    JSR GETNAMEC   ;Require comma
          BCS GSYN
          LDX PNT+1      ;Point to comma
          JSR PARSNAM
          BCC GSYN       ;Error if another comma
          TXA
          SBC PNT        ;Length 2nd name
          BEQ GSYN
          LDX PNT
          DEX
          STA IN+$80,X   ;Store length 2nd name
          TXA
          ORA #$80
          STA RENPATH2   ;Set ptr to it
          GOMLI rename   ;REN
          JMP RETMER

GETONL    STA ONLUNIT
          GOMLIX online  ;ONL

ONLINE    JSR OVRSPC
          BNE GSYN       ;Error if something after cmd
          LDA #0         ;All devices
          JSR GETONL
          BIT CONTROL
          STA AUXZP
          JSR HOME
          PRINT "DRIVE SLOT NAME"8D8D
:NXT      LDA DSKBUF,Y
          BEQ :DONE
          TAX
          AND #$F
          STA LEN
          BEQ :NXY
:GETDS    TXA
          ASL
          PHA
          LDA #1
          LDX #5
          JSR PRBL3
          PLA
          LUP 5
          LSR
          --^
          CLC
          LDX #4
          JSR PRBL3
          LDX LEN
          JSR PRDSKB
          JSR CROUT
:NXY      TYA
          AND #$F0
          CLC
          ADC #$10
          TAY
          BNE :NXT
:DONE     RTS            ;Returns to Merlin

PRBL3     ADC #"0"
          JSR COUT
          JMP PRBL2

ADRTBL    DA BLOAD-1,BRUN-1,DELETE-1
          DA UNLOCK-1,PREFIX-1,RENAME-1
          DA ONLINE-1,LOCK-1,BSAVE-1
          DA PREFIX-1,EQSLOT-1,POP-1,BRUN2-1

CMDTBL    DCI "BLOAD"
          DCI "BRUN"
          DCI "DELETE"
          DCI "UNLOCK"
          DCI "PREFIX"
          DCI "RENAME"
          DCI "ONLINE"
          DCI "LOCK"
          DCI "BSAVE"
          DCI "PFX"
          DCI "SLOT"
          DCI "POP"
          DCI "-"
                         ;Uses next BRK as end ptr
ERCODES   BRK            ;No match (MLI ERROR)
          HEX 27         ;I/O
          HEX 2B         ;Write prot
          HEX 40         ;Inval path
          HEX 44         ;Dir not found
          HEX 45         ;Vol not found
          HEX 46         ;File not found
          HEX 47         ;Dup file name
          HEX 48         ;Vol full
          HEX 49         ;Vol dir full
          HEX 4E         ;Locked
          HEX 56         ;Mem in use
          DFB 13         ;File type mismatch
          DFB 16         ;Syntax
                         ;Last byte must be even!
ERRINDX   INDEX mli      ;err;0
          INDEX io       ;err;0
          INDEX wp       ;0
          INDEX inv      ;nam;0
          INDEX dir      ;nf;0
          INDEX vol      ;nf;0
          INDEX fil      ;nf;0
          INDEX dup      ;fil;nam
          INDEX vol      ;full;0
          INDEX vol      ;dir;full
          INDEX fil      ;lock;0
          INDEX mem      ;0
          INDEX fil      ;mis;0
          INDEX syn      ;err;0

ERRMSGS
mli       DCI "MLI"
err       DCI " ERROR"
io        DCI "I/O"
wp        DCI "WRITE PROTECTED"
inv       DCI "INVALID PATH"
nam       DCI "NAME"
dir       DCI "DIRECTORY "
nf        DCI "NOT FOUND"
vol       DCI "VOLUME "
fil       DCI "FILE "
dup       DCI "DUPLICATE "
full      DCI "FULL"
lock      DCI "LOCKED"
mem       DCI "MEMORY IN USE"
syn       DCI "SYNTAX"
mis       DCI "TYPE MISMATCH"

          ERR mis-ERRMSGS/$80

*------------------
* Parsing routines:
*------------------

PARSNAM   JSR OVRSPC     ;Bypass spaces
          STX PNT        ;Point to 1st chr
          BEQ :PARSED
]LOOP     CMP #","
          CLC
          BEQ :PARSED    ;Exit carry clear if comma
          JSR OVRSPC
          BNE ]LOOP      ;Exit carry set if CR
:PARSED   STX PNT+1      ;Point to chr beyond
          RTS

GETNAME   JSR PARSNAM
          BCC OVFLO      ;Error if comma
MOVNAM    TXA
          SEC
          SBC PNT        ;Length of name
          STA DOSFNAM
          STA IN+$80     ;For "-" cmd
          TAY
          BEQ :MOVD
          CMP #$40       ;Too long?
          BGE OVFLO      ;Error if so
]LOOP     LDA IN,X       ;Move name
          STA DOSFNAM+1,Y
          AND #$7F
          STA IN+$81,Y
          DEX
          DEY
          BPL ]LOOP      ;Carry is clear on exit
:MOVD     RTS            ;Carry set if no name

SYNCHR    STA ACL
          JSR OVRSPC
          EOR ACL
          BNE OVFLO
          RTS

ISA       LDX PNT+1      ;Check for "A$" and get #
          LDA #"A"
          JSR SYNCHR
ISDOL     LDA #"$"
          JSR SYNCHR
          STA ACL        ;A = 0
          STA ACL+1
:NXDIG    JSR OVRSPC
          JSR ASCNIB
          BCC :HEXGOT
          LDY #4
]LOOP     ASL
          ROL ACL
          ROL ACL+1
          BCS OVFLO
          DEY
          BNE ]LOOP
          BEQ :NXDIG
:HEXGOT   LDA ACL
          LDY ACL+1
          RTS

GETNAMEC  JSR PARSNAM
          BCC MOVNAM     ;Branch if have comma
OVFLO     JMP SYNE

*--------------------------------------------------
* Interrupt patch used only by main memory version:
*--------------------------------------------------

INTPATCH  STX AUXZP
          LDA #>INTEXIT
          PHA
          LDA #INTEXIT
          PHA
          LDA #4
          PHA
          JMP INTHAND

INTEXIT   STX MAINZP
          RTI

          ERR \$BDC0
          DS $BDC0-*

DSKNAMSV  HEX 8D         ;Name save for DSK & SWAP
STARTUP   STADR $E003    ;WRMVEC
          LDY #5         ;This code is used only
:SV       LDA $E00A,Y    ; on boot
          STA SOURCE,Y   ;Establish zp pntrs
          DEY
          BPL :SV
          LDY STUPNAM    ;Length of startup
          BEQ :GOWRM     ;Ignore if 0
          LDA #$8D       ;For command parser
          INY
:MV       STA IN,Y
          LDA STUPNAM-1,Y
          DEY
          BNE :MV
          LDA #"-"       ;Fake "-" command
          STA IN
          JSR COMMAND    ;Execute startup
:GOWRM    JMP WARM       ;Go to Merlin

          DS $BE00-*-13,$8D

MERNAM    ASC 'MERLIN.SYSTEM'
MERNEND

          PUT MERLIN.GP

          ORG

NOWIEND   = *-1

MERLOC    ERR *+$3800/DSKBUF ;Room for ASM code

* More equates:

DSKBUF    = INT-$800     ;Buffer for DSK & misc use
ORDBUF    = INT-$400     ;Buffer for LOAD, SAVE,
                         ; PUT, USE, BLOAD, etc.
          DO SAVOBJ
          SAV INTERPRETER
          FIN
