//
//  LedgerDocumentController.swift
//  LedgerGUI
//
//  Created by Florian Kugler on 01/09/16.
//  Copyright © 2016 objc.io. All rights reserved.
//

import Cocoa

struct LedgerDocumentState {
    var ledger: Ledger = Ledger()
    var accountFilter: String?
    
    var filteredTransactions: [EvaluatedTransaction] {
        return ledger.evaluatedTransactions.filter { transaction in transaction.matches(accountFilter) }
    }
}

final class LedgerDocumentController {
    var state = LedgerDocumentState() {
        didSet {
            update()
        }
    }
    
    var ledger: Ledger {
        get { return state.ledger }
        set { state.ledger = newValue }
    }

    var windowController: LedgerWindowController? {
        didSet {
            windowController?.balanceViewController?.didSelect = { account in
                self.state.accountFilter = account
            }
            update()
        }
    }
    
    func update() {
        windowController?.balanceViewController?.balanceTree = ledger.balanceTree
        windowController?.registerViewController?.transactions = state.filteredTransactions
    }
}


