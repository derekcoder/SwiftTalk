//
//  Splitting_Arrays_Tests.swift
//  Splitting Arrays Tests
//
//  Created by Derek on 26/1/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import XCTest

func ==(lhs: Block, rhs: Block) -> Bool {
    switch (lhs, rhs) {
    case let (.code(l), .code(r)): return l == r
    case let (.text(l), .text(r)): return l == r
    case let (.header(l), .header(r)): return l == r
    default: return false
    }
}

func ==(lhs: PlaygroundElement, rhs: PlaygroundElement) -> Bool {
    switch (lhs, rhs) {
    case let (.code(l), .code(r)): return l == r
    case let (.documentation(l), .documentation(r)): return l == r
    default: return false
    }
}

enum Block: Equatable {
    case code(String)
    case text(String)
    case header(String)
    // ...
}

enum PlaygroundElement: Equatable {
    case code(String)
    case documentation([Block])
}

func playground(blocks: [Block]) -> [PlaygroundElement] {
    return blocks.reduce([]) { result, block in
        switch (block, result.last) {
        case let (.code(code), _):
            return result + [.code(code)]
        case let (_, .documentation(exsting)?):
            return result.dropLast() + [.documentation(exsting + [block])]
        default:
            return result + [.documentation([block])]
        }
    }
}

func AssertEqual<A: Equatable>(_ l: [A], _ r: [A], file: StaticString = #file, line: UInt = #line) {
    var message = ""
    dump(l, to: &message)
    message += "\n\nis not equal to\n\n"
    dump(r, to: &message)
    XCTAssertEqual(l, r, message, file: file, line: line)
}

class Splitting_Arrays_Tests: XCTestCase {
    func testPlayground() {
        let sample: [Block] = [
            .code("swift sample code"),
            .header("My Header"),
            .text("Hello"),
            .code("more")
        ]
        
        let result: [PlaygroundElement] = [
            .code("swift sample code"),
            .documentation([Block.header("My Header"), Block.text("Hello")]),
            .code("more")
        ]
        AssertEqual(playground(blocks: sample), result)
    }

    func testWithoutTrailingCode() {
        let sample: [Block] = [
            .code("swift sample code"),
            .header("My Header"),
            .text("Hello")
        ]
        
        let result: [PlaygroundElement] = [
            .code("swift sample code"),
            .documentation([Block.header("My Header"), Block.text("Hello")])
        ]
        AssertEqual(playground(blocks: sample), result)
    }
}
