# Results

Trying to validate the scenario in the connecathon, using the VSAC UAT endpoint:

https://uat-cts.nlm.nih.gov/fhir

Using Postman as a client, I'm first trying to just retrieve the valueset definitions in question:

Bilateral Mastectomy: 2.16.840.1.113883.3.464.1003.198.12.1005 version 20190315
Mammography: 2.16.840.1.113883.3.464.1003.108.12.1018 version 20171222 and 20210304
Below Normal Medications: 2.16.840.1.113883.3.600.1.1499

## Read

Direct retrieval of the value sets using a GET works:

https://uat-cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005 // Succeeded
https://uat-cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018 // Succeeded, returned version 20210304
https://uat-cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499 // Succeeded, returned version 20220217

## Search by _id

Search by _id works:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?_id=2.16.840.1.113883.3.464.1003.108.12.1018

But only returns the latest version, see the discussion about server (logical) ids below

Search by _id and version succeeds:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?_id=2.16.840.1.113883.3.464.1003.108.12.1018&version=20171222

But only returns the metadata, not the full content of the resource.

## Search by _url

Search by url succeeds:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018

The result provides the list of available definition versions, but returns SUBSETTED resources

1. If the behavior is that the server is returning "summary" resources, the following elements are marked summary in the FHIR R4 ValueSet resource:

id
meta
implicitRules
url
identifier
version
name
title
status
experimental
date
publisher
contact
useContext
jurisdiction
immutable
compose.lockedDate
compse.inactive
compose.include
compose.include.system
compose.include.version
compose.include.filter

2. Given that the result is SUBSETTED resources, to retrieve the actual definition version requires clients to use the id to request the full resource using a read interaction. However, each resource in the result has the same value for the "id" element (the server or logical id of the resource). This makes it impossible to retrieve the full definition of a ValueSet for anything but the latest version.

Each resource needs a separate logical id. Propose some concatenation of the OID and the version:

2.16.840.1.113883.3.464.1003.108.12.1018-20171222

Note that it should still be possible to resolve the canonical URL to the latest version, as the current behavior, this is a super useful feature for authors and implementers and changing the underlying resource ids to include the version should be done in such a way that the id without the version extension redirects to the id with the latest version.

3. Given that the result is SUBSETTED resources, to retrieve the full definition for each version requires multiple API calls. It should be possible to request the full resource definition if the use case requires it. Propose using the _summary=false flag to communicate this intent.

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018&version=20171222&_summary=false

4. Tracker to Vocab: How do you represent an extensional value set with 10s of 1000s of codes.... (Standards team to followup)

5. Tracker to Vocab: How do you determine what expansion identifiers are available for a given value set URL? (Standards team to followup)

Can propose an "availableExpansion" extension that specifies an expansion identifier:

availableExpansion 0..* uri

In the context of the Measure Terminology Service, the Expansion Identifiers can be appropriately provided as part of the Quality Program library

## $expand

Version-specific Expansion
https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499

20220217
20210220
20170504
20160331
20150430
20140502
...

https://uat-cts.nlm.nih.gov/fhir/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499
// Succeeded, returned 20220217 and used latest RxNorm version

https://uat-cts.nlm.nih.gov/fhir/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499&system-version=http://www.nlm.nih.gov/research/umls/rxnorm|10012018
1. Succeeded, but the contains does not include the system version (where it does if you don't ask for a specific system-version)

2. If the system-version isn't recognized, an unhelpful error is provided:
https://uat-cts.nlm.nih.gov/fhir/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499&system-version=http://www.nlm.nih.gov/research/umls/rxnorm|01062020

```
{
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "fatal",
            "code": "invalid",
            "diagnostics": "A JSONObject text must begin with '{' at 1 [character 2 line 1]"
        }
    ]
}
```

https://uat-cts.nlm.nih.gov/fhir/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499&system-version=http://www.nlm.nih.gov/research/umls/rxnorm|01012020

3. The published RxNorm files are 01062020, but the version that works 01012020

https://uat-cts.nlm.nih.gov/fhir/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499&expansion=eCQM%20Update%2017-05-05

4. Fails, invalid parameter combintation, have to invoke at the instance level (on track to support)

https://uat-cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1499/$expand?expansion=eCQM%20Update%202017-05-05

5. Expansion parameter succeeded, the only issue is the "identifier" of the expansion doesn't match the expansion identifier passed. It seems to be correct, and the "manifest" parameter is great, it might need encoding (%20 vs ` `)

## CodeSystem

CodeSystem search by url:

https://uat-cts.nlm.nih.gov/fhir/CodeSystem?url=http://www.nlm.nih.gov/research/umls/rxnorm

// Succeeds and provides the correct version string (steward-specified) for the code system version

1. Has the same issue with logical ids as ValueSets, every returned resource has the same logical id. Propose the same approach as the ValueSet, append the version with a `-`.

https://uat-cts.nlm.nih.gov/fhir/CodeSystem?url=http://snomed.info/sct

// Succeeds and provides the correct version string (steward-specified) for the code system version
