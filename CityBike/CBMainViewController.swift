//
//  CBMainViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class CBMainViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet private weak var mapView: MKMapView!
    
    private var network: CBNetwork?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func refreshPressed(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        CBService.sharedInstance.fetchNetwork(CBNetworkType.BikesSRM, completion: { (network: CBNetwork?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.network = network
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.addStationsToMap(self.network?.stations ?? [CBStation]())
            })
        })
    }
    
    /// MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is CBAnnotation {
            let view = CBAnnotationView(annotation: annotation, reuseIdentifier: "CBStation")
            view.noneColor = UIColor(red:1, green:0.42, blue:0.49, alpha:1)
            view.fewColor = UIColor(red:1, green:0.94, blue:0.23, alpha:1)
            view.plentyColor = UIColor(red:0.6, green:0.92, blue:0.24, alpha:1)
            
            view.configure((annotation as! CBAnnotation).station)
            return view
        }
        
        return nil
    }
}
