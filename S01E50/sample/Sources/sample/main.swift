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

extension Array where Element == String {
    func withCStrings<T>(_ f: ([UnsafeMutableBufferPointer<Int8>?]) -> T) -> T {
        let values: [UnsafeMutableBufferPointer<Int8>?] = map { param in
            let cString = param.utf8CString
            let pointer = UnsafeMutablePointer<Int8>.allocate(capacity: cString.count)
            pointer.initialize(from: Array<Int8>(cString), count: cString.count)
            return UnsafeMutableBufferPointer(start: pointer, count: cString.count)
        }
        defer {
            for case let value? in values {
                value.baseAddress?.deallocate(capacity: value.count)
            }
        }
        return f(values)
    }
    
    func withCStringsAlt<T>(_ f: ([UnsafePointer<Int8>?]) -> T) -> T {
        let cStrings = map { strdup($0) }
        defer { cStrings.forEach { free($0) } }
        return f(cStrings.map { UnsafePointer($0) })
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
    func query(_ sql: String, _ params: [String]) throws -> Result? {
        let result = params.withCStringsAlt { pointers in
            return PQexecParams(connection, sql, Int32(params.count), params.map { _ in 25 }, pointers, nil, nil, 0)
        }
        return try Result(result: result)
    }
    
    deinit {
        PQfinish(connection)
    }
}

let connectionString = "dbname=sample host=localhost user=postgres client_encoding='UTF8'"

do {
    let conn = try Connection(connectionInfo: connectionString)
//    try conn.query("INSERT INTO users (id, name) VALUES (3, 'FlorianTest');")
    if let result = try conn.query("SELECT * FROM users WHERE name = $1;", ["Chris"]) {
        for row in 0..<result.rowCount {
            for column in 0..<result.columnCount {
                print(result[row: row, column: column])
            }
        }
    }
} catch {
    print(error)
}
