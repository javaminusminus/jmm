#!/bin/bash
source ../jmm.sh
packageDir=$JMMPATH/src/github/com/javaminusminus/jmmimporttest
if [ -d $packageDir ]; then
	rm -rf $packageDir
fi
jmm get github.com/javaminusminus/jmmimporttest
if [ ! -d $packageDir ]; then
	echo "Package was not downloaded."
	exit 1
fi
rm -rf $packageDir
exit 0
