#!/bin/bash

#
# Copyright 2016, Yahoo Inc.
# Copyrights licensed under the New BSD License.
# See the accompanying LICENSE file for terms.
#

source ../jmm.sh

mkdir ./jmmtest
cd ./jmmtest
jmm here .
jmm env
jmm get github.com/jminusminus/jmmexample
jmm get github.com/jminusminus/simplebdd
jmm install ./src/github/com/jminusminus/jmmexample
data=$(jmmexample)
cd ..
# rm -rf ./jmmtest

if [ "$data" = "Congratulations on your first Jmm application." ]; then
	exit 0
fi
echo "Failed to complete the example."
echo "$data"
exit 1
