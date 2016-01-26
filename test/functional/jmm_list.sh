#!/bin/bash
source ../jmm.sh
data=$(jmm list $JMMPATH/src/github/com/javaminusminus/jmminstall)
if [[ "$data" != *"github.com.javaminusminus.jmminstall"* ]] && [[ "$data" != *"github.com.javaminusminus.jmminstall.sub"* ]]; then
	echo "Test did not execute."
	exit 1
fi
data=$(jmm list $JMMPATH/src/github/com/javaminusminus/jmminstall/BuildClass.java)
if [[ "$data" != "github.com.javaminusminus.jmminstall"* ]]; then
	echo "Test did not execute."
	exit 1
fi
exit 0
