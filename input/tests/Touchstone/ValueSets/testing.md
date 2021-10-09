
Version-specific expand with system-version Mastectomy valueset:

`[POST] http://tx.fhir.org/r4/ValueSet/$expand`

```json
{
    "resourceType": "Parameters",
    "parameter": [
        {
            "name": "valueSet",
            "resource": {
            "resourceType": "ValueSet",
            "id": "125-Mastectomy",
            "url": "http://example.org/fhir/ValueSet/125-Mastectomy",
            "version": "20190315",
            "name": "BilateralMastectomy",
            "title": "Bilateral Mastectomy",
            "status": "active",
            "experimental": true,
            "description": "Bilateral Mastectomy",
            "compose": {
              "include": [
                {
                  "system": "http://snomed.info/sct",
                  "filter": [ {
                    "property": "concept",
                    "op": "is-a",
                    "value": "27865001"
                  } ]
                }
              ]
            }
          }
        },
        {
            "name": "system-version",
            "valueCanonical": "http://snomed.info/sct|http://snomed.info/sct/731000124108/version/20190901"
        }
    ]
}
```

https://r4.ontoserver.csiro.au/fhir/ValueSet/$expand`

// Passed for Mastectomy value set (passed in as a parameter)
http://snomed.info/sct|http://snomed.info/sct/900000000000207008/version/20190731
http://snomed.info/sct|http://snomed.info/sct/900000000000207008/version/20210731

// Returned latest expansion for Mammography, appears to be ignoring the valueSetVersion parameter:
https://r4.ontoserver.csiro.au/fhir/ValueSet/$expand?url=http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018&valueSetVersion=20171222
// The result has version of 20210304, latest version, but it probably can't expand anyway, because it doesn't have the HCPCS code system: http://www.nlm.nih.gov/research/umls/hcpcs

https://fhir.hausamconsulting.com/r4
// No HCPCS Code System
