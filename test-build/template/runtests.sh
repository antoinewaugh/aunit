#!/bin/bash

# ########################################
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

## Validate env vars set

if [ -z "$AUNIT_HOME" ] || [ -z "$AUNIT_PROJECT_HOME" ] || [ -z "$APAMA_HOME" ] || [ -z "$APAMA_JRE" ]; then
	error
	exit 1
fi

if [ -z "$JAVA_HOME" ]; then
	export JAVA_HOME=$APAMA_JRE
fi

if [[ -z "$AUNIT_PYTHON_PATH" ]]; then 
	export AUNIT_PYTHON_PATH=$AUNIT_HOME/.__test/lib
	export PYTHONPATH=$AUNIT_PYTHON_PATH:$PYTHONPATH
fi

pushd "${AUNIT_HOME}/.__test"

pysys run

popd

