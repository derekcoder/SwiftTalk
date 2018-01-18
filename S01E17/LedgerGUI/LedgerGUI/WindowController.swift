//
//  WindowController.swift
//  LedgerGUI
//
//  Created by Florian on 06/07/16.
//  Copyright © 2016 objc.io. All rights reserved.
//

import Cocoa


class LedgerWindowController: NSWindowController {

    var didSearch: ((String) -> ())?

    @IBAction func search(_ sender: NSSearchField) {
        didSearch?(sender.stringValue)
    }
    var balanceViewController: BalanceViewController? {
        return contentViewController?.childViewControllers.flatMap( { $0 as? BalanceViewController }).first
    }

    var registerViewController: RegisterViewController? {
        return contentViewController?.childViewControllers.flatMap( { $0 as? RegisterViewController }).first
    }
    
    override func windowDidLoad() {
        window?.setFrame(NSRect(x: 240, y: 105, width: 1920/2, height: 1080/2), display: true)
    }
}

