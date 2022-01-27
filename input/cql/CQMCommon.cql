/*
@description: Common declarations used in quality measures
*/
library CQMCommon version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Observation Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.143'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

define "Inpatient Encounter":
  [Encounter: "Encounter Inpatient"] EncounterInpatient
		where EncounterInpatient.status = 'finished'
	    and "LengthInDays"(EncounterInpatient.period) <= 120
			and EncounterInpatient.period ends during "Measurement Period"

/*Calculates the difference in calendar days between the start and end of the given interval.*/
define function "LengthInDays"(Value Interval<DateTime> ):
  difference in days between start of Value and end of Value

/*Returns the most recent emergency department visit, if any, that occurs 1 hour or less prior to the given encounter.*/
define function "ED Visit"(TheEncounter FHIR.Encounter ):
  Last(
    [Encounter: "Emergency Department Visit"] EDVisit
      where EDVisit.status = 'finished'
        and EDVisit.period ends 1 hour or less on or before start of FHIRHelpers.ToInterval(TheEncounter.period)
      sort by end of period
    )

/*Hospitalization returns the total interval for admission to discharge for the given encounter, or for the admission of any immediately prior emergency department visit to the discharge of the given encounter.*/
define function "Hospitalization"(TheEncounter FHIR.Encounter ):
  ( "ED Visit"(TheEncounter) ) X
    return
        if X is null then TheEncounter.period
        else Interval[start of FHIRHelpers.ToInterval(X.period), end of FHIRHelpers.ToInterval(TheEncounter.period)]

/*Returns list of all locations within an encounter, including locations for immediately prior ED visit.*/
define function "Hospitalization Locations"(TheEncounter FHIR.Encounter ):
  ( "ED Visit"(TheEncounter) ) EDEncounter
    return
        if EDEncounter is null then TheEncounter.location
        else flatten { EDEncounter.location, TheEncounter.location }

/*Returns the length of stay in days (i.e. the number of days between admission and discharge) for the given encounter, or from the admission of any immediately prior emergency department visit to the discharge of the encounter*/
define function "Hospitalization Length of Stay"(TheEncounter FHIR.Encounter ):
  LengthInDays("Hospitalization"(TheEncounter))

/*Returns admission time for an encounter or for immediately prior emergency department visit.  */
define function "Hospital Admission Time"(TheEncounter FHIR.Encounter ):
  start of "Hospitalization"(TheEncounter)

/*Hospital Discharge Time returns the discharge time for an encounter*/
define function "Hospital Discharge Time"(TheEncounter FHIR.Encounter ):
end of FHIRHelpers.ToInterval(TheEncounter.period)

/*Returns earliest arrival time for an encounter including any prior ED visit. */
define function "Hospital Arrival Time"(TheEncounter FHIR.Encounter ):
  start of FHIRHelpers.ToInterval(First(
  	    ( "Hospitalization Locations"(TheEncounter) ) HospitalLocation
  			sort by start of FHIRHelpers.ToInterval(period)
  	).period)

// TODO - fix these (must fetch Location resources and compare id to reference)
/*Returns the latest departure time for encounter including any prior ED visit. */
/*
define function "Hospital Departure Time"(TheEncounter FHIR.Encounter):
	end of FHIRHelpers.ToInterval(Last(
	    ( "Hospitalization Locations"(TheEncounter) ) HospitalLocation
			sort by start of FHIRHelpers.ToInterval(period)
	).period)
define function "Emergency Department Arrival Time"(TheEncounter FHIR.Encounter):
	start of FHIRHelpers.ToInterval((
	    singleton from (
	        ( "Hospitalization Locations"(TheEncounter) ) HospitalLocation
				where HospitalLocation.type ~ "ER"
		)
	).period)
define function "First Inpatient Intensive Care Unit"(TheEncounter FHIR.Encounter):
	First(
	    ( TheEncounter.location ) HospitalLocation
			where HospitalLocation.type ~ "ICU"
				and HospitalLocation.period during TheEncounter.period
			sort by start of FHIRHelpers.ToInterval(period)
	)
*/

/*Hospitalization with Observation and Outpatient Surgery Service returns the total interval from the start of any immediately prior emergency department visit, outpatient surgery visit or observation visit to the discharge of the given encounter.*/
/* TODO:
define function "HospitalizationWithObservationAndOutpatientSurgeryService"(Encounter "Encounter, Performed" ):
  Encounter Visit
  	let ObsVisit: Last(["Encounter, Performed": "Observation Services"] LastObs
  			where LastObs.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
  			sort by
  			end of relevantPeriod
  	),
  	VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of Visit.relevantPeriod),
  	EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
  			where LastED.relevantPeriod ends 1 hour or less on or before VisitStart
  			sort by
  			end of relevantPeriod
  	),
  	VisitStartWithED: Coalesce(start of EDVisit.relevantPeriod, VisitStart),
  	OutpatientSurgeryVisit: Last(["Encounter, Performed": "Outpatient Surgery Service"] LastSurgeryOP
  			where LastSurgeryOP.relevantPeriod ends 1 hour or less on or before VisitStartWithED
  			sort by
  			end of relevantPeriod
  	)
  	return Interval[Coalesce(start of OutpatientSurgeryVisit.relevantPeriod, VisitStartWithED),
  	end of Visit.relevantPeriod]
*/

/*Hospitalization with Observation returns the total interval from the start of any immediately prior emergency department visit through the observation visit to the discharge of the given encounter*/
define function "HospitalizationWithObservation"(TheEncounter FHIR.Encounter ):
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

/*Returns the tail of the given uri (i.e. everything after the last slash in the URI).*/
define function "GetId"(uri String ):
  Last(Split(uri, '/'))

/*Returns the Condition resources referenced by the diagnosis element of the Encounter*/
define function "EncounterDiagnosis"(Encounter Encounter):
  Encounter.diagnosis D
    return singleton from ([Condition] C where C.id = "GetId"(D.condition.reference))

// Returns the condition that is specified as the principal diagnosis for the encounter
define function "PrincipalDiagnosis"(Encounter Encounter ):
  (singleton from (Encounter.diagnosis D where D.rank = 1)) PD
  		return singleton from ([Condition] C where C.id = "GetId"(PD.condition.reference))

/*Returns the Location resource specified by the given reference*/
define function "GetLocation"(reference Reference):
  singleton from (
    [Location] L where L.id = GetId(reference.reference)
  )
