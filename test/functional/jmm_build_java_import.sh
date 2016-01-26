#!/bin/bash
source ../jmm.sh
jmm install $JMMPATH/src/github/com/ricallinson/jmmjava
data=$(jmmjava)
if [ "$data" == "101" ]; then
	exit 0
fi
echo "Jar 'jmmjava' did not execute."
exit 1
