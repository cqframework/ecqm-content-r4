# Results

Trying to validate the scenario in the connecathon, using the VSAC UAT endpoint:

https://uat-cts.nlm.nih.gov/fhir/r4

Using Postman as a client, I'm first trying to just retrieve the valueset definitions in question:

Bilateral Mastectomy: 2.16.840.1.113883.3.464.1003.198.12.1005 version 20190315
Mammography: 2.16.840.1.113883.3.464.1003.108.12.1018 version 20171222 and 20210304

Direct retrieval of the value sets using a GET works:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005
https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018

Search by _id works:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?_id=2.16.840.1.113883.3.464.1003.108.12.1018

Search by _id and version fails:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?_id=2.16.840.1.113883.3.464.1003.108.12.1018&version=20171222

```json
{
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "error",
            "code": "not-supported",
            "diagnostics": "Invalid request: The FHIR endpoint on this server does not know how to handle GET operation[ValueSet] with parameters [[_id, version]]"
        }
    ]
}
```

Search by _url and version fails:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018&version=20171222

```json
{
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "error",
            "code": "not-supported",
            "diagnostics": "Invalid request: The FHIR endpoint on this server does not know how to handle GET operation[ValueSet] with parameters [[version, url]]"
        }
    ]
}
```

Expand with "id":

Basic expand works

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018/$expand

Expand with valueSetVersion as a parameter executes, however, the returned expansion does not include the expected codes...

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018/$expand?valueSetVersion=20171222

Expand with "url"

version-specific expand:
Attempted using [GET]:

Request:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018&amp;valueSetVersion=20171222

Response:

```json
{
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "error",
            "code": "processing",
            "diagnostics": "HTTP Method GET is not allowed for this operation. Allowed method(s): POST"
        }
    ]
}
```

Attempted using [POST]:

Request:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/$expand

```json
{
    "resourceType": "Parameters",
    "parameter": [
        {
            "name": "url",
            "valueUri": "http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018"
        },
        {
            "name": "valueSetVersion",
            "valueString": "20171222"
        }
    ]
}
```

Response:

```json
{
    "resourceType": "OperationOutcome",
    "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><table class=\"grid\"><tr><td><b>Severity</b></td><td><b>Location</b></td><td><b>Code</b></td><td><b>Details</b></td><td><b>Diagnostics</b></td></tr><tr><td>ERROR</td><td/><td>Required element missing</td><td/><td>A required element is missing.</td></tr></table></div>"
    },
    "issue": [
        {
            "severity": "error",
            "code": "required",
            "diagnostics": "A required element is missing."
        }
    ]
}
```

# Results with FederatedTerminologyClient:

Running an $expand works, but the result is a Parameters
