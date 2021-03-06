#!/bin/bash


## ########################################
## TEST
## ########################################

function test {

	## Generate Pysys Tests

  if [[ -z "$AUNIT_PYTHON" ]]; then
    export AUNIT_PYTHON=python
  fi

	if [[ $# -eq 1 ]]; then
    eval "$AUNIT_PYTHON ${AUNIT_HOME}/test-build/aunit.py -s $1"
 	else 
 		if [[ $# -eq 2 ]]; then
      eval "$AUNIT_PYTHON ${AUNIT_HOME}/test-build/aunit.py -s $1 -f $2"
		else
			eval "$AUNIT_PYTHON ${AUNIT_HOME}/test-build/aunit.py"
		fi
 	fi
	
	## Call Pysys Tests
	if [[ -z "$AUNIT_TEST_HOME" ]]; then 
		export AUNIT_TEST_HOME=${AUNIT_HOME}/.__test
	fi

	if [[ -z "$AUNIT_BUNDLE_HOME" ]]; then 
		export AUNIT_BUNDLE_HOME=${AUNIT_HOME}/.__repository
	fi

	eval "${AUNIT_TEST_HOME}/runtests.sh"

}


## ########################################
## BUILD
## ########################################

function build {
	## Generate project packages
	ant -q -f "${AUNIT_HOME}/project-build/ant_macros/build.xml"
}



## ########################################
## ERROR
## ########################################

function error {
	echo 
	echo "Warning: The following environment variables must be defined: "
	echo 
	echo "AUNIT_HOME"
	echo "APAMA_HOME"
	echo "APAMA_JRE"
	echo 
}

## ########################################
## USAGE 
## ########################################

function usage {
	echo "Usages: aunit <build> "
	echo "        aunit <test> [Project] [FilenameFilter]"
	echo "        aunit <all> "
}


## Validate env vars set

if [ -z "$AUNIT_HOME" ] || [ -z "$APAMA_HOME" ] || [ -z "$APAMA_JRE" ]; then
	error
	exit 1
fi

## Ensure param passed in

if [[ $# -eq 0 ]]; then 
	usage
	exit 1
fi


## ########################################
## DETERMINE MODE
## ########################################

## Check 'mode' being run
if [[ $1 == "test" ]]; then
  if [[ $# -eq 2 ]]; then
          test $2
  elif [[ $# -eq 3 ]]; then
          test $2 $3
  else
          test
  fi
elif [[ $1 == "build" ]]; then 
    build
elif [[ $1 == "all" ]]; then 
    build
    test 
else
    usage
fi
