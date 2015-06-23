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
    case LocationServicesAccessDenied
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
        case .LocationServicesAccessDenied: configureForLocationServicesAccessDenied()
        }
    }
    
    private func configureForNoStations() {
        titleLabel.setText(NSLocalizedString("NO STATIONS", comment: ""))
        detailTextLabel.setText(NSLocalizedString("No stations selected yet. Open iPhone app and select some city bike network first.", comment: ""))
    }
    
    private func configureForLocationServicesDisabled() {
        titleLabel.setText(NSLocalizedString("LOCATION SERVICES", comment: ""))
        detailTextLabel.setText(NSLocalizedString("To show you approximate distance to bike stations app needs location services. You can turn it on your iPhone", comment: ""))
    }
    
    private func configureForLocationServicesAccessDenied() {
        titleLabel.setText(NSLocalizedString("LOCATION SERVICES", comment: ""))
        detailTextLabel.setText(NSLocalizedString("App have no permissions to use Location Services. To show approximate distance to bike stations please give permissions using iPhone.", comment: ""))
    }
}
