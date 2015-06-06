//
//  CBMainVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class CBMainVC: UIViewController, MKMapViewDelegate, CBRideButtonDelegate {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var locateMeButton: UIButton!
    @IBOutlet private weak var networksButton: UIButton!
    @IBOutlet weak var rideButton: CBRideButton!
    
    @IBOutlet private weak var connectionErrorLabel: UILabel!
    @IBOutlet private weak var connectionErrorBarHeight: NSLayoutConstraint!
    @IBOutlet private weak var connectionErrorBarTop: NSLayoutConstraint!
    @IBOutlet private weak var connectionErrorBar: UIView!
    
    private var locationManager = CLLocationManager()
    private var noNetworksSelectedPopupPresented = false
    
    
    /// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locateMeButton.makeStyleShadowedWhite()
        self.networksButton.makeStyleShadowedWhite()
        
        /// Configure Ride Button
        self.rideButton.makeStyleShadowedWhite()
        self.rideButton.delegate = self
        self.rideButton.onStopText = "Start a ride"
        if let ti = NSUserDefaults.getStartRideTimeInterval() {
            self.rideButton.startTimeInterval = ti
            self.rideButton.startTimer()
        }

        self.locationManager.requestWhenInUseAuthorization()
        
        CBContentManager.sharedInstance.start()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStations(CBContentManager.sharedInstance.stations)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateStationsNotification:", name: CBContentManager.DidUpdateStationsNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.presentNoNetworkSelectedIfNecessary()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /// MARK: Actions & Private
    @IBAction func locateMePressed(sender: AnyObject) {
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 2000, 2000)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func presentNoNetworkSelectedIfNecessary() {
        if self.noNetworksSelectedPopupPresented == false &&
            NSUserDefaults.getNetworkIDs().count == 0 &&
            NSUserDefaults.getDoNotShowAgainNoBikeNetworks() == false {
                
                self.noNetworksSelectedPopupPresented = true
                self.performSegueWithIdentifier("ShowSelectBikeNetworks", sender: nil)
        }
    }

    private func updateStations(stations: [CBStation]) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        var updatedAnnotations = [CBAnnotation]()
        
        for station in stations {
            let annotation = CBAnnotation(station: station)
            updatedAnnotations.append(annotation)
        }
        
        self.mapView.addAnnotations(updatedAnnotations)
    }
    
    /// MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSelectBikeNetworks" {
            let vc = segue.destinationViewController as! UIViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
    }
    
    
    /// MARK: Notifications
    func didUpdateStationsNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let error = notification.userInfo!["error"] as? NSError
            if error != nil {
                self.connectionErrorLabel.text = "Internet connection problem."
                
                /// Animate Error Bar
                if self.connectionErrorBar.alpha == 0 {
                    self.connectionErrorBarTop.constant = 0
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                        self.connectionErrorBar.alpha = 1
                    })
                }
            } else {
                let stations = notification.userInfo!["stations"]! as! [CBStation]
                self.updateStations(stations)

                /// Animate Error Bar
                if self.connectionErrorBar.alpha != 0 {
                    self.connectionErrorBarTop.constant = -self.connectionErrorBarHeight.constant
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                        self.connectionErrorBar.alpha = 0
                    })
                }
            }
        })
    }
    
    
    /// MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CBAnnotation) { return nil }
        
        let view = CBAnnotationView(annotation: annotation, reuseIdentifier: "CBStation")
        view.noneColor = UIColor.noneColor()
        view.fewColor = UIColor.fewColor()
        view.plentyColor = UIColor.plentyColor()
        
        view.configure((annotation as! CBAnnotation).station)
        return view
    }
    
    
    /// MARK: CBRideButtonDelegate
    func rideButtonDidStartAtTime(button: CBRideButton, timeInterval: NSTimeInterval) {
        NSUserDefaults.setStartRideTimeInterval(timeInterval)
    }
    
    func rideButtonDidStopAfterTime(button: CBRideButton, timeInterval: NSTimeInterval) {
        NSUserDefaults.removeStartRideTimeInterval()
    }
}
