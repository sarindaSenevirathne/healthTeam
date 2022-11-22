import wso2/healthcare.fhir.r4;
import ballerina/lang.value;
import ballerina/http;

isolated function getPatientRequestResource(http:RequestContext httpContext) returns r4:Patient|r4:FHIRError {
    r4:FHIRResourceEntity patientPayload = check r4:getRequestResourceEntity(httpContext);
    value:Cloneable resourceRecord = patientPayload.unwrap();
    if resourceRecord is r4:Patient {
        return resourceRecord;
    } else {
        string diagMsg = "Expected r4:Patient resource payload not found, found resource of type:" + 
                                                            (typeof resourceRecord).toBalString();
        return r4:createInternalFHIRError("Incoming r4:Patient resource payload not found", 
                                                            r4:ERROR, r4:PROCESSING_NOT_FOUND, diagnostic = diagMsg);
    }
}

isolated function setPatientResponse(r4:Patient patient, http:RequestContext httpContext) returns r4:FHIRError? {
    r4:FHIRResourceEntity entity = new(patient);
    check r4:setResponseResourceEntity(entity, httpContext);
}

isolated function setPatientSearchResponse(r4:Bundle patientsBundle, http:RequestContext httpContext) returns r4:FHIRError? {
    r4:FHIRContainerResourceEntity entity = new(patientsBundle);
    check r4:setResponseResourceEntity(entity, httpContext);
}