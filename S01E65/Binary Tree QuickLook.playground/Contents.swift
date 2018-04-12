//: Playground - noun: a place where people can play

import UIKit

let nodeSize = CGSize(width: 24, height: 24)
let nodeAttributes: [NSAttributedStringKey: Any] = [
    NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12),
    NSAttributedStringKey.foregroundColor: UIColor.white
]

let tree: BinaryTree = .node(
    5,
    .node(
        3,
        .node(1, .empty, .empty),
        .node(4, .empty, .empty)
    ),
    .node(
        10,
        .node(7, .empty, .empty),
        .empty
    )
)

let spacing = (horizontal: 1.5 as CGFloat, vertical: 1.5 as CGFloat)
extension BinaryTree {
    var maxHeight: Int {
        switch self {
        case .empty: return 0
        case let .node(_, left, right): return max(left.maxHeight, right.maxHeight) + 1
        }
    }
    
    var bounds: CGRect {
        let width = pow(2, CGFloat(maxHeight)-1) * nodeSize.width * spacing.horizontal
        let height = CGFloat(maxHeight) * nodeSize.height * spacing.vertical
        return CGRect(origin: .zero, size: CGSize(width: width, height: height))
    }
    
    func render(into context: CGContext, at center: CGPoint, currentHeight: Int) {
        guard case let .node(element, left, right) = self else { return }
        
        func recurse(child: BinaryTree, offset: CGFloat) {
            guard case .node = child else { return }
            let childCenter = CGPoint(x: center.x+offset, y: center.y+nodeSize.height*spacing.vertical)
            context.drawLine(from: center, to: childCenter)
            child.render(into: context, at: childCenter, currentHeight: currentHeight-1)
        }
        
        let offset = pow(2, CGFloat(currentHeight-1)) * nodeSize.width * spacing.horizontal / 2
        recurse(child: left, offset: -offset)
        recurse(child: right, offset: offset)
        
        UIColor.black.setFill()
        context.fillEllipse(in: CGRect(center: center, size: nodeSize))
        "\(element)".draw(center: center, attributes: nodeAttributes)
    }
    
    func render() -> UIImage {
        let center = CGPoint(x: bounds.midX, y: nodeSize.height/2)
        return UIGraphicsImageRenderer(bounds: bounds).image { context in
            self.render(into: context.cgContext, at: center, currentHeight: self.maxHeight-1)
        }
    }
}

extension BinaryTree: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return render()
    }
}

tree
