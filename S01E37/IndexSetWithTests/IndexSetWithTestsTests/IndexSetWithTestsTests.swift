//
//  IndexSetWithTestsTests.swift
//  IndexSetWithTestsTests
//
//  Created by Derek on 13/2/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import XCTest

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
    var sortedRanges: [RangeType] = []
    
    mutating func insert(_ element: RangeType) {
        sortedRanges.append(element)
        sortedRanges.sort { $0.lowerBound < $1.lowerBound }
        merge()
    }
    
    private mutating func merge() {
        sortedRanges = sortedRanges.reduce(into: []) { (newRanges, range) in
            if let last = newRanges.last, last.overlapsOrAdjacent(range) {
                newRanges[newRanges.endIndex-1] = last.merge(range)
            } else {
                newRanges.append(range)
            }
        }
    }
}

class IndexSetWithTestsTests: XCTestCase {
    func testInsertion() {
        var set = IndexSet()
        set.insert(5...6)
        set.insert(1...2)
        XCTAssert(set.sortedRanges == [1...2, 5...6])
    }
    
    func testMerging() {
        var set = IndexSet()
        set.insert(5...6)
        set.insert(3...6)
        XCTAssert(set.sortedRanges == [3...6])
    }
    
    func testMergingAdjacent() {
        var set = IndexSet()
        set.insert(5...6)
        set.insert(3...4)
        XCTAssert(set.sortedRanges == [3...6])
    }
}
