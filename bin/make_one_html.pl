#!/usr/bin/perl -w
# Usage make_one_html.pl amd-phenom-athlon,1918.html amd-phenom-athlon,1918-1.html > all.html

use strict;
my $FILE_NUMBER=0;
my @list_of_elements;


sub search_html_element_start ($$) { #returns 1 when element is found, 0 otherwise (html block like <title>text</title>)
  use vars qw(@list_of_elements);
  my $element= shift;         #html element like <title>
  my $with_attribute = shift; #parse attributes, like <head profile="http://www.w3.org/2005/11/profile"> ?
			      #0 false, any other number true
  my $search;
  $search="<" . $element . "[^>]*>";


    if (m/$search/) {
     print $&;   #Matching string
     if ( $with_attribute ) { 
	print $&;   #Matching string
     } else {
	print "<",$element,"\>";
     }
     $_=$';      #string following what was matched
     push(@list_of_elements, $element);      #add to end of list
     return 1;                     #true - we have found an element
    } else {
     return 0;                     #false - element not found
   }
}


sub search_html_element_start_with_parameter ($$$) { #returns 1 when element is found, 0 otherwise <p class="spip">
  use vars qw(@list_of_elements);
  my $element = shift;         #html element like <p>
  my $attribute = shift;       #mandatory attribute class="spip"
  my $with_attribute = shift;  #print attribute? => <p> or <p class="spip">?
			       #0 false, any other number true
  my $search = "<" . $element . " " . $attribute . ">";


  if (m/$search/) {
   if ( $with_attribute ) {
     print $&;   #Matching string
   } else {
     print "<",$element,"\>";
   }
   $_=$';      #string following what was matched
   push(@list_of_elements, $element);      #add to end of list
#  print STDERR "search_html_element_start_with_parameter", @list_of_elements, "\t",$#list_of_elements+1,"\n";
   return 1;                               #true - we have found an element
  } else {
    return 0;                              #false - element not found
  }
}

sub search_html_element_stop () {
  use vars qw(@list_of_elements);
#  print STDERR "search_html_element_stop", @list_of_elements, "\n";
  my $element;
  my $search;
  foreach $element (reverse @list_of_elements) {
    $search = "</" . $element . ">";
#    print STDERR $search,$_;
    if (m&$search&) {
      print $`, $&;   #Matching string
      $_=$';
      pop @list_of_elements;
    }
  }
  if ( $#list_of_elements >= 0 ) {
    print;
  }
}



while(<>) {
 if ( search_html_element_start_with_parameter("p","class=\"spip\"",1) ) {
   print STDERR "main\t",@list_of_elements,"\t",$#list_of_elements+1,"\n";
 }
 if ( $#list_of_elements >= 0 ) {
   search_html_element_stop;
 }
}









##  if ( $.==1) {
##    print STDERR "Processing file $ARGV, still to process " , $#ARGV+1, " files.\n";
##    ++$FILE_NUMBER;
##  }
##
##  if ($FILE_NUMBER == 1 ) { #First file in the list - we will look for title
##   search_html_element_start("
##
##
##    print $_,"<html>\n" if ($.==1) ;
##    if ($TITLE == 0) {
##      if (m/<title/) {
##	print $&;
##	$_=$';
##	$TITLE=1;
##      }
##    }
##    if ($TITLE ==1) {
##      if (m%</title>%) {
##	print $`,$&,"\n";
##	$TITLE=-1;
##	###$FIRST=0; #false
##      } else {
##	print;
##      }
##    }
##    if ($TITLE == -1) { #Title has been found - now we will look for h3
##      if ($H3 == 0) {
##	if (m/<h3/) {
##	  print $&;
##	  $_=$';
##	  $H3=1;
##	}
##      }
##
##      if ($H3 == 1) {
##	if (m%</h3>%) {
##	  print $`,$&,"\n";
##	  $H3=-1;
##	  $FIRST=0; #false
##	} else {
##	  print;
##	}
##      }
##    }
##
##  }
##
##
##    
##  if ( $DIV_COUNT==0) {
##    if (m/<div.*class="inner_content">/) {
##      print;
##      $DIV_COUNT=1;
##      $_=$';  #string following what was matched
##      $DIV_COUNT=count_div($_);
##    }
##  } else {
##    if (m/Digg this article/) {      
##      do {
##	print "</div>\n";
##	$DIV_COUNT-=1;
##      } until ( $DIV_COUNT==0);
##
##    } else {
##      $DIV_COUNT=count_div($_);
##      print;
##    }
##  }
##  if (eof) {
##    close (ARGV); #needed only when line counting should work for each input file separately
##    print "<!-- End of processing of file ", $ARGV, " -->\n";
##  }
##
##}
##
##print "</html>\n";
##
