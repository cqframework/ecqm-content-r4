# ecqm-content-r4
eCQM Measure Content (FHIR R4 v4.0.1)

This repository contains measure artifacts for FHIR based eCQMs published in May of 2020 for the 2021 reporting year. These measures and shared libraries are translated from the QDM-based versions of eCQMs published in May 2020 for the 2021 reporting year, and have specific versions, especially for the shared libraries, appropriate to the content for that publication update. For current translation efforts focused on the 2021 publication and the 2022 reporting year, see the [eCQM Content R4 2021](https://github.com/cqframework/ecqm-content-r4-2021) repository.

Commits to this repository will automatically trigger a build of the continuous integration build, available here:

https://build.fhir.org/ig/cqframework/ecqm-content-r4

## Content Index

The following table provides an index to the currently available library content in this implementation guide:

### Shared Libraries

|Library|Version|Status|
|----|----|----|
|[AdultOutpatientEncountersFHIR4](input/cql/AdultOutpatientEncountersFHIR4.cql)|2.0.000|Active|
|[AdvancedIllnessandFrailtyExclusionECQMFHIR4](input/cql/AdvancedIllnessandFrailtyExclusionECQMFHIR4.cql)|5.12.000|Active|
|[FHIRHelpers](input/cql/FHIRHelpers.cql)|4.0.001|Active|
|[HospiceFHIR4](input/cql/HospiceFHIR4.cql)|2.0.000|Active|
|[MATGlobalCommonFunctionsFHIR4](input/cql/MATGlobalCommonFunctionsFHIR4.cql)|5.0.000|Active|
|[SupplementalDataElementsFHIR4](input/cql/SupplementalDataElementsFHIR4.cql)|2.0.000|Active|
|[TJCOverallFHIR](input/cql/TJCOverallFHIR.cql)|1.1.000|Active|

### Measure Libraries

|Library|Version|Status|
|----|----|----|
|[BreastCancerScreeningFHIR](input/cql/BreastCancerScreeningFHIR.cql)|2.0.003|Draft|
|[CMS111](input/cql/CMS111.cql)|0.0.013|Draft|
|[CervicalCancerScreeningFHIR](input/cql/CervicalCancerScreeningFHIR.cql)|0.0.001|Draft|
|[ChlamydiaScreeningForWomenFHIR](input/cql/ChlamydiaScreeningForWomenFHIR.cql)|0.0.001|Draft|
|[ColorectalCancerScreeningsFHIR](input/cql/ColorectalCancerScreeningsFHIR.cql)|0.0.001|Draft|
|[DiabetesHemoglobinA1cHbA1cPoorControl9FHIR](input/cql/DiabetesHemoglobinA1cHbA1cPoorControl9FHIR.cql)|0.0.001|Draft|
|[DischargedonAntithromboticTherapyFHIR](input/cql/DischargedonAntithromboticTherapyFHIR.cql)|1.0.001|Draft|
|[EXM506](input/cql/EXM506.cql)|0.0.002|Draft|
|[FHIR347](input/cql/FHIR347.cql)|0.1.009|Draft|
|[HybridHWRFHIR](input/cql/HybridHWRFHIR.cql)|1.2.002|Draft|
|[PrimaryCariesPreventionasOfferedbyPCPsincludingDentistsFHIR](input/cql/PrimaryCariesPreventionasOfferedbyPCPsincludingDentistsFHIR.cql)|0.0.002|Draft|

## Repository Structure

It is setup like any HL7 FHIR IG project but also includes the CQL files and test data which means the file structure will be as follows:

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
       |-- MAT
           |--EXM124bundle files
       |-- measure
           |--EXM124
   |-- input
       |-- ecqm-content-r4.xml
       |-- cql
           |-- EXM124.cql
       |-- pagecontent
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

## Refresh IG Processing

The CQF Tooling provides "refresh" tooling that performs the following functions:

* Translates and validates all CQL source files
* Packages CQL and ELM content in the corresponding FHIR resources
* Refreshes generated content for each knowledge artifact (Library, Measure, PlanDefinition, ActivityDefinition) including parameters, dependencies, and effective data requirements

Then run the `_refresh` command to refresh the implementation guide content with the new content, and then run `_genonce` to run the publication tooling on the implementation guide (the same process that the continuous integration build uses to publish the implementation guide when commits are made to this repository).
