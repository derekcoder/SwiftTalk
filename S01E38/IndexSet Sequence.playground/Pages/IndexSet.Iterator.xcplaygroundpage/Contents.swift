//: Playground - noun: a place where people can play

import Foundation

extension CountableClosedRange {
    func merge(_ other: CountableClosedRange) -> CountableClosedRange {
        return Swift.min(lowerBound, other.lowerBound)...Swift.max(upperBound, other.upperBound)
    }
    
    func overlapsOrAdjacent(_ other: CountableClosedRange) -> Bool {
        return ((lowerBound.advanced(by: -1))...(upperBound.advanced(by: 1))).overlaps(other)
    }
}

struct IndexSet {
    typealias RangeType = CountableClosedRange<Int>
    
    // Invariant: sorted by lower bound
    var ranges: [RangeType] = []
    
    mutating func insert(_ element: RangeType) {
        ranges.append(element)
        ranges.sort { $0.lowerBound < $1.lowerBound }
        merge()
    }
    
    private mutating func merge() {
        ranges = ranges.reduce(into: []) { (newRanges, range) in
            if let last = newRanges.last, last.overlapsOrAdjacent(range) {
                newRanges[newRanges.endIndex-1] = last.merge(range)
            } else {
                newRanges.append(range)
            }
        }
    }
}

extension IndexSet {
    struct RangeView: Sequence {
        var base: IndexSet
        
        func makeIterator() -> AnyIterator<RangeType> {
            return AnyIterator(base.ranges.makeIterator())
        }
    }
    
    var rangeView: RangeView {
        return RangeView(base: self)
    }
}

extension IndexSet: Sequence {
    struct Iterator: IteratorProtocol {
        var rangeIterator: RangeView.Iterator
        var elementsIterator: RangeType.Iterator? = nil
        
        mutating func next() -> Int? {
            if let element = elementsIterator?.next() {
                return element
            } else {
                if let range = rangeIterator.next() {
                    elementsIterator = range.makeIterator()
                    return elementsIterator?.next()
                } else {
                    return nil
                }
            }
        }
    }
    
    func makeIterator() -> Iterator {
        return Iterator(rangeIterator: rangeView.makeIterator(), elementsIterator: nil)
    }
}

var set = IndexSet()
set.insert(4...5)
set.insert(0...2)

for range in set.rangeView {
    print(range)
}

for x in set {
    print(x)
}

