                         ; 5/25/1986
                         ; 3/1/2006
                         ; 6/13/2011

_lib      equ $9000
_local    equ 2
_sp       equ 4
_t        equ 16
_r0       equ _t
_r1       equ _t+2
_mli      equ $bf00
          dsect
          org $0200
CONBUF    ds 128
          org $8F80
CLPCNT    db 0           ; Count of command line parameters
CLPADR    dw 0,0,0,0,0,0,0,0 ; Addresses of parameters
CLPSTR    ds 111         ; Storage for parameter strings
          DEND

          lst off

_abi      macro
          jsr _lib+$15f
          endm

_abr      macro
          jsr _lib+$162
          endm

_adi      macro
          jsr _lib+6
          endm

_adr      macro
          jsr _lib+$54
          endm

_and      macro
          jsr _lib+$14d
          endm

_ana      macro
          jsr _lib+$180
          endm

_arc      macro
          jsr _lib+$111
          endm

_beq      macro
          jsr _lib+$cf
          beq _&1
          endm

_cgb      macro
          lda _global-&1
          cmp _global-&2
          beq _&3
          endm

_cgw      macro
          lda _global-&1
          cmp _global-&2
          bne *+10
          lda _global-&1+1
          cmp _global-&2+1
          beq _&3
          endm

_chk      macro
          lda #>&1
          ldy #<&1
          jsr _lib+3
          lda #>&2-&1
          ldy #<&2-&1
          jsr _lib+9
          endm

_chn      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$21
          endm

_clb      macro
          lda #>_&4+5-&1
          ldy #<_&4+5-&1
          jsr _lib+$a8
          lda #>_&4+5-&2
          ldy #<_&4+5-&2
          jsr _lib+$a8
          jsr _lib+$cf
          beq _&3
          endm

_clw      macro
          lda #>_&4+5-&1
          ldy #<_&4+5-&1
          jsr _lib+$ab
          lda #>_&4+5-&2
          ldy #<_&4+5-&2
          jsr _lib+$ab
          jsr _lib+$cf
          beq _&3
          endm

_cos      macro
          jsr _lib+$129
          endm

_ddo      macro
          lda #>_&1
          ldy #<_&1
          jsr _lib+$12
          endm

_dgb      macro
          dec _global-&1
          endm

_dgw      macro
          lda _global-&1
          bne *+5
          dec _global-&1+1
          dec _global-&1
          endm

_dis      macro
          jsr _lib+$114
          endm

_dlb      macro
          lda #>_&2+5-&1
          ldy #<_&2+5-&1
          jsr _lib+$1b
          endm

_dlw      macro
          lda #>_&2+5-&1
          ldy #<_&2+5-&1
          jsr _lib+$24
          endm

_dvi      macro
          jsr _lib+$18
          endm

_dvr      macro
          jsr _lib+$5d
          endm

_end      macro
_&1       equ &2
          lda #>&2+5
          ldy #<&2+5
          jmp _lib+$66
          endm

_eof      macro
          jsr _lib+$12c
          endm

_eol      macro
          jsr _lib+$ff
          endm

_eq       macro
          jsr _lib+$69
          endm

_eqr      macro
          jsr _lib+$84
          endm

_eqs      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$ed
          endm

_equ      macro
_&1       equ &2
          endm

_err      macro
          lda #&1
          jsr _lib+$144
          endm

_exp      macro
          jsr _lib+$126
          endm

_fld      macro
          clc
          lda 0,x
          adc #>&1
          sta 0,x
          lda 1,x
          adc #<&1
          sta 1,x
          endm

_fln      macro
          jsr _lib+$42
          endm

_flt      macro
          jsr _lib+$3f
          endm

_fun      macro
          sec
          lda _sp
          sbc #>&1
          sta _sp
          lda _sp+1
          sbc #<&1
          sta _sp+1
          endm

_gei      macro
          jsr _lib+$10e
          endm

_ger      macro
          jsr _lib+$93
          endm

_ges      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$fc
          endm

_get      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$b4
          endm

_go       macro
          lda #&2
          jsr _lib+$153
          jmp _&1
          endm

_gti      macro
          jsr _lib+$102
          endm

_gtr      macro
          jsr _lib+$8d
          endm

_gts      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$f6
          endm

_fjp      macro
          lda #>_&1
          ldy #<_&1
          jsr _lib+$147
          endm

_igb      macro
          inc _global-&1
          endm

_igw      macro
          inc _global-&1
          bne *+5
          inc _global-&1+1
          endm

_ilb      macro
          lda #>_&2+5-&1
          ldy #<_&2+5-&1
          jsr _lib+$13e
          endm

_ilw      macro
          lda #>_&2+5-&1
          ldy #<_&2+5-&1
          jsr _lib+$13b
          endm

_inp      macro
          lda #>$befe
          ldy #<$befe
          jsr _lib+$c
          endm

_jmp      macro
          jmp _&1
          endm

_jsr      macro
          jsr _&1
          endm

_lbl      macro
_&1       equ *
          endm

_lcr      macro
          jsr _lib+$3c
          endm

_lcw      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$c
          endm

_ldb      macro
          lda (0,x)
          sta 0,x
          lda #0
          sta 1,x
          endm

_ldr      macro
          jsr _lib+$45
          endm

_ldw      macro
          jsr _lib+$14a
          endm

_lei      macro
          jsr _lib+$132
          endm

_ler      macro
          jsr _lib+$90
          endm

_les      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$f9
          endm

_lga      macro
          lda #>_global-&1
          ldy #<_global-&1
          jsr _lib+$c
          endm

_lgb      macro
          dex
          dex
          lda _global-&1
          sta 0,x
          lda #0
          sta 1,x
          endm

_lgw      macro
          dex
          dex
          lda _global-&1
          sta 0,x
          lda _global-&1+1
          sta 1,x
          endm

_lia      macro
          dex
          dex
          lda _local
          sta _t
          lda _local+1
          sta _t+1
          ldy #0
          lda (_t),y
          iny
          cmp #&2
          beq *+16
          lda (_t),y
          pha
          iny
          lda (_t),y
          sta _t+1
          pla
          sta _t
          jmp *-20
          clc
          lda _t
          adc #>_&3+5-&1
          sta 0,x
          iny
          lda _t+1
          adc #<_&3+5-&1
          sta 1,x
          endm

_lin      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$ba
          endm

_ln       macro
          jsr _lib+$123
          endm

                         ; &1 = lex level
                         ; &2 = stack size label
                         ; &3 = param size

_lnk      macro
          lda #>_&2+5-&3
          ldy #<_&2+5-&3
          jsr _lib+$63
          ldy #0
          lda #&1
          sta (_sp),y
          endm

_lla      macro
          lda #>_&2+5-&1
          ldy #<_&2+5-&1
          jsr _lib+$141
          endm

_lpa      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$17d
          endm

_lsa      macro
          lda #>*+10
          ldy #<*+8
          jsr _lib+$c
          jmp *+&1+3
          endm

_lti      macro
          jsr _lib+$105
          endm

_ltr      macro
          jsr _lib+$8a
          endm

_lts      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$f3
          endm

_max      macro
          lda #>&1
          cmp 0,x
          lda #<&1
          sbc 1,x
          bcs *+7
          lda #2
          jsr _lib+$144
          endm

_min      macro
          sec
          lda 0,x
          sbc #>&1
          sta 0,x
          lda 1,x
          sbc #<&1
          sta 1,x
          endm

_mod      macro
          jsr _lib+$6c
          endm

_mov      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$60
          endm

_mpi      macro
          jsr _lib+$15
          endm

_mpr      macro
          jsr _lib+$5a
          endm

_ndx      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$9c
          endm

_ndxb     macro
          clc
          lda 2,x
          adc 0,x
          sta 2,x
          lda 3,x
          adc 1,x
          sta 3,x
          inx
          inx
          endm

_ndxw     macro
          asl 0,x
          rol 1,x
          clc
          lda 2,x
          adc 0,x
          sta 2,x
          lda 3,x
          adc 1,x
          sta 3,x
          inx
          inx
          endm

_ne       macro
          jsr _lib+$16e
          endm

_ner      macro
          jsr _lib+$87
          endm

_nes      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$f0
          endm

_new      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$117
          endm

_ngi      macro
          jsr _lib+$96
          endm

_ngr      macro
          jsr _lib+$51
          endm

_odd      macro
          jsr _lib+$171
          endm

_not      macro
          jsr _lib+$36
          endm

_or       macro
          jsr _lib+$150
          endm

_ora      macro
          jsr _lib+$183
          endm

_out      macro
          lda #>$beff
          ldy #<$beff
          jsr _lib+$c
          endm

_pag      macro
          jsr _lib+$16b
          endm

_prd      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$165
          endm

_put      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$b7
          endm

_rdc      macro
          jsr _lib+$4b
          endm

_rdf      macro
          jsr _lib+$11a
          endm

_rdi      macro
          jsr _lib+$9f
          endm

_rdl      macro
          jsr _lib+$138
          endm

_rdr      macro
          jsr _lib+$a2
          endm

_rdv      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$174
          endm

_res      macro
          jsr _lib+$ae
          endm

_rew      macro
          jsr _lib+$b1
          endm

_rds      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$39
          endm

_rou      macro
          jsr _lib+$12f
          endm

_sbi      macro
          jsr _lib+$f
          endm

_sbr      macro
          jsr _lib+$57
          endm

_see      macro
          jsr _lib+$1e
          endm

_sgb      macro
          lda 0,x
          sta _global-&1
          inx
          inx
          endm

_sgw      macro
          lda 0,x
          sta _global-&1
          lda 1,x
          sta _global-&1+1
          inx
          inx
          endm

_sin      macro
          jsr _lib+$e7
          endm

_slb      macro
          lda #>_&2+5-&1
          ldy #<_&2+5-&1
          jsr _lib+$2a
          endm

_slw      macro
          lda #>_&2+5-&1
          ldy #<_&2+5-&1
          jsr _lib+$2d
          endm

_sqi      macro
          jsr _lib+$108
          endm

_sqr      macro
          jsr _lib+$10b
          endm

_sqt      macro
          jsr _lib+$120
          endm

_stb      macro
          jsr _lib+$30
          endm

_str      macro
          jsr _lib+$48
          endm

_stw      macro
          jsr _lib+$33
          endm

_scc      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$168
          endm

_tdo      macro
          lda 0,x
          cmp 2,x
          lda 3,x
          eor #$80
          sta _t
          lda 1,x
          eor #$80
          sbc _t
          bcs *+9
          inx
          inx
          inx
          inx
          jmp _&1
          endm

_tru      macro
          jsr _lib+$4e
          endm

_wrb      macro
          jsr _lib+$7e
          endm

_wrc      macro
          jsr _lib+$7b
          endm

_wre      macro
          lda #&1
          jsr _lib+$17a
          endm

_wrf      macro
          jsr _lib+$11d
          endm

_wri      macro
          jsr _lib+$72
          endm

_wrl      macro
          jsr _lib+$6f
          endm

_wrr      macro
          jsr _lib+$75
          endm

_wrs      macro
          lda #>&1
          ldy #<&1
          jsr _lib+$78
          endm

_wrv      macro
          lda #>0-&1
          ldy #<0-&1
          jsr _lib+$177
          endm

_wrx      macro
          jsr _lib+$81
          endm

_zdf      macro
          jsr _lib+$156
          endm

_zem      macro
          jsr _lib+$e4
          endm

_zeq      macro
          jsr _lib+$d8
          endm

_zin      macro
          jsr _lib+$cc
          endm

_zld      macro
          jsr _lib+$c0
          endm

_zne      macro
          jsr _lib+$db
          endm

_znt      macro
          jsr _lib+$159
          endm

_zsb      macro
          jsr _lib+$de
          endm

_zsg      macro
          jsr _lib+$c6
          endm

_zsp      macro
          jsr _lib+$e1
          endm

_zsr      macro
          jsr _lib+$c9
          endm

_zst      macro
          jsr _lib+$c3
          endm

_zun      macro
          jsr _lib+$15c
          endm

          lst on

          ifndef _SystemFile
          ifndef _UsesHires
_global   equ $8F80
          org $800
          endif
          endif

          ifndef _SystemFile
          ifdef _UsesHires
_global   equ $2000
          org $4000
          endif
          endif

          ifdef _SystemFile
          ifndef _UsesHires
          ldx #0
_m1       lda $2000,x
          sta $be00,x
          inx
          bne _m1
          jmp $be0e
          lda #>$2000+_m3
          sta _r0
          lda #<$2000+_m3
          sta _r0+1
          lda #>$800
          sta _r1
          lda #<$800
          sta _r1+1
          ldx #<_lomem-_start+255
          ldy #0
_m2       lda (_r0),y
          sta (_r1),y
          iny
          bne _m2
          inc _r0+1
          inc _r1+1
          dex
          bne _m2
          jmp $800
_m3
_global   equ $8F80
          sys
          org $800
          endif
          endif

          ifdef _SystemFile
          ifdef _UsesHires
          lda #>_lomem-$4000+$2000+_mov3
          sta _r0
          lda #<_lomem-$4000+$2000+_mov3
          sta _r0+1
          lda #>_lomem
          sta _r1
          lda #<_lomem
          sta _r1+1
          ldx #<_lomem-$4000+255
          ldy #$ff
_mov1     dec _r0+1
          dec _r1+1
_mov2     lda (_r0),y
          sta (_r1),y
          dey
          cpy #$ff
          bne _mov2
          dex
          bne _mov1
          jmp $4000
_mov3
_global   equ $2000
          sys
          org $4000
          endif
          endif

_start    ldx #$ff
          txs

          jsr _ParseCmdLine

          ifndef _oldver
          lda #%00000000
          ldx #24-1
qtfb      sta $BF58,X
          dex
          bnm qtfb
          inc $BF58+23
          ldx #%11001111
          stx $BF58
          endif

          jsr _LoadPascalLibrary

          ifdef _UsesHires
          lda #>$800
          ldy #<$800
          else
          lda #>_lomem
          ldy #<_lomem
          endif

          jsr _lib

          lda #>_global
          sta _sp
          lda #<_global
          sta _sp+1

          ldx #0
          jsr _1

          jmp _quit

                         ;---------------------
                         ; load pascal library
                         ;---------------------

_LoadPascalLibrary

                         ; set up parameters for prodos open call

          lda #3
          sta _t

          lda #0
          sta _t+3
          lda #<_lomem+255
          sta _t+4

                         ; branch if less than 128k ram

          lda $bf98
          and #$30
          cmp #$30
          bne _lpl1

                         ; try ram disk path

          lda #>ypath
          sta _t+1
          lda #<ypath
          sta _t+2

          jsr _mli       ; prodos "open" call
          db $c8
          dw _t
          beq ylib4

                         ; use the directory from which this program was loaded

_lpl1

          ldy $280
          bne *+5
          jmp yy1

                         ; backup over program name

_lpl2

          dey
          beq _lpl3
          lda $280,y
          and #$7f
          cmp #'/
          bne _lpl2

                         ; append "lib"

_lpl3

          iny
          lda #'l
          sta $280,y

          iny
          lda #'i
          sta $280,y

          iny
          lda #'b
          sta $280,y

          sty $280

                         ; try opening the file again

          lda #>$280
          sta _t+1
          lda #<$280
          sta _t+2

          jsr _mli
          db $c8
          dw _t
          beq ylib4

          ifndef _SystemFile
          jsr _SysDir
          endif

          bne yy1

                         ; read

ylib4     lda #4
          sta _t

          lda _t+5
          sta _t+1

          lda #>_lib
          sta _t+2
          lda #<_lib
          sta _t+3

          lda #>$ffff
          sta _t+4
          lda #<$ffff
          sta _t+5

          jsr _mli
          db $ca
          dw _t
          bne yy1

                         ; close

          lda #1
          sta _t

          lda #0
          sta _t+1

          jsr _mli
          db $cc
          dw _t
          bne yy1

          rts

                         ; error load pascal library

yy1       ldx #0
yy2       inx
          lda yy3,x
          ora #$80
          jsr cout
          cpx yy3
          bne yy2
          jsr crout
          ifndef _oldver
yy4       lda $C000      ; new
          bnm yy4        ; new
          sta $c010      ; new
          endif
          jmp _quit
yy3       str 'error loading pascal library'

ypath     str '/ram/bin/lib'

_ParseCmdLine
                         ;
                         ; Clear count
                         ;
          lda #0
          sta CLPCNT
                         ;
                         ; Set source pointer
                         ;
          ldx #<CONBUF
          ldy #>CONBUF
          stx _T+1
          sty _T
                         ;
                         ; Set source index
                         ;
* ldy #0
                         ;
                         ; Set destination offset
                         ;
          ldx #0
                         ;
                         ; Skip leading spaces
                         ;
loop1     jsr skplsp
                         ;
                         ; Save offset to start of parameter
                         ;
          stx cpbase
                         ;
                         ; Increment destination offset
                         ;
loop2     inx
                         ;
                         ; Get current command line character
                         ;
          lda (_T),Y
                         ;
                         ; Remove high order bit
                         ;
          and #%01111111
                         ;
                         ; Branch if end of parameter
                         ;
          cmp #$20
          be ep
                         ;
                         ; Branch if end of command line
                         ;
          cmp #$0D
          be eocl
                         ;
                         ;
                         ;
          sta CLPSTR,X
                         ;
                         ;
                         ;
          iny
                         ;
                         ; Unconditional branch
                         ;
          bne loop2
                         ;
                         ;
                         ;
ep        jsr finp
                         ;
                         ; Unconditional branch
                         ;
          clv
          bnv loop1
                         ;
                         ;
                         ;
eocl      jsr finp
                         ;
                         ;
                         ;
          rts
******************************
                         ;
                         ;
                         ;
skplsp    lda (_T),Y
          cmp #$A0
          bne skpex
          iny
          bnz skplsp
skpex     rts
******************************
                         ;
                         ; Save offset
                         ;
finp      txa
          pha
                         ;
                         ;
                         ;
          lda CLPCNT
          asl a
          tax
          clc
          lda #>CLPSTR
          adc cpbase
          sta CLPADR,X
          lda #<CLPSTR
          sta CLPADR+1,X
                         ;
                         ;
                         ;
          inc CLPCNT
                         ;
                         ;
                         ;
          pla
          pha
                         ;
                         ;
                         ;
          seb
          sbb cpbase
          ldx cpbase
          sta CLPSTR,X
                         ;
                         ;
                         ;
          pla
          tax
                         ;
                         ;
                         ;
          rts
                         ;
                         ;
                         ;
cpbase    db 0

                         ;-----------------------------------------------
                         ; see if the library is in the system directory
                         ;-----------------------------------------------

          ifndef _SystemFile

_SysDir   ldy #$ff

_sysd1    iny

          lda $300,y
          sta $280,y

          cpy $300
          bne _sysd1

          iny
          lda #'l
          sta $280,y

          iny
          lda #'i
          sta $280,y

          iny
          lda #'b
          sta $280,y

          sty $280

          lda #>$280
          sta _t+1
          lda #<$280
          sta _t+2

          jsr _mli
          db $c8
          dw _t

          rts

          endif

cout         equ     $fded
crout       equ     $fd8e
rdkey       equ     $fd0c

                         ;--------------
                         ; quit routine
                         ;--------------

_quit     jsr _mli
          db $65
          dw *+2
          db 4
          db 0
          dw 0
          db 0
          dw 0
