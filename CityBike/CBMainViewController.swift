//
//  CBMainViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class CBMainViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CBService.sharedInstance.fetchNetwork(CBNetworkType.BikesSRM, completion: { (network: CBNetwork?) -> Void in
            println(network)
        })
    }
}
