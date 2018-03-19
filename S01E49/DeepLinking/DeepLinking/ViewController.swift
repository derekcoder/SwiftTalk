//
//  ViewController.swift
//  DeepLinking
//
//  Created by Derek on 19/3/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    enum Tab: Int {
        case tab1 = 0
        case tab2 = 1
    }
    
    func showTab(_ tab: Tab) {
        selectedIndex = tab.rawValue
    }

    @IBAction func showModal(sender: Any) {
        let modal = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Modal")
        present(modal, animated: true, completion: nil)
    }
    
    @IBAction func returnFromModal(segue: UIStoryboardSegue) {
        
    }
}

