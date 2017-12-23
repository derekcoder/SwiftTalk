//
//  ParseCSVTests.swift
//  ParseCSVTests
//
//  Created by ZHOU DENGFENG on 23/12/17.
//  Copyright © 2017 ZHOU DENGFENG DEREK. All rights reserved.
//

import XCTest

extension Substring {
    mutating func remove(upToAndIncluding idx: Index) {
        self = self[index(after: idx)...]
    }
    
    mutating func parseField() -> Substring {
        assert(!self.isEmpty)
        switch self[startIndex] {
        case "\"":
            removeFirst()
            guard let quoteIdx = index(of: "\"") else {
                fatalError("expected quote") // todo throws
            }
            let result = prefix(upTo: quoteIdx)
            remove(upToAndIncluding: quoteIdx)
            if !isEmpty {
                let comma = removeFirst()
                assert(comma == ",") // todo throws
            }
            
            return result
        default:
            if let commaIdx = index(of: ",") {
                let result = prefix(upTo: commaIdx)
                remove(upToAndIncluding: commaIdx)
                return result
            } else {
                let result = self
                removeAll()
                return result
            }
        }
    }
}

func parse(line: Substring) -> [Substring] {
    var remainder = line
    var result: [Substring] = []
    while !remainder.isEmpty {
        result.append(remainder.parseField())
    }
    return result
}

func parse(lines: String) -> [[Substring]] {
    return lines.split(whereSeparator: { character in
        switch character {
        case "\r", "\n", "\r\n": return true
        default: return false
        }
    }).map { line in
        parse(line: line)
    }
}

class ParseCSVTests: XCTestCase {
    func testLine() {
        let line = "one,2,,three" as Substring
        XCTAssertEqual(parse(line: line), ["one", "2", "", "three"])
    }

    func testLineWithQuotes() {
        let line = "one,\"qu,ote\",2,,three" as Substring
        XCTAssertEqual(parse(line: line), ["one","qu,ote", "2", "", "three"])
    }

    func testLines() {
        let line = "one,2,,three\nfour,five"
        let result = parse(lines: line)
        print(result)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], ["one", "2", "", "three"])
        XCTAssertEqual(result[1], ["four","five"])
    }
    
    func testLinesWithCRLF() {
        let line = "one,2,,three\r\nfour,five"
        let result = parse(lines: line)
        print(result)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], ["one", "2", "", "three"])
        XCTAssertEqual(result[1], ["four","five"])
    }
}
