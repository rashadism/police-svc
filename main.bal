import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new (
    host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE
);

public type Offense record {
    string[] nic_numbers;
    string file_id;
    string offense_description;
    string offense_date;
    string location;
};

isolated function addOffense(Offense offense) returns error? {
    sql:ExecutionResult result = check dbClient->execute(`
    INSERT INTO offenses (file_id, offense_date, offense_description, location)
    VALUES (${offense.file_id}, ${offense.offense_date}, ${offense.offense_description}, ${offense.location})
    `);

    (string|int)? lastInsertId = result.lastInsertId;
    foreach var nic in offense.nic_numbers {
        sql:ExecutionResult _ = check dbClient->execute(`
        INSERT INTO nic_offenses (nic_number, offense_id)
        VALUES (${nic}, ${lastInsertId})
        `);
    }

    
}

isolated function getOffenses(string nic_number) returns Offense[]|error {
    Offense[] offenses = [];

    stream<Offense, error?> results = dbClient->query(`
    SELECT o.*
    FROM nic_offenses no
    JOIN offenses o ON no.offense_id = o.offense_id
    WHERE no.nic_number = ${nic_number};
`);

    check from Offense offense in results
        do {
            offenses.push(offense);
        };
    check results.close();
    return offenses;
}

