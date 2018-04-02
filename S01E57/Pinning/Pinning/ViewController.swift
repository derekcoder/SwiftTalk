//
//  ViewController.swift
//  Pinning
//
//  Created by Derek on 2/4/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    let certificates: [Data] = {
        let url = Bundle.main.url(forResource: "objcio", withExtension: "cer")!
        let data = try! Data(contentsOf: url)
        return [data]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://www.objc.io")!
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            print("Loaded!")
            if let data = data {
                DispatchQueue.main.async {
                    self.webView.load(data, mimeType: response?.mimeType ?? "", textEncodingName: response?.textEncodingName ?? "", baseURL: url)
                }
            }
        }
        task.resume()
    }
}

extension ViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 {
            if let certificate = SecTrustGetCertificateAtIndex(trust, 0) {
                let data = SecCertificateCopyData(certificate) as Data
                if certificates.contains(data) {
                    completionHandler(.useCredential, URLCredential(trust: trust))
                    return
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

