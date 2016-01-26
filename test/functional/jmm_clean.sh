#!/bin/bash
source ../jmm.sh
jmm install $JMMPATH/src/github/com/javaminusminus/jmminstall
jmm clean
if [ -e "$JMMPATH/bin/jmminstall" ]; then
	echo "Jar 'jmminstall.jar' did not get removed."
	exit 1
fi
exit 0
