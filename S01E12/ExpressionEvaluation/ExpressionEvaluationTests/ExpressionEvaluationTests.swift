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
    var commodity: Commodity
    
    init(value: LedgerDouble, commodity: Commodity = "") {
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

extension Int {
    var eur: Amount {
        return Amount(value: LedgerDouble(self), commodity: "EUR")
    }
    
    var usd: Amount {
        return Amount(value: LedgerDouble(self), commodity: "USD")
    }
}

indirect enum Expression {
    case amount(Amount)
    case infixOperator(String, Expression, Expression)
    case identifier(String)
}

struct Posting {
    var account: String
    var amount: Expression?
}

struct EvaluatedPosting: Equatable {
    var account: String
    var amount: Amount
    
    static func ==(lhs: EvaluatedPosting, rhs: EvaluatedPosting) -> Bool {
        return (lhs.account == rhs.account) && (lhs.amount == rhs.amount)
    }
}

typealias ExpressionContext = [String: Amount]

extension Posting {
    func evaluate(context: ExpressionContext) throws -> EvaluatedPosting {
        assert(amount != nil, "Cannot call evaluate on posting without amount")
        let evaluatedAmount = try amount!.evaluate(context: context)
        return EvaluatedPosting(account: account, amount: evaluatedAmount)
    }
}

struct Transaction {
//    var date: Date
//    var title: String
    var postings: [Posting]
}

struct EvaluatedTransaction: Equatable {
//    var date: Date
//    var title: String
    var postings: [EvaluatedPosting]
    
    static func ==(lhs: EvaluatedTransaction, rhs: EvaluatedTransaction) -> Bool {
        return lhs.postings == rhs.postings
    }
}

extension EvaluatedTransaction {
    var balance: [Commodity: LedgerDouble] {
        var total: [Commodity: LedgerDouble] = [:]
        for posting in postings {
            total[posting.amount.commodity, default: 0] += posting.amount.value
        }
        return total
    }
    
    func verify() throws {
        for (_, value) in balance {
            guard value == 0 else { throw "Transaction does not balance" }
        }
    }
}
extension Transaction {
    func evaluate(context: ExpressionContext) throws -> EvaluatedTransaction {
        let postingsWithAmount = postings.filter { $0.amount != nil }
        let postingsWithoutAmount = postings.filter { $0.amount == nil }
        guard postingsWithoutAmount.count <= 1 else { throw "Transaction can only contain one posting without amount" }
        
        let evaluatedPostings = try postingsWithAmount.map { try $0.evaluate(context: context) }
        var evaluatedTransaction = EvaluatedTransaction(postings: evaluatedPostings)
        
        if let posting = postingsWithoutAmount.first {
            for (commdity, value) in evaluatedTransaction.balance where value != 0 {
                evaluatedTransaction.postings.append(EvaluatedPosting(account: posting.account, amount: Amount(value: -value, commodity: commdity)))
            }
        }
        
        try evaluatedTransaction.verify()
        return evaluatedTransaction
    }
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
        self.commodity = ""
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
    
    let checkingMinus10 = Posting(account: "Assets:Checking", amount: .amount((-10).eur))
    let food10 = Posting(account: "Expenses:Food", amount: .amount(10.eur))
    let checkingMinus20USD = Posting(account: "Assets:Checking", amount: .amount((-20).usd))
    let food20USD = Posting(account: "Expenses:Food", amount: .amount(20.usd))
    
    let evaluatedCheckingMinus10 = EvaluatedPosting(account: "Assets:Checking", amount: (-10).eur)
    let evaluatedFood10 = EvaluatedPosting(account: "Expenses:Food", amount: 10.eur)
    let evaluatedCheckingMinus20USD = EvaluatedPosting(account: "Assets:Checking", amount: (-20).usd)
    let evaluatedFood20USD = EvaluatedPosting(account: "Expenses:Food", amount: (20).usd)


    // 2016/07/25 Lunch
    //    Expenses:Food  10 EUR
    //    Assets:Checking  -10 EUR
    func testTransaction() {
        let transaction = Transaction(postings: [food10, checkingMinus10])
        XCTAssertEqual(try! transaction.evaluate(context: [:]), EvaluatedTransaction(postings: [evaluatedFood10, evaluatedCheckingMinus10]))
    }

    // 2016/07/26 Non-balanced lunch ; throws an error!
    //    Expenses:Food  5 EUR
    //    Assets:Checking  -10 EUR
    func testUnbalancedTransaction() {
        let transaction = Transaction(postings: [Posting(account: "Expenses:Food", amount: .amount(5.eur)),  checkingMinus10])
        XCTAssertNil(try? transaction.evaluate(context: [:]))
    }

    // 2016/07/27 International lunch
    //    Expenses:Food  10 EUR
    //    Expenses:Food  20 USD
    //    Assets:Checking  -10 EUR
    //    Assets:Checking  -20 USD
    func testMultiCommdityTransaction() {
        let transaction = Transaction(postings: [food10, food20USD, checkingMinus10, checkingMinus20USD])
        XCTAssertEqual(try! transaction.evaluate(context: [:]), EvaluatedTransaction(postings: [evaluatedFood10, evaluatedFood20USD, evaluatedCheckingMinus10, evaluatedCheckingMinus20USD]))
    }

    // 2016/07/25 Implicit lunch
    //    Expenses:Food  10 EUR
    //    Assets:Checking
    func testImplicitTransaction() {
        let transaction = Transaction(postings: [food10, Posting(account: "Assets:Checking", amount: nil)])
        XCTAssertEqual(try! transaction.evaluate(context: [:]), EvaluatedTransaction(postings: [evaluatedFood10, evaluatedCheckingMinus10]))
    }
}
















