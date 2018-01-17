//: Playground - noun: a place where people can play

import Foundation

struct Parser<A> {
    let parse: (String) -> (A, String)?
}

func character(condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { string in
        guard let char = string.first, condition(char) else { return nil }
        return (char, String(string.dropFirst()))
    }
}

extension Parser {
    var many: Parser<[A]> {
        return Parser<[A]> { input in
            var result: [A] = []
            var remainder = input
            while let (element, newRemainder) = self.parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }
            return (result, remainder)
        }
    }
    
    func map<T>(_ transform: @escaping (A) -> T) -> Parser<T> {
        return Parser<T> { input in
            guard let (result, remainder) = self.parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }
    
    func followed<B>(by other: Parser<B>) -> Parser<(A, B)> {
        return Parser<(A, B)> { input in
            guard let (result1, remainder1) = self.parse(input) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder1) else { return nil }
            
            return ((result1, result2), remainder2)
        }
    }
}

func multiply(_ x: Int, _ op: Character, _ y: Int) -> Int {
    return x * y
}

//func multiply(_ x: Int) -> ((Character) -> ((Int) -> Int)) {
//    return { op in
//        return { y in
//            return x * y
//        }
//    }
//}

func curry<A, B, C, R>(_ f: @escaping (A, B, C) -> R) -> (A) -> (B) -> (C) -> R {
    return { a in { b in { c in f(a, b, c) } } }
}


let curriedMultiply = curry(multiply)

multiply(2, "x", 3)
curriedMultiply(2)("*")(3)

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator <*>: SequencePrecedence
func <*><A, B>(lhs: Parser<(A) -> (B)>, rhs: Parser<A>) -> Parser<B> {
    return lhs.followed(by: rhs).map { (f, x) in f(x) }
}

infix operator <^>: SequencePrecedence
func <^><A, B>(lhs: @escaping (A) -> B, rhs: Parser<A>) -> Parser<B> {
    return rhs.map(lhs)
}

let digit = character(condition: { CharacterSet.decimalDigits.contains($0.unicodeScalar) })
let int = digit.many.map { characters in Int(String(characters))! }
int.parse("123")

//let multiplication =
//    int
//        .followed(by: character { $0 == "*" })
//        .followed(by: int)
//        .map { (lhs, rhs) in lhs.0 * rhs }

let multiplication =
    curriedMultiply <^> int <*> character { $0 == "*" } <*> int

multiplication.parse("12*3") // (((12, "*"), 3), "")

// ( (12, "*"), 3 )
//let multiplication = curriedMultiply <^> int <*> character { $0 == "*" } <*> int

