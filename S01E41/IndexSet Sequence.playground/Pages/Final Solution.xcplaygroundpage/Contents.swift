//: [Previous](@previous)

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
    func makeIterator() -> AnyIterator<Int> {
        return AnyIterator(rangeView.joined().makeIterator())
    }
}

extension IndexSet: Collection {
    struct Index {
        let rangeIndex: Int
        let elementIndex: RangeType.Index
    }
    
    var startIndex: Index {
        let zero = (0...0).startIndex
        return Index(rangeIndex: ranges.startIndex, elementIndex: ranges.first?.startIndex ?? zero)
    }
    
    var endIndex: Index {
        let zero = (0...0).startIndex
        return Index(rangeIndex: ranges.endIndex, elementIndex: zero)
    }
    
    subscript(index: Index) -> Int {
        return ranges[index.rangeIndex][index.elementIndex]
    }
    
    func index(after index: Index) -> Index {
        let range = ranges[index.rangeIndex]
        let nextElementIndex = range.index(after: index.elementIndex)
        if nextElementIndex < range.endIndex {
            return Index(rangeIndex: index.rangeIndex, elementIndex: nextElementIndex)
        }
        let nextRangeIndex = ranges.index(after: index.rangeIndex)
        if nextRangeIndex < ranges.endIndex {
            let nextRange = ranges[nextRangeIndex]
            return Index(rangeIndex: nextRangeIndex, elementIndex: nextRange.startIndex)
        } else {
            return endIndex
        }
    }
}

extension IndexSet.Index: Comparable {
    static func ==(lhs: IndexSet.Index, rhs: IndexSet.Index) -> Bool {
        return lhs.rangeIndex == rhs.rangeIndex && lhs.elementIndex == rhs.elementIndex
    }
    
    static func <(lhs: IndexSet.Index, rhs: IndexSet.Index) -> Bool {
        if lhs.rangeIndex < rhs.rangeIndex { return true }
        if lhs.rangeIndex == rhs.rangeIndex {
            return lhs.elementIndex < rhs.elementIndex
        }
        return false
    }
}

var set = IndexSet()
set.insert(4...5)
set.insert(0...2)

// -----------------------------------------------------

let idx = set.startIndex
set[idx]
set.count



