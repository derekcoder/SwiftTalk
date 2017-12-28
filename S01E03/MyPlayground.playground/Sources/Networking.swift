import Foundation

public typealias JSONDictionary = [String: Any]

public struct Resource<A> {
    public let url: URL
    public let parse: (Data) -> A?
}

extension Resource {
    public init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data)
            return json.flatMap(parseJSON)
        }
    }
}

public enum Result<A> {
    case success(A)
    case error(Error)
}

extension Result {
    public init(_ value: A?, or error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .error(error)
        }
    }
    
    public var value: A? {
        guard case .success(let v) = self else { return nil }
        return v
    }
}

public enum WebserviceError: Error {
    case other
}

public final class Webservice {
    public init() {}
    public func load<A>(resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { data, _, _ in
            let parsed = data.flatMap(resource.parse)
            let result = Result(parsed, or: WebserviceError.other)
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }
}
