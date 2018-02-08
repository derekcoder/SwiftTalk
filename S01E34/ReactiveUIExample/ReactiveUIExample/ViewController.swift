//
//  ViewController.swift
//  ReactiveUIExample
//
//  Created by Derek on 8/2/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit
import SwiftDevHints
import RxSwift
import RxCocoa

func vat(country: String) -> Resource<Double> {
    let url = URL(string: "http://localhost:8080/\(country).json")!
    return Resource(url: url) { (json: Any) in
        return (json as? [String:Double])?["vat"]
    }
}

extension Webservice {
    func load<A>(_ resource: Resource<A>) -> Observable<A> {
        return Observable.create { observer in
            print("start loading")
            self.load(resource) { result in
                sleep(1)
                switch result {
                case .error(let error):
                    observer.onError(error)
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var vatLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    let webservice = Webservice()
    let countriesDataSource = CountriesDataSource()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.dataSource = self.countriesDataSource
        countryPicker.delegate = self.countriesDataSource
        
       let priceSignal = priceSlider.rx.value
            .asDriver()
            .map { floor(Double($0)) }
        
        priceSignal
            .map { "\($0) USD" }
            .drive(priceLabel.rx.text)
            .disposed(by: disposeBag)
        
        let countriesDataSource = self.countriesDataSource
        let webservice = self.webservice
        let vatSignal = countriesDataSource.selectedIndex.asDriver()
            .distinctUntilChanged()
            .map { index in
                countriesDataSource.countries[index].lowercased()
            }.flatMapLatest {  country in
                webservice.load(vat(country: country)).map { Optional.some($0) }.startWith(nil).asDriver(onErrorJustReturn: nil)
            }
        
        vatSignal
            .map { vat in
                vat.map { "\($0) %" } ?? "..."
            }
            .drive(vatLabel.rx.text)
            .disposed(by: disposeBag)
        
        Driver.combineLatest(vatSignal, priceSignal) { (vat: Double?, price: Double) -> Double? in
            guard let vat = vat else { return nil }
            return price * (1 + vat/100)
        }.map { total in
            total.map { "\($0) USD" } ?? "..."
        }.drive(totalLabel.rx.text)
        .disposed(by: disposeBag)
    }
}

