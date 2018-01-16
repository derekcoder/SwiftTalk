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
        return Parser<[A]> { string in
            var result: [A] = []
            var remainder = string
            while let (element, newRemainder) = self.parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }
            return (result, remainder)
        }
    }
    
    func map<T>(_ transform: @escaping (A) -> T) -> Parser<T> {
        return Parser<T> { string in
            guard let (result, remainder) = self.parse(string) else { return nil }
            return (transform(result), remainder)
        }
    }
}

let digit = character(condition: { CharacterSet.decimalDigits.contains($0.unicodeScalar) })
let int = digit.many.map { characters in Int(String(characters))! }
int.parse("123")

