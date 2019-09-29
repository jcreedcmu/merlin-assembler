
*--------------------------------
* Merlin interpreter global page:
*--------------------------------

          ERR *-$BE00

OPARMS    DFB 3          ;Parms for OPEN
          DA DOSFNAM     ;Always
          DA ORDBUF      ;Always
OREF      DFB 0

RWPARMS   DFB 4          ;Parms for R/W (PUT/SAV)
RWREF     DFB 0
RWBUF     DA $905
RWCNT     DA 44          ;44 parms
RWGOT     DA 0

ODPARMS   DFB 3          ;Parms for DSK open only
          DA DOSFNAM     ;Always
          DA DSKBUF      ;Always
ODREF     DFB 0

DSKPARMS  DFB 4          ;Parms for DSK only!
DSKREF    DFB 0
          DA BYTE        ;Always
          DA 1           ;Always
          DA 1

BYTE      BRK            ;Put byte to write here

CLSPARMS  DFB 1          ;Close & flush
CLSREF    DFB 0

MRKPARMS  DFB 2          ;SETMARK & GETEOF usage
MRKREF    DFB 0
MRKPOS    DFB 0,0,0      ;3 byte position

NEWPARMS  DFB 3
NEWREF    DFB 0
NEWENBL   DFB 0
NEWCHAR   DFB 0

DESPARMS  DFB 1          ;Parms for DESTROY, SETPREFIX
          DA DOSFNAM     ;Always

DRIVER    JMP 0
          DS -2
RAMDRADR  DA 0

RENPARMS  DFB 2          ;Rename usage
          DA DOSFNAM     ;Always
RENPATH2  DA IN          ;Low byte must be set

INFPARMS  DFB 10
INFPATH   DA DOSFNAM
INFACC    DFB $C3
INFTYPE   DFB 6
INFAUX    DA 0           ;Length of code in LNK files
INFSTYP   DFB 0
INFBLKS   DA 0
INFDATE   DA 0
INFTIME   DA 0
INFCDATE  DA 0
INFCTIME  DA 0

CREPARMS  DFB 7          ;Parms for CREATE
          DA DOSFNAM     ;Always
          DFB $C3        ;Always
CRETYPE   DFB 6
          DA 0           ;CREAUX not used
CRESTYP   DFB 1          ;1=ord file, $D=dir file
CREDATE   DA 0
CRETIME   DA 0

DEVDFLT   DFB $E0        ;Device # for = syntax
OBJTYPE   DFB 6

ONLPARMS  DFB 2
ONLUNIT   DFB 0
          DA DSKBUF      ;Always

BMPARMS   DFB 3          ;Bit map read parms
BMUNIT    DFB $60        ; (these parms not now used)
          DA DSKBUF
BMPNT     DA 0

LOADTYP   DFB 4          ;Text file

BLEN      DA 0           ;Used by linker

GPXPARMS  DFB 1          ;For GETPFIX only
          DA DSKBUF      ;Always

SWAPPNT   DA $901
          DA $AA00       ;Value doesn't matter
          DA $901

RNPARMS   DFB 3          ;For linker name file (NEWLINE)
RNREF     DFB 0
          DFB $FF        ;Enable new line
          DFB 0          ;Stop at 0 mark

RCPARMS   DFB 1          ;Close for linker name file
RCREF     DFB 0

RRPARMS   DFB 4          ;Read for linker name file
RRREF     DFB 0
          DA IN+$80      ;Buffer
          DA $40         ;Read count (max)
          DA 0           ;Count got (not used)

DIPARMS   DFB 1          ;Deallocate interrupts
DIUNIT    DFB 4

XFLAG     BRK            ;Ovflo bit set if Merlin
                         ; is in main memory
RAMNUM    DFB 0          ;/RAM device found on
                         ; entry stored here
          ERR \$BE80
          DS $BE80-*

DOSFNAM   STR 'PARMS'
          ASC " Copyright (C) 1984 "
          ASC "by Glen E. Bredon & "
          ASC "RWP, Santee, CA"8D8D8D
          ERR FILENAME-DOSFNAM-$40
FILENAME  HEX 8D
          ASC " Copyright (C) 1984 "
          ASC " by Glen E. Bredon &"
          ASC " RWP, Santee, Calif."8D8D8D

          ERR *-$BF00
