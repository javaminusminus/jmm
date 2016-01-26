#!/bin/bash
source ../jmm.sh
data=$(jmm test $JMMPATH/src/github/com/javaminusminus/jmmtest/TestClass_test.java)
if [ "$data" != "pass" ]; then
	echo "Test failed !pass."
	exit 1
fi
data=$(jmm test $JMMPATH/src/github/com/javaminusminus/jmmtest/sub/SubTestClass_test.java)
if [ "$data" != "fail" ]; then
	echo $data
	echo "Test failed !fail."
	exit 1
fi
data=$(jmm test $JMMPATH/src/github/com/javaminusminus/jmmtest)
if [[ "$data" != *"pass"* ]] && [[ "$data" != *"fail"* ]]; then
	echo "Test failed !pass and !fail."
	exit 1
fi
exit 0
