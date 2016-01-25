#!/bin/bash
source ../jmm.sh

mkdir ./jmmtest
cd ./jmmtest
jmm here .
jmm get github.com/ricallinson/jmmexample
jmm install ./src/github/com/ricallinson/jmmexample
data=$(jmmexample)
cd ..
rm -rf ./jmmtest

if [ "$data" = "Congratulations on your first Java-- application." ]; then
	exit 0
fi
echo "Failed to complete the example."
exit 1
