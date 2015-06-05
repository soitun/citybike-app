//
//  CBNetworkCountriesVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

typealias CountryCode = String

class OrderedObject {
    var countryCode: CountryCode!
    var selectedNetworks: Int = 0
    
    lazy var countryString: String! = {
        let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: self.countryCode])
        return NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)!
    }()
}

class CBNetworkCountriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum SegueIdentifiers: String {
        case ShowBikeNetworksSegue = "ShowBikeNetworks"
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var networksByCountryCode = [CountryCode: [CBNetwork]]()
    private var orderedNetworksByCountryCode = [OrderedObject]()
    
    
    /// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: CBRightDetailCell.Identifier, bundle: nil), forCellReuseIdentifier: CBRightDetailCell.Identifier)
        self.tableView.registerNib(UINib(nibName: CBNoItemsCell.Identifier, bundle: nil), forCellReuseIdentifier: CBNoItemsCell.Identifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshContent(CBContentManager.sharedInstance.networks)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateNetworksNotification:", name: CBContentManager.DidUpdateNetworksNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /// MARK: Private
    private func refreshContent(inputNetworks: [CBNetwork]) {
        /// Get networks and collect them in pairs by country code
        var networksByCountryCode = [CountryCode: [CBNetwork]]()
        var networksFromContentProvider = inputNetworks
        
        for network in networksFromContentProvider {
            let key = network.location.country
            if networksByCountryCode[key] == nil {
                networksByCountryCode[key] = [CBNetwork]()
            }
            
            networksByCountryCode[key]!.append(network)
        }
        
        self.networksByCountryCode = networksByCountryCode
        
        /// Sort using countryString.
        var selectedNetworkIDs = NSUserDefaults.getNetworkIDs()
        
        self.orderedNetworksByCountryCode = [OrderedObject]()
        for (countryCode, networks) in networksByCountryCode {
            let orderedObject = OrderedObject()
            orderedObject.countryCode = countryCode
            
            /// Get number of selected networks
            for network in networks {
                if find(selectedNetworkIDs, network.id) != nil {
                    orderedObject.selectedNetworks += 1
                }
            }
            self.orderedNetworksByCountryCode.append(orderedObject)
        }
        
        self.orderedNetworksByCountryCode.sort {$0.countryString < $1.countryString}
        self.tableView.reloadData()
    }
    
    
    /// MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.ShowBikeNetworksSegue.rawValue {
            let vc = segue.destinationViewController as! CBNetworksVC
            vc.networks = self.networksByCountryCode[(sender as! OrderedObject).countryCode]
        }
    }
    
    
    /// MARK: Notifications
    func didUpdateNetworksNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let networks = notification.userInfo!["networks"]! as! [CBNetwork]
            self.refreshContent(networks)
        })
    }
    
    
    /// MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.orderedNetworksByCountryCode.count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.orderedNetworksByCountryCode.count > 0 {
            let orderedObject = self.orderedNetworksByCountryCode[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier(CBRightDetailCell.Identifier) as! CBRightDetailCell
            cell.label?.text = orderedObject.countryString
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

            if orderedObject.selectedNetworks == 0 {
                cell.detailLabel?.text = nil
            } else {
                cell.detailLabel?.text = String.localizedStringWithFormat("%d selected", orderedObject.selectedNetworks)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(CBNoItemsCell.Identifier) as! CBNoItemsCell
            cell.label.text = "No bike networks."
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.orderedNetworksByCountryCode.count > 0 {
            let oobject = self.orderedNetworksByCountryCode[indexPath.row]
            self.performSegueWithIdentifier(SegueIdentifiers.ShowBikeNetworksSegue.rawValue, sender: oobject)
        }
    }
}
