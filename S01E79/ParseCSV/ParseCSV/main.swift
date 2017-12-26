//
//  main.swift
//  ParseCSV
//
//  Created by ZHOU DENGFENG on 24/12/17.
//  Copyright © 2017 ZHOU DENGFENG DEREK. All rights reserved.
//

import Foundation

let url = URL(fileURLWithPath: "/Users/Derek/Developer/SwiftTalk/S01E79/ParseCSV/ParseCSV/medium.txt")
let data = try! Data(contentsOf: url)
let string = String(data: data, encoding: .isoLatin1)! + ""

_ = parse(lines: string)

