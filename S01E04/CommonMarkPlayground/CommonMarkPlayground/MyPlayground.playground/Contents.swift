//: Playground - noun: a place where people can play

import cmark

let markdown = "# Heading **strong**\nHello **Markdown**!"

let tree = Node(markdown: markdown)!.elements
dump(tree)

extension Array where Element == NSAttributedString {
    func join(separator: String = "") -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString() }
        let result = self[0].mutableCopy() as! NSMutableAttributedString
        for element in suffix(from: 1) {
            result.append(NSAttributedString(string: separator))
            result.append(element)
        }
        return result
    }
}

extension UIFont {
    var bold: UIFont {
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)!
        return UIFont(descriptor: boldFontDescriptor, size: 0)
    }
}

extension NSAttributedString {
    func addAttribute(_ attribute: NSAttributedStringKey, value: Any) -> NSAttributedString {
        let result = mutableCopy() as! NSMutableAttributedString
        result.addAttribute(attribute, value: value, range: NSRange(location: 0, length: result.length))
        return result
    }
}

struct Attributes {
    var family: String
    var size: CGFloat
    var bold: Bool
    var color: UIColor
}

extension NSAttributedString {
    convenience init(string: String, attributes: Attributes) {
        let fontDescriptor = UIFontDescriptor(name: attributes.family, size: attributes.size)
        var traits = UIFontDescriptorSymbolicTraits()
        if attributes.bold {
            traits.formUnion(.traitBold)
        }
        let newFontDescriptor = fontDescriptor.withSymbolicTraits(traits)!
        let font = UIFont(descriptor: newFontDescriptor, size: 0)
        self.init(string: string, attributes: [.font: font, .foregroundColor: attributes.color])
    }
}

class Stylesheet {
    func strong(_ attributes: inout Attributes) {
        attributes.bold = true
        attributes.color = .red
    }
    
    func heading(_ attributes: inout Attributes) {
        attributes.size = 48
    }
}

extension Inline {
    func render(stylesheet: Stylesheet, attributes: Attributes) -> NSAttributedString {
        var newAttributes = attributes
        switch self {
        case .text(let text):
            return NSAttributedString(string: text, attributes: attributes)
        case .strong(let children):
            stylesheet.strong(&newAttributes)
            return children.map { $0.render(stylesheet: stylesheet, attributes: newAttributes) }.join()
        default: fatalError()
        }
    }
}

extension Block {
    func render(stylesheet: Stylesheet, attributes: Attributes) -> NSAttributedString {
        var newAttributes = attributes
        switch self {
        case .paragraph(let children):
            return children.map { $0.render(stylesheet: stylesheet, attributes: attributes) }.join()
        case .heading(let children, _):
            stylesheet.heading(&newAttributes)
            return children.map { $0.render(stylesheet: stylesheet, attributes: newAttributes) }.join()
        default: fatalError()
        }
    }
}

let baseAttributes = Attributes(family: "Helvetica", size: 24, bold: false, color: .black)
let stylesheet = Stylesheet()
let output = tree.map { $0.render(stylesheet: stylesheet, attributes: baseAttributes) }.join(separator: "\n")

output












