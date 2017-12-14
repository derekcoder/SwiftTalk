//: Playground - noun: a place where people can play

import Foundation

var x = [3, 1, 2]
let y = x
x.sort()
for idx in x.indices {
    x[idx] *= x[idx]
}
x

y.sorted()
y

struct Account {
    var balance: Int
    
    func depositing(amount: Int) -> Account {
//        return Account(balance: balance + amount)
        var copy = self
        copy.deposit(amount: amount)
        return copy
    }
    
    mutating func deposit(amount: Int) {
        balance += amount
//        self = depositing(amount: amount)
    }
    
    mutating func transfer(amount: Int, from: Account) {
        balance += amount
        from.balance -= amount
    }
}

func deposit(amount: Int, into account: inout Account) {
    account.balance += amount
}

var account = Account(balance: 0)
let other = account
deposit(amount: 10, into: &account)
account.balance
other.balance
