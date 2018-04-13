//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by Derek on 9/4/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var driver: Driver<State>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        driver = Driver(State())
        window?.rootViewController = driver?.viewController
        window?.makeKeyAndVisible()
        return true
    }

}

