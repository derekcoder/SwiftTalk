//
//  ViewController.swift
//  ApplePayTest
//
//  Created by Derek on 12/3/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit
import PassKit

extension String: Error { }
typealias STPToken = String

final class FakeStripe {
    static let shared = FakeStripe()
    
    func createToken(with payment: PKPayment, callback: @escaping (STPToken?, Error?) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            callback("success", nil)
        }
    }
}

final class Webservice {
    static let shared = Webservice()
    
    func processToken(_ token: STPToken, product: Product, callback: @escaping (Bool) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            callback(true)
        }
    }
}

struct Product {
    let name: String
    let price: Int
}

extension Product {
    var paymentRequest: PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.io.objc.applepaytest"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.merchantCapabilities = .capabilityCredit
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: name, amount: NSDecimalNumber(value: price)),
            PKPaymentSummaryItem(label: "objc.io", amount: NSDecimalNumber(value: price))
        ]
        return request
    }
}

struct State {
    var buttonIsEnabled: Bool
    var statusLabelText: String?
}

class ViewModel {
    var state: State = State(buttonIsEnabled: true, statusLabelText: nil) {
        didSet {
            callback(state)
        }
    }
    let product: Product
    var callback: (State) -> ()
    private var didAuthorize = false
    
    init(product: Product, callback: @escaping (State) -> ()) {
        self.product = product
        self.callback = callback
        self.callback(state)
    }
    
    func buyButtonPressed() {
        didAuthorize = false
        state.statusLabelText = "Authorizing..."
    }
    
    func stripeCreatedToken(token: STPToken?, error: Error?, completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        if let token = token {
            Webservice.shared.processToken(token, product: self.product, callback: { success in
                if success {
                    self.state.statusLabelText = "Thank you"
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                } else {
                    self.state.statusLabelText = "Something went wrong."
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                }
            })
        } else if let error = error {
            self.state.statusLabelText = "Stripe error \(error)..."
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
        } else {
            fatalError()
        }
    }
    
    func didAuthorizePayment() {
        didAuthorize = true
    }
    
    func authorizationFinished() {
        if !didAuthorize {
            state.statusLabelText = nil
        }
    }
}

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    let product = Product(name: "Test product", price: 100)
    var didAuthorize = false
    var viewModel: ViewModel!
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel(product: product) { [unowned self] state in
            self.statusLabel.text = state.statusLabelText
            self.buyButton.isEnabled = state.buttonIsEnabled
        }
    }
    
    @IBAction func buy(_ sender: Any) {
        let vc = PKPaymentAuthorizationViewController(paymentRequest: product.paymentRequest)!
        vc.delegate = self
        viewModel.buyButtonPressed()
        present(vc, animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        viewModel.didAuthorizePayment()
        FakeStripe.shared.createToken(with: payment) { (token, error) in
            self.viewModel.stripeCreatedToken(token: token, error: error, completion: completion)
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        viewModel.authorizationFinished()
    }
}





































