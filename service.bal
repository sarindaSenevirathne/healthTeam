import wso2/healthcare.fhir.r4;
import ballerina/io;
import ballerina/log;
import ballerina/http;

final r4:ResourceAPIConfig apiConfig = {
    resourceType: "Patient",
    profiles: ["http://hl7.org/fhir/StructureDefinition/Patient"],
    defaultProfile: (),
    searchParameters: [
        {
            name: "active",
            active: true
        }, 
        {
            name: "address",
            active: false
        },
        {
            name: "address-city",
            active: true
        },
        {
            name: "name",
            active: true,
            preProcessor: patientNameSearchPreProcessor
        }
    ],
    operations: [
        {
            name: "validate",
            active: true
        }
    ],
    serverConfig: ()
};


# A service representing a network-accessible API
# bound to port `9090`.
@http:ServiceConfig{
    interceptors: [
        new r4:FHIRReadRequestInterceptor(apiConfig), 
        new r4:FHIRVReadRequestInterceptor(apiConfig), 
        new r4:FHIRUpdateRequestInterceptor(apiConfig), 
        new r4:FHIRPatchRequestInterceptor(apiConfig), 
        new r4:FHIRDeleteRequestInterceptor(apiConfig), 
        new r4:FHIRInstanceHistorySearchRequestInterceptor(apiConfig), 
        new r4:FHIRCreateRequestInterceptor(apiConfig), 
        new r4:FHIRSearchRequestInterceptor(apiConfig),
        new r4:FHIRRequestErrorInterceptor(),
        new r4:FHIRResponseInterceptor(apiConfig),
        new r4:FHIRResponseErrorInterceptor()
    ]
}
service /fhir/r4 on new http:Listener(9090) {

    // Search the resource type based on some filter criteria
    resource function get Patient (http:RequestContext ctx, http:Request request) returns json|xml|r4:FHIRError {
        log:printDebug("FHIR interaction : search");
        r4:FHIRContext fhirContext = check r4:getFHIRContext(ctx);
        log:printDebug(fhirContext.getSearchParameters().toString());

        r4:Patient patient = {
            id: "123",
            name: [
                {
                    given: [
                        "Milinda"
                    ],
                    family: "Perera"
                }
            ],
            active: true,
            address: [
                {
                    period: {
                        end: "",
                        'start: "",
                        extension: []
                    }
                }
            ]
        };

        r4:BundleEntry[] entries = [];

        r4:BundleEntry entry = {
            fullUrl: request.rawPath,
            'resource: patient
        };

        entries.push(entry);

        r4:Bundle bundle = {
            'type: r4:BUNDLE_TYPE_SEARCHSET,
            entry: entries
        };

        check setPatientSearchResponse(bundle, ctx);
        return;
    }

    // Read the current state of the resource
    resource function get Patient/[string id] (http:RequestContext ctx) returns json|xml|r4:FHIRError {
        log:printDebug("[START]FHIR interaction : read");
        r4:Patient patient = {
            id: id,
            name: [
                {
                    given: [
                        "Milinda"
                    ],
                    family: "Perera"
                }
            ],
            active: true,
            address: [
                {
                    period: {
                        end: "",
                        'start: "",
                        extension: []
                    }
                }
            ]
        };
        
        check setPatientResponse(patient, ctx);
        log:printDebug("[END]FHIR interaction : read");
        return;
    }

    // Retrieve the change history for a particular resource
    resource function get Patient/[string id]/_history () returns json|xml|r4:FHIRError {
        io:println("FHIR interaction : history (instance level)");

    }

    // Read the state of a specific version of the resource
    resource function get Patient/[string id]/_history/[string vid] () returns json|xml|r4:FHIRError {
        io:println("FHIR interaction : vread");
    }
    
    // Create a new resource with a server assigned id
    resource isolated function post Patient (http:RequestContext ctx, http:Request request) returns json|r4:FHIRError {
        io:println("[START] Patient Create API Resource");

        r4:Patient patient = check getPatientRequestResource(ctx);
        io:println("Request:" + patient.toBalString());
        
        io:println("[END] Patient Create API Resource");
        return {};
    }

    // Update an existing resource by its id (or create it if it is new)
    resource function put Patient/[string id] () returns json|xml|r4:FHIRError {
        io:println("FHIR interaction : update");

    }

    // Update an existing resource by posting a set of changes to it
    resource function patch Patient/[string id] () returns json|xml|r4:FHIRError {
        io:println("FHIR interaction : patch");

    }

    // Delete a resource
    resource function delete Patient/[string id] () returns json|xml|r4:FHIRError {
        io:println("FHIR interaction : delete");

    }

    resource function get Patient/_history () returns json|xml|r4:FHIRError {
        io:println("FHIR interaction : history (type level)");

    }
}

public isolated function patientNameSearchPreProcessor(r4:SearchParameterDefinition definition, string resourceType, string value) 
                                                                        returns r4:RequestSearchParameter|r4:FHIRError {
    r4:StringSearchParameter sParam = {
        name: definition.name,
        value: value
    };
    return sParam;
}

public isolated function dateSearchPreProcessor(r4:SearchParameterDefinition definition, string resourceType, string value) 
                                                                        returns r4:RequestSearchParameter|r4:FHIRError {
    r4:StringSearchParameter sParam = {
        name: definition.name,
        value: value
    };
    return sParam;
}