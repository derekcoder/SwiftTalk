//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport

let center = NotificationCenter.default

struct NotificationDescriptor<A> {
    let name: Notification.Name
    let convert: (Notification) -> A
}

struct PlaygroundPagePayload {
    let page: PlaygroundPage
    let needsIndefiniteExecution: Bool
}

extension PlaygroundPagePayload {
    init(note: Notification) {
        page = note.object as! PlaygroundPage
        needsIndefiniteExecution = note.userInfo!["PlaygroundPageNeedsIndefiniteExecution"] as! Bool
    }
}

let playgroundNotification = NotificationDescriptor<PlaygroundPagePayload>(name: Notification.Name("PlaygroundPageNeedsIndefiniteExecutionDidChangeNotification"), convert: PlaygroundPagePayload.init)

extension NotificationCenter {
    func addObserver<A>(forDescriptor d: NotificationDescriptor<A>, using block: @escaping (A) -> ()) -> Token {
        let t = addObserver(forName: d.name, object: nil, queue: nil, using: { note in
            block(d.convert(note))
        })
        return Token(token: t, center: self)
    }
}

var token: Token? = center.addObserver(forDescriptor: playgroundNotification, using: { print($0) })

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

