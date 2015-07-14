//
//  MessageTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit
import Swifternalization

enum MessageType {
    case NoStations
    case LocationServicesDisabled
    case CannotObtainUserLocation
    case FetchingData
    case NoInternet
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
        case .NoInternet: configureForNoInternet()
        }
    }
    
    private func configureForNoStations() {
        icon.setTintColor(UIColor.noneColor())
        titleLabel.setText(I18n.localizedString("no-stations"))
        detailTextLabel.setText(I18n.localizedString("no-stations-suggestion"))
    }
    
    private func configureForLocationServicesDisabled() {
        icon.setTintColor(UIColor.noneColor())
        titleLabel.setText(I18n.localizedString("location-services"))
        detailTextLabel.setText(I18n.localizedString("location-services-suggestion"))
    }
    
    private func configureForCannotObtainUserLocation() {
        icon.setTintColor(UIColor.plentyColor())
        titleLabel.setText(I18n.localizedString("current-location"))
        detailTextLabel.setText(I18n.localizedString("getting-your-location"))
    }
    
    private func configurForFetchingData() {
        icon.setTintColor(UIColor.plentyColor())
        titleLabel.setText(I18n.localizedString("updating"))
        detailTextLabel.setText(I18n.localizedString("getting-newest-data"))
    }
    
    private func configureForNoInternet() {
        icon.setTintColor(UIColor.noneColor())
        titleLabel.setText(I18n.localizedString("no-internet-title"))
        detailTextLabel.setText(I18n.localizedString("no-internet-description"))
    }
}
