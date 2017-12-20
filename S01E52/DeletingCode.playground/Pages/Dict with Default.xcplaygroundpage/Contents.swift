
var str = "Hello"

/*
extension Dictionary {
    subscript(key: Key, or other: Value) -> Value {
        get {
            return self[key] ?? other
        }
        set {
            self[key] = newValue
        }
    }
}*/

var frequencies: [Character: Int] = [:]
for c in str {
    frequencies[c, default: 0] += 1
}
print(frequencies)
