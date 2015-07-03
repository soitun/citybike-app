//
//  GettingStartedMapViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 07/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import Swifternalization

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

        freeBikesLabel.text = I18n.localizedString("bikes-available")
        
        manyLabel.text = I18n.localizedString("many")
        fewLabel.text = I18n.localizedString("few")
        noneLabel.text = I18n.localizedString("none")
        
        manyCircleImageView.tintColor = UIColor.plentyColor()
        fewCircleImageView.tintColor = UIColor.fewColor()
        noneCircleImageView.tintColor = UIColor.noneColor()
    }
}
