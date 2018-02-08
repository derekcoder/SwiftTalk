//
//  CountriesDataSource.swift
//  ReactiveUIExample
//
//  Created by Derek on 8/2/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit
import UIKit
import RxSwift

final class CountriesDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let countries = ["Germany", "Netherlands"]
    let selectedIndex = Variable<Int>(0)
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex.value = row
    }
}
