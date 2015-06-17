//
//  CBMenuBikeNetworksViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CBModel

class CBMenuBikeNetworksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var noItemsIndicator: UIActivityIndicatorView!
    
    private var orderedNetworks = [CBOrderedNetworksGroup]()
    private var selectedNetworkIDs = [String]()
    private var filteredNetworks = [CBFilteredNetworksGroupProxy]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedNetworkIDs = NSUserDefaults.getNetworkIDs()
        
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.frame))
        self.tableView.tableFooterView = UIView()
        
        for tableView in [self.tableView, self.searchDisplayController!.searchResultsTableView] {
            tableView.registerNib(UINib(nibName: CBSubtitleCell.Identifier, bundle: nil), forCellReuseIdentifier: CBSubtitleCell.Identifier)
            tableView.registerNib(UINib(nibName: CBDefaultHeader.Identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: CBDefaultHeader.Identifier)
            tableView.separatorColor = UIColor.concreteColor()
        }

        self.searchBar.barTintColor = UIColor.concreteColor()

        self.noItemsLabel.text = NSLocalizedString("No City Bike Networks", comment: "")
        self.noItemsLabel.textColor = UIColor.whiteLilac()
        self.noItemsLabel.hidden = true
        self.noItemsIndicator.color = UIColor.whiteLilac()
        self.noItemsIndicator.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateNetworksNotification:", name: CBSyncManager.DidUpdateNetworksNotification, object: nil)
        
        self.refresAll()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.saveSelectedNetworks()
    }
    
    
    /// MARK: Notifications
    func didUpdateNetworksNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { self.refresAll() })
    }
    
    private func refresAll() {
        let allNetworks = CDNetwork.fetchAll(CoreDataHelper.sharedInstance().mainContext) as! [CDNetwork]
        self.refreshContent(allNetworks)
    }
    
    /// MARK: Private
    private func saveSelectedNetworks() {
        NSUserDefaults.saveNetworkIDs(self.selectedNetworkIDs)
        
        /// Force content update. Redownload stations
        CBModelUpdater.sharedInstance.forceUpdate()
    }
    
    private func refreshContent(networksToDisplay: [CDNetwork]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.orderedNetworks = CBNetworksSort.orderNetworks(networksToDisplay)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                
                let noItems = self.orderedNetworks.count == 0
                self.noItemsLabel.hidden = !noItems
                noItems ? self.noItemsIndicator.startAnimating() : self.noItemsIndicator.stopAnimating()
            })
        })
    }
    
    
    /// MARK: UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableView == self.tableView ? self.orderedNetworks.count : self.filteredNetworks.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.orderedNetworks[section].networks.count
        } else {
            return self.filteredNetworks[section].networks.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        func createCell(name: String, city: String, id: String) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(CBSubtitleCell.Identifier) as! CBSubtitleCell
            cell.label?.text = name
            cell.detailLabel.text = city
            cell.accessoryType = (find(self.selectedNetworkIDs, id) != nil) ? .Checkmark : .None
            return cell
        }
        
        if tableView == self.tableView {
            let network = self.orderedNetworks[indexPath.section].networks[indexPath.row]
            return createCell(network.name, network.location.city, network.id)
        } else {
            let networkProxy = self.filteredNetworks[indexPath.section].networks[indexPath.row]
            return createCell(networkProxy.name, networkProxy.city, networkProxy.id)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        func update(id: String) {
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            if let idx = find(self.selectedNetworkIDs, id) {
                cell.accessoryType = .None
                self.selectedNetworkIDs.removeAtIndex(idx)
            } else {
                cell.accessoryType = .Checkmark
                self.selectedNetworkIDs.append(id)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == self.tableView {
            update(self.orderedNetworks[indexPath.section].networks[indexPath.row].id)
        } else {
            update(self.filteredNetworks[indexPath.section].networks[indexPath.row].id)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        func createHeader(countryName: String) -> CBDefaultHeader {
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CBDefaultHeader.Identifier) as! CBDefaultHeader
            header.label.text = countryName.uppercaseString
            header.label.textColor = UIColor.flamePeaColor()
            header.backgroundView = UIView()
            header.backgroundView?.backgroundColor = UIColor.concreteColor()
            return header
        }
        
        if tableView == self.tableView {
            return createHeader(self.orderedNetworks[section].countryName)
        } else {
            return createHeader(self.filteredNetworks[section].countryName)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    
    /// MARK: SearchBar
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        let height = CGRectGetHeight(self.searchBar.frame)
        if self.tableView.contentOffset.y <= height {
            self.tableView.contentOffset = CGPointMake(0, height)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredNetworks = CBFilterNetworks.filteredNetworks(self.orderedNetworks, phrase: searchText)
        self.searchDisplayController?.searchResultsTableView.reloadData()
    }
}
