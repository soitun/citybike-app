//
//  GettingStartedNetworksViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class GettingStartedNetworksViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = I18n.localizedString("getting-started-networks")
    }
}
