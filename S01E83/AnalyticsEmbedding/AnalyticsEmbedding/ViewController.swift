//
//  ViewController.swift
//  AnalyticsEmbedding
//
//  Created by Derek on 1/6/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit

final class AnalyticsBackend {
    static let shared = AnalyticsBackend()
    
    func send(_ event: Event) {
        print("Sending event \(event.data.name), metadata: \(event.data.metadata)")
    }
}

protocol Analytics {
    func send(_ event: Event)
}

extension AnalyticsBackend: Analytics {}

enum Event {
    case tapMeTapped 
    case viewControllerAppeared(name: String, date: Date)
}

extension Event {
    var data: (name: String, metadata: [String: String]) {
        switch self {
        case .tapMeTapped:
            return (name: "viewController1.tapMeTapped", metadata: [:])
        case let .viewControllerAppeared(name, date):
            return (name: "viewController.appear", metadata: ["name": name, "time": "\(date.timeIntervalSince1970)"])
        }
    }
}

class ViewController: UIViewController {
    var analytics: Analytics = AnalyticsBackend.shared
    
    @IBAction func tapMe(_ sender: Any) {
        analytics.send(.tapMeTapped)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analytics.send(.viewControllerAppeared(name: "master", date: Date()))
    }
}

class DetailViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsBackend.shared.send(.viewControllerAppeared(name: "detail", date: Date()))
    }
}

