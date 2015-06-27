//
//  GettingStartedMapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class GettingStartedMapViewController: UIViewController {

    @IBOutlet private weak var freeBikesLabel: UILabel!
    
    @IBOutlet private weak var manyLabel: UILabel!
    @IBOutlet private weak var fewLabel: UILabel!
    @IBOutlet private weak var noneLabel: UILabel!
    
    @IBOutlet private weak var manyCircleImageView: UIImageView!
    @IBOutlet private weak var fewCircleImageView: UIImageView!
    @IBOutlet private weak var noneCircleImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        freeBikesLabel.text = NSLocalizedString("bikes-available", comment: "")
        
        manyLabel.text = NSLocalizedString("many", comment: "")
        fewLabel.text = NSLocalizedString("few", comment: "")
        noneLabel.text = NSLocalizedString("none", comment: "")
        
        manyCircleImageView.tintColor = UIColor.plentyColor()
        fewCircleImageView.tintColor = UIColor.fewColor()
        noneCircleImageView.tintColor = UIColor.noneColor()
    }
}
