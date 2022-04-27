#!/bin/bash
#DO NOT EDIT WITH WINDOWS

server_url="http://localhost:8080/fhir/"

usage () {
    cat <<HELP_USAGE

    $0  [-s <fhir_base_url>] [-u]

   Runs Refresh and loads resources to a FHIR server.  Defaults to $server_url.
   
   -h  Print this help
   -s  Use specificed fhir base url like http://localhost:8080/fhir/
   -u  Unattended mode.  Defaults to false.
HELP_USAGE
	exit 0
}

refresh_script="_refresh.sh"
unattended=""

while getopts hs:u flag
do
    case "${flag}" in
		h) usage;;
        s) server_url=${OPTARG};;
		u) unattended="-u";;
    esac
done

fsoption="-s $server_url"

set -e

if test -f "$refresh_script"; then
	echo "running: ./_refresh.sh $fsoption $unattended"
	./_refresh.sh "$fsoption" "$unattended"
else
	echo Publish script NOT FOUND.  Please install _publish.sh.  Aborting...
fi
