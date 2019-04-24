//
//  ViewController.swift
//  T9Search
//
//  Created by George Vashakidze on 3/1/19.
//  Copyright © 2019 Toptal. All rights reserved.
//

import UIKit

fileprivate let cellIdentifier = "contact_list_cell"

final class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate lazy var dataSource = [PhoneContact]()
    fileprivate var searchString : String?
    fileprivate var searchInT9   : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(
            UINib(
                nibName: "ContactListCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ContactListCell"
        )
        PhoneContactStore.requestForAccess { (ok, err) in }
    }
    
    func filter(searchString: String, t9: Bool = true) {
        self.searchString = searchString
        self.searchInT9 = t9
        
        if let str = self.searchString {
            if t9 {
                self.dataSource = PhoneContactStore.findWith(t9String: str)
            } else {
                self.dataSource = PhoneContactStore.findWith(str: str)
            }
        } else {
            self.dataSource = [PhoneContact]()
        }
        
        self.reloadListSection(section: 0)
    }
    
    func reloadListSection(section: Int, animation: UITableViewRowAnimation = .none) {
        if self.tableView.numberOfSections <= section {
            self.tableView.beginUpdates()
            self.tableView.insertSections(IndexSet(integersIn:0..<section + 1), with: animation)
            self.tableView.endUpdates()
        }
        self.tableView.reloadSections(IndexSet(integer:section), with: animation)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ContactListCell")!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let contactCell = cell as? ContactListCell else { return }
        let row = self.dataSource[indexPath.row]
        contactCell.configureCell(
            fullName: row.fullName,
            t9String: row.t9String,
            number: row.phoneNumber,
            searchStr: searchString,
            img: row.image,
            t9Search: self.searchInT9
        )
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filter(searchString: searchText)
    }

}
