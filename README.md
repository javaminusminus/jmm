# Java--

[![Build Status](https://travis-ci.org/javaminusminus/jmm.svg?branch=master)](https://travis-ci.org/javaminusminus/jmm)

__UNSTABLE__

This project started life as a joke after having coffee with a fellow engineer. Java-- is taking Java in a different direction by using highly opinionated choices as to what should or should not be used from the language. Java-- is not a new language, it's just a collection of tools that let you work with Java in a different way.

## Install

Using git, clone this repository into a directory named `~/.jmm`.

    git clone git@github.com:javaminusminus/jmm.git ~/.jmm

To activate jmm, you need to source it from your shell:

    source ~/.jmm/jmm.sh

I always add this line to my _~/.bashrc_, _~/.profile_, or _~/.zshrc_ file to have it automatically sourced upon login.

## Usage

Java-- follows the same development patten as [Go](https://golang.org/). There are no externally linked libraries and all the source code for a program is contained in a Java-- workspace. A workspace is a directory that contains a projects code. Generally you'll have one workspace per project which contains the following directories.

	bin
	pkg
	src

Raw `.java` files are placed under the `src` directory with a package name derived from their location in a source control system such as [Github](https://github.com/).

Compiled `.class` files are generated under the `pkg` directory.

Self contained `.jar` files are put in the `bin` directory along with an executable script to run them.

### Getting Started Example

This example creates a Java-- workspace, gets the source code for a package, installs a `.jar` and then executes it.

	mkdir ./jmmtest
	cd ./jmmtest
	jmm here .
	jmm get github.com/javaminusminus/jmmexample
	jmm test ./src/github/com/javaminusminus/jmmexample
	jmm install ./src/github/com/javaminusminus/jmmexample
	jmmexample

## Help

### jmm clean

Removes all files in the `$JMMPATH/bin` and `$JMMPATH/pkg` directories.

	jmm clean

### jmm env

Prints the values of all Java-- environment variables.

	jmm env

### jmm get

Get a package from [github.com](https://github.com/) and copy its source into the current workspace.

	jmm get github.com/javaminusminus/jmmimporttest

### jmm here

Creates a new Java-- workspace at the given path and exports the `$JMMPATH` as that directory.

	jmm here ./some/dir

Determines if the current directory is part of a Java-- workspace. If it is the `$JMMPATH` is changed to that workspace.

	jmm here

### jmm install

Builds a `.jar` from the `.java` files in the given directory. A `.jar` named the same as the directory is created and placed in the `$JMMPATH/bin` directory. An executable to run the `.jar` is also created and placed in the `$JMMPATH/bin` directory. All imports are resolved to packages in the current workspace.

	jmm install ./src/github/com/javaminusminus/jmminstall

The following will install the current working directory.

	jmm install

### jmm lint

Checks the given packages or files against the Java-- opinionated style. Note: The opinionated style is not complete yet.

	jmm lint ./src/github/com/javaminusminus/jmminstall

### jmm list

List all packages under a given directory.

	jmm list ./src/github/com/javaminusminus/jmminstall

The following will list packages in the current working directory.

	jmm list

### jmm run

Provide one or more `.java` files to run. The first file must have the main method. A `.jar` named the same as the first class files directory is created and placed in the `$JMMPATH/bin` directory. Note: this will overwrite an existing `.jar` if it has the same name.

	jmm run ./src/github/com/javaminusminus/jmmrun/RunClass.java ./src/github/com/javaminusminus/jmmrun/OtherClass.java

### jmm test

Tests in Java-- are identified by the postfix `_test` on a `.java` file. The class must have a main method and be in the same directory as the code it's testing or import the code it's testing. Test files are executed one at time in isolation from each other. All test files are excluded from a install.

	jmm test ./src/github/com/javaminusminus/jmmtest/TestClass_test.java

Directories are tested recursively to allow packages to be tested with one command.

	jmm test ./src/github/com/javaminusminus/jmmtest

### jmm version

Prints the version of jmm in use.

	jmm version

## Legal Packages

This is the complete list of "legal" Java-- packages allowed from the [Java 8](https://docs.oracle.com/javase/8/docs/api/overview-summary.html) package list. Note: The opinionated package list is not complete yet.

* [java.io.IOException](https://docs.oracle.com/javase/8/docs/api/java/io/IOException.html)
* [java.io.InputStream](https://docs.oracle.com/javase/8/docs/api/java/io/InputStream.html)
* [java.io.OutputStream](https://docs.oracle.com/javase/8/docs/api/java/io/OutputStream.html)
* [java.math](https://docs.oracle.com/javase/8/docs/api/java/math/MathContext.html)
* [java.net.ServerSocket](https://docs.oracle.com/javase/8/docs/api/java/net/ServerSocket.html)
* [java.net.Socket](https://docs.oracle.com/javase/8/docs/api/java/net/Socket.html)

## Run Tests

Tests to validate everything is working as expected.

	./test/run.sh
