//: Playground - noun: a place where people can play

import Foundation

var dict: [String: Any] = [
    "countries": [
        "japan": [
            "capital": "tokyo"
        ]
    ]
]

/*
if var countries = dict["countries"] as? [String: Any],
    var japan = countries["japan"] as? [String: Any] {
    japan["capital"] = "berlin"
    countries["japan"] = japan
    dict["countries"] = countries
}

((dict["countries"] as? [String: Any])?["japan"] as? [String: Any])?["capital"]
*/

//(dict as NSDictionary).value(forKeyPath: "countries.japan.capital")


extension Dictionary {
    subscript(string key: Key) -> String? {
        get {
            return self[key] as? String
        }
        set {
            self[key] = newValue as? Value
        }
    }
    
    subscript(jsonDict key: Key) -> [String: Any]? {
        get {
            return self[key] as? [String: Any]
        }
        set {
            self[key] = newValue as? Value
        }
    }
}

dict[jsonDict: "countries"]?[jsonDict: "japan"]?[string: "capital"]?.append("!")
dump(dict)

