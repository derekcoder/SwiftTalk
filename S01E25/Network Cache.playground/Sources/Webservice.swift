import Foundation

public typealias JSONDictionary = [String: Any]

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
    case notAuthenticated
    case other
}

func logError<A>(_ result: Result<A>) {
    guard case let .error(e) = result else { return }
    assert(false, "\(e)")
}

var session: URLSession {
    let config = URLSessionConfiguration.default
    config.urlCache = nil
    return URLSession(configuration: config)
}

public final class Webservice {
    public var authenticationToken: String?
    public init() { }
    
    public func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        session.dataTask(with: resource.url, completionHandler: { data, response, _ in
            let result: Result<A>
            if let httpResponse = response as? HTTPURLResponse , httpResponse.statusCode == 401 {
                result = Result.error(WebserviceError.notAuthenticated)
            } else {
                let parsed = data.flatMap(resource.parse)
                result = Result(parsed, or: WebserviceError.other)
            }
            DispatchQueue.main.async { completion(result) }
        }) .resume()
    }
}




















