library ControllingHighBloodPressureFHIR version '0.0.002'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.001' called FHIRHelpers
include SupplementalDataElementsFHIR4 version '2.0.000' called SDE
include MATGlobalCommonFunctionsFHIR4 version '6.0.000' called Global
include AdultOutpatientEncountersFHIR4 version '2.0.000' called AdultOutpatientEncounters
include HospiceFHIR4 version '2.0.000' called Hospice
include AdvancedIllnessandFrailtyExclusionECQMFHIR4 version '5.12.000' called AdvancedIllness

codesystem "LOINC": 'http://loinc.org'
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'

valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240'
valueset "Chronic Kidney Disease, Stage 5": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1002'
valueset "Dialysis Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1013'
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207'
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209'
valueset "ED": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1085'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "End Stage Renal Disease": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.353'
valueset "ESRD Monthly Outpatient Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1014'
valueset "Essential Hypertension": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.104.12.1011'
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Hospice care ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1108.15'
valueset "Kidney Transplant": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1012'
valueset "Kidney Transplant Recipient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1029'
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Pregnancy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.378'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Vascular Access for Dialysis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1011'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Blood pressure panel with all children optional": '85354-9' from "LOINC" display 'Blood pressure panel with all children optional'
code "Diastolic blood pressure": '8462-4' from "LOINC" display 'Diastolic blood pressure'
code "emergency": 'EMER' from "ActCode" display 'emergency'
code "inpatient acute": 'ACUTE' from "ActCode" display 'inpatient acute'
code "inpatient encounter": 'IMP' from "ActCode" display 'inpatient encounter'
code "inpatient non-acute": 'NONAC' from "ActCode" display 'inpatient non-acute'
code "pre-admission": 'PRENC' from "ActCode" display 'pre-admission'
code "short stay": 'SS' from "ActCode" display 'short stay'
code "Systolic blood pressure": '8480-6' from "LOINC" display 'Systolic blood pressure'

parameter "Measurement Period" Interval<DateTime>
  default Interval [@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Essential Hypertension Diagnosis":
  [Condition: "Essential Hypertension"] Hypertension
                                    where Hypertension.verificationStatus ~ ToConcept(Global."confirmed")
                                    and (Global."Prevalence Period"(Hypertension) overlaps Interval[start of "Measurement Period" - 1 year, end of "Measurement Period"])

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") between 18 and 84
    and exists "Essential Hypertension Diagnosis"
    and exists AdultOutpatientEncounters."Qualifying Encounters"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice"
    or exists "Pregnancy Or Renal Diagnosis Exclusions"
    or (exists "End Stage Renal Disease Procedures"
      or exists "End Stage Renal Disease Encounter")
    or AgeInYearsAt(start of "Measurement Period") >= 65
    and AdvancedIllness."Long Term Care Periods Longer Than 90 Consecutive Days"
    or AdvancedIllness."Advanced Illness and Frailty Exclusion Including Over Age 80"

define "Pregnancy Or Renal Diagnosis Exclusions":
  ([Condition: "Pregnancy"]
                                    union [Condition: "End Stage Renal Disease"]
                                    union [Condition: "Kidney Transplant Recipient"]
                                    union [Condition: "Chronic Kidney Disease, Stage 5"]) PregnancyESRDDiagnosis
                                    where PregnancyESRDDiagnosis.verificationStatus ~ ToConcept(Global."confirmed")
                                    and (Global."Prevalence Period"(PregnancyESRDDiagnosis) overlaps "Measurement Period")

define "End Stage Renal Disease Procedures":
  ([Procedure: "Vascular Access for Dialysis"]
                                  union [Procedure: "Kidney Transplant"]
                                  union [Procedure: "Dialysis Services"]) ESRDProcedure
                                  where ESRDProcedure.status = 'completed'
                                  and Global."Normalize Interval"(ESRDProcedure.performed) starts before end of "Measurement Period"

define "End Stage Renal Disease Encounter":
  [Encounter: "ESRD Monthly Outpatient Services"] ESRDEncounter
                                  where ESRDEncounter.status in {'arrived', 'triaged', 'in-progress', 'onleave', 'finished'}
                                  and ESRDEncounter.period starts before end of "Measurement Period"

define "Blood Pressure Days":
  (("Qualifying Diastolic Blood Pressure Reading" DBPExam
                                  return date from DBPExam.effective)
                                  intersect ("Qualifying Systolic Blood Pressure Reading" SBPExam
                                  return date from SBPExam.effective))

define "Most Recent Blood Pressure Day":
  Max("Blood Pressure Days")

define "Qualifying Diastolic Blood Pressure Reading":
  [Observation: "Blood pressure panel with all children optional"] BloodPressure
                                  where BloodPressure.status.value in {'final', 'amended'}
                                  and Global."Normalize Interval"(BloodPressure.effective) during "Measurement Period"
    and not ((GetEncounter(BloodPressure.encounter)).class.code.value in {'emergency', 'inpatient encounter', 'inpatient acute', 'inpatient non-acute', 'pre-admission', 'short stay'})
                                  and exists (BloodPressure.component DiastolicBP
                                  where FHIRHelpers.ToConcept(DiastolicBP.code) ~ "Diastolic blood pressure"
                                  and DiastolicBP.value.unit = 'mm[Hg]')

define "Qualifying Systolic Blood Pressure Reading":
  [Observation: "Blood pressure panel with all children optional"] BloodPressure
                                    where BloodPressure.status.value in {'final', 'amended'}
                                    and Global."Normalize Interval"(BloodPressure.effective) during "Measurement Period"
    and not (GetEncounter(BloodPressure.encounter).class.code.value in {'emergency', 'inpatient encounter', 'inpatient acute', 'inpatient non-acute', 'pre-admission', 'short stay'})
                                    and exists (BloodPressure.component SystolicBP
                                    where FHIRHelpers.ToConcept(SystolicBP.code) ~ "Systolic blood pressure"
                                    and SystolicBP.value.unit = 'mm[Hg]')

define "Numerator":
  "Has Diastolic Blood Pressure Less Than 90"
                                  and "Has Systolic Blood Pressure Less Than 140"

define "Lowest Diastolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Diastolic Blood Pressure Reading" DBPReading
                            where DBPReading.effective same day as "Most Recent Blood Pressure Day"
                            return singleton from (
                            DBPReading.component C
                              where C.code ~ "Diastolic blood pressure"
                              return C.value as Quantity
                          )
                    			sort ascending
                    	)

define "Lowest Systolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Systolic Blood Pressure Reading" SBPReading
                            where SBPReading.effective same day as "Most Recent Blood Pressure Day"
                           return singleton from (
                            SBPReading.component C
                              where C.code ~ "Systolic blood pressure"
                              return C.value as Quantity
                          )
                          sort ascending
                    	)

define "Has Systolic Blood Pressure Less Than 140":
  "Lowest Systolic Reading on Most Recent Blood Pressure Day".value < 140

define "Has Diastolic Blood Pressure Less Than 90":
  "Lowest Diastolic Reading on Most Recent Blood Pressure Day"
                    .value < 90

define function "GetEncounter"(ref Reference ):
  singleton from (AdultOutpatientEncounters."Qualifying Encounters" x where x.id = Global."GetId"(ref.reference))
