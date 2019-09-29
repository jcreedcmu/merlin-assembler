*--------------------------------------
*       BLOAD & BSAVE   macros
* Requires parm tables OPARMS, RWPARMS,
* CLSPARMS, INFPARMS, MRKPARMS
*--------------------------------------

* MLI call codes:

setinfo   = $C3
getinfo   = $C4
open      = $C8
newline   = $C9
read      = $CA
write     = $CB
close     = $CC
seteof    = $D0
geteof    = $D1

MLI       = $BF00

MOVD      MAC
          LDA ]1
          STA ]2
          LDA ]1+1
          STA ]2+1
          <<<

OPEN      MAC
          JSR MLI
          DFB open
          DA OPARMS
          BCS ERR
          LDA OREF
          STA RWREF
          STA CLSREF
          STA MRKREF
          <<<

GETEOF    MAC
          JSR MLI
          DFB geteof
          DA MRKPARMS
          BCS ERR
          MOVD MRKPOS    ;RWCNT
          <<<

SETEOF    MAC            ;Use after a write
          MOVD RWGOT     ;MRKPOS ;Assume MRKPOS+2=0
          JSR MLI
          DFB seteof
          DA MRKPARMS
          BCS ERR
          <<<

GETINFO   MAC
          LDA #10
          STA INFPARMS
          JSR MLI
          DFB getinfo
          DA INFPARMS
          BCS ERR
          <<<

SETINFO   MAC
          LDA #7
          STA INFPARMS
          JSR MLI
          DFB setinfo
          DA INFPARMS
          BCS ERR
          <<<

READTO    MAC            ;READTO adrpnt or READTO *
          IF *=]1
          MOVD INFAUX    ;RWBUF
          ELSE
          MOVD ]1        ;RWBUF
          FIN
          JSR MLI
          DFB read
          DA RWPARMS
          BCS ERR
          <<<

WRITE     MAC            ;WRITE adrpnt;lenpnt
          IF *=]1
          ELSE
          MOVD ]1        ;RWBUF
          FIN
          IF *=]2
          ELSE
          MOVD ]2        ;RWCNT
          FIN
          JSR MLI
          DFB write
          DA RWPARMS
          BCS ERR
          <<<

CLOSE     MAC
          JSR MLI
          DFB close
          DA CLSPARMS
          BCS ERR
          <<<

BLOAD     MAC            ;BLOAD "path";adrspnt(*)
          SETNAME ]1
          OPEN
          GETEOF
          GETINFO
          READTO ]2
          CLOSE
          <<<

BSAVE     MAC            ;BSAVE "path";type;adrpnt;lenpnt
          SETNAME ]1
          GETINFO
          IF *=]2
          ELSE
          LDA #]2
          STA INFTYPE
          FIN
          OPEN
          WRITE ]3       ;]4
          SETEOF
          CLOSE
          IF *=]2
          ELSE
          SETINFO
          FIN
          <<<

SETNAME   MAC
          LDA #THISNAM
          STA ONAME
          STA INFNAME
          LDA #>THISNAM
          STA ONAME+1
          STA INFNAME+1
          BNE EOM        ;Always
THISNAM   STR ]1
ERR       JMP ERROR
EOM
          <<<

FILEINFO  MAC
          SETNAME ]1
          GETINFO
          <<<
