#!/usr/bin/perl

use File::Path qw(make_path);

$ACMD = "java -jar /tmp/AppleCommander-1.3.5.jar";
@ACMD = ("java","-jar","/tmp/AppleCommander-1.3.5.jar");
$DISK = "/tmp/validate.po";
$OUTDIR = "/tmp/validate";

open PIPE, "$ACMD -l $DISK |";

$dir = "";

while(<PIPE>) {
	 if (/([ *]+)([^ *]+) ([^ *]+) ([^ ]{3}) /) {
		  my ($space, $file, $type) = ($1, $2, $3);
		  if ($type eq 'DIR') {
				$dir = $file;
				next;
		  }
		  my $indent = length $space;
		  my $filedir = $indent == 4 ? "$dir" : "";

		  my $writedir = $indent == 4 ? "$OUTDIR/$dir" : "$OUTDIR";
		  my $writefile = "$writedir/$file";
		  print "Writing to file $writefile\n";
		  die if $writefile =~ /\.\./; # avoid zipslip!

		   make_path($writedir);
		   open(my $IN, "-|", @ACMD, '-e', $DISK, $file) or die $!;
		   open(my $OUT, ">", $writefile);
		   while (my $x = <$IN>) {
				 print $OUT $x;
		   }
		  close $OUT;
	 }
}
