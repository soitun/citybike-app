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

class CBMapViewController: UIViewController, MKMapViewDelegate, CBMapDetailViewDelegate {
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var stopwatchReadyButton: CBMapButton!
    @IBOutlet private weak var stopwatchDoneButton: CBMapButton!
    
    /// Container is displayed when there is no internet connection
    @IBOutlet private weak var noInternetContainer: UIView!
    @IBOutlet private weak var noInternetLabel: UILabel!

    @IBOutlet private weak var stopwatchPopover: CBSimplePopover!
    @IBOutlet private weak var mapDetailView: CBMapDetailView!
    @IBOutlet private weak var mapDetailViewBottomConstraint: NSLayoutConstraint!
    
    private var stopwatchManager = CBRideManager()
    private var locationManager = CLLocationManager()
    private var mapUpdater = CBMapUpdater()
    private var selectedStation: StationID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapDetailView.delegate = self
        
        self.noInternetLabel.text = NSLocalizedString("No internet connection", comment: "")
        self.noInternetContainer.makeRounded()
        self.noInternetContainer.changeVisibility(false, animated: false)
        
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateStationsNotification:", name: CBSyncManagerNotification.DidUpdateStations.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateNetworksNotification:", name: CBSyncManagerNotification.DidUpdateNetworks.rawValue, object: nil)
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
                self.noInternetContainer.changeVisibility(true, animated: true)
                
            } else {
                let stations = CDStation.fetchAll(CoreDataHelper.sharedInstance().mainContext) as! [CDStation]
                self.mapUpdater.update(self.mapView, updatedStations: stations)
                self.noInternetContainer.changeVisibility(false, animated: true)
                
                self.updateMapDetailView(self.selectedStation)
            }
        })
    }
    
    func didUpdateNetworksNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.noInternetContainer.changeVisibility((notification.userInfo?["error"] != nil), animated: true)
        })
    }
    
    /// MARK: Stopwatch
    @IBAction func stopwatchReadyPressed(sender: AnyObject) {
        self.startStopwatch(NSDate(), animated: true)
    }
    
    private func runStopwatchIfNeeded() {
        /// Check if stopwatch should be turned on
        if let startDate = NSUserDefaults.getStartRideDate() {
            self.startStopwatch(startDate, animated: false)
            
        } else {
            self.stopwatchPopover.changeVisibility(false, animated: false)
        }
    }
    
    private func startStopwatch(startDate: NSDate, animated: Bool) {
        self.stopwatchManager.start(startDate, updateBlock: { (duration) -> Void in
            self.stopwatchPopover.label.text = duration.stringTimeRepresentationStyle2
        })
        
        self.switchStopwatchButtons(presentReady: false)
        self.stopwatchPopover.changeVisibility(true, animated: animated)
    }
    
    private func switchStopwatchButtons(#presentReady: Bool) {
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
        self.switchStopwatchButtons(presentReady: true)
        self.stopwatchPopover.changeVisibility(false, animated: true)
        self.stopwatchManager.stop()
    }
    
    @IBAction func findPressed(sender: AnyObject) {
        let alert = UIAlertView(title: "Not ready yet", message: "Feature will allow user to find closest free bike and free dock.", delegate: nil, cancelButtonTitle: "Great, but I want to use it now!")
        alert.show()
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
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.updateMapDetailView(self.selectedStation)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.setMapRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        view.bounce(0.1)
        if let annotation = (view.annotation as? CBAnnotation) {
            self.updateMapDetailView(annotation.stationProxy.id)
        }
    }
    
    private func updateMapDetailView(stationID: StationID?) {
        if stationID == nil { return }
        
        let station = CDStation.fetchWithAttribute("id", value: stationID!, context: CoreDataHelper.sharedInstance().mainContext).first as! CDStation
        self.selectedStation = station.id
        
        let detailText = "\(station.network.location.city), \(station.network.location.country)"
        
        var distanceInMeters = 0.0
        if let userLocation = self.mapView.userLocation.location {
            distanceInMeters = userLocation.distanceFromLocation(CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude))
        }
        
        self.mapDetailView.update(station.name, detailText: detailText, freeBikes: station.freeBikes.integerValue, freeSlots: station.emptySlots.integerValue, distance: Float(distanceInMeters), date: station.timestamp)
        
        self.mapDetailViewBottomConstraint.constant = 0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    
    /// MARK: CBMapDetailViewDelegate
    func mapDetailViewDidPressClose(view: CBMapDetailView) {
        self.selectedStation = nil
        self.mapDetailViewBottomConstraint.constant = -CGRectGetHeight(self.mapDetailView.frame)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
