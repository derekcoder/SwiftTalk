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

extension Sequence {
    func split(batchSize: Int) -> AnySequence<[Iterator.Element]> {
        return AnySequence { () -> AnyIterator<[Iterator.Element]> in
            var iterator = self.makeIterator()
            return AnyIterator {
                var batch: [Iterator.Element] = []
                while batch.count < batchSize, let el = iterator.next() {
                    batch.append(el)
                }
                return batch.isEmpty ? nil : batch
            }
        }
    }
}

let array = [1, 2, 3, 4]
array.split(batchSize: 2)

final class ReadRandom: IteratorProtocol {
    let handle = FileHandle(forReadingAtPath: "/dev/urandom")!
    
    deinit {
        handle.closeFile()
    }
    
    func next() -> UInt8? {
        let data = handle.readData(ofLength: 1)
        return data[0]
    }
}

let randomSource = ReadRandom()
randomSource.next()

let randomSequence = AnySequence { ReadRandom() }
//for el in randomSequence {
//    print(el)
//}
let result = randomSequence.split(batchSize: 3).lazy.map { "\($0)" }
Array(result.prefix(5))

