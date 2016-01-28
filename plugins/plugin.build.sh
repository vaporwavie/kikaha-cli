#!/bin/sh

if [ "$SKIPTESTS" = "" ]; then
	SKIPTESTS=false
fi

MVN_OPTS="$MVN_OPTS -Dconfig.skip.tests=$SKIPTESTS"
MVN="mvn $MVN_OPTS"

debug "mvn: `which mvn`"
debug "M2_HOME: $M2_HOME"
debug "Maven command line: $MVN"

build_run(){
	if [ "$#" = "0" ]; then
		warn "Bad syntax" 
		build_help
		halt
	fi
	build_$@
}

build_requires_pom(){
	if [ ! -f "pom.xml" ]; then
		warn "Nothing to do here!"
		warn "Make sure you are at a valid maven project."
		halt
	fi
}

build_move_to(){
	action=$1
	dir=$2
	if [ ! "$dir" = "" ]; then
		info "$action module $dir..."
		cd ${dir}
	else
		info "$action current project (and its modules)."
	fi

}

build_build(){
	build_move_to "Building" $1
	build_requires_pom
        $MVN clean install
}

build_run_app(){
	build_move_to "Running" $1
	build_requires_pom
        $MVN clean package kikaha:run
}

build_package(){
	build_move_to "Packing" $1
	build_requires_pom
        $MVN clean package kikaha:package
}

build_deploy(){
	build_move_to "Deploying" $1
	build_requires_pom
        $MVN clean deploy
}

build_clean(){
	build_move_to "Cleaning" $1
	build_requires_pom
        $MVN clean
}

build_help(){
cat <<EOF
 --[ available commands ]--------------------------
  $(grape build):        full build of all modules
  $(grape clean):        clean up the current workspace
  $(grape package):      generate a package from a module
  $(grape run):          run a module
  $(grape help):         print this help message

 --[ available config variables ]------------------
  $(grape SKIPTESTS)    [$(yellow true),$(yellow false)]
        skip all unit and integration tests.

  $(grape QUIET)        [$(yellow true),$(yellow false)]
        hide all uneeded text output, except by those
        printed by the build plan itself.

  $(grape DEBUG)        [$(yellow true),$(yellow false)]
        show debug informations.

EOF

}

build_debug_info(){
cat <<EOF

 --[ environment ]-------------------------------- 
   mvn:         $( which mvn )
   java:        $( which java )

 --[ vars ]--------------------------------------- 
  SKIPTESTS:    $SKIPTESTS
  VERSION:      $VERSION
  PATH:		$PATH
 
 --[ output log ]---------------------------------

EOF
}

