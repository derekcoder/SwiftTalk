import Foundation

extension Array where Element == String {
    public mutating func randomChange() -> (String, deleted: Bool) {
        let freshNames = names.filter { !self.contains($0) }
        if freshNames.isEmpty || count > 1 && arc4random_uniform(2) == 0 {
            let index = Int(arc4random_uniform(UInt32(count)))
            let old = self[index]
            remove(at: index)
            return (old, true)
        } else {
            let nameIndex = Int(arc4random_uniform(UInt32(freshNames.count)))
            let index = Int(arc4random_uniform(UInt32(count + 1)))
            insert(freshNames[nameIndex], at: index)
            return (self[index], false)
        }
    }
}

extension Array where Element == (String, deleted: Bool) {
    mutating func simplify() {
        var index = startIndex
        while index < endIndex {
            let (name, deleted) = self[index]
            if !deleted, let deletion = self[index+1..<endIndex].index(where: { $0.0 == name && $0.1 == true}) {
                self.remove(at: deletion)
                self.remove(at: index)
            } else {
                index += 1
            }
        }
        
    }
    public var simplified: [(String, deleted: Bool)] {
        var result = self
        result.simplify()
        return result
    }
}

let names = [
    "Hertha",
    "Meagan",
    "Alphonse",
    "Malinda",
    "Jerrold",
    "Loria",
    "Brittanie",
    "Vikki",
    "Hui",
    "Rachelle",
    "Bob",
    "Rosy",
    "Dannie",
    "Larisa",
    "Vannesa",
    "Otelia",
    "Bess",
    "Alejandro",
    "Cheyenne",
    "Marilee",
    "Clotilde",
    "Gavin",
    "Ronnie",
    "Anika",
    "Mui",
    "Alvaro",
    "Liberty",
    "Lemuel",
    "Rupert",
    "Beverley"
]



