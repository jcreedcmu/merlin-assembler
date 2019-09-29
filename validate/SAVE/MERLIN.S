********************************
*                              *
*         SAVE MERLIN          *
*                              *
*   Glen E. Bredon   6/21/85   *
*                              *
********************************

          DATE

CVERS     KBD "Assemble one drive version (1/0)?"

          EXP OFF
          TR

          ORG $1000

BADR      = 0
EXADR     = 2
TXTP      = 6

WHEREMER  = $2046        ;Startup revision

KEY       = $C000
STROBE    = $C010
MAINZP    = $C008
AUXZP     = $C009
READZP    = $C016
CONTROL   = $C080
XFLAG     = $BE79
PRNTAX    = $F941
CROUT     = $FD8E
PRBYTE    = $FDDA
COUT      = $FDED

STADR     MAC
          LDA #]1
          STA ]2
          LDA #>]1
          STA ]2+1
          <<<

INCD      MAC
          INC ]1
          BNE NI
          INC ]1+1
NI
          <<<

MONL      MAC
          SWITCHZP
          BIT CONTROL
          JSR MONITORL
          SWITCHZP
          <<<

MONS      MAC
          SWITCHZP
          BIT CONTROL
          JSR MONITORS
          SWITCHZP
          <<<

PRINT     MAC
          DO CVERS
          SWITCHZP
          BIT CONTROL
          JSR SENDMSG
          ASC ]18D00
          SWITCHZP
          BIT STROBE
WT        LDA KEY
          BPL WT
          BIT STROBE
          FIN
          <<<

SWITCHZP  MAC
          BIT READZP
          STA AUXZP
          BPL OV
          STA MAINZP
OV        <<<

          USE SAVE/BMACS

          PLA
          TAX
          PLA
          SWITCHZP
          PHA
          TXA
          PHA
          STA MAINZP     ;Merlin off
          BIT XFLAG
          BVC :OV
          STA AUXZP
:OV       PRINT "INSERT /ED"
          BLOAD 'INTERPRETER';*
          MONL
          MOVD WHEREMER  ;BADR
          PRINT "INSERT /ASS"
          BLOAD 'ASMOBJ/PROASM.BANK1';BADR
          MONL
          LDA BADR+1
          CLC
          ADC #$10
          STA BADR+1
          BLOAD 'ASMOBJ/ED';BADR
          MONL
          FILEINFO 'ASMOBJ/EX'
          LDA BADR
          CLC
          ADC INFAUX
          STA EXADR
          LDA BADR+1
          ADC INFAUX+1
          SEC
          SBC #>$D000
          STA EXADR+1
          BLOAD 'ASMOBJ/EX';EXADR
          MONL
          LDA BADR
          CLC
          ADC #$E5F0-$D000
          STA EXADR
          LDA BADR+1
          ADC #>$E5F0-$D000
          STA EXADR+1
          BLOAD 'ASMOBJ/AS';EXADR
          MONL
          LDA EXADR
          CLC
          ADC RWGOT
          STA RWCNT
          LDA EXADR+1
          ADC RWGOT+1
          SEC
          SBC #>$2000
          STA RWCNT+1
          STADR $2000    ;RWBUF
          BSAVE 'MERLIN.SYSTEM';*;*;*
          MONS
          SWITCHZP       ;Merlin on
          BIT CONTROL
          RTS

ERROR     SWITCHZP
          BIT CONTROL
          PHA
          JSR CROUT
          JSR CROUT
          PLA
          JSR PRBYTE     ;Print error code
          JSR SENDMSG
          ASC " DISK ERROR"8D8D00
          RTS            ;Back to Merlin

MONITORS  JSR SENDMSG
          ASC "BSAVE "00
          JMP MONITOR
MONITORL  JSR SENDMSG
          ASC "BLOAD "00
MONITOR   MOVD ONAME     ;TXTP
          LDA (TXTP),Y
          TAX            ;Name length (Y=0)
LOOP      INY
          LDA (TXTP),Y
          ORA #$80
          JSR COUT
          DEX
          BNE LOOP
          JSR SENDMSG
          ASC " A$"00
          LDA RWBUF+1
          LDX RWBUF
          JSR PRNTAX
          JSR SENDMSG
          ASC " L$"00
          LDA RWCNT+1
          LDX RWCNT
          JSR PRNTAX
          JSR SENDMSG
          ASC " Actual R/W count:$"00
          LDA RWGOT+1
          LDX RWGOT
          JSR PRNTAX
          JMP CROUT

          VAR TXTP       ;COUT
          PUT LIB/SENDMSG

OPARMS    DFB 3
ONAME     DA 0
          DA $AA00       ;One of Merlin's buffers
OREF      DFB 0

RWPARMS   DFB 4
RWREF     DFB 0
RWBUF     DA 0
RWCNT     DA 0
RWGOT     DA 0

CLSPARMS  DFB 1
CLSREF    DFB 0

INFPARMS  DFB 10
INFNAME   DA 0
          DFB $C3
INFTYPE   DFB 6          ;Binary
INFAUX    DA 0
          DFB 0
          DA 0
          DA 0
          DA 0
          DA 0
          DA 0

MRKPARMS  DFB 2
MRKREF    DFB 0
MRKPOS    DFB 0,0,0

          ERR \$2000
