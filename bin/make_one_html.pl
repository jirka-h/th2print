#!/usr/bin/perl -w
# Usage feedthrou.pl index.html page*html > print.html

sub count_div {
  my $input_string=shift(@_);
  my $check_string=$input_string;

  while ($check_string =~ m/<div/) {
    $DIV_COUNT+=1;
    $check_string=$';
  }
  
  $check_string=$input_string;
  
  while ($check_string =~ m%</div%) {
    $DIV_COUNT-=1;
    $check_string=$';
  }
  return $DIV_COUNT;
}


$DIV_COUNT=0;
$FIRST=1;       #true;
$TITLE=0;
$H2=0;

while(<>) {
  if ($FIRST) { #First file in the list - we will look for title
    print $_,"<html>\n" if ($.==1) ;
    if ($TITLE == 0) {
      if (m/<title/) {
	print $&;
	$_=$';
	$TITLE=1;
      }
    }
    if ($TITLE ==1) {
      if (m%</title>%) {
	print $`,$&,"\n";
	$TITLE=-1;
	###$FIRST=0; #false
      } else {
	print;
      }
    }
    if ($TITLE == -1) { #Title has been found - now we will look for h2
      if ($H2 == 0) {
	if (m/<h2/) {
	  print $&;
	  $_=$';
	  $H2=1;
	}
      }

      if ($H2 == 1) {
	if (m%</h2>%) {
	  print $`,$&,"\n";
	  $H2=-1;
	  $FIRST=0; #false
	} else {
	  print;
	}
      }
    }

  }

  if ( $.==1) {
    print STDERR "Processing file $ARGV, still to process " , $#ARGV+1, " files.\n";
  }
    
  if ( $DIV_COUNT==0) {
    if (m/<div.*class="inner_content">/) {
      print;
      $DIV_COUNT=1;
      $_=$';  #string following what was matched
      $DIV_COUNT=count_div($_);
    }
  } else {
    if (m/Digg this article/) {      
      do {
	print "</div>\n";
	$DIV_COUNT-=1;
      } until ( $DIV_COUNT==0);

    } else {
      $DIV_COUNT=count_div($_);
      print;
    }
  }
  if (eof) {
    close (ARGV); #needed only when line counting should work for each input file separately
    print "<!-- End of processing of file ", $ARGV, " -->\n";
  }

}

print "</html>\n";

