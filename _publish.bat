@ECHO OFF
SET server_url="http://localhost:8080/fhir/"

IF "%1%"=="-h" GOTO printUsage
GOTO publish

:printUsage
ECHO Usage: %0 [-s fhir_base_url] [-u]
ECHO.
ECHO Runs Refresh and loads resources to a FHIR server.  Defaults to %server_url%.
ECHO   -h  Print this help
ECHO   -s  Use specificed fhir base url like http://localhost:8080/fhir/
ECHO   -u  Unattended mode.  Defaults to false.
GOTO exit0

:publish
SET refresh_script=_refresh.bat
SET unattended=

IF "%1%"=="-u" (
	SET unattended=-u
) ELSE IF "%2%"=="-u" (
	SET unattended=-u
)

IF "%1%"=="-s" (
	SET server_url=%1%
) ELSE IF "%2%"=="-s" (
	SET server_url=%2%
)

SET fsoption=-s %server_url%

IF EXIST "%refresh_script%" (
	ECHO running: %refresh_script% %fsoption% %unattended%
	CALL _refresh.bat %fsoption% %unattended%
) ELSE (
	ECHO Refresh script NOT FOUND.  Please install _refresh.bat.  Aborting...
	GOTO exit1
)

:exit0
EXIT /b 0

:exit1
EXIT /b 1
