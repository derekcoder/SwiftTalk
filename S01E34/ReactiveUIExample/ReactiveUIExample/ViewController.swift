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
            .map { floor(Double($0)) }
        
        priceSignal
            .map { "\($0) USD" }
            .bind(to: priceLabel.rx.text)
            .disposed(by: disposeBag)
        
        let vatSignal = countriesDataSource.selectedIndex.asObservable()
            .distinctUntilChanged()
            .map { [unowned self] index in
                self.countriesDataSource.countries[index].lowercased()
            }.flatMapLatest { [unowned self] country in
                self.webservice.load(vat(country: country)).map { Optional.some($0) }.startWith(nil)
            }.share(replay: 1)
        
        vatSignal
            .map { vat in
                vat.map { "\($0) %" } ?? "..."
            }.asDriver(onErrorJustReturn: "")
            .drive(vatLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(vatSignal, priceSignal) { (vat, price) -> Double? in
            guard let vat = vat else { return nil }
            return price * (1 + vat/100)
        }.map { total in
            total.map { "\($0) USD" } ?? "..."
        }.asDriver(onErrorJustReturn: "")
        .drive(totalLabel.rx.text)
        .disposed(by: disposeBag)
    }
}

