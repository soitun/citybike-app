//
//  UpdateTableRowController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import WatchKit
import Swifternalization

class UpdateTableRowController: NSObject {
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var dateLabel: WKInterfaceLabel!

    func configure(date: NSDate) {
        titleLabel.setText(I18n.localizedString("recently-updated"))
        dateLabel.setText(date.updatedWhileAgoTextualRepresentation())
    }
}