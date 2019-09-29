XCODES    USR COP
          DDB COP-1
          USR PER
          DDB PER-1
          USR BRL
          DDB BRL-1
          USR REP
          DDB REP-1
          USR SEP
          DDB SEP-1
          USR PEI
          DDB PEI-1
          USR PEA
          DDB PEA-1
          USR MVP
          DDB MVP-1
          USR MVN
          DDB MVN-1
          USR XCE
          DDB XCE-1
          USR MX
          DDB MXOP-1
PSEUDO    USR =
          ERR *-PSEUDO-2
          ERR PSEUDO!XCODES&$FF00
          DDB EQU-1
          USR EQU
          DDB EQU-1
          USR >>>
          DDB PMC-1
          USR PMC
          DDB PMC-1
          USR HEX
          DDB HEX-1
          USR DFB
          DDB DFB-1
          USR DB
          DDB DFB-1
          USR DA
          DDB DA-1
          USR DW
          DDB DA-1
          USR DDB
          DDB DDB-1
          USR DS
          DDB DS-1
          USR LST
          DDB LST-1
          USR LSTD
          DDB LSTD-1
          USR AST
          DDB AST-1
          USR ORG
          DDB ORG-1
          USR SET
          DDB SET-1
          USR SKP
          DDB SKP-1
          USR PAG
          DDB PAG-1
          USR PAU
          DDB PAUSE-1
          USR EXP
          DDB EXP-1
          USR PUT
          DDB PUT-1
          USR USE
          DDB USE-1
          USR TR
          DDB TRUNC-1
          USR CHK
          DDB CHK-1
          USR VAR
          DDB VAR-1
          USR SAV
          DDB SAV-1
          USR END
          DDB END-1
          USR DSK
          DDB DSK-1
          USR LUP
          DDB LUP-1
          USR ERR
          DDB USERR-1
          USR USR
          DDB USR-1
          USR DUM
          DDB DUM-1
          USR DEND
          DDB DEND-1
          USR SW
          DDB SW-1
          USR XC
          DDB XC-1
          USR CYC
          DDB CYC-1
          USR OBJ
          DDB OBJ-1
          USR REL
          DDB REL-1
          USR EXT
          DDB EXT-1
          USR ENT
          DDB ENT-1
          USR TYP
          DDB TYP-1
          USR DAT
          DDB DATE-1

STRING    USR ASC
          DDB ASC-1
          USR DCI
          DDB DCI-1
          USR FLS
          DDB FLS-1
          USR INV
          DDB INV-1
          USR REV
          DDB REV-1
          USR STR
          DDB STR-1
          USR KBD
          DDB KBD-1

          BRK

* Conditionals
          USR <<<
          DDB EOM-1
          USR DO
          DDB DO-1
          USR ELS
          DDB ELSE-1
          USR FIN
          DDB FIN-1
          USR MAC
          DDB MAC-1
          USR EOM
          DDB EOM-1
          USR IF
          DDB IF-1
          USR --^
          DDB ENDLUP-1
          BRK

* One byte
          USR CLC
          HEX 18
          USR DEX
          HEX CA
          USR DEY
          HEX 88
          USR INX
          HEX E8
          USR INY
          HEX C8
          USR RTS
          HEX 60
          USR SEC
          HEX 38
          USR TAX
          HEX AA
          USR TAY
          HEX A8
          USR TXA
          HEX 8A
          USR TYA
          HEX 98
          USR PHA
          HEX 48
          USR PHP
          HEX 08
          USR PLA
          HEX 68
          USR PLP
          HEX 28
          USR TSX
          HEX BA
          USR TXS
          HEX 9A
          USR CLD
          HEX D8
          USR SED
          HEX F8
          USR SEI
          HEX 78
          USR RTI
          HEX 40
          USR CLI
          HEX 58
          USR CLV
          HEX B8
          USR NOP
          HEX EA
          USR BRK
          HEX 0000

* Onebyte 65C02 and Sweet 16
          ERR *&$FF-1/-1 ;Must not be pg bdry
          ERR *!RELOP&$FF00 ;Same pg as RELOP
          USR RTN
          HEX 00
          USR BK
          HEX 0A
          USR RS
          HEX 0B
          USR NUL
          HEX 0D
          USR PHX
          HEX DA
          USR PHY
          HEX 5A
          USR PLX
          HEX FA
          USR PLY
          HEX 7A00

* Onebyte 65802
          USR PHD
          HEX 0B
          USR TCS
          HEX 1B
          USR PLD
          HEX 2B
          USR TSC
          HEX 3B
          USR PHK
          HEX 4B
          USR TCD
          HEX 5B
          USR RTL
          HEX 6B
          USR TDC
          HEX 7B
          USR PHB
          HEX 8B
          USR TXY
          HEX 9B
          USR PLB
          HEX AB
          USR TYX
          HEX BB
          USR WAI
          HEX CB
          USR STP
          HEX DB
          USR XBA
          HEX EB00

RELOP
          USR BCC
          HEX 90
          USR BCS
          HEX B0
          USR BEQ
          HEX F0
          USR BMI
          HEX 30
          USR BNE
          HEX D0
          USR BLT
          HEX 90
          USR BGE
          HEX B0
          USR BPL
          HEX 10
          USR BVC
          HEX 50
          USR BVS
          HEX 70
          USR BR
          HEX 01
          USR BNC
          HEX 02
          USR BC
          HEX 03
          USR BP
          HEX 04
          USR BM
          HEX 05
          USR BZ
          HEX 06
          USR BNZ
          HEX 07
          USR BM1
          HEX 08
          USR BNM
          HEX 09
          USR BS
          HEX 0C
          USR BRA
          HEX 0000

* Sweet
          USR LD
          HEX 24
          USR ST
          HEX 35
          USR LDD
          HEX 06
          USR STD
          HEX 07
          USR POP
          HEX 08
          USR STP
          HEX 09
          USR ADD
          HEX A0
          USR SUB
          HEX B0
          USR POPD
          HEX 0C
          USR CPR
          HEX D0
          USR INR
          HEX E0
          USR DCR
          HEX F000

* Following data bytes = format,base#
* JMP & JSR done differently

* Bits: imm,imp,indx,indy,relx,zx,rely,zy

          USR STA
          DFB %00111110,$81
          USR STX
          DFB %00000001,$82
          USR STY
          DFB %00000100,$80
          USR LDA
          DFB %10111110,$A1
          USR LDX
          DFB %10000011,$A2
          USR LDY
          DFB %10001100,$A0
          USR ADC
          DFB %10111110,$61
          USR AND
          DFB %10111110,$21
          USR ASL
          DFB %01001100,$02
          USR CMP
          DFB %10111110,$C1
          USR CPX
          DFB %10000000,$E0
          USR CPY
          DFB %10000000,$C0
          USR DEC
          DFB %01001100,$C2
          USR EOR
          DFB %10111110,$41
          USR INC
          DFB %01001100,$E2
          USR JMP
          DFB %00100000,$4C
          USR JSR
          DFB %00100000,$20
          USR SBC
          DFB %10111110,$E1
          USR ORA
          DFB %10111110,$01
          USR LSR
          DFB %01001100,$42
          USR BIT
          DFB %10001100,$20
          USR ROL
          DFB %01001100,$22
          USR ROR
          DFB %01001100,$62
          USR STZ
          DFB %00001100,$64
          USR TSB
          DFB %00000000,$00
          USR TRB
          DFB %00000000,$10
          BRK

MASK      DFB %1000      ;#
          DFB %1000      ;implied
          DFB %0         ;(-,X)
          DFB %10000     ;(-),Y
          DFB %11100     ;--,X
          DFB %10100     ;-,X
          DFB %11000     ;--,Y
          DFB %10100     ;-,Y
          DFB %1100      ;--
          DFB %100       ;-
          DFB %1110      ;---
          DFB %11110     ;---,X
          DFB %10        ;-,S
          DFB %10010     ;(-,S),Y
          DFB %110       ;[-]
          DFB %10110     ;[-],Y

OPTBL     ASC ') ,]'
MATHOP    ASC '+-'
LOGIC     ASC '!.&'
DVML      ASC '/*'
ENDTBL    = *-1

* Zpag code: ADC,SBC,EOR,ORA,AND used by "ARITH":

CODE      HEX 65E5450525

SPECIAL   HEX 28,89,00,00,7C,9E,BA,BE,6C,9C

BITS      DFB %10000000  ;This must follow SPECIAL!
          DFB %01000000
          DFB %00100000
          DFB %00010000
          DFB %00001000
          DFB %00000100
          DFB %00000010
          DFB %00000001
          HEX 00,00,10,10,10,10,10,10

*-----------------------------------------
* Cycle times indexed by opcode.
*  $20 bit set if a 6502 opcode.
*  $10 bit set if 65C02 opcode.
*  $8  bit set if 65C02 exception.
*  SIGN flag if added cycle possible
*  OVERFLOW flag if a branch opcode
* TIME is 0 if invalid opcode.
*-----------------------------------------

TIMETBL
* 0X
          HEX 37,36,07,04,15,33,35,06
          HEX 33,32,32,04,16,34,36,05
* 1X
          HEX F2,B5,15,07,15,34,36,06
          HEX 32,B4,12,02,16,B4,3F,05
* 2X
          HEX 36,36,07,04,33,33,35,06
          HEX 34,32,32,05,34,34,36,05
* 3X
          HEX F2,B5,15,07,14,34,36,06
          HEX 32,B4,12,02,94,B4,3F,05
* 4X
          HEX 36,36,00,04,07,33,35,06
          HEX 33,32,32,03,33,34,36,05
* 5X
          HEX F2,B5,15,07,07,34,36,06
          HEX 32,B4,13,02,04,B4,3F,05
* 6X
          HEX 36,36,06,04,13,33,35,06
          HEX 34,32,32,06,3D,34,36,05
* 7X
          HEX F2,B5,15,07,14,34,36,06
          HEX 32,B4,14,02,16,B4,3F,05
* 8X
          HEX 54,36,03,04,33,33,33,06
          HEX 32,12,32,03,34,34,34,05
* 9X
          HEX F2,36,15,07,34,34,34,06
          HEX 32,35,32,02,14,35,15,05
* AX
          HEX 32,36,32,04,33,33,33,06
          HEX 32,32,32,04,34,34,34,05
* BX
          HEX F2,B5,15,07,34,34,34,06
          HEX 32,B4,32,02,B4,B4,B4,05
* CX
          HEX 32,36,03,04,33,33,35,06
          HEX 32,32,32,03,34,34,36,05
* DX
          HEX F2,B5,15,07,06,34,36,06
          HEX 32,B4,13,03,06,B4,3F,05
* EX
          HEX 32,36,03,04,33,33,35,06
          HEX 32,32,32,03,34,34,36,05
* FX
          HEX F2,B5,15,07,05,34,36,06
          HEX 32,B4,14,02,06,B4,3F,05

*-------------------------------
          ERR *-TIMETBL-$100
