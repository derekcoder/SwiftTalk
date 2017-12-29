//: Playground - noun: a place where people can play

import Foundation

public typealias JSONDictionary = [String: Any]

public enum HttpMethod<Body> {
    case get
    case post(Body)
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}

extension HttpMethod {
    func map<B>(f: (Body) -> B) -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .post(let body): return .post(f(body))
        }
    }
}

public struct Resource<A> {
    public let url: URL
    public let method: HttpMethod<Data>
    public let parse: (Data) -> A?
}

extension Resource {
    public init(url: URL, method: HttpMethod<Any> = .get, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.method = method.map { json in
            // TODO try! is not safe here anymore
            try! JSONSerialization.data(withJSONObject: json)
        }
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data)
            return json.flatMap(parseJSON)
        }
    }
}

extension URLRequest {
    init<A>(resource: Resource<A>) {
        self.init(url: resource.url)
        httpMethod = resource.method.method
        if case let .post(data) = resource.method {
            httpBody = data
        }
    }
}

public final class Webservice {
    public init() {}
    public func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        let request = URLRequest(resource: resource)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            let result = data.flatMap(resource.parse)
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }
}

//let url = URL(string: "https://videos-staging.herokuapp.com/episodes.json")!

func pushNotification(token: String) -> Resource<Bool> {
    let url = URL(string: "")!
    let dictionary = ["token": token]
    return Resource(url: url, method: .post(dictionary), parseJSON: { _ in
        return true
    })
}
