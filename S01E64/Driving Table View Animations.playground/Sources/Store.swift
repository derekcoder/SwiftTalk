import Foundation

public final class Store {
    public var items: [String] = []
    
    public enum Change<A> {
        case insert(A)
        case delete(A)
    }
    
    public init() {
    }
    
    public func subscribe(_ f: @escaping (Change<String>) -> ()) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            let (name, deleted) = self.items.randomChange()
            let change: Change = deleted ? .delete(name) : .insert(name)
            f(change)
        }
    }
    
    public func subscribeMultiple(_ f: @escaping ([Change<String>]) -> ()) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let changes: [Change<String>] = (0..<3).map { _ in
                self.items.randomChange()
            }.simplified.map { (name, deleted) in
                return deleted ? .delete(name) : .insert(name)
            }
            f(changes)
        }
    }
}

