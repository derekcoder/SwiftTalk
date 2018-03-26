//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

class MyViewController: UIViewController {
    let rootStackView = UIStackView()
    let titleLabel = UILabel()
    let emailLabel = UILabel()
    let emailTextField = UITextField()
    let emailStackView = UIStackView()
    let nameLabel = UILabel()
    let nameTextField = UITextField()
    let nameStackView = UIStackView()
    let passwordLabel = UILabel()
    let passwordTextField = UITextField()
    let passwordStackView = UIStackView()
    let submitButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        
        titleLabel.text = "Sign up"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: self.traitCollection)
        titleLabel.textColor = UIColor(white: 0.2, alpha: 1)
        
        nameLabel.text = "Name"
        nameLabel.font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: self.traitCollection)
        nameTextField.borderStyle = .roundedRect
        nameStackView.axis = .vertical
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(nameTextField)
        
        emailLabel.text = "Email"
        emailLabel.font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: self.traitCollection)
        emailTextField.borderStyle = .roundedRect
        emailStackView.axis = .vertical
        emailStackView.addArrangedSubview(emailLabel)
        emailStackView.addArrangedSubview(emailTextField)
        
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: self.traitCollection)
        passwordTextField.borderStyle = .roundedRect
        passwordStackView.axis = .vertical
        passwordStackView.addArrangedSubview(passwordLabel)
        passwordStackView.addArrangedSubview(passwordTextField)
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .blue
        submitButton.layer.cornerRadius = 6
        submitButton.layer.masksToBounds = true
        submitButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout, compatibleWith: self.traitCollection)
        submitButton.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
        
        rootStackView.spacing = 16
        
        view.addSubview(rootStackView)
        rootStackView.addArrangedSubview(titleLabel)
        rootStackView.addArrangedSubview(nameStackView)
        rootStackView.addArrangedSubview(emailStackView)
        rootStackView.addArrangedSubview(passwordStackView)
        rootStackView.addArrangedSubview(submitButton)
        
        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStackView.topAnchor.constraint(equalTo: view.topAnchor),
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)            
        ])
    }
}

let parent = UIViewController()
let vc = MyViewController()
parent.addChildViewController(vc)

let traits = UITraitCollection(traitsFrom: [
    UITraitCollection(verticalSizeClass: .regular),
    UITraitCollection(horizontalSizeClass: .compact),
    UITraitCollection(preferredContentSizeCategory: .extraSmall)
    ])


parent.preferredContentSize = .init(width: 320, height: 568)

parent.setOverrideTraitCollection(traits, forChildViewController: vc)

parent.view.translatesAutoresizingMaskIntoConstraints = false
parent.view.addSubview(vc.view)

NSLayoutConstraint.activate([
    vc.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
    vc.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
    vc.view.topAnchor.constraint(equalTo: parent.view.topAnchor),
    vc.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor)
    ])

let anotherVC = MyViewController()
let anotherParent = playgroundWrapper(child: anotherVC, device: .phone4inch, orientation: .portrait, contentSizeCategory: UIContentSizeCategory.extraExtraLarge)

PlaygroundPage.current.liveView = anotherParent

























