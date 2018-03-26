//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import MyFramework

let bundle = Bundle(for: StoryboardSignupViewController.self)
let storyboard = UIStoryboard(name: "StoryboardSignupViewController", bundle: bundle)

let vc = storyboard.instantiateInitialViewController()!

let parent = playgroundWrapper(child: vc, device: .phone4_7inch, orientation: .portrait, contentSizeCategory: .large)

PlaygroundPage.current.liveView = parent

