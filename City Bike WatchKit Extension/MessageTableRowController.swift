//
//  MessageTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit

enum MessageType {
    case NoStations
    case LocationServicesDisabled
    case CannotObtainUserLocation
    case FetchingData
}

class MessageTableRowController: NSObject {
    
    @IBOutlet weak var icon: WKInterfaceImage!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var detailTextLabel: WKInterfaceLabel!
    
    func configure(type: MessageType) {
        switch type {
        case .NoStations: configureForNoStations()
        case .LocationServicesDisabled: configureForLocationServicesDisabled()
        case .CannotObtainUserLocation: configureForCannotObtainUserLocation()
        case .FetchingData: configurForFetchingData()
        }
    }
    
    private func configureForNoStations() {
        icon.setTintColor(UIColor.noneColor())
        titleLabel.setText(NSLocalizedString("no-stations", comment: ""))
        detailTextLabel.setText(NSLocalizedString("no-stations-suggestion", comment: ""))
    }
    
    private func configureForLocationServicesDisabled() {
        icon.setTintColor(UIColor.noneColor())
        titleLabel.setText(NSLocalizedString("location-services", comment: ""))
        detailTextLabel.setText(NSLocalizedString("location-services-suggestion", comment: ""))
    }
    
    private func configureForCannotObtainUserLocation() {
        icon.setTintColor(UIColor.plentyColor())
        titleLabel.setText(NSLocalizedString("current-location", comment: ""))
        detailTextLabel.setText(NSLocalizedString("getting-your-location", comment: ""))
    }
    
    private func configurForFetchingData() {
        icon.setTintColor(UIColor.plentyColor())
        titleLabel.setText(NSLocalizedString("updating", comment: ""))
        detailTextLabel.setText(NSLocalizedString("getting-newest-data", comment: ""))
    }
}
