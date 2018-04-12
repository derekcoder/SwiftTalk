public enum BinaryTree<Element: Comparable> {
    case empty
    indirect case node(Element, BinaryTree<Element>, BinaryTree<Element>)
}

extension BinaryTree {
    public func inserting(_ newElement: Element) -> BinaryTree<Element> {
        switch self {
        case let .node(element, left, right):
            if element < newElement {
                return .node(element, left, right.inserting(newElement))
            } else {
                return .node(element, left.inserting(newElement), right)
            }
        default:
            return .node(newElement, .empty, .empty)
        }
    }
    
    public mutating func insert(_ newElement: Element) {
        self = inserting(newElement)
    }
}

