//: Playground - noun: a place where people can play

import UIKit

final class Header {
    let setTitle: (String) -> ()
    let view: UIView
    
    init(view: UIView, setTitle: @escaping (String) -> ()) {
        self.setTitle = setTitle
        self.view = view
    }
}

class ParallaxView: UIView {
    let headerView: Header
    
    init(frame: CGRect, headerView: Header) {
        self.headerView = headerView
        super.init(frame: frame)
        
        addSubview(headerView.view)
        headerView.setTitle("Hello")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

let label = UILabel()
let header = Header(view: label, setTitle: { label.text = $0 })
let p = ParallaxView(frame: .zero, headerView: header)
