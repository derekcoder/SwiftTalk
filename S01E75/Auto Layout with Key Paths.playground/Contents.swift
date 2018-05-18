//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

extension UIView {
    func addSubview(_ other: UIView, constraints: [Constraint]) {
        addSubview(other)
        other.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { c in
            c(other, self)
        })
    }
}

func equal<L>(_ keyPath: KeyPath<UIView, L>, to constant: CGFloat) -> Constraint where L: NSLayoutDimension {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

func equal<Axis, L>(_ keyPath: KeyPath<UIView, L>) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalTo: parent[keyPath: keyPath])
    }
}

func equal<Axis, L>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: from].constraint(equalTo: parent[keyPath: to])
    }
}

let root = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
root.backgroundColor = .white

let label = UILabel(frame: .zero)
label.backgroundColor = .blue
label.textAlignment = .center
label.textColor = .white
label.text = "This is a label."

root.addSubview(label, constraints: [
    equal(\.topAnchor),
    equal(\.leadingAnchor),
    equal(\.trailingAnchor),
    equal(\.heightAnchor, to: 200),
])

PlaygroundPage.current.liveView = root

