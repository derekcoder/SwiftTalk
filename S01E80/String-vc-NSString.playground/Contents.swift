//: Playground - noun: a place where people can play

import UIKit

var text = "_Hello_ 👩🏼‍🚒 *World* 🇫🇷👨‍👩‍👧"

var value = "👩🏼‍🚒"

let stringCount = value.count
let nsStringCount = (value as NSString).length
let utf16Count = value.utf16.count
let unicodeScalarCount = value.unicodeScalars.count
let byteCount = value.data(using: .utf8)!.count
