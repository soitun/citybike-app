//
//  MenuViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import Model

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cityBikesButton: UIButton!
    @IBOutlet weak var providedByLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor.concreteColor()
        self.tableView.registerNib(UINib(nibName: RightDetailCell.Identifier, bundle: nil), forCellReuseIdentifier: RightDetailCell.Identifier)
        self.tableView.registerNib(UINib(nibName: SubtitleCell.Identifier, bundle: nil), forCellReuseIdentifier: SubtitleCell.Identifier)
        self.tableView.registerNib(UINib(nibName: DefaultCell.Identifier, bundle: nil), forCellReuseIdentifier: DefaultCell.Identifier)
        self.tableView.registerNib(UINib(nibName: DefaultHeader.Identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: DefaultHeader.Identifier)
        
        let attr = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let attrText = NSAttributedString(string: "CityBikes API", attributes: attr)
        self.cityBikesButton.titleLabel?.attributedText = attrText
        self.cityBikesButton.setTitleColor(UIColor.jumboColor(), forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshProvidedBy", name: CBSyncManagerNotification.DidUpdateNetworks.rawValue, object: nil)
        self.refreshProvidedBy()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func cityBikesAPIPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://citybik.es")!)
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func refreshProvidedBy() {
        let networksCount = Network.fetchAll(CoreDataStack.sharedInstance().mainContext).count
        if networksCount == 0 {
            self.providedByLabel.text = NSLocalizedString("Provided by", comment: "")
        
        } else {
            self.providedByLabel.text = String.localizedStringWithFormat("%d networks provided by", networksCount)
        }
    }
    
    /// MARK: UITableView
    private enum Section: Int {
        case Statistics, Settings, HelpUs
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .Statistics: return 1
        case .Settings: return 1
        case .HelpUs: return 1 /// Turn on Rate the app after it is available in the store
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .Statistics:
            let cell = tableView.dequeueReusableCellWithIdentifier(DefaultCell.Identifier) as! DefaultCell
            cell.label.text = NSLocalizedString("Rides History", comment: "") + " 🏁 🚴🏼"
            cell.accessoryType = .DisclosureIndicator
            return cell
            
        case .Settings:
            let cell = tableView.dequeueReusableCellWithIdentifier(RightDetailCell.Identifier) as! RightDetailCell
            cell.label.text = NSLocalizedString("City Bike Networks", comment: "")
            cell.detailLabel.text = String.localizedStringWithFormat("%d Selected", UserSettings.sharedInstance().getNetworkIDs().count)
            cell.accessoryType = .DisclosureIndicator
            return cell
            
        case .HelpUs:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(SubtitleCell.Identifier) as! SubtitleCell
                cell.label.text = NSLocalizedString("Send Feedback", comment: "") + " ✉️"
                cell.detailLabel.text = NSLocalizedString("We’d love to hear your feedback!", comment: "")
                return cell
                
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(DefaultCell.Identifier) as! DefaultCell
                cell.label.text = NSLocalizedString("Rate the app", comment: "") + " ⭐️⭐️⭐️⭐️⭐️"
                return cell
            }
        }
        
        return UITableViewCell() /// just return something, will not be visible
    }
    
    func headerTitles() -> [String] {
        return [
            NSLocalizedString("Statistics", comment: ""),
            NSLocalizedString("Settings", comment: ""),
            NSLocalizedString("Help Us", comment: "")
        ]
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(DefaultHeader.Identifier) as! DefaultHeader
        header.label.text = self.headerTitles()[section].uppercaseString
        header.label.textColor = UIColor.havelockBlue()
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = UIColor.concreteColor()
        return header
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        
        if cell.respondsToSelector(Selector("layoutMargins")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == Section.Settings.rawValue && indexPath.row == 0 {
            self.performSegueWithIdentifier("BikeNetworks", sender: nil)
            
        } else if indexPath.section == Section.Statistics.rawValue && indexPath.row == 0 {
            self.performSegueWithIdentifier("RidesHistory", sender: nil)
            
        } else if indexPath.section == Section.HelpUs.rawValue && indexPath.row == 0 {
            FeedbackMailComposeViewController.presentInViewController(self)
        }
    }
}
