//
//  CBMapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit
import CBModel

class CBMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private var stopwatchReadyButton: CBMapButton!
    @IBOutlet private var stopwatchDoneButton: CBMapButton!
    
    /// Container is displayed when there is no internet connection
    @IBOutlet weak var noInternetContainer: UIView!
    @IBOutlet weak var noInternetLabel: UILabel!

    private var stopwatchManager = CBRideManager()
    private var locationManager = CLLocationManager()
    private var mapUpdater = CBMapUpdater()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noInternetContainer.makeRounded()
        self.noInternetLabel.text = NSLocalizedString("No internet connection", comment: "")
        self.changeNoInternetContainer(false, animated: false)
                
        self.runStopwatchIfNeeded()

        /// Request content
        self.locationManager.requestWhenInUseAuthorization()
        CBModelUpdater.sharedInstance.start()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerObservers()
        
        let allStations = CDStation.fetchAll(CoreDataHelper.sharedInstance().mainContext) as! [CDStation]
        self.mapUpdater.update(self.mapView, updatedStations: allStations)
       
        /// Show last saved region
        if let savedRegion = NSUserDefaults.getMapRegion() {
            self.mapView.setRegion(savedRegion, animated: false)
        }
    }
    
    private func registerObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateStationsNotification:", name: CBSyncManager.DidUpdateStationsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateNetworksNotification:", name: CBSyncManager.DidUpdateNetworksNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func locateMePressed(sender: AnyObject) {
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 2000, 2000), animated: true)
    }

    /// MARK: Notifications
    func didUpdateStationsNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let error = notification.userInfo?["error"] as? NSError {
                self.changeNoInternetContainer(true, animated: true)
                
            } else {
                let stations = CDStation.fetchAll(CoreDataHelper.sharedInstance().mainContext) as! [CDStation]
                self.mapUpdater.update(self.mapView, updatedStations: stations)
                self.changeNoInternetContainer(false, animated: true)
            }
        })
    }
    
    func didUpdateNetworksNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let error = notification.userInfo?["error"] as? NSError {
                self.changeNoInternetContainer(true, animated: true)
                
            } else {
                self.changeNoInternetContainer(false, animated: true)
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
//            self.stopwatchTimeLabel.text = duration.stringTimeRepresentationStyle2
        })
        
        if (showBar) {
            self.switchStopwatchButtons(false)
            self.changeStopwatchContainer(true, animated: animated)
        }
    }
    
    private func switchStopwatchButtons(presentReady: Bool) {
        let btnToShow = presentReady ? self.stopwatchReadyButton : self.stopwatchDoneButton
        let btnToHide = presentReady ? self.stopwatchDoneButton : self.stopwatchReadyButton
        
        btnToShow.alpha = 0
        btnToShow.hidden = false
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            btnToShow.alpha = 1
            btnToHide.alpha = 0
            }, completion: { _ in
                btnToHide.hidden = true
        })
    }
    
    @IBAction func stopwatchDonePressed(sender: AnyObject) {
        self.switchStopwatchButtons(true)
        self.changeStopwatchContainer(false, animated: true)
        self.stopwatchManager.stop()
    }
    
    private func changeStopwatchContainer(show: Bool, animated: Bool) {
//        self.stopwatchContainerTopConstraint.constant = show ? 0 : -CGRectGetHeight(self.stopwatchContainer.frame)
//        if show && self.connectionErrorPresented {
//            self.showConnectionErrorLabel(true)
//        }
//        
//        UIView.animateWithDuration(animated ? 0.25 : 0, animations: { () -> Void in
//            self.stopwatchContainer.alpha = show ? 1.0 : 0.0 /// explicit
//            self.view.layoutIfNeeded()
//        })
    }
    
    
    /// MARK: No Internet Container
    private func changeNoInternetContainer(show: Bool, animated: Bool) {
        let duration = animated ? 0.25 : 0
        if show == true && self.noInternetContainer.hidden == true {
            self.noInternetContainer.alpha = 0
            self.noInternetContainer.hidden = false
            UIView.animateWithDuration(duration, animations: { self.noInternetContainer.alpha = 1 })

        } else if show == false && self.noInternetContainer.hidden == false {
            self.noInternetContainer.alpha = 1
            UIView.animateWithDuration(duration, animations: {
                self.noInternetContainer.alpha = 0
                }) { _ in
                    self.noInternetContainer.hidden = true
            }
        }
    }
    
    
    /// MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CBAnnotation) { return nil }
        
        let cbAnnotation = (annotation as! CBAnnotation)
        let view = self.mapUpdater.viewForAnnotation(cbAnnotation)
        view.noneColor = UIColor.noneColor()
        view.fewColor = UIColor.fewColor()
        view.plentyColor = UIColor.plentyColor()
        
        let station = CDStation.fetchWithAttribute("id", value: cbAnnotation.stationProxy.id, context: CoreDataHelper.sharedInstance().mainContext).first as! CDStation
        view.configure(station)
        return view
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.setMapRegion(mapView.region)
    }
}
