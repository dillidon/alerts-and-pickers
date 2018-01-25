//
//  SearchableListViewController.swift
//  Alerts&Pickers
//
//  Created by Jason Jon E. Carreos on 25/01/2018.
//  Copyright © 2018 Supreme Apps. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    /// Add Searchable list
    ///
    /// - Parameters:
    ///   - dataSource: list of strings to be rendered in the list
    ///   - action: for selected item
    
    func addSearchableList(dataSource: [String], action: SearchableListViewController.Action?) {
        let vc = SearchableListViewController(dataSource: dataSource, action: action)
        
        vc?.preferredContentSize.height = (vc?.preferredHeight)!
        
        set(vc: vc)
    }
}

final class SearchableListViewController: UIViewController {

    // MARK: - Properties
    
    public typealias Action = (Any?) -> Swift.Void
    
    fileprivate let cellIdentifier = ItemTableViewCell.identifier
    
    fileprivate lazy var containerView: UIView = {
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        
        return $0
    }(UIView(frame: .zero))
    fileprivate lazy var searchBar: UISearchBar = {
        $0.delegate = self
        $0.searchBarStyle = .minimal
        
        return $0
    }(UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40)))
    fileprivate lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
        
        $0.bounces = true
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.maskToBounds = true
        $0.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        
        $0.register(ItemTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    fileprivate var action: Action?
    fileprivate var dataSource: [String] = []
    fileprivate var filteredDataSource: [String] = []
    
    // MARK: - UI Metrics
    
    var preferredHeight: CGFloat {
        // NOTE: Workaround for alert controller being scrollable, in addition to the table view
        
        return UIScreen.main.bounds.height * 0.50
    }
    
    // MARK: - Methods
    
    required init?(dataSource: [String], action: Action?) {
        self.dataSource = dataSource
        self.action = action
        
        self.filteredDataSource = dataSource
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        tableView.tableHeaderView = searchBar
    }
    
}

final class ItemTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: ItemTableViewCell.self)
    
    // MARK: Methods
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = nil
        contentView.backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        accessoryType = selected ? .checkmark : .none
    }
    
}

extension SearchableListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {
            filteredDataSource = dataSource
            
            tableView.reloadData()
            
            return
        }
        
        filteredDataSource = dataSource
        
        if !text.isEmpty {
            filteredDataSource = dataSource.filter { $0.lowercased().contains(text.lowercased()) }
        }
        
        tableView.reloadData()
    }

}

extension SearchableListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ItemTableViewCell
        
        cell.textLabel?.text = filteredDataSource[indexPath.row]
        
        return cell
    }
    
}

extension SearchableListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        action?(filteredDataSource[indexPath.row])
    }
    
}
