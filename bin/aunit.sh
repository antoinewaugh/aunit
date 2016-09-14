#!/bin/bash


## ########################################
## TEST
## ########################################

function test {

	## Generate Pysys Tests

	if [[ $# -eq 2 ]]; then 
		python "${AUNIT_HOME}/test-build/aunit.py -s $2"
 	else
		python "${AUNIT_HOME}/test-build/aunit.py"
 	fi
	
	## Call Pysys Tests

	eval "${AUNIT_HOME}/.__test/runtests.sh"

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
	echo "AUNIT_PROJECT_HOME"
	echo "APAMA_HOME"
	echo "APAMA_JRE"
	echo 
}

## ########################################
## USAGE 
## ########################################

function usage {
	echo "Usage: call 'aunit build' or 'aunit test [ProjectName]' "
}


## Validate env vars set

if [ -z "$AUNIT_HOME" ] || [ -z "$AUNIT_PROJECT_HOME" ] || [ -z "$APAMA_HOME" ] || [ -z "$APAMA_JRE" ]; then
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
	test
else 
	if [[ $1 == "build" ]]; then 
		build
	else
		usage
	fi
fi