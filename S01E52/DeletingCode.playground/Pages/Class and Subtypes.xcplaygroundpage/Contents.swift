//: [Previous](@previous)

import UIKit

protocol HeaderView {
    func setTitle(_ string: String)
}

class ParallaxView: UIView {
    let headerView: UIView & HeaderView
    
    init(frame: CGRect, headerView: UIView & HeaderView) {
        self.headerView = headerView
        super.init(frame: frame)
        
        addSubview(headerView)
        headerView.setTitle("Hello")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
}

extension UILabel: HeaderView {
    func setTitle(_ string: String) {
        text = string
    }
}

let header = UILabel()
let p = ParallaxView(frame: .zero, headerView: header)
