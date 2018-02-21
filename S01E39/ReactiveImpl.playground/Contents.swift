//: Playground - noun: a place where people can play

import Cocoa

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
    private var callbacks: [(Result<A>) -> ()] = []
    var objects: [Any] = []
    
    static func pipe() -> ((Result<A>) -> (), Signal<A>) {
        let signal = Signal<A>()
        return ({ [weak signal] value in signal?.send(value) }, signal)
    }
    
    private func send(_ value: Result<A>) {
        for callback in callbacks {
            callback(value)
        }
    }
    
    func subscribe(_ callback: @escaping (Result<A>) -> ()) {
        callbacks.append(callback)
    }
    
    deinit {
        print("Removing signal")
    }
}

extension NSTextField {
    func signal() -> Signal<String> {
        let (sink, result) = Signal<String>.pipe()
        let observer = KeyValueObserver(object: self, keyPath: #keyPath(stringValue)) { str in
            sink(.success(str))
        }
        result.objects.append(observer)
        return result
    }
}

final class VC {
    let textField = NSTextField()
    var stringSignal: Signal<String>?
    func viewDidLoad() {
        stringSignal = textField.signal()
        stringSignal?.subscribe { result in
            print(result)
        }
    }
    
    deinit {
        print("Removing vc")
    }
}

var vc: VC? = VC()
vc?.viewDidLoad()
vc?.textField.stringValue = "New Value"
vc = nil
