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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return self.networks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let network = self.networks[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("NetworkCell") as! UITableViewCell
        cell.textLabel?.text = network.name
        cell.detailTextLabel?.text = "\(network.location.country), \(network.location.city)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
