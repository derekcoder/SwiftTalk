//: Playground - noun: a place where people can play

import UIKit

let store = Store()

final class TableViewController: UITableViewController {
    var names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        store.subscribeMultiple { [weak self] changes in
            guard let `self` = self else { return }
            self.names = store.items.sorted()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
}


import PlaygroundSupport
let vc = TableViewController()
vc.view.frame = CGRect(x: 0, y: 0, width: 250, height: 400)
PlaygroundPage.current.liveView = vc.view
