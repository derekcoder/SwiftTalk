//
//  main.swift
//  Test
//
//  Created by Derek on 26/2/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import Foundation

final class KeyValueObserver<A>: NSObject {
    let block: (A) -> ()
    let keyPath: String
    var object: NSObject
    init(object: NSObject, keyPath: String, _ block: @escaping (A) -> ()) {
        self.block = block
        self.keyPath = keyPath
        self.object = object
        super.init()
        object.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
    }
    
    deinit {
        object.removeObserver(self, forKeyPath: keyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        block(change![.newKey] as! A)
    }
}

enum Result<A> {
    case success(A)
    case error(Error)
    
    init(_ value: A?, or error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .error(error)
        }
    }
}

extension Result {
    func map<B>(_ transform: (A) -> B) -> Result<B> {
        switch self {
        case .success(let value): return .success(transform(value))
        case .error(let error): return .error(error)
        }
    }
}

extension String: Error { }

final class Signal<A> {
    private typealias Token = UUID
    private var callbacks: [Token: (Result<A>) -> ()] = [:]
    var objects: [Any] = []
    
    static func pipe() -> ((Result<A>) -> (), Signal<A>) {
        let signal = Signal<A>()
        return ({ [weak signal] value in signal?.send(value) }, signal)
    }
    
    private func send(_ value: Result<A>) {
        for callback in callbacks.values {
            callback(value)
        }
    }
    
    func subscribe(_ callback: @escaping (Result<A>) -> ()) -> Disposable {
        let token = UUID()
        callbacks[token] = callback
        return Disposable {
            self.callbacks[token] = nil
        }
    }
    
    func map<B>(_ transform: @escaping (A) -> B) -> Signal<B> {
        let (sink, signal) = Signal<B>.pipe()
        let disposable = subscribe { result in
            sink(result.map(transform))
        }
        signal.objects.append(disposable)
        return signal
    }
    
    deinit {
        print("Removing signal")
    }
}

final class Disposable {
    let dispose: () -> ()
    init(_ dispose: @escaping () -> ()) {
        self.dispose = dispose
    }
    
    deinit {
        dispose()
    }
}

let (sink, signal) = Signal<String>.pipe()

DispatchQueue.global(qos: .userInitiated).async {
    for _ in 0..<30000 {
        signal.subscribe { _ in }
    }
}

for _ in 0..<30000 {
    sink(.success(""))
}





