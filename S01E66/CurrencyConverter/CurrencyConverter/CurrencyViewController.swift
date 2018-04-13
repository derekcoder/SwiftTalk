//
//  CurrencyViewController.swift
//  CurrencyConverter
//
//  Created by Derek on 9/4/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit

let ratesURL = URL(string: "http://api.fixer.io/latest?base=EUR")!

struct State: RootComponent {
    private var inputText: String? = "100"
    private var rate: Double? = nil
    
    enum Message {
        case setInputText(String?)
        case dataReceived(Data?)
        case reload
    }
    
    mutating func send(_ message: Message) -> [Command<Message>] {
        switch message {
        case .setInputText(let text):
            inputText = text
            return []
        case .dataReceived(let data):
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String: Any],
                let dataDict = dict["rates"] as? [String: Double] else { return [] }
            self.rate = dataDict["USD"]
            return []
        case .reload:
            return [.request(URLRequest(url: ratesURL), available: Message.dataReceived)]
        }
    }
    
    var viewController: ViewController<State.Message> {
        return .viewController(View.stackView(views: [
            View.textField(text: inputText ?? "", backgroundColor: inputAmount == nil ? .red : .white, onChange: Message.setInputText),
            View.button(text: "Reload", onTap: Message.reload),
            View.label(text: outputAmount.map { "\($0) USD " } ?? "...", font: .systemFont(ofSize: 20))
            ]))
    }
    
    var inputAmount: Double? {
        guard let text = inputText, let number = Double(text) else { return nil }
        return number
    }
    
    var outputAmount: Double? {
        guard let input = inputAmount, let rate = rate else { return nil }
        return input * rate
    }
}
