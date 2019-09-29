ENDPUT    STA PUTFLG
          TRDB SPSAV     ;SPNT
          JMP START

GTLIN     LDA #' '
          LDY #OPERAND-LABEL
]LOOP     DEY
          STA LABEL,Y
          BNE ]LOOP
          STY SPCNT
          STY TABCNT
          STY PACKR
          STY PNFLG
          STY OPNDLEN
          STY OPNT+1     ;For error detection
          STY OFFSET
          LDA MACLEV     ;No linnum inc in macro
          BNE MVLN
          BIT PUTFLG     ;Use others in PUT
          BMI :INL
          LDX #LINNUM-PLIN
:INL      INC PLIN,X
          BNE :ZX
          INC PLIN+1,X
:ZX       TAX            ;0
MVLN      LDA (SPNT,X)
          BEQ ENDPUT
          STA LABEL
          CMP #"*"       ;LABEL will be - only
          BEQ MVOPND     ;when "*" or empty line
          CMP #"         ;" ;or ";".
          BEQ MVOPND
          CMP #$FF
          BEQ END
]LOOP     JSR GTSRC
          CMP #'@'
          BNE :SL
          SBC LUPCNT
          CMP #'Z'+1
          BGE LABERR
:SL       STA LABEL,Y
          CMP #' '
          BEQ MVOPC
          INY
          STY LEN        ;May exit at GTSRC
          CPY #14        ;Max len=13 since macro
          BEQ LABERR     ; name would add 2
          CMP #'0'       ;Legal label chr?
          BGE ]LOOP
LABERR    ERX lab
          JMP ERR2
MVOPC     JSR OVRSPC
          CMP #'         ;'
          BEQ MVOPND
MVOP      JSR GTSRC
          CPY #13        ;Must leave spc to
          BGE :NY        ;signal opcode end
          STA OPCODE,Y
:NY       INY
          CMP #' '
          BNE MVOP
          JSR OVRSPC
          LDA DOFL
          CMP #1
MVOPND    ROR TEMP       ;Flags DO off or comment line
          TRDB SPNT      ;OPNT
          JSR OA
          LDA MACLEV
          STA LEVEL
          DEY            ;=-1
CNTSP     INY
]LOOP     LDA (LVAR),Y
          CMP #$8D
          BEQ GOBACK
          JSR BRACKET    ;Convert local vars
          BIT OFFSET     ;Real spc yet?
          BMI CNTSP      ;Branch if so
          INX            ;Did replacement occur?
          BEQ CNTSP      ;Branch if so
          CMP (LVAR),Y   ;Inv spc now?
          INY
          BLT :IV        ;Branch if not
          LDA (LVAR),Y
          CMP #"         ;"
          BEQ :RO
          INC SPCNT      ;Count for tabbing
          BNE ]LOOP
:IV       CMP #' '       ;Real spc now?
          BNE ]LOOP
:RO       ROR OFFSET     ;Stop counting if so
          BMI ]LOOP      ;Always

END       LDX PASNUM
          BNE DONE
          INC PASNUM
          STX PUTFLG     ;If PUT file has END
          BNE :SYEND     ;Always
]LOOP     JSR NXTSYM
:SYEND    JSR GTLEN      ;Find end of sym tbl
          BNE ]LOOP
          TRDB SYMPNT    ;SYMEND
          INCD SYMEND    ;Dict & XREF use
          JMP STPT

GOBACK    TYA
          ADC SPNT       ;Carry is set
          STA SPNT
          BCC :NI
          INC SPNT+1
:NI       RTS

BYTPRN    JSR PRDEC
          JSR SENDMSG
          ASC "bytes, Errors: "00
          LDA ERCOUNT
          CLC
          ADC DUPCNT
          TAX
          JMP PRDEC+2    ;NH now 0

DONE      JSR SENDMSG
          HEX A08DA08D
          ASC "--End assembly, "00
          JSR ADDLEN
          LDX BYTCNT     ;A has BTYCNT+1
          JSR BYTPRN
QUIT      JSR CLOSE
          LDA RELFLAG
          ORA ORGFLG     ;Defeat obj save
          STA ORGFLG     ; if a rel file
          POKE DSKNAMSV  ;$8D ;For SWAP
