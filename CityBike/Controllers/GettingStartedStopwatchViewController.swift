//
//  GettingStartedStopwatchViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class GettingStartedStopwatchViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textLabel.text = NSLocalizedString("Track how much time you spend cycling.\n You can check your rides history in menu.", comment: "")
    }
}
