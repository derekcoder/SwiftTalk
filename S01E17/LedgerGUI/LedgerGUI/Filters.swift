//
//  Filters.swift
//  LedgerGUI
//
//  Created by Florian Kugler on 01/09/16.
//  Copyright © 2016 objc.io. All rights reserved.
//

import Foundation

enum Filter {
    case account(String)
    case string(String)
    case period(from: EvaluatedDate, to: EvaluatedDate)
}

extension EvaluatedTransaction {
    func matches(_ search: String?) -> Bool {
        guard let search = search else { return true }
        return matches(Filter.string(search))
    }
    
    func matches(_ search: [Filter]) -> Bool {
        return search.all(matches)
    }
    
    func matches(_ search: Filter) -> Bool {
        switch search {
        case .account:
            return postings.first { $0.matches(search) } != nil
        case .string(let string):
            return title.lowercased().contains(string.lowercased()) || postings.first { $0.matches(search) } != nil
        case .period(let from, let to):
            return date >= from && date <= to
        }
    }
}

extension EvaluatedPosting {
    func matches(_ search: String) -> Bool {
        return matches(Filter.string(search))
    }
    
    func matches(_ search: [Filter]) -> Bool {
        return search.all(matches)
    }
    
    func matches(_ search: Filter) -> Bool {
        switch search {
        case .account(let name):
            return account.hasPrefix(name)
        case .string(let string):
            return account.lowercased().contains(string.lowercased()) || amount.displayValue.contains(string)
        case .period:
            return false
        }
    }
}

