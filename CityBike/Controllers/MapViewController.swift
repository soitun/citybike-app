//
//  MapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit
import Model

class MapViewController: UIViewController, MKMapViewDelegate, CBMapDetailViewDelegate {
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var stopwatchReadyButton: MapButton!
    @IBOutlet private weak var stopwatchDoneButton: MapButton!
    
    /// Container is displayed when there is no internet connection
    @IBOutlet private weak var noInternetContainer: UIView!
    @IBOutlet private weak var noInternetLabel: UILabel!

    @IBOutlet private weak var stopwatchPopover: StopwatchPopover!
    @IBOutlet private weak var mapDetailView: MapDetailView!
    @IBOutlet private weak var mapDetailViewBottomConstraint: NSLayoutConstraint!
    
    private var stopwatchManager = RideManager()
    private var selectedStation: StationID?
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        mapDetailView.delegate = self
        
        noInternetLabel.text = I18n.localizedString("connectivity-issue")
        noInternetContainer.makeRounded()
        noInternetContainer.changeVisibility(false, animated: false)
        
        listenForWormholeNotifications()
    }
    
    private func listenForWormholeNotifications() {
        WormholeNotificationSystem.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.StopwatchStarted.rawValue, listener: { _ in
            if self.stopwatchManager.isGoing == false {
                self.startStopwatch(UserSettings.sharedInstance().getStartRideDate()!, animated: true)
            }
        })
        
        WormholeNotificationSystem.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.StopwatchStopped.rawValue, listener: { _ in
            if self.stopwatchManager.isGoing == true {
                self.stopStopwatch()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ModelUpdater.sharedInstance.setSelectedNetworkIds(UserSettings.sharedInstance().getNetworkIDs())
        ModelUpdater.sharedInstance.start()
        runStopwatchIfNeeded()
        registerObservers()
        refreshContent()
       
        /// Show last saved region
        if let savedRegion = UserSettings.sharedInstance().getMapRegion() {
            mapView.setRegion(savedRegion, animated: false)
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
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 2000, 2000), animated: true)
    }
    
    private func refreshContent() {
        let stations = StationManager.allStationsForSelectedNetworks()
        
        var annotationsToAdd = [StationAnnotation]()
        var annotationsOnMap = mapView.annotations.filter({$0 is StationAnnotation}) as! [StationAnnotation]
        
        /// find new stations to show on the map
        for station in stations {
            if annotationsOnMap.filter({$0.stationProxy.id == station.id}).first == nil {
                let newAnnotation = StationAnnotation(stationProxy: StationProxy(station: station))
                annotationsToAdd.append(newAnnotation)
            }
        }
        
        /// find stations to remove from the map and remove them
        var annotationsToRemove = [StationAnnotation]()
        for annotation in annotationsOnMap {
            if stations.filter({$0.id == annotation.stationProxy.id}).first == nil {
                annotationsToRemove.append(annotation)
            }
        }
        
        
        /// refresh UI
        mapView.removeAnnotations(annotationsToRemove)
        mapView.addAnnotations(annotationsToAdd)
        
        for station in stations {
            /// refresh annotations
            NSNotificationCenter.defaultCenter().postNotificationName(station.id, object: nil)
        }
    }

    /// MARK: Notifications
    func didUpdateStationsNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let error = notification.userInfo?["error"] as? NSError {
                self.noInternetContainer.changeVisibility(true, animated: true)
                
            } else {
                self.refreshContent()
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
        startStopwatch(NSDate(), animated: true)
    }
    
    private func runStopwatchIfNeeded() {
        /// Check if stopwatch should be turned on
        if let startDate = UserSettings.sharedInstance().getStartRideDate() {
            startStopwatch(startDate, animated: false)
            
        } else {
            stopwatchPopover.changeVisibility(false, animated: false)
        }
    }
    
    private func startStopwatch(startDate: NSDate, animated: Bool) {
        stopwatchManager.start(startDate, updateBlock: { (duration) -> Void in
            self.stopwatchPopover.label.text = duration.stringTimeRepresentationStyle2
        })
        
        switchStopwatchButtons(presentReady: false)
        stopwatchPopover.changeVisibility(true, animated: animated)
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
        stopStopwatch()
    }
    
    private func stopStopwatch() {
        switchStopwatchButtons(presentReady: true)
        stopwatchPopover.changeVisibility(false, animated: true)
        stopwatchManager.stop()
    }
    
    @IBAction func findPressed(sender: AnyObject) {
        let alert = UIAlertView(title: "Not ready yet", message: "Feature will allow user to find closest free bike and free dock.", delegate: nil, cancelButtonTitle: "Great, but I want to use it now!")
        alert.show()
    }
    
    /// MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is StationAnnotation) == false { return nil }
        
        let stationAnnotation = (annotation as! StationAnnotation)
        return StationAnnotationView(annotation: stationAnnotation, reuseIdentifier: "StationAnnotationView")
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        updateMapDetailView(self.selectedStation)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        UserSettings.sharedInstance().setMapRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        view.bounce(0.1)
        if let annotation = (view.annotation as? StationAnnotation) {
            updateMapDetailView(annotation.stationProxy.id)
        }
    }
    
    private func updateMapDetailView(stationID: StationID?) {
        if stationID == nil { return }
        
        let station = Station.fetchWithAttribute("id", value: stationID!, context: CoreDataStack.sharedInstance().mainContext).first as! Station
        selectedStation = station.id
        
        let detailText = "\(station.network.location.city), \(station.network.location.country)"
        
        var distanceInMeters = 0.0
        if let userLocation = mapView.userLocation.location {
            distanceInMeters = userLocation.distanceFromLocation(CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude))
        }
        
        mapDetailView.update(station.name, detailText: detailText, freeBikes: station.freeBikes.integerValue, freeSlots: station.emptySlots.integerValue, distance: Float(distanceInMeters), date: station.timestamp)
        
        mapDetailViewBottomConstraint.constant = 0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    
    /// MARK: CBMapDetailViewDelegate
    func mapDetailViewDidPressClose(view: MapDetailView) {
        selectedStation = nil
        mapDetailViewBottomConstraint.constant = -CGRectGetHeight(mapDetailView.frame)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

extension StationProxy {
    convenience init(station: Station) {
        self.init(id: station.id, freeBikes: station.freeBikes.integerValue, totalSlots: station.freeBikes.integerValue + station.emptySlots.integerValue, coordinate: station.coordinate)
    }
}
