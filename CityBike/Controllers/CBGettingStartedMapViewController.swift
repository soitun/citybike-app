//
//  CBGettingStartedMapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBGettingStartedMapViewController: UIViewController {

    @IBOutlet private weak var freeBikesLabel: UILabel!
    
    @IBOutlet private weak var manyLabel: UILabel!
    @IBOutlet private weak var fewLabel: UILabel!
    @IBOutlet private weak var noneLabel: UILabel!
    
    @IBOutlet private weak var manyCircleImageView: UIImageView!
    @IBOutlet private weak var fewCircleImageView: UIImageView!
    @IBOutlet private weak var noneCircleImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.freeBikesLabel.text = NSLocalizedString("number of free bikes in station", comment: "")
        
        self.manyLabel.text = NSLocalizedString("Many", comment: "")
        self.fewLabel.text = NSLocalizedString("Few", comment: "")
        self.noneLabel.text = NSLocalizedString("None", comment: "")
        
        self.manyCircleImageView.tintColor = UIColor.plentyColor()
        self.fewCircleImageView.tintColor = UIColor.fewColor()
        self.noneCircleImageView.tintColor = UIColor.noneColor()
    }
}
