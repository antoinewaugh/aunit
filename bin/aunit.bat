@echo off 

:: ########################################
:: DETERMINE MODE
:: ########################################

IF "%AUNIT_HOME%"=="" GOTO :error
IF "%AUNIT_PROJECT_HOME%"=="" GOTO :error

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
IF "%2"=="" SET PROJECT_FILTER=""

call python "%AUNIT_HOME%/test-build/aunit.py" "%PROJECT_FILTER%"

:: Call Pysys Tests

call "%AUNIT_HOME%/.__test/runtests.bat"

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

echo Warning: AUNIT_HOME and AUNIT_PROJECT_HOME must be defined.

:: ########################################
:: USAGE 
:: ########################################

:usage

ECHO Usage: call "aunit build" or "aunit test [ProjectName]"

:: ########################################
:: END
:: ########################################

:end
