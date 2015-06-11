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
    @IBOutlet private weak var locateMeButton: CBButton!
    @IBOutlet private weak var networksButton: CBButton!
    @IBOutlet weak var rideButton: CBRideButton!
    
    @IBOutlet private weak var connectionErrorLabel: UILabel!
    @IBOutlet private weak var connectionErrorBarHeight: NSLayoutConstraint!
    @IBOutlet private weak var connectionErrorBarTop: NSLayoutConstraint!
    @IBOutlet private weak var connectionErrorBar: UIView!
    
    private var noNetworksSelectedPopupPresented = false
}
