#!/bin/bash
source ../jmm.sh
data=$(jmm install $JMMPATH/src/github/com/javaminusminus/jmmillegal)
if [ "$data" = "Illegal package: java.util.Date;" ]; then
	exit 0
fi
echo "Illegal package not found."
exit 1
