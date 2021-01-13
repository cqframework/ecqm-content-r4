library CervicalCancerScreeningFHIR version '1.0.002'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.001' called FHIRHelpers
include SupplementalDataElementsFHIR4 version '2.0.000' called SDE
include MATGlobalCommonFunctionsFHIR4 version '5.0.000' called Global
include HospiceFHIR4 version '2.0.000' called Hospice
include AdultOutpatientEncountersFHIR4 version '2.0.000' called AdultOutpatientEncounters

codesystem "LOINC": 'http://loinc.org' 
codesystem "SNOMEDCT": 'http://snomed.info/sct' 

valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207' 
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "Female": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.560.100.2' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Hospice care ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1108.15' 
valueset "HPV Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1059' 
valueset "Hysterectomy with No Residual Cervix": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1014' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Pap Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1017' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Congenital absence of cervix (disorder)": '37687000' from "SNOMEDCT" display 'Congenital absence of cervix (disorder)'
code "Discharge to healthcare facility for hospice care (procedure)": '428371000124100' from "SNOMEDCT" display 'Discharge to healthcare facility for hospice care (procedure)'
code "Discharge to home for hospice care (procedure)": '428361000124107' from "SNOMEDCT" display 'Discharge to home for hospice care (procedure)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Initial Population":
  Patient.gender = 'female'
      	and Global."CalendarAgeInYearsAt"(FHIRHelpers.ToDate(Patient.birthDate), start of "Measurement Period") in Interval[23, 64]
      	and  exists AdultOutpatientEncounters."Qualifying Encounters"

define "Denominator":
  "Initial Population"

define "Denominator Exclusion":
  Hospice."Has Hospice"
      		or exists "Absence of Cervix"

define "Absence of Cervix":
  ([Procedure: "Hysterectomy with No Residual Cervix"] NoCervixProcedure
         where Global."Normalize Interval"(NoCervixProcedure.performed) ends on or before end of "Measurement Period"
           and NoCervixProcedure.status = 'completed'
           )
        union [Condition : "Congenital absence of cervix (disorder)"] NoCervixBirth
      		where Global."Normalize Interval"(NoCervixBirth.onset) starts on or before end of "Measurement Period"
        //    and NoCervixBirth.clinicalStatus ~ ToConcept(Global."active") because this is an excluion, all statuses are acceptable

define "Numerator":
  exists "Cervical Cytology Within 3 Years"
      		or exists "HPV Test Within 5 Years for Women Age 30 and Older"

define "Cervical Cytology Within 3 Years":
  [Observation: "Pap Test"] CervicalCytology
      		where CervicalCytology.value is not null
      			and CervicalCytology.status in { 'final', 'amended', 'corrected', 'preliminary' }
      		  and Global."Normalize Interval"(CervicalCytology.effective) ends 3 years or less on or before end of "Measurement Period"

define "HPV Test Within 5 Years for Women Age 30 and Older":
  [Observation: "HPV Test"] HPVTest
            where HPVTest.value is not null
              and HPVTest.status in { 'final', 'amended', 'corrected', 'preliminary' }
              and  Global."CalendarAgeInYearsAt"(FHIRHelpers.ToDate(Patient.birthDate), start of Global."Normalize Interval"(HPVTest.effective))>= 30
              and Global."Normalize Interval"(HPVTest.effective) ends 5 years or less on or before end of "Measurement Period"

