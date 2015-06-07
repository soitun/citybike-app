//
//  CBMapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Put logo in navigation bar
        let logo = UIImageView(image: UIImage(named: "city-bike-logo-nav"))
        self.navigationItem.titleView = logo
    }
}
