#!/usr/bin/perl -w
# Usage make_one_html.pl amd-phenom-athlon,1918.html amd-phenom-athlon,1918-1.html > all.html
# vim: set sw=2


use strict;
my $FILE_NUMBER=0;
my @list_of_elements;
my @header=(["!DOCTYPE",1,0], ["html",1,0], ["head",1,1], ["body",0,0],["h4",0,1],["h3",0,1]);
#Coding: html element,print attributes?,add element to list_of_elements and search for </element>?
#my $header_white_list="<meta.*?/>|<title.*?>.*</title>|<link.*?/>|</head>";
#my $header_white_list="<meta.*?/>|<title.*?>.*</title>|</head>";
my $header_white_list="<meta.*?/>|<title.*?>.*</title>|<link.*?icon.*?/>|</head>";
#Which elements are allowed inside <head>...</head>?
#@header has to contain ["head",1,1] (important is last 1)



sub search_html_element_start ($$$) { #returns 1 when element is found, 0 otherwise (html block like <title>text</title>)
				     # search_html_element_start title 1 1
				     # search for title and print attributes and push element on @list_of_elements
  use vars qw(@list_of_elements);
  my $element= shift;         #html element like <title>
  my $with_attribute = shift; #parse attributes, like <head profile="http://www.w3.org/2005/11/profile"> ?
			      #0 false, any other number true
  my $add_to_list = shift;    #0 false, any other number true

  my $search;
  $search="<" . $element . "[^>]*>";


    if (m/$search/) {
     if ( $with_attribute ) { 
	print $&;   #Matching string
     } else {
	print "<",$element,"\>";
     }
     $_=$';      #string following what was matched
     if ($add_to_list) {
	push(@list_of_elements, $element);      #add to end of list
     }
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
      print $`, $&, "\n";   #Before match, matching string
      $_=$';
      pop @list_of_elements;
    }
  }
  if ( @list_of_elements > 0 ) {
    print;
    $_="";
  }
}

sub handle_head () {
#if last element in @list_of_elements is "head" we will search for $header_white_list
  use vars qw(@list_of_elements $header_white_list);
  
  if ( $list_of_elements[-1] =~ "head" ) {
    if (m/$header_white_list/) {
      print $&,"\n";   #Matching string
      $_=$';      #string following what was matched
      if ($& =~ "</head>") {
        pop @list_of_elements;
      }
    } else {
      $_="";
    }
  }
}

#TODO - in head povoloit pouze meta,title,link
while(<>) {#main loop

  if ( $.==1) {
    print STDERR "Processing file \"$ARGV\", still to process " , $#ARGV+1, " files.\n";
    ++$FILE_NUMBER;
  }

  while(length($_) > 0 ) {
  
    ##print STDERR $., ":", length($_),":\"",$_,"\"\n";

    if ( @list_of_elements > 0 ) {
      if ($list_of_elements[-1] =~ "head" ) {
        handle_head ();
        next;
      }
    }
  
    if ( @header > 0 ) {
      if ( search_html_element_start($header[0][0], $header[0][1], $header[0][2]) ) {
        if (! $header[0][2] ) { print "\n"; }
        if ($header[0][0] =~ "head") {
          if ($header[0][2]) { 
            handle_head ();
          } else {
            print "</", $header[0][0], ">\n";
          }
        }
        shift @header;
      } else { 
        if (@list_of_elements == 0) {$_="";}
      }
      if ( @list_of_elements > 0 ) {
        search_html_element_stop;
      }
    } else {
      if ( search_html_element_start_with_parameter("p","class=\"spip\"",0) ) {
        ##print STDERR "main\t",@list_of_elements,"\t",$#list_of_elements+1,"\n";
      } else {
        if (@list_of_elements == 0) {$_="";}
      }
      if ( @list_of_elements > 0 ) {
        search_html_element_stop;
      }
    }
  }

  if (eof) {

    if ( @header > 0 && $FILE_NUMBER == 1) {
      print STDERR "Warning: there are ", scalar(@header), " not processed header elements at the end of file \"$ARGV\"\n";
      print STDERR "These elements are:\"", @header, "\"\n";
      @header=();
    }

    if ( @list_of_elements > 0 ) {
      print STDERR "Warning: there are ", scalar(@list_of_elements), " not processed elements at the end of file \"$ARGV\"\n";
      print STDERR "These elements are:\"", @list_of_elements, "\"\n";
      @list_of_elements=();
    }
    @header=(["h3",1,1]);
    close (ARGV); #needed only when line counting should work for each input file separately
  }
}

print "</body>\n";
print "</html>\n";







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
