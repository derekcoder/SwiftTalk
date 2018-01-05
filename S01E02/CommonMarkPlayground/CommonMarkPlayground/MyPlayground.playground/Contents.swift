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

extension Inline {
    func render(font: UIFont) -> NSAttributedString {
        switch self {
        case .text(let text):
            return NSAttributedString(string: text, attributes: [.font: font])
        case .strong(let children):
            let result = children.map { $0.render(font: font) }.join()
            return result.addAttribute(.font, value: font.bold)
        default: fatalError()
        }
    }
}

extension Block {
    func render(font: UIFont) -> NSAttributedString {
        switch self {
        case .paragraph(let children):
            return children.map { $0.render(font: font) }.join()
        case .heading(let children, _):
            let headerFont = font.withSize(48.0)
            return children.map { $0.render(font: headerFont) }.join()
        default: fatalError()
        }
    }
}

let baseFont = UIFont(name: "Helvetica", size: 24)!
let output = tree.map { $0.render(font: baseFont) }.join(separator: "\n")

output












