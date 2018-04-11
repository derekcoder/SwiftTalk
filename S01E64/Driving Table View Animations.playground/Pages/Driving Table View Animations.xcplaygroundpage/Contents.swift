//: [Previous](@previous)

import UIKit

let store = Store()

final class SortedArrayController<Element: Comparable> {
    var sortedArray: SortedArray<Element>
    
    init(unsorted: [Element]) {
        sortedArray = SortedArray(unsorted: unsorted)
    }

    struct TableViewChanges {
        var inserts: [Int]
        var deletes: [Int]
    }
    
    func apply(_ changes: [Store.Change<Element>]) -> TableViewChanges {
        var itemsToBeInserted: [Element] = []
        var indicesToBeDeleted: [Int] = []
        for change in changes {
            switch change {
            case .insert(let element):
                itemsToBeInserted.append(element)
            case .delete(let element):
                let deletedIndex = sortedArray.index(of: element)!
                indicesToBeDeleted.append(deletedIndex)
            }
        }
        
        for index in indicesToBeDeleted.sorted().reversed() {
            sortedArray.remove(at: index)
        }
        
        var insertedIndices: [Int] = []
        for element in itemsToBeInserted.sorted() {
            let index = sortedArray.insert(element)
            insertedIndices.append(index)
        }
        
        return TableViewChanges(inserts: insertedIndices, deletes: indicesToBeDeleted)
    }
}

final class TableViewController: UITableViewController {
    var namesController: SortedArrayController<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        namesController = SortedArrayController(unsorted: store.items)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        store.subscribeMultiple { [weak self] changes in
            self?.update(with: changes)
        }
    }
    
    func update(with changes: [Store.Change<String>]) {
        let tableViewChanges = namesController.apply(changes)
        tableView.beginUpdates()
        let inserts = tableViewChanges.inserts.map { IndexPath(row: $0, section: 0) }
        tableView.insertRows(at: inserts, with: .automatic)
        let deletes = tableViewChanges.deletes.map { IndexPath(row: $0, section: 0) }
        tableView.deleteRows(at: deletes, with: .automatic)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesController.sortedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = namesController.sortedArray[indexPath.row]
        return cell
    }
}


import PlaygroundSupport
let vc = TableViewController()
vc.view.frame = CGRect(x: 0, y: 0, width: 250, height: 400)
PlaygroundPage.current.liveView = vc.view

