Extracted Merlin Assembler Sources
===

I was curious about what assemblers historically existed for the Apple
//. I found
[this webpage](https://www.callapple.org/vintage-apple-computers/apple-ii/8-bit-merlin-ide-version-2-59-source-now-documented-and-available/)
which linked to a file named [VALIDATE.PO](ftp://public.asimov.net/pub/apple_II/images/programming/assembler/merlin/VALIDATE.PO).

I guessed that it was
a [ProDOS](https://en.wikipedia.org/wiki/Apple_ProDOS) formatted disk,
so headed over
to
[this online Apple // emulator](https://www.scullinsteel.com/apple2/),
put a copy of `ProDOS_2_4_2.dsk` that I found
in
[this archive](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/masters/prodos/) in
Disk Drive 1, put `VALIDATE.PO` in Disk Drive 2, selected
`BASIC.SYSTEM` and typed `CAT,D2` (meaning: "list file catalog, drive
2") and saw a bunch of `.S` files. Only later did I realize that I
didn't actually have to go into the BASIC prompt, and could have just
hit the `6` key to toggle over to `Slot 6 Disk 2`, instead of the
default `Slot 6, Disk 1`.

The next task was to try to actually extract the files. I
tried [dskalyzer](https://github.com/paleotronic/dskalyzer) to but
couldn't quite succeed at using it after `go build`. I did
subsequently succeed at
using [Apple Commander](http://applecommander.sourceforge.net/), and
wrote a little perl script to extract all of the files since I
couldn't find documentation for bulk extraction.

The extracted files are in the directory `validate`. Looking at the
instructions in `READMEFIRST`, I seem to need something called
`AppleWin`, and an emulator that supports hard drives, to actually run
`MERLIN.SYSTEM`. If I try to do so from the javascript emulator
implementation, I get an error message "Unsupported Configuration".
