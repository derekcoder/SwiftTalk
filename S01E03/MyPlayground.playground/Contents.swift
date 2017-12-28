//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

public struct Episode {
    public let id: String
    public let title: String
}

extension Episode {
    public init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            let title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
}

public struct Media {}

public let url = URL(string: "https://talk.objc.io/episodes.json")!

extension Episode {
    public static let all = Resource<[Episode]>(url: url, parseJSON: { json in
        guard let dictionaries = json as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap(Episode.init)
    })
}


let sharedWebservice = Webservice()

final class LoadingViewController: UIViewController {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    init<A>(load: (@escaping (Result<A>) -> ()) -> (), build: @escaping (A) -> UIViewController) {
        super.init(nibName: nil, bundle: nil)
        spinner.startAnimating()
        load() { [weak self] result in
            self?.spinner.stopAnimating()
            guard let value = result.value else { return }
            self?.add(content: build(value))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(spinner)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.center(in: view)
    }
    
    func add(content: UIViewController) {
        addChildViewController(content)
        view.addSubview(content.view)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        content.view.constraint(edgesToMarginOf: view)
        content.didMove(toParentViewController: self)
    }
}

final class EpisodeDetailViewController: UIViewController {
    let titleLabel = UILabel()
    
    convenience init(episodes: [Episode]) {
        self.init()
        titleLabel.text = episodes.first?.title
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.constraint(edgesToMarginOf: view)
    }
}

let episodesVC = LoadingViewController(load: { callback in
    sharedWebservice.load(resource: Episode.all, completion: callback)
}, build: EpisodeDetailViewController.init)
episodesVC.view.frame = CGRect(origin: .zero, size: CGSize(width: 250, height: 300))

PlaygroundPage.current.liveView = episodesVC.view
PlaygroundPage.current.needsIndefiniteExecution = true















