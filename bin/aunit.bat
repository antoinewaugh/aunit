@echo off 

:: ########################################
:: DETERMINE MODE
:: ########################################

IF "%AUNIT_HOME%"=="" GOTO :error
IF "%APAMA_HOME%"=="" GOTO :error
IF "%APAMA_JRE%"=="" GOTO :error

IF "%JAVA_HOME%"=="" SET JAVA_HOME=%APAMA_JRE%

:: Check 'mode' being run
IF "%1"=="build" GOTO :build
IF "%1"=="test" GOTO :test

GOTO :usage 

:: ########################################
:: TEST
:: ########################################

:test

:: Generate Pysys Tests

SET PROJECT_FILTER=-s%2
SET FILE_FILTER=-f%3
IF "%2"=="" SET PROJECT_FILTER=""
IF "%3"=="" SET FILE_FILTER=""

IF "%AUNIT_TEST_HOME%"=="" (
	SET AUNIT_TEST_HOME="%AUNIT_HOME%\.__test"
)

IF "%AUNIT_BUNDLE_HOME%"=="" (
	SET AUNIT_BUNDLE_HOME="%AUNIT_HOME%\.__repository"
)

call python "%AUNIT_HOME%/test-build/aunit.py" "%PROJECT_FILTER%" "%FILE_FILTER%" 
:: Call Pysys Tests

call %AUNIT_TEST_HOME%\runtests.bat

GOTO :end

:: ########################################
:: BUILD
:: ########################################

:build

:: Generate project packages
call ant -q -f "%AUNIT_HOME%\project-build\ant_macros\build.xml"

GOTO :end

:: ########################################
:: ERROR
:: ########################################

:error

echo ""
echo Warning: The following environment variables must be defined: 
echo ""
echo AUNIT_HOME
echo APAMA_HOME
echo APAMA_JRE
echo ""

:: ########################################
:: USAGE 
:: ########################################

:usage

ECHO Usage: call "aunit build" or "aunit test [ProjectName TestFile]"

:: ########################################
:: END
:: ########################################

:end
