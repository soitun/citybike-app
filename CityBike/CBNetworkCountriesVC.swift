//
//  CBNetworkCountriesVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBNetworkCountriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum SegueIdentifiers: String {
        case ShowBikeNetworksSegue = "ShowBikeNetworks"
    }
    
    class OrderedObject {
        var countryCode: CountryCode!
        var selectedNetworks: Int = 0
        
        lazy var countryString: String! = {
            let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: self.countryCode])
            return NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: identifier)!
        }()
    }
    
    typealias OObject = CBNetworkCountriesVC.OrderedObject
    typealias CountryCode = String

    
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var objects = [CountryCode: [CBNetwork]]()
    private var orderedObjects = [OObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: CBRightDetailCell.Identifier, bundle: nil), forCellReuseIdentifier: CBRightDetailCell.Identifier)
        self.tableView.registerNib(UINib(nibName: CBNoItemsCell.Identifier, bundle: nil), forCellReuseIdentifier: CBNoItemsCell.Identifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareContent()
        self.tableView.reloadData()
    }
    
    private func prepareContent() {
        
        /// Get networks and collect them in pairs by country code
        var result = [CountryCode: [CBNetwork]]()
        var networks = CBContentManager.sharedInstance.networks

        for network in networks {
            let key = network.location.country
            if result[key] == nil {
                result[key] = [CBNetwork]()
            }
            
            result[key]!.append(network)
        }
        
        self.objects = result

        /// Sort using countryString.
        var selectedNetworkIDs = NSUserDefaults.getNetworkIDs()
        
        self.orderedObjects = [OObject]()
        for (countryCode, networks) in result {
            let orderedObject = OObject()
            orderedObject.countryCode = countryCode
            
            /// Get number of selected networks
            for network in networks {
                if find(selectedNetworkIDs, network.id) != nil {
                    orderedObject.selectedNetworks += 1
                }
            }
                        
            self.orderedObjects.append(orderedObject)
        }
        
        self.orderedObjects.sort {$0.countryString < $1.countryString}
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.ShowBikeNetworksSegue.rawValue {
            let vc = segue.destinationViewController as! CBNetworksVC
            vc.networks = self.objects[(sender as! OObject).countryCode]
        }
    }
    
    /// MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.orderedObjects.count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.orderedObjects.count > 0 {
            let orderedObject = self.orderedObjects[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier(CBRightDetailCell.Identifier) as! CBRightDetailCell
            cell.label?.text = orderedObject.countryString
            
            if orderedObject.selectedNetworks == 0 {
                cell.detailLabel?.text = nil
            } else {
                cell.detailLabel?.text = String.localizedStringWithFormat("%d selected", orderedObject.selectedNetworks)
            }
            
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(CBNoItemsCell.Identifier) as! CBNoItemsCell
            cell.label.text = "No bike networks."
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.orderedObjects.count > 0 {
            let oobject = self.orderedObjects[indexPath.row]
            self.performSegueWithIdentifier(SegueIdentifiers.ShowBikeNetworksSegue.rawValue, sender: oobject)
        }
    }
}
