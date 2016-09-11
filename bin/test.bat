@echo off

IF "%AUNIT_HOME%"=="" GOTO :error
IF "%AUNIT_PROJECT_HOME%"=="" GOTO :error

:: Generate Pysys Tests
call python "%AUNIT_HOME%/test-build/aunit.py" -a "%AUNIT_HOME%" -p "%AUNIT_PROJECT_HOME%"

:: Call Pysys Tests
call "%AUNIT_HOME%/.__test/runtests.bat"

GOTO :end

:error
echo Warning: AUNIT_HOME and AUNIT_PROJECT_HOME must be defined.

:end