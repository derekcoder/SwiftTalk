//
//  ViewController.swift
//  ButtonFlowLayout
//
//  Created by Derek on 18/5/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import UIKit

func flowLayout(containerSize: CGSize, spacing: UIOffset = UIOffset(horizontal: 10, vertical: 10), sizes: [CGSize]) -> [CGRect] {
    var current = CGPoint.zero
    var lineHeight: CGFloat = 0

    var result: [CGRect] = []
    for size in sizes {
        if current.x + size.width > containerSize.width {
            current.x = 0
            current.y += lineHeight + spacing.vertical
            lineHeight = 0
        }
        defer {
            lineHeight = max(lineHeight, size.height)
            current.x += size.width + spacing.horizontal
        }
        result.append(CGRect(origin: current, size: size))
    }
    return result
}

final class ButtonsView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizes = subviews.map { $0.intrinsicContentSize }
        let frames = flowLayout(containerSize: bounds.size, sizes: sizes)
        for (idx, frame) in frames.enumerated() {
            subviews[idx].frame = frame
        }
    }
}

extension UIButton {
    convenience init(pill title: String) {
        self.init(type: .custom)
        setTitle(title, for: .normal)
        backgroundColor = UIColor.lightGray
        contentEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 15)
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = intrinsicContentSize.height / 2
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var buttonView: ButtonsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttons = (0..<20).map { UIButton(pill: "Button   \($0)") }
        for b in buttons { buttonView.addSubview(b) }
    }
}

