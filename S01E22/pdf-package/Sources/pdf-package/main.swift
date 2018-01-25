import Cocoa
import Commander

extension String {
    func writePDF(to url: URL, width: CGFloat) {
        let textView = NSTextView()
        textView.frame.size = CGSize(width: width, height: 100)
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

command(
    Option("width", default: 200, description: "The width of text box.")
) { width in
    let data = FileHandle.standardInput.readDataToEndOfFile()
    let string = String(data: data, encoding: .utf8)
    
    string?.writePDF(to: URL(fileURLWithPath: "/Users/Derek/Desktop/out.pdf"), width: CGFloat(width))
}.run()



