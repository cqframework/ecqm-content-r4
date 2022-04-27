@ECHO OFF
IF "%1%"=="-h" GOTO printUsage
GOTO refresh

:printUsage
ECHO Usage: %0 [-d] [-s fhir_base_url] [-u]
ECHO.
ECHO Refreshes FHIR documents in place. Optionally loads resources to a FHIR server.
ECHO   -h  Print this help
ECHO   -d  Use default Alphora FHIR sandbox.  Mutually exclusive with -s.
ECHO   -s  Use specificed fhir base url like http://localhost:8080/fhir/.  Mutually exclusive with -d.
ECHO   -u  Unattended mode.  Defaults to false.
GOTO exit0

:refresh
SET tooling_jar=tooling-1.4.1-SNAPSHOT-jar-with-dependencies.jar
SET input_cache_path=%~dp0input-cache
SET ig_resource_path=%~dp0input\ecqm-content-r4.xml
SET unattended=false
SET server_url=

IF "%1%"=="-u" (
	SET unattended=true
) ELSE IF "%2%"=="-u" (
	SET unattended=true
) ELSE IF "%3%"=="-u" (
	SET unattended=true
)

IF "%1%"=="-d" (
	SET server_url=https://cloud.alphora.com/sandbox/r4/cqm/fhir/
	GOTO igpublish
) ELSE IF "%2%"=="-d" (
	SET server_url=https://cloud.alphora.com/sandbox/r4/cqm/fhir/
	GOTO igpublish
)
IF "%1%"=="-s" (
	SET server_url=%2%
	GOTO igpublish
) ELSE IF "%2%"=="-s" (
	SET server_url=%3%
	GOTO igpublish
)

SET fsoption=

:igpublish
SET JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8

IF NOT "%server_url%"=="" (
	SET fsoption=-fs=%server_url%
)

IF "%server_url%"=="" (
	ECHO No FHIR server specified.  Resources will not be loaded.
) ELSE (
	ECHO Resources will be loaded to FHIR server: %server_url%
)

IF EXIST "%input_cache_path%\%tooling_jar%" (
	ECHO running: JAVA -jar "%input_cache_path%\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p %fsoption% -rp input\cql
	JAVA -jar "%input_cache_path%\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p %fsoption% -rp input\cql
) ELSE IF EXIST "..\%tooling_jar%" (
	ECHO running: JAVA -jar "..\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p %fsoption%
	JAVA -jar "..\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p %fsoption%
) ELSE (
	ECHO IG Refresh NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
	GOTO exit1
)

IF "%unattended%"=="true" GOTO exit0

PAUSE

:exit0
EXIT /b 0

:exit1
EXIT /b 1
