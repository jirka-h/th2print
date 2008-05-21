#!/usr/bin/perl -w
#Usage toc.pl index.html

use strict;
use File::Basename;
my @suffixes=(".html",".htm");
my $name_main;
my $name_frame;
my $name_toc;
my $toc;
my $frame;
my $main;
my $counter=0;

while(<>) {

  if ( $.==1) {
    print STDERR "Processing file $ARGV\n";
    my ($name_pur,$path,$suf) = fileparse($ARGV,@suffixes);
    

    $name_frame = $name_pur . "_frame" . $suf;
    $name_toc =  $name_pur . "_toc" . $suf;
    $name_main = $name_pur . "_main" . $suf;

    $frame = $path . "/" . $name_frame;
    $toc = $path . "/" . $name_toc;
    $main = $path . "/" . $name_main;

    print STDERR "Output $frame, $toc, $main \n";
    
    open (TOC_FH,">$toc") or die "Cannot open $toc\n";
    open (FRAME_FH,">$frame") or die "Cannot open $frame\n";
    open (MAIN_FH,">$main") or die "Cannot open $main\n";
    
    print FRAME_FH << "FOO";
<HTML>
<frameset cols="400,*">
  <FRAME SRC="$name_toc" NAME="TOC">
  <FRAME SRC="$name_main" NAME="main" marginwidth="10" SCROLLING="yes">
  <NOFRAMES>
  <BODY>
  <P>Viewing this page requires a browser capable of displaying frames. </P>
  </BODY>
  </NOFRAMES>
</FRAMESET>

</HTML>
FOO
    close (FRAME_FH)  or die "Cannot close $frame\n";

    print TOC_FH << "FOO1";
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
    <base target="main">
</head>
<body>

FOO1
  }
 
  if (m&<h3>\s*(.*?)\s*</h3>&) {
    ++$counter;
    print TOC_FH "<a href=\"$name_main#$counter\">$1</a><br>\n";
    print MAIN_FH "<a name=$counter> </a>\n";
  }
  print MAIN_FH;


  if (eof) {
    print TOC_FH << "FOO2";
</body>
</html>
FOO2
    close (TOC_FH) or die "Cannot close $toc\n";
    close (ARGV) or die "Cannot close $ARGV\n"; #needed only when line counting should work for each input file separately
    print STDERR "End of processing of file $ARGV \n";
  }

}

