enum File {}
enum Directory {}

struct Path<FileType> {
    var components: [String]
    
    private init(_ components: [String]) {
        self.components = components
    }
    
    var rendered: String {
        return "/" + components.joined(separator: "/")
    }
}

extension Path where FileType == Directory {
    init(directoryComponents: [String]) {
        self.components = directoryComponents
    }
    
    func appending(directory: String) -> Path<Directory> {
        return Path(directoryComponents: components + [directory])
    }
    
    func appendingFile(_ file: String) -> Path<File> {
        return Path<File>(components + [file])
    }
}

let path = Path(directoryComponents: ["Users", "chris"])
//let path2 = path.appendingFile("test.md")
let path3 = path.appendingFile("test.md")

print(path3.rendered)
