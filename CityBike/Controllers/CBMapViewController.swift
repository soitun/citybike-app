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

    @IBOutlet private weak var connectionErrorBar: UIView!
    @IBOutlet private weak var connectionErrorLabel: UILabel!
    @IBOutlet private weak var connectionErrorTopConstraint: NSLayoutConstraint!
    private var connectionErrorPresented: Bool = false

    private var stopwatchManager = CBRideManager()
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideConnectionErrorLabel(false)
        /// Put logo in navigation bar
        let logo = UIImageView(image: UIImage(named: "city-bike-logo-nav"))
        self.navigationItem.titleView = logo
        
        /// Set button initially
        self.navigationItem.leftBarButtonItems = [self.stopwatchReadyButton, self.locateMeButton]
        
        self.stopwatchContainer.backgroundColor = UIColor.blueGrayColor()
        self.runStopwatchIfNeeded()

        /// Request content
        self.locationManager.requestWhenInUseAuthorization()
        CBModelUpdater.sharedInstance.start()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let stations = CDStation.allStations(CoreDataHelper.mainContext)
        self.updateStations(stations)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateStationsNotification:", name: CBContentManager.DidUpdateStationsNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func locateMePressed(sender: AnyObject) {
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 2000, 2000)
        self.mapView.setRegion(region, animated: true)
    }

    private func updateStations(stations: [CDStation]) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        var updatedAnnotations = [CDAnnotation]()
        
        for station in stations {
            let annotation = CDAnnotation(station: station)
            updatedAnnotations.append(annotation)
        }
        
        self.mapView.addAnnotations(updatedAnnotations)
    }
    
    /// MARK: Notifications
    func didUpdateStationsNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let userInfo = notification.userInfo {
                let error = notification.userInfo!["error"] as? NSError
                if error != nil {
                    self.connectionErrorLabel.text = "Internet connection problem."
                    self.showConnectionErrorLabel(true)
                }
                
            } else {
                let stations = CDStation.allStations(CoreDataHelper.mainContext)
                self.updateStations(stations)
                self.hideConnectionErrorLabel(true)
            }
        })
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
        if show && self.connectionErrorPresented {
            self.showConnectionErrorLabel(true)
        }
        
        UIView.animateWithDuration(animated ? 0.25 : 0, animations: { () -> Void in
            self.stopwatchContainer.alpha = show ? 1.0 : 0.0 /// explicit
            self.view.layoutIfNeeded()
        })
    }
    
    
    /// MARK: Connection Error Label
    private func showConnectionErrorLabel(animated: Bool) {
        self.connectionErrorPresented = true
        self.connectionErrorTopConstraint.constant = 0
        if self.stopwatchManager.isGoing {
            self.stopwatchContainerTopConstraint.constant = CGRectGetHeight(self.connectionErrorBar.frame)
        }
        
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: { () -> Void in
            self.connectionErrorBar.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    private func hideConnectionErrorLabel(animated: Bool) {
        self.connectionErrorPresented = false
        self.connectionErrorTopConstraint.constant = -CGRectGetHeight(self.connectionErrorBar.frame)
        if self.stopwatchManager.isGoing {
            self.stopwatchContainerTopConstraint.constant = 0
        }
        
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: { () -> Void in
            self.connectionErrorBar.alpha = 0
            self.view.layoutIfNeeded()
        })
    }
    
    
    /// MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CDAnnotation) { return nil }
        
        let view = CDStationAnnotationView(annotation: annotation, reuseIdentifier: "CDStationAnnotationView")
        view.noneColor = UIColor.noneColor()
        view.fewColor = UIColor.fewColor()
        view.plentyColor = UIColor.plentyColor()
        
        view.configure((annotation as! CDAnnotation).station)
        return view
    }
}
