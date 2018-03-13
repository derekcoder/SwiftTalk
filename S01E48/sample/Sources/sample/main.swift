import libpq

struct PostgresError: Error {
    let message: String
}

final class Result {
    let result: OpaquePointer
    
    init?(result: OpaquePointer?) throws {
        switch PQresultStatus(result) {
        case PGRES_TUPLES_OK:
            self.result = result!
        case PGRES_COMMAND_OK:
            return nil
        default:
            let message = PQresultErrorMessage(result)!
            throw PostgresError(message: String(cString: message))
        }
    }
    
    var rowCount: Int32 {
        return PQntuples(result)
    }

    var columnCount: Int32 {
        return PQnfields(result)
    }
    
    subscript(row row: Int32, column column: Int32) -> String {
        let value = PQgetvalue(result, row, column)!
        return String(cString: value)
    }

    deinit {
        PQclear(result)
    }
}

final class Connection {
    let connection : OpaquePointer
    
    init(connectionInfo: String) throws {
        connection = PQconnectdb(connectionInfo)
        guard PQstatus(connection) == CONNECTION_OK else {
            throw PostgresError(message: "Connection failed")
        }
    }
    
    @discardableResult
    func query(_ sql: String) throws -> Result? {
        let pointer = PQexec(connection, sql)!
        return try Result(result: pointer)
    }
    
    deinit {
        PQfinish(connection)
    }
}

let connectionString = "dbname=sample host=localhost user=postgres client_encoding='UTF8'"

do {
    let conn = try Connection(connectionInfo: connectionString)
    try conn.query("INSERT INTO users (id, name) VALUES (3, 'FlorianTest');")
    if let result = try conn.query("SELECT * FROM users;") {
        for row in 0..<result.rowCount {
            for column in 0..<result.columnCount {
                print(result[row: row, column: column])
            }
        }
    }
} catch {
    print(error)
}
