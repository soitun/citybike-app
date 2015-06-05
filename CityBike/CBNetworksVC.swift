//
//  CBNetworksVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 05/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBNetworksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    
    var networks: [CBNetwork]!
    private var selectedNetworkIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: CBNoItemsCell.Identifier, bundle: nil), forCellReuseIdentifier: CBNoItemsCell.Identifier)
        self.selectedNetworkIDs = NSUserDefaults.getNetworkIDs()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.selectedNetworkIDs.count == 0 {
            return
        }
        
        var savedNetworkIDs = NSUserDefaults.getNetworkIDs()
        var networkIDsToSave = self.selectedNetworkIDs

        for savedNetworkID in savedNetworkIDs {
            /// check if local network contains saved network ID
            var foundInLocalNetwork = false
            
            for network in self.networks {
                if network.id == savedNetworkID {
                    foundInLocalNetwork = true
                    
                    if find(self.selectedNetworkIDs, savedNetworkID) != nil {
                        if find(networkIDsToSave, savedNetworkID) == nil {
                            networkIDsToSave.append(savedNetworkID)
                        }
                    }
                    
                    break
                }
            }
            
            if foundInLocalNetwork == false {
                if find(networkIDsToSave, savedNetworkID) == nil {
                    networkIDsToSave.append(savedNetworkID)
                }
            }
        }
    
        NSUserDefaults.saveNetworkIDs(networkIDsToSave)
    }
    
    /// MARK: UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, self.networks.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.networks.count > 0 {
            let network = self.networks[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("NetworkCell") as! UITableViewCell
            cell.textLabel?.text = network.name
            cell.detailTextLabel?.text = network.location.city
            
            if find(self.selectedNetworkIDs, network.id) != nil {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(CBNoItemsCell.Identifier) as! CBNoItemsCell
            cell.label.text = "No bike networks in this country."
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.networks.count > 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let network = self.networks[indexPath.row]
            
            if let idx = find(self.selectedNetworkIDs, network.id) {
                cell.accessoryType = .None
                self.selectedNetworkIDs.removeAtIndex(idx)
            } else {
                cell.accessoryType = .Checkmark
                self.selectedNetworkIDs.append(network.id)
            }
        }
    }
}