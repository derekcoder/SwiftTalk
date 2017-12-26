//
//  ParseCSVTests.swift
//  ParseCSVTests
//
//  Created by ZHOU DENGFENG on 24/12/17.
//  Copyright © 2017 ZHOU DENGFENG DEREK. All rights reserved.
//

import XCTest

class ParseCSVTests: XCTestCase {
    func testLine() {
        let line = "one,2,,three" as Substring
        XCTAssertEqual(parse(line: line), ["one", "2", "", "three"])
    }
    
    func testParseAlt() {
        let line = "one,2,,three\nfour,five,\"hello,q\""
        let result = line.parseAlt()
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], ["one", "2", "", "three"])
        XCTAssertEqual(result[1], ["four","five","hello,q"])
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
    
    func testPerformance() {
        let bundle = Bundle(for: ParseCSVTests.self)
        let url = bundle.url(forResource: "small", withExtension: "txt")!
        let data = try! Data(contentsOf: url)
        let string = String(data: data, encoding: .isoLatin1)! + ""

        measure {
            _ = string.parseAlt()
        }
    }
}

