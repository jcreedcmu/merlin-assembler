
* Local variable replacement:

GB        LDA #"]"
          DEY
SETOPND   LDX OPNDLEN
          AND #$7F
          STA OPERAND,X
          CPX #$40
          BGE OPNDTOOL
          INC OPNDLEN
          RTS

OPNDTOOL  JSR INSP
          BNE OTL        ;Always

* Recursive replacement routine:

BRACKET   BIT TEMP       ;Do off or comment line?
          BMI SETOPND    ;Branch if so
BRACK     CMP #"]"
          BNE SETOPND
          LDX LEVEL
          INY
          LDA (LVAR),Y
          SBC #"1"       ;Carry is set
          CMP #8         ;Local var?
          BGE GB         ;Branch if not
          PHA
          JSR ESTPNT     ;Reset LVAR according to level
          PLA
          TAX
          DEC LEVEL
          TYA
          PHA
          LDY #-1
:NX       DEX            ;Count semicolons
          BMI REPLC
]LOOP     INY            ;Find next semicolon
          LDA (LVAR),Y
          CMP #$8D
          BEQ BADVAR
          CMP #"""       ;Must ignore ; in strings
          BEQ :JF
          CMP #"'"
          BNE :NQ
:JF       JSR FNDNX
          BEQ ]LOOP      ;Always
:NQ       CMP #"         ;"
          BEQ :NX
          AND #" "!$FF
SPMSK     = *-1
          BNE ]LOOP
BADVAR    ERX var
          HEX 2C
OTL       ERX toolong
          JMP ERR2

JR        JSR BRACK      ;Recursion till no ]
REPLC     INY
REPT      LDA (LVAR),Y
          CMP #$8D
          BEQ :REPLCD
          CMP #"""
          BEQ QUO
          CMP #"'"
          BEQ QUO
          BIT SPMSK      ;Test for space or inv space
          BEQ :REPLCD
          CMP #"         ;"
          BNE JR
:REPLCD   TYA
          BEQ BADVAR
          INC LEVEL
          LDX LEVEL
          INX
          PLA
          TAY
ESTPNT    CPX MACLEV     ;Get adrs of var names
          BLT :LLV
          BNE OA
:LLV      LDA LVPNT,X
          STA LVAR
          LDA LVPNT+MX,X
          JMP SWB
OA        LDA OPNT       ;Current operand adrs
          STA LVAR
          LDA OPNT+1
SWB       BEQ BADVAR
          STA LVAR+1
          LDX #-1        ;For final exit, from GTLIN
          RTS            ; to force branch

QUO       STY PL
          JSR FNDNX
          STY PL+1
          LDY PL
]LOOP     LDA (LVAR),Y   ;Put literal in opnd
          JSR SETOPND
          CPY PL+1
          INY
          BLT ]LOOP
          BGE REPT

FNDNX     INY            ;Skip over literal
          STA PAR
          LDA (LVAR),Y
]LOOP     CMP #$8D
          BEQ BADVAR
          INY
          LDA (LVAR),Y
          CMP PAR
          BNE ]LOOP
          RTS
