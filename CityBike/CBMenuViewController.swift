//
//  CBMenuViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cityBikesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor.concreteColor()
        self.tableView.registerNib(UINib(nibName: CBRightDetailCell.Identifier, bundle: nil), forCellReuseIdentifier: CBRightDetailCell.Identifier)
        self.tableView.registerNib(UINib(nibName: CBSubtitleCell.Identifier, bundle: nil), forCellReuseIdentifier: CBSubtitleCell.Identifier)
        self.tableView.registerNib(UINib(nibName: CBDefaultCell.Identifier, bundle: nil), forCellReuseIdentifier: CBDefaultCell.Identifier)
        self.tableView.registerNib(UINib(nibName: CBDefaultHeader.Identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: CBDefaultHeader.Identifier)
        
        let attr = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let attrText = NSAttributedString(string: "CityBikes API", attributes: attr)
        self.cityBikesButton.titleLabel?.attributedText = attrText
        self.cityBikesButton.setTitleColor(UIColor.jumboColor(), forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    @IBAction func cityBikesAPIPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://citybik.es")!)
    }
    
    
    /// MARK: UITableView
    private enum Section: Int {
        case Settings, HelpUs
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .Settings:
            return 1
            
        case .HelpUs:
            return 1 /// Turn on Rate the app after it is available in the store
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .Settings:
            let cell = tableView.dequeueReusableCellWithIdentifier(CBRightDetailCell.Identifier) as! CBRightDetailCell
            cell.label.text = NSLocalizedString("City Bike Networks", comment: "")
            cell.detailLabel.text = String.localizedStringWithFormat("%d Selected", NSUserDefaults.getNetworkIDs().count)
            cell.accessoryType = .DisclosureIndicator
            return cell
            
        case .HelpUs:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(CBSubtitleCell.Identifier) as! CBSubtitleCell
                cell.label.text = NSLocalizedString("Send Feedback", comment: "")
                cell.detailLabel.text = NSLocalizedString("We’d love to hear your feedback!", comment: "")
                return cell
                
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(CBDefaultCell.Identifier) as! CBDefaultCell
                cell.label.text = NSLocalizedString("Rate the app ⭐️⭐️⭐️⭐️⭐️", comment: "")
                return cell
            }
        }
        
        return UITableViewCell() /// just to return something, will not be visible
    }
    
    func headerTitles() -> [String] {
        return [
            NSLocalizedString("Settings", comment: ""),
            NSLocalizedString("Help Us", comment: "")
        ]
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CBDefaultHeader.Identifier) as! CBDefaultHeader
        header.label.text = self.headerTitles()[section].uppercaseString
        header.label.textColor = UIColor.flamePeaColor()
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
        }
    }
}
