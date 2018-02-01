//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport

let center = NotificationCenter.default

protocol NotificationDescriptor {
    static var name: Notification.Name { get }
    init(notification: Notification)
}

struct PlaygroundPageNotification {
    let page: PlaygroundPage
    let needsIndefiniteExecution: Bool
}

extension PlaygroundPageNotification: NotificationDescriptor {
    static let name = Notification.Name("PlaygroundPageNeedsIndefiniteExecutionDidChangeNotification")
    
    init(notification: Notification) {
        page = notification.object as! PlaygroundPage
        needsIndefiniteExecution = notification.userInfo!["PlaygroundPageNeedsIndefiniteExecution"] as! Bool
    }
}

extension NotificationCenter {
    func addObserver<Note: NotificationDescriptor>(queue: OperationQueue? = nil, using block: @escaping (Note) -> ()) -> Token {
        let t = addObserver(forName: Note.name, object: nil, queue: queue, using: { note in
            block(Note(notification: note))
        })
        return Token(token: t, center: self)
    }
}

var token: Token? = center.addObserver { (note: PlaygroundPageNotification) in
    print(note)
}

class Token {
    let token: NSObjectProtocol
    let center: NotificationCenter
    
    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
token = nil
PlaygroundPage.current.needsIndefiniteExecution = false
