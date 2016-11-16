
@echo off

setlocal enabledelayedexpansion

IF "%AUNIT_HOME%"=="" GOTO :error
IF "%APAMA_HOME%"=="" GOTO :error
IF "%APAMA_JRE%"=="" GOTO :error

IF "%AUNIT_TEST_HOME%"=="" (
	SET AUNIT_TEST_HOME="%AUNIT_HOME%\.__test"
)

IF "%AUNIT_PYTHON_PATH%"=="" (
	SET AUNIT_PYTHON_PATH=%AUNIT_TEST_HOME%\lib;%APAMA_HOME%\third_party\python\Lib;%APAMA_HOME%\third_party\python\Lib\site-packages;%APAMA_HOME%\third_party\python\DLLs;
	SET PYTHONPATH=!AUNIT_PYTHON_PATH!;%PYTHONPATH%
)

IF "%JAVA_HOME%"=="" SET JAVA_HOME=%APAMA_JRE%

PUSHD "%AUNIT_TEST_HOME%"

CALL pysys run

POPD

GOTO :end

:error

echo Warning: The following environment variables must be defined: 
echo ""	 
echo AUNIT_HOME
echo APAMA_HOME
echo APAMA_JRE
echo ""
:end