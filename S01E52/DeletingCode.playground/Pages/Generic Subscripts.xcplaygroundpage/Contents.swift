//: [Previous](@previous)

import Foundation

protocol PostgresType {
    init(postgresString: String)
}

extension Int: PostgresType {
    init(postgresString: String) {
        self = Int(postgresString)!
    }
}

extension Bool: PostgresType {
    init(postgresString: String) {
        switch postgresString {
        case "t": self = true
        case "f": self = false
        default: fatalError()
        }
    }
}

extension String: PostgresType {
    init(postgresString: String) {
        self = postgresString
    }
}

struct PostgresResult {
    let result: [String]
    
    subscript<T: PostgresType>(index: Int) -> T {
        return T(postgresString: result[index])
    }
}

let sample = PostgresResult(result: ["one", "13", "t"])
let str: String = sample[0]
let int: Int = sample[1]
let bool: Bool = sample[2]
