//
//  RidesHistoryViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import Model

class RidesHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noItemsLabel: UILabel!
    
    private var history = [RideHistoryDay]()
    private var dateFormatter = NSDateFormatter()
    private var dateTimeFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
       
        self.dateTimeFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateTimeFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        self.tableView.tableFooterView = UIView()

        self.tableView.registerNib(UINib(nibName: SubtitleCell.Identifier, bundle: nil), forCellReuseIdentifier: SubtitleCell.Identifier)
        self.tableView.registerNib(UINib(nibName: RightDetailHeader.Identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: RightDetailHeader.Identifier)
        self.tableView.separatorColor = UIColor.concreteColor()

        self.noItemsLabel.text = NSLocalizedString("Empty History", comment: "")
        self.noItemsLabel.textColor = UIColor.whiteLilac()
        self.noItemsLabel.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.history = RideHistoryDay.fetchAll(CoreDataStack.sharedInstance().mainContext) as! [RideHistoryDay]
        self.tableView.reloadData()
        
        self.noItemsLabel.hidden = self.history.count > 0
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// MARK: UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.history.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.history[section].entries.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(RightDetailHeader.Identifier) as! RightDetailHeader
        
        let day = self.history[section]
        header.label.text = self.dateFormatter.stringFromDate(day.date)
        
        var sum: NSTimeInterval = 0
        for entry in day.entries {
            sum += (entry as! RideHistoryEntry).duration.doubleValue
        }
        
        header.detailLabel.text = sum.stringTimeRepresentationStyle1
        header.label.textColor = UIColor.havelockBlue()
        header.detailLabel.textColor = UIColor.havelockBlue()
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = UIColor.concreteColor()
        return header
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entry = self.history[indexPath.section].entries[indexPath.row] as! RideHistoryEntry
        
        let cell = tableView.dequeueReusableCellWithIdentifier(SubtitleCell.Identifier) as! SubtitleCell
        cell.label?.text = entry.duration.doubleValue.stringTimeRepresentationStyle1
        cell.detailLabel.text = self.dateTimeFormatter.stringFromDate(entry.date)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}