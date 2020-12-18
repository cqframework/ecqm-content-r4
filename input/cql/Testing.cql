library Testing version '1.0.000'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0'
include MATGlobalCommonFunctions version '4.0.000' called Global
include SupplementalDataElements version '1.0.0' called SDE

valueset "All Opioids": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1196.87'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

define "Opioid Medication":
  [Medication: "All Opioids"]

define "Opioid Medication Dispensed":
  [MedicationDispense: "All Opioids"]
