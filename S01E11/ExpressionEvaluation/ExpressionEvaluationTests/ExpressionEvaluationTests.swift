//
//  ExpressionEvaluationTests.swift
//  ExpressionEvaluationTests
//
//  Created by Derek on 10/1/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import XCTest
@testable import ExpressionEvaluation

typealias LedgerDouble = Double
typealias Commodity = String

extension String: Error { }

struct Amount: Equatable {
    var value: LedgerDouble
    var commodity: Commodity?
    
    init(value: LedgerDouble, commodity: Commodity? = nil) {
        self.value = value
        self.commodity = commodity
    }
    
    static func ==(lhs: Amount, rhs: Amount) -> Bool {
        return (lhs.value == rhs.value && lhs.commodity == rhs.commodity)
    }
}

extension Amount {
    func compute(operatorFunction: (LedgerDouble, LedgerDouble) -> LedgerDouble, other: Amount) throws -> Amount {
        guard commodity == other.commodity else {
            throw "Commdities don't match"
        }
        return Amount(value: operatorFunction(value, other.value), commodity: commodity)
    }
}

indirect enum Expression {
    case amount(Amount)
    case infixOperator(String, Expression, Expression)
    case identifier(String)
}

extension Expression {
    func evaluate(context: [String: Amount]) throws -> Amount {
        switch self {
        case .amount(let amount):
            return amount
        case let .infixOperator(op, lhs, rhs):
            let operators: [String: (LedgerDouble, LedgerDouble) -> LedgerDouble] = [
                "+": (+),
                "*": (*)
            ]
            guard let operatorFunction = operators[op] else { throw "Undefined operator: \(op)" }
            let left = try lhs.evaluate(context: context)
            let right = try rhs.evaluate(context: context)
            return try left.compute(operatorFunction: operatorFunction, other: right)
        case .identifier(let name):
            guard let value = context[name] else { throw "Unknown variable: \(name)" }
            return value
        }
    }
}

extension Amount: ExpressibleByIntegerLiteral {
    init(integerLiteral value: LedgerDouble) {
        self.value = value
        self.commodity = nil
    }
}

class ExpressionEvaluationTests: XCTestCase {
    func testAmount() {
        // 5 EUR
        let expr = Expression.amount(Amount(value: 5, commodity: "EUR"))
        XCTAssertEqual(try! expr.evaluate(context: [:]), Amount(value: 5, commodity: "EUR"))
    }
    
    func testOperator() {
        // 5 + 2
        let expr = Expression.infixOperator("+", .amount(5), .amount(2))
        XCTAssertEqual(try! expr.evaluate(context: [:]), 7)
    }

    func testMultiplication() {
        // 5 * 2
        let expr = Expression.infixOperator("*", .amount(5), .amount(2))
        XCTAssertEqual(try! expr.evaluate(context: [:]), 10)
    }
    
    func testIdentifier() {
        // numberOfPeople
        let expr = Expression.identifier("numberOfPeople")
        let context: [String: Amount] = ["numberOfPeople": 5]
        XCTAssertEqual(try! expr.evaluate(context: context), 5)
    }
    
    func testMultiplicationWithIdentifier() {
        // 10 * numberOfPeople
        let expr = Expression.infixOperator("*", .amount(10), .identifier("numberOfPeople"))
        XCTAssertEqual(try! expr.evaluate(context: ["numberOfPeople": 5]), 50)
    }
}
















