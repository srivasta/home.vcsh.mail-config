#!/bin/bash
#                               -*- Mode: Sh -*- 
# re-learn-sa.sh --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
# Created On       : Thu Jan 11 11:59:31 2007
# Created On Node  : glaurung.internal.golden-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Thu Jan 11 12:31:24 2007
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 13
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

set -e

Corpus_Top="/backup/classify/Done"
withecho () {
        echo " $@" >&2
        "$@"
}
action='withecho'

here=$(pwd)

num_spam=$(ls -1 $Corpus_Top/Spam | wc -l)
num_good=$(ls -1 $Corpus_Top/Ham  | wc -l)
if [ $num_spam -lt $num_good ]; then
    low_max=$num_spam; 
else
    low_max=$num_good;
fi

limit=$low_max
for type in spam ham; do
	if [ ! -d $type ]; then
		mkdir $type
   	for i in $(nice ls -1 $Corpus_Top/$type/ | tail -n $limit); do
    		nice cp $Corpus_Top/$type/$i $type/$i
   	done
	fi
done

test -d ham.new  || mkdir ham.new
test -d spam.new || mkdir spam.new

PROCESS=Yes
while [ "X$PROCESS" != "X" ]; do
    PROCESS=
    for type in spam ham; do
        j=$(builtin cd $here/${type}; nice ls -1 | grep ^msg | wc -l)
        if test $j -gt 10; then
            (builtin cd $here/${type}; 
                nice mv `ls -1 | grep ^msg | head -n 50` $here/${type}.new/)
            PROCESS=Yes
            nice sa-learn "--${type}" $here/${type}.new
						nice rm -rf $here/${type}.new
						mkdir $here/${type}.new
        fi
    done
done


