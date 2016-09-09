@echo off 

IF "%AUNIT_HOME%"=="" GOTO :error
IF "%AUNIT_PROJECT_HOME%"=="" GOTO :error

:: Generate project packages
call ant -q -f %AUNIT_HOME%\project-build\ant_macros\build.xml

GOTO :end

:error
echo Warning: AUNIT_HOME and AUNIT_PROJECT_HOME must be defined.

:end

