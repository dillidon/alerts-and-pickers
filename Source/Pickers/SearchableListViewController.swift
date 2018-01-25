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
    
    fileprivate let cellIdentifier = "ItemCell"
    
    fileprivate lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
        
        $0.bounces = true
        $0.backgroundColor = .clear
        $0.clipsToBounds = false
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        $0.maskToBounds = false
        $0.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        
        $0.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    fileprivate var action: Action?
    fileprivate var dataSource: [String] = []
    
    // MARK: - UI Metrics
    
    var preferredHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - Methods
    
    required init?(dataSource: [String], action: Action?) {
        self.dataSource = dataSource
        self.action = action
        
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
    
}

extension SearchableListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.backgroundColor = .clear
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
}

extension SearchableListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        action?(dataSource[indexPath.row])
    }
    
}
