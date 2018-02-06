//: Playground - noun: a place where people can play

import Foundation

extension Collection {
    func split(batchSize: IndexDistance) -> [SubSequence] {
        var result: [SubSequence] = []
        var remainderIndex = startIndex
        while remainderIndex < endIndex {
            let batchEndIndex = index(remainderIndex, offsetBy: batchSize, limitedBy: endIndex) ?? endIndex
            result.append(self[remainderIndex..<batchEndIndex])
            remainderIndex = batchEndIndex
        }
        return result
    }
}

let array = [1, 2, 3, 4]

let slice = array.suffix(from: 1)
array.split(batchSize: 3)
slice.split(batchSize: 2)

dump("Hello,World!".split(batchSize: 2).map { String($0) })

