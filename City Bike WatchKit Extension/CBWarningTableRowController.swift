//
//  CBWarningTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit

enum CBWarningType {
    case NoStations
    case LocationServicesDisabled
    case CannotObtainUserLocation
}

class CBWarningTableRowController: NSObject {
    
    @IBOutlet weak var icon: WKInterfaceImage!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var detailTextLabel: WKInterfaceLabel!
    
    func configure(type: CBWarningType) {
        icon.setTintColor(UIColor.noneColor())

        switch type {
        case .NoStations: configureForNoStations()
        case .LocationServicesDisabled: configureForLocationServicesDisabled()
        case .CannotObtainUserLocation: configureForCannotObtainUserLocation()
        }
    }
    
    private func configureForNoStations() {
        titleLabel.setText(NSLocalizedString("NO STATIONS", comment: ""))
        detailTextLabel.setText(NSLocalizedString("No stations selected. Open iPhone app and select some city bike network first.", comment: ""))
    }
    
    private func configureForLocationServicesDisabled() {
        titleLabel.setText(NSLocalizedString("LOCATION SERVICES", comment: ""))
        detailTextLabel.setText(NSLocalizedString("To show you nearest bike stations and approximate distance to them app needs access to Location Services. If this is your first launch please go to iPhone app to accept permissions, otherwise go to system Settings.", comment: ""))
    }
    
    private func configureForCannotObtainUserLocation() {
        titleLabel.setText(NSLocalizedString("CURRENT LOCATION", comment: ""))
        detailTextLabel.setText(NSLocalizedString("Getting your location...", comment: ""))

    }
}
