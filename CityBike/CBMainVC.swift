//
//  CBMainVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class CBMainVC: UIViewController, MKMapViewDelegate {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var locateMeButton: UIButton!
    @IBOutlet private weak var networksButton: UIButton!
    
    private var stations = [CBStation]()
    private var locationManager = CLLocationManager()
    private var noNetworksSelectedPopupPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locateMeButton.makeRoundedAndShadowed()
        self.networksButton.makeRoundedAndShadowed()

        self.locationManager.requestWhenInUseAuthorization()

        /// Download networks
        self.networksButton.enabled = false
        CBContentManager.sharedInstance.fetchAllNetworks {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.networksButton.enabled = true
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.noNetworksSelectedPopupPresented == false && NSUserDefaults.getNetworkIDs().count == 0 {
            self.noNetworksSelectedPopupPresented = true
            self.presentNoNetworksSelectedPopup()
        }
    }
    
    @IBAction func refreshPressed(sender: AnyObject) {
        self.refreshSelectedNetworks()
    }
    
    private func refreshSelectedNetworks() {
        let networkIDs = NSUserDefaults.getNetworkIDs()
        
        var networkTypes = [CBNetworkType]()
        for networkID in networkIDs {
            if let type = CBNetworkType(rawValue: networkID) {
                networkTypes.append(type)
            }
        }
        
        if networkIDs.count == 0 || networkTypes.count == 0 {
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        CBContentManager.sharedInstance.fetchStationsForNetworkTypes(networkTypes, completion: { (stations) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.stations = stations
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.addStationsToMap(self.stations)
            })
        })
    }
    
    private func addStationsToMap(stations: [CBStation]!) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        var updated = [CBAnnotation]()
        for station in stations {
            let annotation = CBAnnotation(station: station)
            updated.append(annotation)
        }
        
        self.mapView.addAnnotations(updated)
    }
    
    @IBAction func locateMePressed(sender: AnyObject) {
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 2000, 2000)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func presentNoNetworksSelectedPopup() {
        self.performSegueWithIdentifier("ShowSelectBikeNetworks", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSelectBikeNetworks" {
            let vc = segue.destinationViewController as! UIViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
    }
    
    /// MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is CBAnnotation {
            let view = CBAnnotationView(annotation: annotation, reuseIdentifier: "CBStation")
            view.noneColor = UIColor.noneColor()
            view.fewColor = UIColor.fewColor()
            view.plentyColor = UIColor.plentyColor()
            
            view.configure((annotation as! CBAnnotation).station)
            return view
        }
        
        return nil
    }
}
