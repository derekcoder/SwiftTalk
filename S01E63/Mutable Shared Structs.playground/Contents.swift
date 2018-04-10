
struct Person {
    var first: String
    var last: String
    
    init(first: String, last: String) {
        self.first = first
        self.last = last
    }
}

extension Person: Equatable {
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.first == rhs.first && lhs.last == rhs.last
    }
}

let people = [
    Person(first: "Jo", last: "Smith"),
    Person(first: "Joanne", last: "Williams"),
    Person(first: "Annie", last: "Williams"),
    Person(first: "Robert", last: "Jones"),
    ]

final class Var<A> {
    private let _get: () -> A
    private let _set: (A) -> ()
    let addObserver: (_ observer: @escaping Observer) -> Disposable
    
    var value: A {
        get {
            return _get()
        }
        set {
            _set(newValue)
        }
    }
    init(initialValue: A) {
        var observers: [Int:Observer] = [:]
        var value = initialValue {
            didSet {
                for o in observers.values {
                    o(value, oldValue)
                }
            }
        }
        _get = { value }
        _set = { newValue in value = newValue }
        var freshInt = (0...).makeIterator()
        addObserver = { observer in
            let id = freshInt.next()!
            observers[id] = observer
            return Disposable { observers[id] = nil }
        }
    }
    
    typealias Observer = (A, A) -> ()
    
    private init(get: @escaping () -> A, set: @escaping (A) -> (), addObserver: @escaping (@escaping Observer) -> Disposable) {
        _get = get
        _set = set
        self.addObserver = addObserver
    }
    
    subscript<B>(keyPath: WritableKeyPath<A, B>) -> Var<B> {
        return Var<B>(get: {
            self.value[keyPath: keyPath]
        }, set: { newValue in
            self.value[keyPath: keyPath] = newValue
        }, addObserver: { observer in
            self.addObserver { newValue, oldValue in
                observer(newValue[keyPath: keyPath], oldValue[keyPath: keyPath])
            }
        })
    }
}

extension Var where A: MutableCollection {
    subscript(index: A.Index) -> Var<A.Element> {
        return Var<A.Element>(get: {
            self.value[index]
        }, set: { newValue in
            self.value[index] = newValue
        }, addObserver: { observer in
            self.addObserver { newValue, oldValue in
                observer(newValue[index], oldValue[index])
            }
        })
    }
}

final class Disposable {
    private let dispose: () -> ()
    init(_ dispose: @escaping () -> ()) {
        self.dispose = dispose
    }
    deinit {
        dispose()
    }
}

final class PersonViewController {
    var person: Var<Person>
    let disposable: Any?
    
    init(person: Var<Person>) {
        self.person = person
        disposable = self.person.addObserver { newPerson, oldPerson in
            guard newPerson != oldPerson else { return }
            print(newPerson)
        }
    }
    
    func update() {
        person.value.last = "changed"
    }
}

let peopleVar: Var<[Person]> = Var(initialValue: people)
peopleVar.addObserver { newPeople, oldPeople in
    print("peoplevar changed: \(newPeople)")
}

peopleVar[1].value.first = "Test"

let vc = PersonViewController(person: peopleVar[0])
vc.update()

