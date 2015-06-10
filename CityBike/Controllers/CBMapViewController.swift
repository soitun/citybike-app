//
//  CBMapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class CBMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet private weak var mapView: MKMapView!
    
    @IBOutlet private var locateMeButton: UIBarButtonItem!
    
    @IBOutlet private var stopwatchReadyButton: UIBarButtonItem!
    @IBOutlet private var stopwatchDoneButton: UIBarButtonItem!
    @IBOutlet private weak var stopwatchContainer: UIView!
    @IBOutlet private weak var stopwatchContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stopwatchTimeLabel: UILabel!

    private var stopwatchManager = CBRideManager()
    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Put logo in navigation bar
        let logo = UIImageView(image: UIImage(named: "city-bike-logo-nav"))
        self.navigationItem.titleView = logo
        
        /// Set button initially
        self.navigationItem.leftBarButtonItems = [self.stopwatchReadyButton, self.locateMeButton]
        
        self.stopwatchContainer.backgroundColor = UIColor.blueGrayColor()
        self.runStopwatchIfNeeded()
        
        /// Request content
        self.locationManager.requestWhenInUseAuthorization()
        CBContentManager.sharedInstance.start()
    }
    
    @IBAction func locateMePressed(sender: AnyObject) {
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 2000, 2000)
        self.mapView.setRegion(region, animated: true)
    }

    
    /// MARK: Stopwatch
    @IBAction func stopwatchReadyPressed(sender: AnyObject) {
        self.startStopwatch(nil, showBar: true, animated: true)
    }
    
    private func runStopwatchIfNeeded() {
        /// Check if stopwatch should be turned on
        if let startTimeInterval = NSUserDefaults.getStartRideTimeInterval() {
            self.startStopwatch(startTimeInterval, showBar: true, animated: false)
        } else {
            self.changeStopwatchContainer(false, animated: false)
        }
    }
    
    private func startStopwatch(var ti: NSTimeInterval?, showBar: Bool, animated: Bool) {
        self.stopwatchManager.start(ti, updateBlock: { (duration) -> Void in
            self.stopwatchTimeLabel.text = duration.stringTimeRepresentationStyle2
        })
        
        if (showBar) {
            self.navigationItem.setLeftBarButtonItems([self.stopwatchDoneButton, self.locateMeButton], animated: animated)
            self.changeStopwatchContainer(true, animated: animated)
        }
    }
    
    @IBAction func stopwatchDonePressed(sender: AnyObject) {
        self.navigationItem.setLeftBarButtonItems([self.stopwatchReadyButton, self.locateMeButton], animated: true)
        self.changeStopwatchContainer(false, animated: true)
        self.stopwatchManager.stop()
    }
    
    private func changeStopwatchContainer(show: Bool, animated: Bool) {
        self.stopwatchContainerTopConstraint.constant = show ? 0 : -CGRectGetHeight(self.stopwatchContainer.frame)
        UIView.animateWithDuration(animated ? 0.25 : 0, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
