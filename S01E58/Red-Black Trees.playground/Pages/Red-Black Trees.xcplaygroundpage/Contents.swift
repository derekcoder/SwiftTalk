//: Playground - noun: a place where people can play

enum Color {
    case red
    case black
}

enum RedBlackTree<Element: Comparable> {
    case empty
    indirect case node(Color, Element, RedBlackTree<Element>, RedBlackTree<Element>)
}

extension RedBlackTree {
    func inserting(_ newElement: Element) -> RedBlackTree<Element> {
        switch _inserting(newElement) {
        case let .node(.red, element, left, right):
            return .node(.black, element, left, right)
        case let tree:
            return tree
        }
    }
    
    func _inserting(_ newElement: Element) -> RedBlackTree<Element> {
        switch self {
        case .empty:
            return .node(.red, newElement, .empty, .empty)
        case let .node(color, element, left, right):
            if element < newElement {
                return balanced(color, element, left, right._inserting(newElement))
            } else {
                return balanced(color, element, left._inserting(newElement), right)
            }
        }
    }
    
    private func balanced(_ color: Color, _ element: Element, _ left: RedBlackTree, _ right: RedBlackTree) -> RedBlackTree {
        switch (color, element, left, right) {
        case let (.black, z, .node(.red, y, .node(.red, x, a, b), c), d):
            return .node(.red, y, .node(.black, x, a, b), .node(.black, z, c, d))
        case let (.black, z, .node(.red, x, a, .node(.red, y, b, c)), d):
            return .node(.red, y, .node(.black, x, a, b), .node(.black, z, c, d))
        case let (.black, x, a, .node(.red, z, .node(.red, y, b, c), d)):
            return .node(.red, y, .node(.black, x, a, b), .node(.black, z, c, d))
        case let (.black, x, a, .node(.red, y, b, .node(.red, z, c, d))):
            return .node(.red, y, .node(.black, x, a, b), .node(.black, z, c, d))
        default:
            return .node(color, element, left, right)
        }
    }
    
    mutating func insert(_ newElement: Element) {
        self = inserting(newElement)
    }
    
    func contains(_ element: Element) -> Bool {
        switch self {
        case .empty:
            return false
        case let .node(_, member, left, right):
            if member == element {
                return true
            } else if member < element {
                return right.contains(element)
            }
            else {
                return left.contains(element)
            }
        }
    }
}

extension RedBlackTree: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty:
            return "()"
        case let .node(_, element, .empty, .empty):
            return "(\(element))"
        case let .node(_, element, left, right):
            return "(\(left) \(element) \(right))"
        }
    }
}

import UIKit

let nodeSize: CGFloat = 24.0
func renderNode(color: UIColor = .black, label: String) -> UIImage {
    let bounds = CGRect(x: 0, y: 0, width: nodeSize, height: nodeSize)
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { context in
        let c = context.cgContext
        color.setFill()
        c.fillEllipse(in: bounds)
        let attributes: [NSAttributedStringKey: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
        let size = (label as NSString).size(withAttributes: attributes)
        let labelBounds = CGRect(origin: CGPoint(x: bounds.midX-size.width/2, y: bounds.midY-size.height/2), size: size)
        (label as NSString).draw(in: labelBounds, withAttributes: attributes)
    }
}
let horizontalPadding: CGFloat = 24
let verticalPadding: CGFloat = 20
struct TreeImage {
    let image: UIImage
    let rootMidX: CGFloat
}
extension RedBlackTree {
    func _render() -> TreeImage? {
        switch self {
        case .empty:
            return nil
        case let .node(color, element, left, right):
            let nodeImage = renderNode(color: color == .red ? .red : .black, label: "\(element)")
            switch (left._render(), right._render()) {
            case (nil, nil):
                return TreeImage(image: nodeImage, rootMidX: nodeSize / 2)
            case let (leftImage, rightImage):
                let leftSize = leftImage?.image.size ?? .zero
                let rightSize = rightImage?.image.size ?? .zero
                let bounds = CGRect(
                    x: 0,
                    y: 0,
                    width: leftSize.width + horizontalPadding + rightSize.width,
                    height: nodeImage.size.height + verticalPadding + Swift.max(leftSize.height, rightSize.height))
                let nodeRect = CGRect(origin: CGPoint(x: leftSize.width + horizontalPadding / 2 - nodeImage.size.width / 2, y: 0),
                                      size: nodeImage.size)
                let renderer = UIGraphicsImageRenderer(bounds: bounds)
                let image = renderer.image { context in
                    let subtreeY = nodeImage.size.height + verticalPadding
                    let start = CGPoint(x: nodeRect.midX, y: nodeRect.midY)
                    if let leftImage = leftImage {
                        let leftRect = CGRect(origin: CGPoint(x: 0, y: subtreeY),
                                              size: leftImage.image.size)
                        let end = CGPoint(x: leftImage.rootMidX, y: leftRect.minY + nodeSize / 2)
                        context.cgContext.drawLine(from: start, to: end)
                        leftImage.image.draw(at: leftRect.origin)
                    }
                    if let rightImage = rightImage {
                        let rightRect = CGRect(origin: CGPoint(x: nodeRect.midX + horizontalPadding / 2, y: subtreeY),
                                               size: rightImage.image.size)
                        let end = CGPoint(x: rightRect.minX + rightImage.rootMidX, y: rightRect.minY + nodeSize / 2)
                        context.cgContext.drawLine(from: start, to: end)
                        rightImage.image.draw(at: rightRect.origin)
                    }
                    nodeImage.draw(at: nodeRect.origin)
                }
                return TreeImage(image: image, rootMidX: nodeRect.midX)
            }
        }
    }
    
    func render() -> UIImage? {
        return _render()?.image
    }
}

extension CGContext {
    func drawLine(from start: CGPoint, to end: CGPoint, color: UIColor = .black, width: CGFloat = 1) {
        self.saveGState()
        self.move(to: start)
        self.addLine(to: end)
        UIColor.black.setStroke()
        self.setLineWidth(1)
        self.strokePath()
        self.restoreGState()
    }
}
extension Array {
    public mutating func shuffle() {
        for i in 0 ..< count {
            let j = Int(arc4random_uniform(UInt32(count)))
            if i != j {
                swapAt(i, j)
            }
        }
    }
}
extension Sequence {
    public func shuffled() -> [Iterator.Element] {
        var array = Array(self)
        array.shuffle()
        return array
    }
}

var tree = RedBlackTree<Int>.empty
for i in 0..<20 {
    tree.insert(i)
}
tree.render()
