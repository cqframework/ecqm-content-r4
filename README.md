# ecqm-content-r4
eCQM Measure Content (FHIR release 4)

This repository contains the measure artifacts for all FHIR based eCQMs. It is setup like any HL7 FHIR IG project but also includes the CQL files and test data which means the file structure will be as follows:

```
   |-- _genonce.bat
   |-- _genonce.sh
   |-- _refresh.bat
   |-- _refresh.sh
   |-- _updatePublisher.bat
   |-- _updatePublisher.sh
   |-- _updateCQFTooling.bat
   |-- _updateCQFTooling.sh
   |-- ig.ini
   |-- bundles
       |-- measure
           |--EXM124
   |-- input
       |-- ecqm-content-r4.xml
       |-- pagecontent
           |-- cql
               |-- EXM124.cql
       |-- resources
           |-- library
               |-- EXM124.json
           |-- measure
               |-- EXM124.json
       |-- tests
           |-- measure
               |-- EXM124
       |-- vocabulary
           |-- valueset
```

## Refresh IG Processing

Note that there are known issues with the refresh ig processing of MAT-extracted
measure content that we are still working through as part of Connectathon 26 (2021-JAN).

## Extracting MAT Packages

The CQF Tooling provides support for extracting a MAT exported package into the
directories of this repository so that the measure is included in the published
implementation guide. To do this, place the MAT export files (unzipped) in a
directory in the `bundles\mat` directory, and then run the following tooling
command:

```
[tooling-jar] -ExtractMatBundle bundles\mat\[bundle-directory]\[bundle-file]
```

For example:

```
input-cache\tooling-1.3.1-SNAPSHOT-jar-with-dependencies.jar -ExtractMATBundle bundles\mat\CLONE124_v6_03-Artifacts\measure-json-bundle.json
```

Then run the `_refresh` command to refresh the implementation guide content with
the new content, and then run `_genonce` to publish the implementation guide.
