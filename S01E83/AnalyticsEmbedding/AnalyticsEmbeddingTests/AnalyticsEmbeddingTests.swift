//
//  AnalyticsEmbeddingTests.swift
//  AnalyticsEmbeddingTests
//
//  Created by Derek on 1/6/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import XCTest
@testable import AnalyticsEmbedding

final class FakeAnalytics: Analytics {
    var events: [Event] = []
    func send(_ event: Event) {
        events.append(event)
    }
}

class AnalyticsEmbeddingTests: XCTestCase {
    func testExample() {
        let vc = ViewController()
        let fakeAnalytics = FakeAnalytics()
        vc.analytics = fakeAnalytics
        vc.tapMe(self)
        XCTAssertEqual(fakeAnalytics.events.count, 1)
    }
}
