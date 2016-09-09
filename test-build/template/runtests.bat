
@echo off

IF "%AUNIT_HOME%"=="" GOTO :error
IF "%APAMA_HOME%"=="" GOTO :error

SET RT_PYTHON_PATH=%AUNIT_HOME%\.__test\lib
SET PYTHONPATH=%RT_PYTHON_PATH%;%PYTHONPATH%

PUSHD %AUNIT_HOME%\.__test

CALL pysys run

POPD

GOTO :end

:error
echo Warning: AUNIT_HOME and APAMA_HOME must be defined.

:end