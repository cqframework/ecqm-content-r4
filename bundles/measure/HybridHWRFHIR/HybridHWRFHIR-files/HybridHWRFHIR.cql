library HybridHWRFHIR version '1.2.002'

/*Specification based on CMS529v1-QDM specifications*/

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.001' called FHIRHelpers
include SupplementalDataElementsFHIR4 version '2.0.000' called SDE
include MATGlobalCommonFunctionsFHIR4 version '6.0.000' called Global

codesystem "LOINC": 'http://loinc.org'

valueset "Bicarbonate lab test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.139'
valueset "Body temperature": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.152'
valueset "Body weight": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.159'
valueset "Creatinine lab test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.2363'
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837'
valueset "Glucose lab test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.134'
valueset "Hematocrit lab test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.114'
valueset "Medicare payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1104.10'
valueset "Observation Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.143'
valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1'
valueset "Payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.3591'
valueset "Potassium lab test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.117'
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836'
valueset "Sodium lab test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.119'
valueset "White blood cells count lab test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.129'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Heart rate": '8867-4' from "LOINC" display 'Heart rate'
code "Oxygen saturation in Arterial blood by Pulse oximetry": '59408-5' from "LOINC" display 'Oxygen saturation in Arterial blood by Pulse oximetry'
code "Respiratory rate": '9279-1' from "LOINC" display 'Respiratory rate'
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

define "Initial Population":
  exists "Inpatient Encounters"

define "Inpatient Encounters":
  from
                       ["Encounter": "Encounter Inpatient"] InpatientEncounter,
                       ["Coverage": "Medicare payer"] Payer
                        where (Payer.period overlaps before InpatientEncounter.period
                        or start of Payer.period same as start of InpatientEncounter.period)
                        and end of Payer.period != start of InpatientEncounter.period
                        and "HospitalizationWithObservationLengthofStay" (InpatientEncounter) < 365
                        and InpatientEncounter.period ends during "Measurement Period"
                        and AgeInYearsAt(start of "Measurement Period") >= 65
                    return InpatientEncounter

define "Results":
  flatten{
                    // First physical exams (vital signs)
                      "FirstPhysicalExamWithEncounterId"(([Observation: "Heart rate"] O where O.effective is not null sort by effective.value), 'FirstHeartRate'),
                                  "FirstPhysicalExamWithEncounterId"(([Observation: "Systolic blood pressure"] O where O.effective is not null sort by effective.value), 'FirstSystolicBP'),
                                  "FirstPhysicalExamWithEncounterId"(([Observation: "Respiratory rate"] O where O.effective is not null sort by effective.value), 'FirstRespRate'),
                                  "FirstPhysicalExamWithEncounterId"(([Observation: "Body temperature"] O where O.effective is not null sort by effective.value), 'FirstTeperature'),
                                  "FirstPhysicalExamWithEncounterId"(([Observation: "Oxygen saturation in Arterial blood by Pulse oximetry"] O where O.effective is not null sort by effective.value), 'FirstO2Saturation'),

                    // First weight using lab test timing
                        "FirstPhysicalExamWithEncounterIdUsingLabTiming"(([Observation: "Body weight"] O where O.effective is not null sort by effective.value), 'FirstWeight'),
                    //First lab tests
                         "FirstLabTestWithEncounterId"(([Observation: "Hematocrit lab test"] O where O.issued is not null sort by issued.value), 'FirstHematocrit'),
                          "FirstLabTestWithEncounterId"(([Observation: "White blood cells count lab test"] O where O.issued is not null sort by issued.value), 'FirstWhiteBloodCell'),
                          "FirstLabTestWithEncounterId"(([Observation: "Potassium lab test"] O where O.issued is not null sort by issued.value), 'FirstPotassium'),
                          "FirstLabTestWithEncounterId"(([Observation: "Sodium lab test"] O where O.issued is not null sort by issued.value), 'FirstSodium'),
                          "FirstLabTestWithEncounterId"(([Observation: "Bicarbonate lab test"] O where O.issued is not null sort by issued.value), 'FirstBicarbonate'),
                          "FirstLabTestWithEncounterId"(([Observation: "Creatinine lab test"] O where O.issued is not null sort by issued.value), 'FirstCreatinine'),
                          "FirstLabTestWithEncounterId"(([Observation: "Glucose lab test"] O where O.issued is not null sort by issued.value), 'FirstGlucose')
              }

define function "FirstPhysicalExamWithEncounterIdUsingLabTiming"(ExamList List<FHIR.Observation>, CCDE String ):
  "Inpatient Encounters" Encounter
    let firstexamwithlabtiming: First(ExamList Exam
        where Exam.effective during Interval[start of Encounter.period - 1440 minutes, start of Encounter.period + 1440 minutes]
  and Exam.status in {'final', 'amended', 'preliminary'})
    return '\r\n' & CCDE & ',' & Encounter.id & ',' & ToString(firstexamwithlabtiming.value as Quantity) & ',' & ToString(firstexamwithlabtiming.effective)

define function "FirstPhysicalExamWithEncounterId"(ExamList List<FHIR.Observation>, CCDE String ):
  "Inpatient Encounters" Encounter
    let firstexam: First(ExamList Exam
        where Exam.effective during Interval[start of Encounter.period - 1440 minutes, start of Encounter.period + 120 minutes]
        and Exam.status in {'final', 'amended', 'preliminary'})
    return '\r\n' & CCDE & ',' & Encounter.id & ',' & ToString(firstexam.value as Quantity) & ',' & ToString(firstexam.effective)

define function "FirstLabTestWithEncounterId"(LabList List<FHIR.Observation>, CCDE String ):
  "Inpatient Encounters" Encounter
    let firstlab: First(LabList Lab
        where Lab.issued during Interval[start of Encounter.period - 1440 minutes, start of Encounter.period + 1440 minutes]
        and Lab.status in {'final', 'amended', 'preliminary'})
    return '\r\n' & CCDE & ',' & Encounter.id & ',' & ToString(firstlab.value as Quantity) & ',' & ToString(firstlab.issued)

define function "CalendarAgeInYearsAt"(BirthDateTime DateTime, AsOf DateTime ):
  years between ToDate(BirthDateTime)and ToDate(AsOf)

define function "ToDate"(Value DateTime ):
  DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezoneoffset from Value)

define function "LengthOfStay"(Stay Interval<DateTime> ):
  difference in days between start of Stay and
  end of Stay

define function "LengthInDays"(Value Interval<DateTime> ):
  difference in days between start of Value and end of Value

define function "HospitalizationWithObservation"(TheEncounter Encounter ):
  TheEncounter Visit
    		let ObsVisit: Last([Encounter: "Observation Services"] LastObs
    				where LastObs.period ends 1 hour or less on or before start of Visit.period
    				sort by end of period
    			),
    			VisitStart: Coalesce(start of ObsVisit.period, start of Visit.period),
    			EDVisit: Last([Encounter: "Emergency Department Visit"] LastED
    				where LastED.period ends 1 hour or less on or before VisitStart
    				sort by end of period
    			)
    		return Interval[Coalesce(start of EDVisit.period, VisitStart), end of Visit.period]

define function "HospitalizationWithObservationLengthofStay"(Encounter Encounter ):
  "LengthInDays"("HospitalizationWithObservation"(Encounter))
