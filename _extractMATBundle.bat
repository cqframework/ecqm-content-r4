@ECHO OFF
SET tooling_jar=tooling-1.3.1-SNAPSHOT-jar-with-dependencies.jar
SET input_cache_path=%~dp0input-cache
SET mat_bundle=/Users/mholck/Development/ecqm-content-r4/bundles/mat/EXM506_v6_02_Artifacts/measure-json-bundle.json

SET JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8

IF EXIST "%input_cache_path%\%tooling_jar%" (
	ECHO running: JAVA -jar "%input_cache_path%\%tooling_jar%" -ExtractMatBundle %mat_bundle%
	JAVA -jar "%input_cache_path%\%tooling_jar%" -ExtractMatBundle %mat_bundle%
) ELSE If exist "..\%tooling_jar%" (
	ECHO running: JAVA -jar "..\%tooling_jar%" -ExtractMatBundle %mat_bundle%
	JAVA -jar "..\%tooling_jar%" -ExtractMatBundle %mat_bundle%
) ELSE (
	ECHO Tooling JAR NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
)

PAUSE
