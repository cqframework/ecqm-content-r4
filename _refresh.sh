#!/bin/bash
#DO NOT EDIT WITH WINDOWS

usage () {
    cat <<HELP_USAGE

    $0  [-d] [-s <fhir_base_url>] [-u]

   Refreshes FHIR documents in place. Optionally loads resources to a FHIR server.

   -h  Print this help
   -d  Use default Alphora FHIR sandbox.  Mutually exclusive with -s.
   -s  Use specificed fhir base url like http://localhost:8080/fhir/.  Mutually exclusive with -d.
   -u  Unattended mode.  Defaults to false.
HELP_USAGE
	exit 0
}

tooling_jar=tooling-1.4.1-SNAPSHOT-jar-with-dependencies.jar
input_cache_path=./input-cache
ig_resource_path=./input/ecqm-content-r4.xml
unattended=false

while getopts hds:u flag
do
    case "${flag}" in
		d) server_url="https://cloud.alphora.com/sandbox/r4/cqm/fhir/";; 
		h) usage;;
        s) server_url=${OPTARG};;
		u) unattended=true;;
    esac
done

fsoption=""
if [ ! -z "${server_url}" ]; then
	fsoption="-fs ${server_url}"
fi

set -e

if [ -z "${server_url}" ]; then
	echo "No FHIR server specified.  Resources will not be loaded."
else
	echo "Resources will be loaded to FHIR server: ${server_url}."
fi

tooling=$input_cache_path/$tooling_jar
if test -f "$tooling"; then
	echo "running: java -jar $tooling -RefreshIG -ini=$PWD/ig.ini -t -d -p $fsoption"
	java -jar $tooling -RefreshIG -ini="$PWD"/ig.ini -t -d -p $fsoption
else
	tooling=../$tooling_jar
	echo $tooling
	if test -f "$tooling"; then
		echo "running: java -jar $tooling -RefreshIG -ini=$PWD/ig.ini -t -d -p $fsoption -rp input/cql"
		java -jar $tooling -RefreshIG -ini="$PWD"/ig.ini -t -d -p $fsoption -rp input/cql
	else
		echo IG Refresh NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
	fi
fi

if [ "$unattended" = false ] ; then
	read -p "Press any key to resume ..."
fi
