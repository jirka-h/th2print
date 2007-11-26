#!/bin/sh
# vim: set fdm=marker: VIM modeline
# Usage 
# go.sh http://www.tomshardware.com/2007/11/19/the_spider_weaves_its_web
# SVN
# BLLL

# Colors {{{1
function echo_red() {
if [[ "$TERM" = linux || "$TERM" = xterm ]]
then
  echo -ne "\033[31m" 1>&2
  echo $@ 1>&2
  echo -ne "\033[0m" 1>&2
else
  echo $@ 1>&2
fi
}
#}}}

# WGET Options {{{1
MAXIMUM_PAGES=60      #Maximum number of pages to download
WGET_STANDARD=" -E -H -k -K -p --user-agent=Mozilla/5.0"
WGET_EXPERIMENTAL=-"r -l1 --follow-tags=img"

WGET_OPTIONS="$WGET_STANDARD $WGET_EXPERIMENTAL"

#WGET_BASE_URL="http://www.tomshardware.com/2007/11/19/the_spider_weaves_its_web"
WGET_BASE_URL=`echo $1 | perl -ne 'if (m%(.*)/$%) { print $1;}'`
echo_red "URL is $WGET_BASE_URL"
#}}}

# Download pages {{{1
echo_red "wget $WGET_OPTIONS ${WGET_BASE_URL}/index.html"

if ! wget $WGET_OPTIONS ${WGET_BASE_URL}/index.html
then
  echo_red "Error calling wget $WGET_OPTIONS ${WGET_BASE_URL}/index.html"
fi


for ((a=1; a <= ${MAXIMUM_PAGES} ; a++)) 
do 
  echo_red "wget $WGET_OPTIONS ${WGET_BASE_URL}/page$a.html"
  if ! wget $WGET_OPTIONS ${WGET_BASE_URL}/page$a.html
  then
    echo_red "Error calling wget $WGET_OPTIONS ${WGET_BASE_URL}/page$a.html"
  fi
done

echo_red "Downloading is done!"
#}}}

# Convert pages into one file {{{1
DATE=`date +%Y-%b-%d_%H.%M`
WGET_NAME=`echo $WGET_BASE_URL | perl -ne "if (m%.*/%) { print $';}"`
BASE_OUTPUT_NAME="${WGET_NAME}-${DATE}"
BASE_OUTPUT_SUFFIX=".html"
OUTPUT_NAME="${BASE_OUTPUT_NAME}${BASE_OUTPUT_SUFFIX}"
DIRNAME=`echo $WGET_BASE_URL | perl -ne "if (m%http://%) { print $';}"`
BIN_DIR=`dirname $0`
BASE_DIR=`pwd`
echo_red "Trying to cd $DIRNAME"
cd $DIRNAME
FILES=`ls page*html | sort -k 2 -n -t e`
FILES="index.html $FILES"
echo_red $FILES

echo_red "Trying to call ${BASE_DIR}/${BIN_DIR}/make_one_html.pl"
echo_red "Output will be written into `pwd`/${OUTPUT_NAME}"

if ! ${BASE_DIR}/${BIN_DIR}/make_one_html.pl $FILES > ${OUTPUT_NAME}
then
  echo_red "Error calling ${BASE_DIR}/${BIN_DIR}/make_one_html.pl $FILES > ${OUTPUT_NAME}"
  exit 1
fi

echo_red "Conversion is done!" 
#}}}

# Creating TOC {{{1
echo_red "Trying to call ${BASE_DIR}/${BIN_DIR}/html_create_toc.pl ${OUTPUT_NAME}"

if ! ${BASE_DIR}/${BIN_DIR}/html_create_toc.pl ${OUTPUT_NAME}
then
  echo_red "Error calling ${BASE_DIR}/${BIN_DIR}/html_create_toc.pl ${OUTPUT_NAME}"
  exit 1
fi

# }}}

# Calling firefox {{{1
TOC_NAME="${BASE_OUTPUT_NAME}_frame${BASE_OUTPUT_SUFFIX}"
if [ ! -r $TOC_NAME ] 
then
  echo_red "`pwd`/$TOC_NAME does not exist!"
  OPEN_NAME=${OUTPUT_NAME}
else
  echo_red "`pwd`/$TOC_NAME does exist!"
  OPEN_NAME=$TOC_NAME
fi

echo_red "Will try to open ${OPEN_NAME}"

echo_red "Trying to call exec firefox `pwd`/${OPEN_NAME}"
exec firefox `pwd`/${OPEN_NAME}
# }}}

# Some WGET Options descrition {{{1
#-nr Don't remove the temporary .listing files
#-k After the download is complete, convert the links in the document
#-r recursive
#-l Specify recursion maximum depth level
#-np Do not ever ascend to the parent directory
#-U,  --user-agent=AGENT    identify as AGENT instead of Wget/VERSION.
#-p This option causes Wget to download all the files that are necessary to
# properly display a given HTML page.  This includes such things as inlined images, sounds,
# and referenced stylesheets.
#}}}
