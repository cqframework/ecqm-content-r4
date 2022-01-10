@ECHO OFF
SET tooling_jar=tooling-1.4.0-jar-with-dependencies.jar
SET input_cache_path=%~dp0input-cache
SET ig_resource_path=%~dp0input\ecqm-content-r4.xml

ECHO Checking internet connection...
PING tx.fhir.org -n 1 -w 1000 | FINDSTR TTL && GOTO isonline
ECHO We're offline...
SET fsoption=
GOTO igpublish

:isonline
ECHO We're online, setting publish to the Connectathon sandbox FHIR server (DISABLED TEMPORARILY)
SET fsoption=
REM Disabled temporarily due to an error in the CQF Tooling upload
REM -fs http://cqm-sandbox.alphora.com/cqf-ruler-r4/fhir/

:igpublish

SET JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8

IF EXIST "%input_cache_path%\%tooling_jar%" (
	ECHO running: JAVA -jar "%input_cache_path%\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p
	JAVA -jar "%input_cache_path%\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p %fsoption%
) ELSE If exist "..\%tooling_jar%" (
	ECHO running: JAVA -jar "..\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p
	JAVA -jar "..\%tooling_jar%" -RefreshIG -ini=%~dp0ig.ini -t -d -p %fsoption%
) ELSE (
	ECHO IG Refresh NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
)

PAUSE
