//: Playground - noun: a place where people can play

import Foundation

struct SortedArray<Element> {
    var elements: [Element]
    let areInIncreasingOrder: (Element, Element) -> Bool
    
    init<S: Sequence>(unsorted: S, areInIncreasingOrder: @escaping (Element, Element) -> Bool) where S.Iterator.Element == Element {
        elements = unsorted.sorted(by: areInIncreasingOrder)
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    
    mutating func insert(_ element: Element) {
        elements.append(element)
        elements.sort(by: areInIncreasingOrder)
    }
}

extension SortedArray: Collection {
    var startIndex: Int {
        return elements.startIndex
    }
    
    var endIndex: Int {
        return elements.endIndex
    }
    
    subscript(index: Int) -> Element {
        return elements[index]
    }
    
    func index(after i: Int) -> Int {
        return elements.index(after: i)
    }
    
    func min() -> Element? {
        return elements.first
    }
}

extension SortedArray where Element: Comparable {
    init<S: Sequence>(unsorted: S) where S.Iterator.Element == Element {
        self.init(unsorted: unsorted, areInIncreasingOrder: <)
    }
}

var x = SortedArray(unsorted: [3,1,2])
x.elements
x.insert(-1)
x.elements

for y in x {
    print(y)
}
x.count
x.min()
