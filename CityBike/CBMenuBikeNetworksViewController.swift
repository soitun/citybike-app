//
//  CBMenuBikeNetworksViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

typealias CountryCode = String

class OrderedObject {
    var countryCode: CountryCode!
    var networks = [CBNetwork]()
    
    lazy var countryString: String! = {
        let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: self.countryCode])
        return NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)!
        }()
    
    func copy() -> OrderedObject {
        var obj = OrderedObject()
        obj.countryCode = self.countryCode
        
        var networks = [CBNetwork]()
        for network in self.networks {
            networks.append(network.copy())
        }
        obj.networks = networks
        
        return obj
    }
}

class CBMenuBikeNetworksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var noItemsLabel: UILabel!
    
    private var orderedObjects = [OrderedObject]()
    private var selectedNetworkIDs = [String]()
    
    private var filteredObjects = [OrderedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedNetworkIDs = NSUserDefaults.getNetworkIDs()

        CBContentManager.sharedInstance.start()
        
        self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.frame))
        self.tableView.tableFooterView = UIView()
        
        for tableView in [self.tableView, self.searchDisplayController!.searchResultsTableView] {
            tableView.registerNib(UINib(nibName: CBSubtitleCell.Identifier, bundle: nil), forCellReuseIdentifier: CBSubtitleCell.Identifier)
            tableView.registerNib(UINib(nibName: CBDefaultHeader.Identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: CBDefaultHeader.Identifier)
            tableView.separatorColor = UIColor.concreteColor()
        }

        self.searchBar.barTintColor = UIColor.concreteColor()

        self.noItemsLabel.text = NSLocalizedString("No City Bike Networks", comment: "")
        self.noItemsLabel.textColor = UIColor.whiteLilac();
        self.noItemsLabel.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateNetworksNotification:", name: CBContentManager.DidUpdateNetworksNotification, object: nil)

        self.refreshContent(CBContentManager.sharedInstance.networks)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.saveSelectedNetworks()
    }
    
    
    /// MARK: Notifications
    func didUpdateNetworksNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let networks = notification.userInfo!["networks"]! as! [CBNetwork]
            self.refreshContent(networks)
        })
    }
    
    /// MARK: Private
    private func saveSelectedNetworks() {
        NSUserDefaults.saveNetworkIDs(self.selectedNetworkIDs)
        
        /// Force content update. Redownload stations
        CBContentManager.sharedInstance.forceStationsUpdate()
    }
    
    private func refreshContent(networksToDisplay: [CBNetwork]) {
        var updatedOrderedObject = [OrderedObject]()
        
        for network in networksToDisplay {
            /// Check if ordered object exist for country
            var foundOO : OrderedObject? = nil
            for orderedObject in updatedOrderedObject {
                if orderedObject.countryCode == network.location.country {
                    foundOO = orderedObject
                    break
                }
            }
            
            /// add network to such object
            if let foundOO = foundOO {
                foundOO.networks.append(network)
            } else {
                let createdOO = OrderedObject()
                createdOO.countryCode = network.location.country
                createdOO.networks.append(network)
                updatedOrderedObject.append(createdOO)
            }
        }
        
        /// Sort countries and by network name
        updatedOrderedObject.sort { $0.countryString < $1.countryString }
        for orderedObject in updatedOrderedObject {
            orderedObject.networks.sort { $0.name < $1.name }
        }
        
        self.orderedObjects = updatedOrderedObject
        self.tableView.reloadData()
        
        self.noItemsLabel.hidden = self.orderedObjects.count != 0
    }
    
    
    /// MARK: UITableView
    func content(tableView: UITableView) -> [OrderedObject] {
        if tableView == self.tableView {
            return self.orderedObjects
        } else {
            return self.filteredObjects
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.content(tableView).count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content(tableView)[section].networks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let network = self.content(tableView)[indexPath.section].networks[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier(CBSubtitleCell.Identifier) as! CBSubtitleCell
        cell.label?.text = network.name
        cell.detailLabel.text = network.location.city
        
        if find(self.selectedNetworkIDs, network.id) != nil {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let network = self.content(tableView)[indexPath.section].networks[indexPath.row]
        if let idx = find(self.selectedNetworkIDs, network.id) {
            cell.accessoryType = .None
            self.selectedNetworkIDs.removeAtIndex(idx)
        } else {
            cell.accessoryType = .Checkmark
            self.selectedNetworkIDs.append(network.id)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CBDefaultHeader.Identifier) as! CBDefaultHeader
        
        header.label.text = self.content(tableView)[section].countryString.uppercaseString
        header.label.textColor = UIColor.flamePeaColor()
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = UIColor.concreteColor()
        return header
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
        self.filterObjectsMatchingText(searchText)
        self.searchDisplayController?.searchResultsTableView.reloadData()
    }
    
    private func filterObjectsMatchingText(text: String) {
        var searchPhrase = text.lowercaseString
        
        var allObjects = self.orderedObjects
        var newFilteredObjects = [OrderedObject]()
        
        for object in allObjects {
            /// If country matches add all networks
            let matchesCountryCode = object.countryCode.lowercaseString.rangeOfString(searchPhrase) != nil
            let matchesCountryString = object.countryString.lowercaseString.rangeOfString(searchPhrase) != nil
            
            if matchesCountryCode || matchesCountryString {
                newFilteredObjects.append(object.copy())
                
            } else {
                /// If country doesn't match check networks in every country
                var filteredNetworks = [CBNetwork]()
                for network in object.networks {
                    let matchesName = network.name.lowercaseString.rangeOfString(searchPhrase) != nil
                    let matchesCity = network.location.city.lowercaseString.rangeOfString(searchPhrase) != nil
                    
                    if matchesName || matchesCity {
                        filteredNetworks.append(network.copy())
                    }
                }
                
                if filteredNetworks.count > 0 {
                    var filteredObject = object.copy()
                    filteredObject.networks = filteredNetworks
                    newFilteredObjects.append(filteredObject)
                }
            }
        }

        self.filteredObjects = newFilteredObjects
    }
}
