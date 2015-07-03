//
//  BikeNetworksViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import Model
import Swifternalization

class BikeNetworksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var noItemsIndicator: UIActivityIndicatorView!
    
    private var orderedNetworks = [OrderedNetworksGroup]()
    private var selectedNetworkIDs = [String]()
    private var filteredNetworks = [FilteredNetworksGroupProxy]()
    
    private var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = I18n.localizedString("city-bike-networks")
        
        selectedNetworkIDs = UserSettings.sharedInstance().getNetworkIDs()
        
        tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.frame))
        tableView.tableFooterView = UIView()
        
        for tableView in [self.tableView, self.searchDisplayController!.searchResultsTableView] {
            tableView.registerNib(UINib(nibName: SubtitleCell.Identifier, bundle: nil), forCellReuseIdentifier: SubtitleCell.Identifier)
            tableView.registerNib(UINib(nibName: DefaultHeader.Identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: DefaultHeader.Identifier)
            tableView.separatorColor = UIColor.concreteColor()
        }

        searchBar.barTintColor = UIColor.concreteColor()

        noItemsLabel.text = I18n.localizedString("no-city-bike-networks")
        noItemsLabel.textColor = UIColor.whiteLilac()
        noItemsLabel.hidden = true
        noItemsIndicator.color = UIColor.whiteLilac()
        noItemsIndicator.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateNetworksNotification:", name: CBSyncManagerNotification.DidUpdateNetworks.rawValue, object: nil)
        
        refresAll()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        saveSelectedNetworks()
        ModelUpdater.sharedInstance.setSelectedNetworkIds(UserSettings.sharedInstance().getNetworkIDs())
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /// MARK: Notifications
    func didUpdateNetworksNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { self.refresAll() })
    }
    
    private func refresAll() {
        let allNetworks = Network.fetchAll(CoreDataStack.sharedInstance().mainContext) as! [Network]
        refreshContent(allNetworks)
    }
    
    /// MARK: Private
    private func saveSelectedNetworks() {
        UserSettings.sharedInstance().saveNetworkIDs(self.selectedNetworkIDs)
        /// Force content update. Redownload stations
        ModelUpdater.sharedInstance.forceUpdate()
    }
    
    private func refreshContent(networksToDisplay: [Network]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.orderedNetworks = NetworksSort.orderNetworks(networksToDisplay)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                
                let noItems = self.orderedNetworks.count == 0
                self.noItemsLabel.hidden = !noItems
                noItems ? self.noItemsIndicator.startAnimating() : self.noItemsIndicator.stopAnimating()
            })
        })
    }
    
    
    /// MARK: UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableView == self.tableView ? orderedNetworks.count : filteredNetworks.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return orderedNetworks[section].networks.count
        } else {
            return filteredNetworks[section].networks.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        func createCell(name: String, city: String, id: String) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(SubtitleCell.Identifier) as! SubtitleCell
            cell.label?.text = name
            cell.detailLabel.text = city
            
            if let networkID = find(selectedNetworkIDs, id) {
                cell.accessoryType = .Checkmark
                selectedIndexPath = indexPath
            } else {
                cell.accessoryType = .None
            }
            
            return cell
        }
        
        if tableView == self.tableView {
            let network = orderedNetworks[indexPath.section].networks[indexPath.row]
            return createCell(network.name, network.location.city, network.id)
        } else {
            let networkProxy = filteredNetworks[indexPath.section].networks[indexPath.row]
            return createCell(networkProxy.name, networkProxy.city, networkProxy.id)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        func update(id: String) {
            // Disable multi-selection support till map clustering is implemented
            if let currentlySelectedIndexPath = selectedIndexPath {
                if let cell = tableView.cellForRowAtIndexPath(currentlySelectedIndexPath) {
                    cell.accessoryType = .None
                }
                
                selectedNetworkIDs.removeAll(keepCapacity: false)
                selectedIndexPath = nil

                if currentlySelectedIndexPath == indexPath {
                    return
                }
            }
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            if let idx = find(selectedNetworkIDs, id) {
                cell.accessoryType = .None
                selectedNetworkIDs.removeAtIndex(idx)
            } else {
                /// Store selected bike network
                cell.accessoryType = .Checkmark
                selectedIndexPath = indexPath
                selectedNetworkIDs.append(id)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == self.tableView {
            update(orderedNetworks[indexPath.section].networks[indexPath.row].id)
        } else {
            update(filteredNetworks[indexPath.section].networks[indexPath.row].id)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        func createHeader(countryName: String) -> DefaultHeader {
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(DefaultHeader.Identifier) as! DefaultHeader
            header.label.text = countryName.uppercaseString
            header.label.textColor = UIColor.havelockBlue()
            header.backgroundView = UIView()
            header.backgroundView?.backgroundColor = UIColor.concreteColor()
            return header
        }
        
        if tableView == self.tableView {
            return createHeader(orderedNetworks[section].countryName)
        } else {
            return createHeader(filteredNetworks[section].countryName)
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
        let height = CGRectGetHeight(searchBar.frame)
        if tableView.contentOffset.y <= height {
            tableView.contentOffset = CGPointMake(0, height)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNetworks = FilterNetworks.filteredNetworks(self.orderedNetworks, phrase: searchText)
        searchDisplayController?.searchResultsTableView.reloadData()
    }
}
