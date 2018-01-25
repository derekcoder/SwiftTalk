//
//  main.swift
//  PDFGenerator
//
//  Created by Derek on 25/1/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import Cocoa

extension String {
    func writePDF(to url: URL) {
        let textView = NSTextView()
        textView.frame.size = CGSize(width: 200, height: 100)
        textView.string = self
        textView.backgroundColor = .red
        
        let printInfo = NSPrintInfo(dictionary: [
            .jobDisposition: NSPrintInfo.JobDisposition.save,
            .jobSavingURL: url
            ])
        let op = NSPrintOperation(view: textView, printInfo: printInfo)
        op.showsPrintPanel = false
        op.showsProgressPanel = false
        op.run()
    }
}

let data = FileHandle.standardInput.readDataToEndOfFile()
let string = String(data: data, encoding: .utf8)

string?.writePDF(to: URL(fileURLWithPath: "/Users/Derek/Desktop/out.pdf"))
