//
//  CBNetworksViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBNetworksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    private var networks = [CBNetwork]()
    
    private var selectedNetworkIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedNetworkIDs = NSUserDefaults.getNetworkIDs()
        self.tableView.registerNib(UINib(nibName: CBNoItemsCell.Identifier, bundle: nil), forCellReuseIdentifier: CBNoItemsCell.Identifier)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSUserDefaults.saveNetworkIDs(self.selectedNetworkIDs)
    }
    
    @IBAction func refreshPressed(sender: AnyObject) {
        CBService.sharedInstance.fetchNetworks { (networks) -> Void in
            self.networks = networks
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    /// MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.networks.count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.networks.count > 0 {
            let network = self.networks[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("NetworkCell") as! UITableViewCell
            cell.textLabel?.text = network.name
            cell.detailTextLabel?.text = "\(network.location.country), \(network.location.city)"
            
            if let idx = find(self.selectedNetworkIDs, network.id) {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
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
        
        if self.networks.count > 0 {
            let networkId = self.networks[indexPath.row].id
            let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                
                if let idIndex = find(self.selectedNetworkIDs, networkId) {
                    self.selectedNetworkIDs.removeAtIndex(idIndex)
                }
            } else {
                cell.accessoryType = .Checkmark
                self.selectedNetworkIDs.append(networkId)
            }            
        }
    }
}
