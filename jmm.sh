# 
# Copyright 2016, Yahoo Inc.
# Copyrights licensed under the New BSD License.
# See the accompanying LICENSE file for terms.
#

#
# Lint check by http://www.shellcheck.net/
#

{ # this ensures the entire script is downloaded 

#
# Constants
#

export JMMVERSION="0.0.1"
JMMHOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export JMMHOME=$JMMHOME

#
# Helper functions
#

# @String $1 - Directory path
# @return "dir/path"
# Returns an absolute path from the give input path.
jmm_helper_path_resolve() {
    if [ "${1:0:1}" = "." ]; then # if starts with a .
        echo "$(pwd)${1:1}"
    elif [ "${1:0:1}" = "~" ]; then # if starts with a ~
        echo "$HOME${1:1}"
    elif [ "${1:0:1}" = "/" ]; then # if starts with a /
        echo "$1"
    else
        echo "$(pwd)/$1"
    fi
    return 0
}

# @String $1 - Directory path
# @return "name"
# Returns the jar name for a given directory path.
jmm_helper_get_jar_name() {
    local base
    base=$(dirname "$1")
    echo "${base##*/}"
    return 0
}

# @String $1 - Directory path
# @return "dir/path"
# Returns a class path from a given absolute path.
jmm_helper_get_class_path() {
    local absPath
    local jmmSize
    local absSize
    local absPath
    absPath=$(jmm_helper_path_resolve "$1")
    jmmSize=${#JMMPATH}+5 # remove /src/
    absSize=$((${#absPath}-5))
    absPath=${absPath:0:$absSize} # remove .class
    echo "${absPath:$jmmSize}"
    return 0
}

# @String $1 - Directory path
# @String $2 - Directory name
# @return "dir/path"
# Searches up through the directories until it finds directory name a match for the given input string.
jmm_helper_find_up() {
    local path
    path=$1
    while [ "$path" != "" ] && [ ! -d "$path/$2" ]; do
        path=${path%/*}
    done
    echo "$path"
    return 0
}

# @String $1 - Directory path
# @return "dir/path" || ""
# Searches up through the directories until it finds a directory named 'src'.
jmm_helper_find_src() {
    local dir
    dir="$(jmm_helper_find_up "$1" 'src')"
    if [ -e "$dir/src" ]; then
        echo "$dir/src"
    fi
    return 0
}

# @String $1 - Directory path
# @return "/abs/dir/path" || ""
# Resolves the given directory if it exists.
jmm_helper_resolve() {
    cd "$1" 2>/dev/null || return $?  # cd to desired directory; if fail, quell any error messages but return exit status
    pwd -P # output full, link-resolved path
    return 0
}

# @String $1 - File path to a .java with the main method for the .jar
# @String $@ - List of .java files to put in the .jar
# @return "path/to.jar" || "compile error"
jmm_helper_build_jar() {
    local jarName
    local classPath
    local classFiles
    local classPaths
    mkdir -p "$JMMPATH/bin"
    mkdir -p "$JMMPATH/pkg"
    jarName=$(jmm_helper_get_jar_name "$1")
    classPath=$(jmm_helper_get_class_path "$1")
    classPath=${classPath//[\/]/\.}
    classFiles=()
    classPaths=""
    for file; do
        if [[ $file != "_test.java"* ]]; then
            classFiles+=("$file")
            classPaths="$classPaths -C $JMMPATH/pkg $(jmm_helper_get_class_path $file).class"
        fi
    done
    javac -d "$JMMPATH/pkg" "${classFiles[@]}"
    if [[ $? -eq 1 ]]; then
        return 1
    fi
    jar cfe "$JMMPATH/bin/$jarName.jar" "$classPath" $classPaths
    echo "$JMMPATH/bin/$jarName.jar"
    return 0
}

# @String $1 - Directory path
# @return "list of .java file paths"
# Looks at the given directory path and returns all .java files in it.
jmm_helper_find_java_files() {
    local files
    files=""
    for file in $(find "$1" -name "*.java"); do
        imports=$(jmm_helper_resolve_imports "$file")
        if [[ "$imports" == "$ILLEGAL_PACKAGE"* ]]; then
            echo "$imports"
            return
        fi
        files="$files $file $imports"
    done
    echo "$files"
    return 0
}

# Creates a new imported.txt file.
jmm_start_import_check() {
    echo "" > "$JMMPATH/imported.txt"
}

# Removes an imported.txt file.
jmm_end_import_check() {
    rm "$JMMPATH/imported.txt" > /dev/null
}

# @String $1 - Java import package name
# @return "skip" || "import"
# Checks if the given package name has already been imported.
jmm_helper_import_check() {
    local imported
    read -r -a imported < $JMMPATH/imported.txt
    for import in "${imported[@]}"; do
        if [[ "$1" == "$import" ]]; then
            echo "skip"
            return 1
        fi
    done
    imported+=("$1")
    echo "${imported[@]}" > $JMMPATH/imported.txt
    echo "import"
    return 0
}

# @String $1 - File path to a .java file
# @return "list of .java file paths"
# Looks at the given .java file imports and resolves them to file paths.
jmm_helper_resolve_imports() {
    local files
    files=""
    for import in $(grep ^import "$1"); do
        if [[ "$import" != "import" ]] && [[ -n "$import" ]] && [[ "$(jmm_helper_import_check "$import")" == "import" ]]; then
            import=${import//[;]/}
            import=${import//[\.]/\/}
            import=$(dirname "$import")
            newFiles=$(jmm_helper_find_java_files "$JMMPATH/src/$import")
            files="$files $newFiles"
        fi
    done
    echo "$files"
    return 0
}

# @String $1 - Path to a Jmm test file.
# @return "pass" || "fail"
# Runs the given test file and reports if it passes or fails.
jmm_run_test() {
    local files
    local dir
    jmm_start_import_check
    # get all the files used in the imports.
    files="$1 $(jmm_helper_resolve_imports "$1")"
    # get all the files in the same directory.
    for file in $(find "$(dirname "$1")" -name "*.java"); do
        if [[ ! -d "$file" ]] && [[ "$file" != *"_test.java" ]]; then
            files="$files $file $(jmm_helper_resolve_imports "$file")"
        fi 
    done
    jmm_end_import_check
    # run the test.
    jmm_run $files
    return $?
}

#
# Commands
#

# @String $1 - Directory path
# @return "compile error" || ""
# Compiles the files in the given directory resolving all packages and places final jar in $JMMHOME/bin.
jmm_install() {
    local path
    local mains
    local imports
    local files
    local jar
    local exe
    local path
    path="$1"
    if [[ -z "$path" ]]; then
        path="."
    fi
    jmm_start_import_check
    jmm_lint $path
    if [[ $? -gt 0 ]]; then
        return 1
    fi
    path=$(jmm_helper_path_resolve "$path") # TODO: strip last / if it's there.
    mains=""
    files=""
    for file in $(find "$path" -name '*.java'); do
        if [ "$mains" = "" ] && grep -q "public static void main(" "$file"; then
            imports=$(jmm_helper_resolve_imports "$file")
            mains="$file $imports"
        else
            imports=$(jmm_helper_resolve_imports "$file")
            files="$files $file $imports"
        fi
    done
    jar=$(jmm_helper_build_jar $mains $files)
    if [[ "$jar" == "" ]]; then
        return
    fi
    exe=${jar:0:${#jar}-4}
    echo "java -jar $jar" > "$exe"
    chmod +x "$exe"
    jmm_end_import_check
    return 0
}

# Deletes all files in $JMMHOME/bin and $JMMHOME/pkg
jmm_clean() {
    rm -rf "${JMMPATH:?}/bin/"*
    rm -rf "$JMMPATH/pkg/"*
    return 0
}

# Prints the exported variables used by Jmm.
jmm_env() {
    echo "JMMPATH=\"$JMMPATH\""
    echo "JMMHOME=\"$JMMHOME\""
    echo "JAVA_HOME=\"$JAVA_HOME\""
    return 0
}

# @String $@ - Package names
# Downloads the given github.com package(s) and unpacks them into $JMMHOME/src.
# currently only works with github.com zip files.
jmm_get() {
    local packageDir
    local packageName
    for package; do
        curl -s -o "$JMMPATH/master.zip" -L "$package/archive/master.zip"
        if grep -q "error" "$JMMPATH/master.zip"; then
            rm "$JMMPATH/master.zip"
            echo "Package '$package' not found"
            return 1
        fi
        packageDir=${package//[\.]/\/}
        rm -rf "$JMMPATH/src/$packageDir"
        mkdir -p "$JMMPATH/src/$packageDir"
        unzip -qq "$JMMPATH/master.zip" -d "$JMMPATH/src/$packageDir"
        packageName="$(basename $package)"
        mv "$JMMPATH/src/$packageDir/$packageName-master/"* "$JMMPATH/src/$packageDir/$packageName-master/.."
        mv "$JMMPATH/src/$packageDir/$packageName-master/".[^.]* "$JMMPATH/src/$packageDir/$packageName-master/.."
        rm -r "$JMMPATH/src/$packageDir/$packageName-master"
        rm "$JMMPATH/master.zip"
    done
    return 0
}

# Prints the available commands.
jmm_help() {
    echo "Jmm is a tool for managing Jmm source code."
    echo
    echo "Jmm"
    echo
    echo "Usage:"
    echo
    echo "    jmm command [arguments]"
    echo
    echo "The commands are:"
    echo
    echo "    install       compile packages and dependencies"
    echo "    clean       remove object files"
    echo "    doc         (not implemented) show documentation for package or symbol"
    echo "    env         print Jmm environment information"
    echo "    lint        run lint check on package sources"
    echo "    get         download and install packages and dependencies (currently works with github.com only)"
    echo "    here        set $JMMPATH to the given directory"
    echo "    list        list packages"
    echo "    run         compile and run Jmm program (the first file must have the main method)"
    echo "    test        test packages"
    echo "    version     print Jmm version"
    echo
    return 0
}

# @String $1 - Directory path
# Sets the Java- workspace either by walking up from the given directory
# to find one or creating one in the given directory.
jmv_here() {
    local wPath
    if [ -z "$1" ]; then
        wPath=$(jmm_helper_find_src "$(pwd)")
        wPath=${wPath%/*}
    else
        wPath=$(jmm_helper_resolve "$1")
    fi
    if [ -z "$wPath" ]; then
        echo
        echo "This command must be run in a Jmm workspace"
        echo
        return 0
    fi
    mkdir -p "$wPath/bin"
    mkdir -p "$wPath/pkg"
    mkdir -p "$wPath/src"
    export JMMPATH=$wPath
    export PATH=$PATH:$JMMPATH/bin

    echo
    echo "Jmm workspace set to: $JMMPATH"
    echo

    return 0
}

# @String $@ - Directory path(s)
# Runs the lint rules over the given directories.
jmm_lint() {
    local files
    for file in "$@"; do
        files="$files $file"
    done
    result=$(java -jar "$JMMHOME/vendor/checkstyle/checkstyle-6.14.1-all.jar" -c "$JMMHOME/lint.xml" $files)
    if [[ $? -gt 0 ]]; then
        echo "$result"
        return 1
    fi
    return 0
}

# @String $1 - Directory path
# Prints the packages used in the given directory.
jmm_list() {
    local path
    path="$1"
    if [[ -z "$path" ]]; then
        path="."
    fi
    if [[ -d "$path" ]]; then
        for dir in $path/*; do
            jmm_list "$dir"
        done
    else
        if [[ "$path" == *".java" ]]; then
            for package in $(grep ^package "$1"); do
                if [[ "$package" != "package" ]]; then
                    package=${package//[;]/}
                    if [[ "$(jmm_helper_import_check "$package")" == "import" ]]; then
                        echo "$package"
                    fi
                fi
            done
        fi
    fi
    return 0
}

# @String $@ - File path(s) to .java files
# Creates a jar in $JMMHOME/bin and executes it.
jmm_run() {
    local jarFile
    jmm_lint "$@"
    if [[ $? -gt 0 ]]; then
        return 1
    fi
    jarFile=$(jmm_helper_build_jar "$@")
    java -jar "$jarFile"
    return $?
}

# @String $@ - Directory or file path(s) to &_test.java files
# Runs the tests for the given or found files.
jmm_test() {
    local failures
    failures=$((0))
    jmm_lint "$@"
    failures=$(($failures + $?))
    for path in "$@"; do
        if [[ -d "$path" ]]; then
            # if it's a directory recursively find all test files and execute them one at a time.
            for dir in $path/*; do
                jmm_test "$dir"
                failures=$(($failures + $?))
            done
        elif [[ -e "$path" ]] && [[ "$path" == *"_test.java" ]]; then
            # if the file ends with "_test.java" then run it.
            jmm_run_test "$path"
            failures=$(($failures + $?))
        fi
    done
    return $(($failures))
}

# Prints the current version of this tool.
jmm_version() {
    echo $JMMVERSION
}

#
# Interface
#

# The main entry point.
jmm() {
    case $1 in
    "help" )
        jmm_help
        return 0
    ;;
    "" )
        jmm_help
        return 0
    ;;
    "here" )
        jmv_here "$2"
        return 0
    ;;
    "env" )
        jmm_env
        return 0
    ;;
    "version" )
        jmm_version
        return 0
    ;;
    esac

    if [[ -z "$JMMPATH" ]]; then
        echo
        echo "You must be in a Jmm workspace to use '$1'."
        echo
        return
    fi

    case $1 in
    "clean" )
        jmm_clean
    ;;
    "doc" )
        echo "TODO"
    ;;
    "get" )
        jmm_get "${@:2}"
    ;;
    "install" )
        jmm_install "$2"
    ;;
    "lint" )
        jmm_lint "${@:2}"
    ;;
    "list" )
        jmm_start_import_check
        jmm_list "$2"
        jmm_end_import_check
    ;;
    "run" )
        jmm_run "${@:2}"
    ;;
    "test" )
        jmm_test "${@:2}"
    ;;
    *)
        echo "jmm: unknown subcommand \"$1\""
        echo "Run 'go help' for usage."
        return 1
    esac
    return $?
}

} # this ensures the entire script is downloaded 
