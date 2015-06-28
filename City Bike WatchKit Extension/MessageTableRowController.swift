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
        titleLabel.setText(I18N.localizedString("no-stations"))
        detailTextLabel.setText(I18N.localizedString("no-stations-suggestion"))
    }
    
    private func configureForLocationServicesDisabled() {
        icon.setTintColor(UIColor.noneColor())
        titleLabel.setText(I18N.localizedString("location-services"))
        detailTextLabel.setText(I18N.localizedString("location-services-suggestion"))
    }
    
    private func configureForCannotObtainUserLocation() {
        icon.setTintColor(UIColor.plentyColor())
        titleLabel.setText(I18N.localizedString("current-location"))
        detailTextLabel.setText(I18N.localizedString("getting-your-location"))
    }
    
    private func configurForFetchingData() {
        icon.setTintColor(UIColor.plentyColor())
        titleLabel.setText(I18N.localizedString("updating"))
        detailTextLabel.setText(I18N.localizedString("getting-newest-data"))
    }
}
