
* ProDOS Global Page:

          DUM $BF00

MLI       JMP *
          JMP *          ;RTS
          JMP *          ;RTS
          JMP *          ;SYSERR
          JMP *          ;SYSDEATH
          DFB 0          ;Error code

DEVADR01  DA 0           ;No device
          DA 0           ;Slot 1, Drive 1
          DA 0           ;Slot 2, Drive 1
          DA 0           ;Slot 3, Drive 1
          DA 0           ;Slot 4, Drive 1
          DA 0           ;Slot 5, Drive 1
          DA 0           ;Slot 6, Drive 1
          DA 0           ;Slot 7, Drive 1
          DA 0           ;Slot 0 reserved
          DA 0           ;Slot 1, Drive 2
          DA 0           ;Slot 2, Drive 2
DEVADR32  DA 0           ;/RAM
          DA 0           ;Slot 4, Drive 2
          DA 0           ;Slot 5, Drive 2
          DA 0           ;Slot 6, Drive 2
          DA 0           ;Slot 7, Drive 2

DEVNUM    DFB $60        ;Last device (s & d) used
DEVCNT    DFB 1          ;# of active devices
DEVLST    DFB $E0,$60    ;Search list
          DFB 0,0,0,0
          DFB 0,0,0,0
          DFB 0,0,0,0

          ASC "(C) 1983 APPLE COMPUTER!"

                         ;Mem map of lower 48:
BITMAP    HEX CF00000000000000
          HEX 0000000000000000
          HEX 0000000000000001

BUFFER1   DA 0,0,0,0,0,0,0,0

INTRUPT1  DA 0,0,0,0

INTAREG   DFB 0
INTXREG   DFB 0
INTYREG   DFB 0
INTSREG   DFB 0
INTPREG   DFB 0
INTBNKID  DFB 0
INTADDR   DA 0

DATE      DA 0
TIME      DA 0
LEVEL     DFB 0
BUBIT     DFB 0
          DA 0

MACHID    DFB 0
SLTBYT    DFB 0
PFIXPTR   DFB 0
MLIACTV   DFB 0
CMDADR    DA 0
SAVEX     DFB 0
SAVEY     DFB 0

          ERR *-$BFA0
          DS $BFFC-$BFA0 ;Misc stuff

INTHAND   = $BFEB

IBAKVER   DFB 0          ;Earliest MLI version
IVERSION  DFB 0          ;Interpreter version

KBAKVER   DFB 0          ;Min version compat
KVERSION  DFB 0          ;Version # (Release ID)
          ERR *-$C000
          DEND
