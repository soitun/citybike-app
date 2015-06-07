//
//  CBMapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBMapViewController: UIViewController {

    @IBOutlet private var stopwatchReadyButton: UIBarButtonItem!
    @IBOutlet private var stopwatchDoneButton: UIBarButtonItem!
    @IBOutlet private weak var stopwatchContainer: UIView!
    @IBOutlet private weak var stopwatchContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stopwatchTimeLabel: UILabel!

    private var stopwatch = CBRideStopwatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Put logo in navigation bar
        let logo = UIImageView(image: UIImage(named: "city-bike-logo-nav"))
        self.navigationItem.titleView = logo
        
        /// Set button initially
        self.navigationItem.leftBarButtonItem = self.stopwatchReadyButton
        
        self.stopwatchContainer.backgroundColor = UIColor.blueGrayColor()
        
        /// Check if stopwatch should be turned on
        if let startTimeInterval = NSUserDefaults.getStartRideTimeInterval() {
            self.startStopwatch(startTimeInterval, showBar: true, animated: false)
        } else {
            self.changeStopwatchContainer(false, animated: false)
        }
    }
    
    
    /// MARK: Stopwatch
    @IBAction func stopwatchReadyPressed(sender: AnyObject) {
        self.startStopwatch(nil, showBar: true, animated: true)
    }
    
    private func startStopwatch(var ti: NSTimeInterval?, showBar: Bool, animated: Bool) {
        if ti == nil {
            ti = NSDate().timeIntervalSince1970
            NSUserDefaults.setStartRideTimeInterval(ti!)
        }
        
        self.stopwatch.start(ti!, updateBlock: { (duration) -> Void in
            self.stopwatchTimeLabel.text = duration.stringTimeRepresentationStyle2
        })
        
        if (showBar) {
            self.navigationItem.setLeftBarButtonItem(self.stopwatchDoneButton, animated: animated)
            self.changeStopwatchContainer(true, animated: animated)
        }
    }
    
    @IBAction func stopwatchDonePressed(sender: AnyObject) {
        self.navigationItem.setLeftBarButtonItem(self.stopwatchReadyButton, animated: true)
        self.changeStopwatchContainer(false, animated: true)
        
        let duration = self.stopwatch.stop()
        let startDate = NSDate(timeIntervalSince1970: self.stopwatch.startTimeInterval)
        let typeComponents = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
        let components = NSCalendar.autoupdatingCurrentCalendar().components(typeComponents, fromDate: startDate)
        let dayDate = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        
        let rideRecord = CBRideRecord(duration: duration, startTime: self.stopwatch.startTimeInterval)
        
        var ridesHistory = NSUserDefaults.getRidesHistory()
        let key = dayDate.timeIntervalSince1970
        if ridesHistory[key] != nil {
            ridesHistory[key]!.append(rideRecord)
        } else {
            ridesHistory[key] = [rideRecord]
        }
        
        NSUserDefaults.setRidesHistory(ridesHistory)
        NSUserDefaults.removeStartRideTimeInterval()
    }
    
    private func changeStopwatchContainer(show: Bool, animated: Bool) {
        if show {
            self.stopwatchContainerTopConstraint.constant = 0
        } else {
            self.stopwatchContainerTopConstraint.constant = -CGRectGetHeight(self.stopwatchContainer.frame)
        }
        
        UIView.animateWithDuration(animated ? 0.25 : 0, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
