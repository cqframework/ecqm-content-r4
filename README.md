# ecqm-content
eCQM Measure Content

This repository contains the measure artifacts for all FHIR based eCQMs. It contains a directory for each supported version of FHIR.
Within each FHIR directory, it is setup like any HL7 FHIR IG project but also includes the CQL files and test data which means the file
structure will be as follows:

```
  |-- fhir401
      |-- _genonce.bat
      |-- _genonce.sh
      |-- _updatePublisher.bat
      |-- _updatePublisher.sh
      |-- ig.ini
      |-- input
          |-- ecqm-content.xml
          |-- pagecontent
              |-- cql
                  |-- EXM124-9.0.000.cql
          |-- resources
              |-- library
                  |-- library-EXM124-9.0.000.json
              |-- measure
                  |-- measure-EXM124-9.0.000.json
          |-- tests
              |-- EXM124-9.0.000
          |-- vocabulary
              |-- valueset
```

