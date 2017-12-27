//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

typealias JSONDictionary = [String: Any]

struct Episode {
    let id: String
    let title: String
}

extension Episode {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            let title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
}

struct Media {}

let url = URL(string: "https://talk.objc.io/episodes.json")!

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data)
            return json.flatMap(parseJSON)
        }
    }
}

extension Episode {
    static let all = Resource<[Episode]>(url: url, parseJSON: { json in
        guard let dictionaries = json as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap(Episode.init)
    })    
}


final class Webservice {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { data, _, _ in
            let result = data.flatMap(resource.parse)
            completion(result)
        }.resume()
    }
}

Webservice().load(resource: Episode.all) { result in
    print(result)
}

PlaygroundPage.current.needsIndefiniteExecution = true
