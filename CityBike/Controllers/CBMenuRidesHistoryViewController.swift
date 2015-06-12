//
//  CBMenuRidesHistoryViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBMenuRidesHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noItemsLabel: UILabel!
    
    private var history = RidesHistory()
    private var dateFormatter = NSDateFormatter()
    private var dateTimeFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
       
        self.dateTimeFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateTimeFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        self.tableView.tableFooterView = UIView()

        self.tableView.registerNib(UINib(nibName: CBSubtitleCell.Identifier, bundle: nil), forCellReuseIdentifier: CBSubtitleCell.Identifier)
        self.tableView.registerNib(UINib(nibName: CBRightDetailHeader.Identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: CBRightDetailHeader.Identifier)
        self.tableView.separatorColor = UIColor.concreteColor()

        self.noItemsLabel.text = NSLocalizedString("Empty History", comment: "")
        self.noItemsLabel.textColor = UIColor.whiteLilac()
        self.noItemsLabel.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.history = NSUserDefaults.getRidesHistory()
        self.tableView.reloadData()
        
        self.noItemsLabel.hidden = self.history.keys.array.count != 0
    }
    
    
    /// MARK: UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.history.keys.array.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = self.history.keys.array[section]
        return self.history[key]!.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CBRightDetailHeader.Identifier) as! CBRightDetailHeader
        
        let key = self.history.keys.array[section]
        
        let date = NSDate(timeIntervalSince1970: key)
        header.label.text = self.dateFormatter.stringFromDate(date)
        
        
        var sum: NSTimeInterval = 0
        for record in self.history[key]! {
            sum += record.duration
        }
        
        header.detailLabel.text = sum.stringTimeRepresentationStyle1
        header.label.textColor = UIColor.flamePeaColor()
        header.detailLabel.textColor = UIColor.flamePeaColor()
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = UIColor.concreteColor()
        return header
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let key = self.history.keys.array[indexPath.section]
        let rideRecord = self.history[key]![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CBSubtitleCell.Identifier) as! CBSubtitleCell
        cell.label?.text = rideRecord.duration.stringTimeRepresentationStyle1
        cell.detailLabel.text = self.dateTimeFormatter.stringFromDate(NSDate(timeIntervalSince1970: rideRecord.startTime))
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