//: Playground - noun: a place where people can play
import Foundation

var sampleBytes: [UInt8] = [0x0b, 0xad, 0xf0, 0x0d]

let nsData = NSMutableData(bytes: sampleBytes, length: sampleBytes.count)
let nsOtherData = nsData.mutableCopy() as! NSMutableData
nsData.append(sampleBytes, length: sampleBytes.count)
nsOtherData

final class Box<A> {
    let unbox: A
    init(_ value: A) {
        unbox = value
    }
}

struct MyData {
    var data = Box(NSMutableData())
    var dataForWriting: NSMutableData {
        mutating get {
            if isKnownUniquelyReferenced(&data) {
                return data.unbox
            }
            print("making a copy")
            data = Box(data.unbox.mutableCopy() as! NSMutableData)
            return data.unbox
        }
    }
    
    mutating func append(_ bytes: [UInt8]) {
        dataForWriting.append(bytes, length: bytes.count)
    }
}

extension MyData: CustomDebugStringConvertible {
    var debugDescription: String {
        return String(describing: data)
    }
}

var data = MyData()
let copy = data

(0..<10).reduce(data) { result, _ in
    var copy = result
    copy.append(sampleBytes)
    return copy
}

//for _ in 0..<10 {
//    data.append(sampleBytes)
//}

