//
//  CBGettingStartedNetworksViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBGettingStartedNetworksViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textLabel.text = NSLocalizedString("You have to select at least one city bike network. Networks are grouped by country to make it easy to select.", comment: "")
    }
}
