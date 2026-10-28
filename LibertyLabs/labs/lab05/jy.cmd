@echo off
rem jy.cmd - runs a Jython script against Liberty's JMX REST connector.
rem   jy.cmd 01_connect.py
rem Needs: JAVA_HOME, Liberty at WLP_HOME, jython-standalone jar in C:\LibertyLabs\jython
setlocal
if "%WLP_HOME%"=="" set WLP_HOME=C:\IBM\wlp
if "%JAVA_HOME%"=="" set JAVA_HOME=C:\IBM\semeru-21
for %%J in (C:\LibertyLabs\jython\jython-standalone-*.jar) do set JYTHON_JAR=%%J
if "%JYTHON_JAR%"=="" ( echo Jython jar not found in C:\LibertyLabs\jython & exit /b 1 )
rem python.path: this folder (lab helpers) and Liberty's own Jython helper (restConnector.py)
set PYPATH=%~dp0;%WLP_HOME%\clients\jython;%WLP_HOME%\clients\jython\lib
"%JAVA_HOME%\bin\java" -cp "%JYTHON_JAR%;%WLP_HOME%\clients\restConnector.jar" -Dpython.path="%PYPATH%" org.python.util.jython %*
