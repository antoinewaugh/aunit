
@echo off

setlocal enabledelayedexpansion

IF "%AUNIT_HOME%"=="" GOTO :error
IF "%AUNIT_PROJECT_HOME%"=="" GOTO :error
IF "%APAMA_HOME%"=="" GOTO :error
IF "%APAMA_JRE%"=="" GOTO :error

IF "%AUNIT_PYTHON_PATH%"=="" (
	SET AUNIT_PYTHON_PATH=%AUNIT_HOME%\.__test\lib
	SET PYTHONPATH=!AUNIT_PYTHON_PATH!;%PYTHONPATH%
)

PUSHD "%AUNIT_HOME%\.__test"

CALL pysys run

POPD

GOTO :end

:error

echo Warning: The following environment variables must be defined: 
echo ""	 
echo AUNIT_HOME
echo AUNIT_PROJECT_HOME
echo APAMA_HOME
echo APAMA_JRE
echo ""
:end