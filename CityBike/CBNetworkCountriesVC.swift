//
//  CBNetworkCountriesVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBNetworkCountriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    private var objects = [CountryCode: [CBNetwork]]()
    private var orderedObjects = [OObject]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: CBNoItemsCell.Identifier, bundle: nil), forCellReuseIdentifier: CBNoItemsCell.Identifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareContent()
        self.tableView.reloadData()
    }
    
    @IBAction func refreshPressed(sender: AnyObject) {
        CBContentManager.sharedInstance.fetchAllNetworks {
            self.prepareContent()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
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
    
    
    /// MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.orderedObjects.count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.objects.count > 0 {
            let orderedObject = self.orderedObjects[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("NetworkCell") as! UITableViewCell
            cell.textLabel?.text = orderedObject.countryString
            
            if orderedObject.selectedNetworks == 0 {
                cell.detailTextLabel?.text = nil
            } else {
                cell.detailTextLabel?.text = String.localizedStringWithFormat("%d selected", orderedObject.selectedNetworks)
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
    }
}
