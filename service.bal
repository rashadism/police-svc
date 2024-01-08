import ballerina/http;

configurable string ALLOWED_ORIGIN = ?;

@http:ServiceConfig {
    cors: {
        allowOrigins: [ALLOWED_ORIGIN]
    }
}

service / on new http:Listener(8080) {

    resource function get offenses/[string nic_number]() returns (Offense[]|error)? {
        return getOffenses(nic_number);
    }

    resource function post offenses(@http:Payload Offense offense) returns error? {
        return addOffense(offense);
    }
}
