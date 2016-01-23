export JMM_VERSION="0.0.1"

# Helper functions.

jmm_helper_path_resolve() {
	if [ ${1:0:1} = "." ]; then # if starts with a .
        echo $(pwd)${1:1}
    elif [ ${1:0:1} = "~" ]; then # if starts with a ~
    	echo  $(pwd)${1:1}
    elif [ ${1:0:1} = "/" ]; then # if starts with a /
        echo  $1
    else
    	echo $(pwd)$1
    fi
}

jmm_helper_get_class_path() {
	absPath=$(jmm_helper_path_resolve $1)
	jmmSize=${#JMMPATH}+5 # remove /src/
	absSize=${#absPath}
	absPath=${absPath:0:absSize-5} # remove .class
	echo ${absPath:$jmmSize}
}

jmm_helper_find_up() {
  local path
  path=$1
  while [ "$path" != "" ] && [ ! -d "$path/$2" ]; do
    path=${path%/*}
  done
  echo "$path"
}

jmm_helper_find_src() {
  local dir
  dir="$(jmm_helper_find_up $1 'src')"
  if [ -e "$dir/src" ]; then
    echo "$dir/src"
  fi
}

jmm_helper_resolve() {
    cd "$1" 2>/dev/null || return $?  # cd to desired directory; if fail, quell any error messages but return exit status
    echo "`pwd -P`" # output full, link-resolved path
}

# Commands.

jmm_env() {
	echo "JMMPATH=\"$JMMPATH\""
}

jmv_here() {
	local wPath
    if [ -z $1 ]; then
        wPath=$(jmm_helper_find_src $PWD)
        wPath=${wPath%/*}
    else
        wPath="`jmm_helper_resolve \"$2\"`"
    fi
    if [ -z $wPath ]; then
        echo
        echo "This command must be run in a Jmm workspace"
        echo
        return 0
    fi
    mkdir -p $wPath/bin
    mkdir -p $wPath/pkg
    mkdir -p $wPath/src
    export JMMPATH=$wPath
    export PATH=$PATH:$JMMPATH/bin
    jmm_env
}

jmm_run() {
	classPath=$(jmm_helper_get_class_path $1)
	classFiles=""
	classPaths=""
	for file; do
		classFiles="$classFiles $file"
		classPaths="$classPaths ./$(jmm_helper_get_class_path $file).class"
	done
	javac -d ./ $classFiles
	jar cf $JMMPATH/pkg/test.jar $classPaths
	java -cp $JMMPATH/pkg/test.jar $classPath
}

jmm_version() {
	echo $JMM_VERSION
}

jmm() {
	case $1 in
	"help" )
		echo "Jmm is a tool for managing Java-- source code."
		echo
		echo "Java--"
		echo
		echo "Usage:"
		echo
		echo "    jmm command [arguments]"
		echo
		echo "The commands are:"
		echo
		echo "    build       compile packages and dependencies"
		echo "    clean       remove object files"
		echo "    doc         show documentation for package or symbol"
		echo "    env         print Jmm environment information"
		echo "    fix         run jmm tool fix on packages"
		echo "    fmt         run jmmfmt on package sources"
		echo "    generate    generate Jmm files by processing source"
		echo "    get         download and install packages and dependencies"
		echo "    here        set $JMMPATH to the given directory"
		echo "    install     compile and install packages and dependencies"
		echo "    list        list packages"
		echo "    run         compile and run Jmm program"
		echo "    test        test packages"
		echo "    tool        run specified jmm tool"
		echo "    version     print Jmm version"
		echo "    vet         run jmm tool vet on packages"
		echo
	;;
	"build" )
		echo "TODO"
	;;
	"clean" )
		echo "TODO"
	;;
	"doc" )
		echo "TODO"
	;;
	"env" )
		jmm_env
	;;
	"fix" )
		echo "TODO"
	;;
	"fmt" )
		echo "TODO"
	;;
	"generate" )
		echo "TODO"
	;;
	"get" )
		echo "TODO"
	;;
	"here" )
		jmv_here $2
	;;
	"install" )
		echo "TODO"
	;;
	"list" )
		echo "TODO"
	;;
	"run" )
		jmm_run "${@:2}"
	;;
	"test" )
		echo "TODO"
	;;
	"tool" )
		echo "TODO"
	;;
	"version" )
		jmm_version
	;;
	"vet" )
		echo "TODO"
	;;
	esac
}
