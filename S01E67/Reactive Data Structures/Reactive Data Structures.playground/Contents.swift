import Foundation
import Result
import ReactiveSwift

enum List<A> {
    case empty
    indirect case cons(A, List<A>)
}

extension List {
    func reduce<B>(_ initial: B, _ combine: (B, A) -> B) -> B {
        switch self {
        case .empty:
            return initial
        case let .cons(value, tail):
            let intermediate = combine(initial, value)
            return tail.reduce(intermediate, combine)
        }
    }
}

//let list: List<Int> = .cons(1, .cons(2, .cons(3, .empty)))
//list.reduce(0, +)

enum RList<A> {
    case empty
    indirect case cons(A, MutableProperty<RList<A>>)
}

extension RList {
    init(array: [A]) {
        self = .empty
        for element in array.reversed() {
            self = .cons(element, MutableProperty(self))
        }
    }
}

extension RList {
    func reduce<B>(_ initial: B, _ combine: @escaping (B, A) -> B) -> Property<B> {
        let result = MutableProperty(initial)
        func reduceH(list: RList<A>, intermediate: B) {
            switch list {
            case .empty:
                result.value = intermediate
            case let .cons(value, tail):
                let newIntermediate = combine(intermediate, value)
                tail.signal.observeValues { newTail in
                    reduceH(list: newTail, intermediate: newIntermediate)
                }
                reduceH(list: tail.value, intermediate: newIntermediate)
            }
        }
        reduceH(list: self, intermediate: initial)
        return Property(result)
    }
}

func append<A>(_ value: A, to list: MutableProperty<RList<A>>) {
    switch list.value {
    case .empty:
        list.value = .cons(value, MutableProperty(.empty))
    case .cons(_, let tail):
        append(value, to: tail)
    }
}

func add(_ l: Int, _ r: Int) -> Int {
    print("going to add: \(l) and \(r)")
    return l + r
}

let sample = MutableProperty(RList(array: [1, 2, 3]))
let sum = sample.flatMap(.latest) { $0.reduce(0, add) }
sum.value
sum.signal.observeValues { print($0) }
print("---")
append(4, to: sample)
sum.value

