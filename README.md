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
   |-- _updateRefreshIG.bat
   |-- _updateRefreshIG.sh
   |-- ig.ini
   |-- input
       |-- ecqm-content-r4.xml
       |-- pagecontent
           |-- cql
               |-- EXM124v8.cql
       |-- resources
           |-- library
               |-- EXM124v8.json
           |-- measure
               |-- EXM124v8.json
       |-- tests
           |-- measure
               |-- EXM124v8
       |-- vocabulary
           |-- valueset
```

