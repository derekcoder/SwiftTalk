//: Playground - noun: a place where people can play

import UIKit

typealias LedgerDouble = Double

struct Account {
    let name: String
    let balance: LedgerDouble
}

let accounts = [
    Account(name: "Assets:CreditCard", balance: 100),
    Account(name: "Assets:Checking", balance: 200),
    Account(name: "Expenses:Internet", balance: 300),
    Account(name: "Expenses:Internet:Hosting", balance: 400)
]

// Assets 300
//    Assets:CreditCard 100
//    Assets:Checking 200
// Expenses 700
//    Expenses:Internet 300
//      Expenses:Internet:Hosting 400

struct AccountTree {
    var children: [String: AccountTree]
    let path: [String]
    var amount: LedgerDouble
    
    init(children: [String: AccountTree] = [:], path: [String] = [], amount: LedgerDouble = 0) {
        self.children = children
        self.path = path
        self.amount = amount
    }
}

extension Array {
    var decompose: (Element, [Element])? {
        guard !isEmpty else { return nil }
        return (self[0], Array(self.dropFirst()))
    }
}

extension AccountTree {
    mutating func insert(account: Account, remaingPath: [String]) {
        amount += account.balance
        
        guard let (firstComponent, remaingPath) = remaingPath.decompose else {
            return
        }
        
        let newNode = AccountTree(path: path + [firstComponent])
        children[firstComponent, default: newNode].insert(account: account, remaingPath: remaingPath)
    }
}

var root = AccountTree()

func check(_ condition: Bool) -> UIColor {
    return condition ? .green : .red
}

for account in accounts {
    root.insert(account: account, remaingPath: account.name.components(separatedBy: ":"))
}

root.children

check(root.amount == 1000)
check(root.children["Assets"]?.amount == 300)














