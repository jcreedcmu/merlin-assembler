**********************************
*                                *
*         Linking loader         *
*                                *
* Called by editor LINK command. *
*                                *
**********************************

LOADADR   = $16          ;ED puts load adrs here
PAGFLAG   = $A2          ;Paginator use
STRINGS   = $860         ;Filename here
HIT       = $E02A

*-------------------------------------------
* Also used are:
*
* PL     Dict counter & misc
* ACL    Temp dict depository
* TBLP   Location of field to fix
* ADRS   Load adrs sent to DOS for each file
* OFFSET Add to rel adrs to get final adrs
* SPNT   Next ADRS
* SYMPNT Pointer while looking for ENTRY sym
* LENGTH External label length
*-------------------------------------------

* Dos stuff for linker:

JERROR    = INT+$15

* Ext memory stuff:

FROM      = $3C
ENDMOVE   = $3E
DEST      = $42
AUXMOVE   = $C311

          JMP MAKDIC     ;For USR access

          ERR LINK-$D003

LINK      ROR PAGFLAG    ;Enable paginator
          LSR JUST
          LDA LOADADR    ;Save specified start adrs
          STA ADRSV
          LDA LOADADR+1
          STA ADRSV+1
          SEC            ;Compute offset
          SBC SOURCE+1
          STA LOADADR+1  ;Add this to ADRS for OFFSET
          LDA #>SYMADR
          STA DICPNT+1
          LDA SOURCE+1   ;Init actual mem address
          STA SPNT+1
          STA PASNUM     ;Enable KEYCHK
          LDY #0         ;Always start at page bndry!
          STY DICPNT     ; (SOURCE low not used)
          STY SPNT
          STY ERCOUNT    ;Init error counters
          STY DUPCNT
          STY EXPFLG     ;For KEYCHK
          STY LSTFLG     ; "
]LOOP     LDA STRINGS,Y
          BEQ :GOT
          INY
          STA DOSFNAM,Y
          BNE ]LOOP      ;Always
:GOT      STY DOSFNAM
          JMLI open      ;OD ;Open name file
          MOV ODREF      ;RNREF
          STA RCREF
          STA RRREF
          JMLI newline   ;RN ;Set to end on BRK
LNKLOOP   JMLI read      ;RR ;Read filename to IN+$80
          LDY IN+$80     ;Get length
          BNE :MV        ;Keep going if not 0
          JMLI close     ;RC ;Close name file
          JMP FIXEXT     ;Go fix externals
:MV       LDA IN+$80,Y
          STA DOSFNAM,Y
          DEY
          BPL :MV
          LDA SPNT+1
          LDX SPNT
          STA RWBUF+1
          STX RWBUF
          STA ADRS+1     ;Save code address
          STX ADRS
          INY            ;=0
          STA WRITE.AUX
          TXA            ;Put current memory adrs
          STA (DICPNT),Y ; in dictionary
          INY
          CLC
          ADC LOADADR
          STA OFFSET     ;Can add OFFSET to current
          TAX
          LDA ADRS+1     ; address to get
          STA (DICPNT),Y ; effective address
          ADC LOADADR+1
          PHA
          EOR #$80
          STA OFFSET+1
          JSR BUMPDIC    ;Turns on WRITE.MAIN
          PLA            ;A,X have effective adrs
          JSR JRLOAD     ;Note Y=1 here
          LDA ADRS
          ADC RWGOT
          STA SPNT
          LDA ADRS+1
          ADC RWGOT+1
          STA SPNT+1
          LDA BLEN
          SEC
          SBC RWGOT
          EOR #-1
          STA PL
          LDA BLEN+1
          SBC RWGOT+1
          EOR #-1
          STA PL+1
          LDA #IN+$7F
          STA RWBUF
          LDY #2
          STY RWBUF+1
          DEY
          STY RWCNT
          DEY
          STY RWCNT+1

*----------------------------------------------
* Read dictionary, fix rels, put EXT/ENT in AUX
*----------------------------------------------

LOADIC    INCD PL        ;Done?
          BEQ EEMPTY     ;Branch if so
          JSR GENTRY     ;Get flag byte
          BEQ LOADEE     ;Branch if dic done
          STA ACL
          JSR GENTRY
          STA ACL+1      ;Offset low in code
          JSR GENTRY
          STA ACL+2      ;Offset high
          JSR GENTRY     ;Low byte of value if REL
          STA ACL+3      ; entry # if EXT
          LDA ACL
          AND #%00010000
          BNE PUTDIC     ;Branch if EXT
          JSR FIXCODE    ;Correct the field now if not
          JMP FIXPL
PUTDIC    STA WRITE.AUX
          LDY #3
]LOOP     LDA ACL,Y      ;Put EXT dict entry
          STA (DICPNT),Y ; in table in AUX
          DEY
          BPL ]LOOP
          JSR BUMPDIC
          JSR BUMPDIC
FIXPL     JSR BUMPL3     ;Adjust countdown
          BNE LOADIC
JFERR     JMP FILERR

*---------------------------------------
* Routine to load the symbolic (EXT/ENT)
* part of the dictionary:
*---------------------------------------

GENTRY    LDA #read
          LDX #RWPARMS
          JSR ENTRY      ;Read one byte
          TAY            ;Get error code
          BNE JFERR      ;This will be an EOF
          LDA IN+$7F     ;Get byte read
          RTS

]LOOP     JSR GENTRY
LOADEE    STA WRITE.AUX  ;Y=0 here
          STA (DICPNT),Y
          STA WRITE.MAIN
          INC DICPNT
          BNE :NOCH
          JSR MEMCHK
:NOCH     INCD PL        ;Should read till PL,PL+1=0
          BNE ]LOOP
                         ;Fall into EEMPTY when done
EEMPTY    JMLI close     ;CLS ;Close up this file
          JMP LNKLOOP    ;Loop till NO FILE DOS err

*---------------------------------------------
* Routine to fix code field.  ACL+1 has offset
* in code of byte(s) to fix.  ACL has flag.
* ACL+3 has low byte or EXT #.  OFFSET has
* correction factor.  For EXT, SPL has
* current field value.
*---------------------------------------------

MAKPNT    CLC
          LDA ACL+1      ;Compute mem loc to be fixed
          ADC ADRS
          STA TBLP
          LDA ACL+2
          ADC ADRS+1
          STA TBLP+1
          RTS

SPECODE   ASL
          ASL
          BMI ERRMEM
:FILL     LDA ACL+3
          STA (SPNT),Y
          LDA SPNT
          CLC
          ADC LOADADR
          BEQ FIXED
          INC SPNT
          BNE :FILL
          INC SPNT+1
          BNE :FILL
FIXED     RTS

ERRMEM    LDA SPNT
          CLC
          ADC LOADADR
          STA SPL        ;Effective address of
          LDA SPNT+1     ; end of module+1
          ADC LOADADR+1
          STA SPL+1
          LDA ACL+1      ;Specified memtop
          CMP SPL
          LDA ACL+2
          SBC SPL+1
          BGE FIXED
          JSR JCLOSE
          JSR SENDMSG
          HEX 8D
          ASC "Constraint error: "00
          LDX ACL+1
          LDA ACL+2
          JSR PRNTAX
          JMP HIT

FIXCODE   JSR MAKPNT
          LDY #0
          LDA ACL
          CMP #%11000000
          BGE SPECODE    ;Branch if ERR or DS
          LDA (TBLP),Y   ;Get bytes at field
          STA SPL        ;Put in SPL
          INY
          LDA (TBLP),Y
          STA SPL+1      ;This one not used if
          DEY            ; 1 byte field
          LDA ACL        ;Get flag
          ASL
          BCC :ONEBYT
          ASL
          BMI :HILO
          JSR :ADDOFF0
          INY
          BNE :ADDOFF    ;Always

:HILO     INY
          JSR :ADDOFF0
          DEY
          BEQ :ADDOFF    ;Always

:HIBYT    LDA ACL        ;Get flag
          AND #%00011111
          CMP #%00010000 ;Ext?
          BLT :NOTX      ;Branch if not
          EOR #%11101000 ;Extend to 8 bits
          ADC #%00001000-1
          CLC
          HEX 2C
:NOTX     LDA ACL+3      ;Get low byte
          ADC OFFSET     ;Condition carry
          LDX #1
          BNE :ADDOFF    ;Always

:ONEBYT   ASL
          BCS :HIBYT
                         ;Fall into :ADDOFF0
:ADDOFF0  LDX #0
          CLC
:ADDOFF   LDA SPL,Y
          ADC OFFSET,X
          STA (TBLP),Y
          INX
          RTS

*-----------------------------------
* Pointer updates, memory checks and
* DOS error interface:
*-----------------------------------

BUMPL3    LDA #1
BUMPL     AND #$F
          CLC
          ADC #2
          ADC PL
          STA PL
          BCC :BPD
          INC PL+1
:BPD      RTS

ADD2      CLC
          LDA #2
          JSR BUMPSYM
          LDA SYMPNT+1
          CMP DICPNT+1
          BGE FILERR
          RTS

GETPL     INC PL
          BNE :SAUX
          INC PL+1
          LDA PL+1
          EOR DICPNT+1   ;Must preserve carry
          BEQ FILERR
:SAUX     STA READ.AUX
          LDA (PL),Y
          STA READ.MAIN
MOK       RTS

BUMPDIC   STA WRITE.MAIN
          CLC
          LDA DICPNT
          ADC #2
          STA DICPNT
          BCC MOK
MEMCHK    INC DICPNT+1
          LDA DICPNT+1
          CMP #$BE       ;Leave a 2 page buffer
          BLT MOK        ;Carry clear on return
                         ;Fall into FILTOOL
          LDA #14        ;Prog too large
          HEX 2C
FILERR    LDA #13        ;File type mismatch
          STA ORGFLG     ;Defeat OBJ save
          PHA
          JSR JCLOSE     ;Close all files
          JSR WARMDIS
          PLA
          JMP JERROR

*-----------------------------------------
* Final exit routine.  Move linked code to
* AUX memory for EXEC and set up pointers:
*-----------------------------------------

LINKED    LDA $F800
          CMP #$20
          BNE :LINKED
          JSR PRINTENT
:LINKED   LDA #0         ;Set up move MAIN->AUX
          STA DEST       ; SOURCE,SPNT -> $1000=OBJPNT
          STA OBJPNT
          STA FROM
          LDA #>SYMADR
          STA DEST+1
          STA OBJPNT+1   ;Set OBJPNT for EXEC
          MOV SOURCE+1   ;FROM+1
          LDA SPNT
          STA ENDMOVE
          STA OBLEN      ; and OBLEN
          LDA SPNT+1
          STA ENDMOVE+1
          SEC
          SBC SOURCE+1
          STA OBLEN+1    ;Leaves carry set
          JSR AUXMOVE
          LDA #$FF       ;Set up "valid" flags
          LDY #0
          STY ORGFLG
          STA (ENDSRC),Y
          JSR CROUT
          LDA OBLEN+1
          LDX OBLEN
          JSR BYTPRN     ;Print length & err count
          JMP HIT

*------------------------------
* External resolution routines:
*------------------------------

FIXEXT    JSR SENDMSG
          HEX 8D
          ASC "Externals:"8D8D00
          TYA
          STA WRITE.AUX
          STA (DICPNT),Y ;Mark end of dict
          INCD DICPNT
          STA (DICPNT),Y
          INC DICPNT+1   ;For mem err detect
          STA WRITE.MAIN
          STADR SYMADR-1 ;PL ;Will incr prior to use
NXADR     JSR GETPL      ;Get memory adrs of
          STA ADRS       ; this module
          JSR GETPL
          BEQ LINKED
          STA ADRS+1

*--------------------------------
* Routine to get next dict entry:
*--------------------------------
GETEX     JSR GETPL      ;Get dict flag
          BEQ BYSYM      ;Branch if sym part next
          STA ACL
          JSR GETPL      ;Put 4 byte entry at ACL
          STA ACL+1
          JSR GETPL
          STA ACL+2
          JSR GETPL
          STA ACL+3
          LDA PL         ;Save dict pointer
          PHA
          LDA PL+1
          PHA
]LOOP     JSR GETPL      ;Go through till sym
          BEQ HAVSYM     ; part found.
          JSR BUMPL3
          BNE ]LOOP      ;Always

BYSYM     JSR GETPL      ;Bypass symbol portion
          BEQ NXADR
          JSR BUMPL
          BNE BYSYM      ;Always

GOFERR    JMP FILERR
NXEX      BEQ GOFERR
          JSR BUMPL
          BNE HAVSYM     ;Always

HAVSYM0   JSR GETPL
HAVSYM    JSR GETPL
          BPL NXEX       ;Branch if not EXT
          AND #$F        ;Get length
          STA LENGTH
          LDX #0
]LOOP     JSR GETPL
          STA LABEL,X    ;Put sym name at LABEL
          INX
          CPX LENGTH
          BLT ]LOOP
          LDA #' '
          STA LABEL,X
          JSR GETPL      ;Adrs low (holds ext #)
          CMP ACL+3      ;Is this the ext we seek?
          BNE HAVSYM0    ;Look at next one if not
          STADR SYMADR-2 ;SYMPNT
          JSR FINDENT    ;Look for corresp entry
          BEQ :NORESLV   ;Branch if none found
          JSR GETSYM     ;Get offset low
          CLC
          ADC OFFSET     ;Adjust it
          STA OFFSET     ;Set for FIXCODE
          JSR GETSYM     ;Offset high
          ADC OFFSET+1
          STA OFFSET+1
          JSR FIXCODE    ;Fix field
          JSR NXSY       ;Look for duplicate entry
          BEQ :RESD      ;Branch if no dup
          LDY #1
          JSR PRRES
          JSR SENDMSG
          ASC "- duplicate "00
          JMP :INERR
:RESD     BIT TRFL       ;Only errors wanted?
          BMI :PA        ;Branch if so
          JSR PRRES
:WHERE    JSR MAKPNT     ;Get actual adrs of field
          CLC
          LDA TBLP       ;Correct to effective adrs
          ADC LOADADR
          TAX
          LDA TBLP+1
          ADC LOADADR+1
          JSR PRNTAX
          JSR CROUT
          JSR KEYCHK
:PA       PLA            ;Replace dict pointer
          STA PL+1
          PLA
          STA PL
          LDY #0
          JMP GETEX      ;Look for next EXT

:NORESLV  JSR LABMSG
          ASC "not"00
          LDY LENGTH     ;Point to ending space
          INY
          JSR PRRES
:INERR    INC ERCOUNT
          BNE :WHERE
          DEC ERCOUNT
          BNE :WHERE

FINDENT   LDY #0
          JSR ADD2
          JSR GETSYM0    ;Get mem ptr for this segment
          ADC LOADADR    ;Compute offset (carry is clr)
          STA OFFSET
          JSR GETSYM
          BEQ FENTRET    ;Branch if entry not found
          ADC LOADADR+1
          STA OFFSET+1
          DEY            ;=0
]LOOP     JSR ADD2
          JSR GETSYM0    ;Bypass dict part
          BEQ LOOKEN     ;Branch if now at sym part
          JSR ADD2
          BNE ]LOOP      ;Always

NXSY      LDA LENGTH     ;Get length
NXSY0     AND #$F
NXSY1     CLC
          ADC #3
          JSR BUMPSYM
          LDY #0
LOOKEN    JSR GETSYM     ;Look for ENTRY labels
          BEQ FINDENT    ;Branch if this section done
          BMI NXSY0      ;Branch if EXT
          AND #$F        ;Get length
          TAX
          BIT JUST
          BMI PRENT
          CMP LENGTH     ;Correct?
          BNE NXSY1      ;Loop if not
]LOOP     JSR GETSYM     ;Compare ENT with EXT
          CMP LABEL-2,Y
          BNE NXSY       ;Exit if not same
          DEX
          BNE ]LOOP
          DEX            ;Clear Z flag
FENTRET   RTS

PRENT     JMP PRNENT

PRRES     JSR LABMSG
          ASC "resolved "00
          RTS

LABMSG    DEY
          JSR PRLAB
          JMP SENDMSG
