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

NOTE: Search by _id should not be part of the tests here.

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?_id=2.16.840.1.113883.3.464.1003.108.12.1018

But only returns the latest version, so it's not possible to get a list of available "definition" versions of the value set.

Also the value set resources returned only have metadata, they do not include the full content of the resource.

Search by _id and version succeeds:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?_id=2.16.840.1.113883.3.464.1003.108.12.1018&version=20171222

But only returns the metadata, not the full content of the resource.

Search by url succeeds:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018

1. But only returns the latest definition version, which is an incomplete result because consumers have no way of obtaining a list of versions for the resource (both "definition" and "expansion" versions)

2. The returned resource only contains basic metadata (not the compose, and not any expansion content)
This is fine to provide subsetted resource content, but the SUBSETTED tag SHOULD be used to indicate the resource is incomplete.
https://hl7.org/fhir/search.html#elements

Search by _url and version succeeds:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018&version=20171222

3. A potential workaround for the subsetted resource is to use the _summary=false flag:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018&version=20171222&_summary=false

This returned the same result, but you could use that in the API to allow users to indicate they really do want the full resource.

4. Tracker to Vocab: How do you represent an extensional value set with 10s of 1000s of codes....

5. Tracker to Vocab: How do you determine what expansion identifiers are available for a given value set URL?

But only returns the metadata, not the full content of the resource.

https://ontoserver.csiro.au/vstool/

Expand with "id":

Basic expand works

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018/$expand

Expand with valueSetVersion as a parameter executes, however, the returned expansion does not include the expected codes...

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018/$expand?valueSetVersion=20171222

1. The problem is that the expansion is actually a grouping value set and the member value set (1046) actually results in a test of system versions when a system version is not specified, rather than the intended test of value set definition versions. So I need to go back and find an actual test of valueset version differences (HbA1C) and be sure to specify consistent code system versions (or at least that the codes involved are not changed between code system versions used).

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
            "diagnostics": "One or more parameters or parameter combinations are not supported."
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

Succeeds, but gives the same result as the above value set expansion (missing the G0202 codes but for the same reason)

Test of Same ValueSetVersion expanded with different systemVersion:

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005/$expand

Expand succeeds (using GET)

For the Bilateral Mastectomy value set, the v10 expansion includes new codes:

    836436008: Simple mastectomy of bilateral breasts using robotic assistance (procedure)
    870629001: Bilateral mastectomy for female to male transsexual (procedure)


https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005&valueSetVersion=20190315&system-version=http://snomed.info/sct|http://snomed.info/sct/731000124108/version/20190901

Using GET: 400 with no response

Using POST: https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/$expand

```json
{
    "resourceType": "Parameters",
    "parameter": [
        {
            "name": "url",
            "valueUri": "http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005"
        },
        {
            "name": "valueSetVersion",
            "valueString": "20190315"
        },
        {
            "name": "system-version",
            "valueCanonical": "http://snomed.info/sct|http://snomed.info/sct/731000124108/version/20200901"
        }
    ]
}
```

1. Seems to have ignored the system-version parameter since the new codes are in the expansion

https://uat-cts.nlm.nih.gov/fhir/r4/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005&valueSetVersion=20190315&system-version=http://snomed.info/sct|http://snomed.info/sct/731000124108/version/20200901

### Outstanding Questions

* Search by URL should return all versions with that URL, otherwise there is no way to get the list of versions for a given value set URL
* If searches return a SUBSETTED resource by default, should the server should allow the _summary=false parameter to request full resources?
* Given the `id` of a ValueSet is the OID, how can I retrieve specific versions of a ValueSet?
* How can I retrieve a list of available expansions for a given ValueSet URL?
* Can I use a GET to invoke $expand with both the url and valueSetVersion parameters? (Connectathon testing resulted in an error)



# Server 2

https://fhir.hausamconsulting.com/r4/

https://fhir.hausamconsulting.com/r4/ValueSet/$expand


http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.11.1005


Using POST:
https://fhir.hausamconsulting.com/r4/ValueSet/$expand

```json
{
    "resourceType": "Parameters",
    "parameter": [
        {
            "name": "url",
            "valueUri": "http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.11.1005"
        },
        {
            "name": "valueSetVersion",
            "valueString": "20210220"
        },
        {
            "name": "system-version",
            "valueCanonical": "http://snomed.info/sct|http://snomed.info/sct/731000124108/version/20200901"
        }
    ]
}
```

```json
{
    "resourceType": "OperationOutcome",
    "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><h1>Operation Outcome</h1><table border=\"0\"><tr><td style=\"font-weight: bold;\">ERROR</td><td>[]</td><td><pre>Failed to call access method: java.lang.NullPointerException</pre></td>\n\t\t\t</tr>\n\t\t</table>\n\t</div>"
    },
    "issue": [
        {
            "severity": "error",
            "code": "processing",
            "diagnostics": "Failed to call access method: java.lang.NullPointerException"
        }
    ]
}
```

Receives this result no matter how it's invoked, not sure what the problem is

# Server 3

https://terminz.azurewebsites.net/fhir/

ValueSet is not available, attempting to POST the value set returned a Bundle of ValueSet resources available on the server but did not create the requested valueset.


# Results with FederatedTerminologyClient:

Running an $expand works, but the result is a Parameters
