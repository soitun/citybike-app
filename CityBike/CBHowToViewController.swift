//
//  CBHowToViewController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBHowToViewController: UIViewController {

    @IBOutlet weak var welcomeToLabel: UILabel!
    @IBOutlet weak var cityBikeLabel: UILabel!
    @IBOutlet private weak var bikesLabel: UILabel!
    @IBOutlet private weak var slotsLabel: UILabel!
    @IBOutlet weak var manyLabel: UILabel!
    @IBOutlet weak var fewLabel: UILabel!
    @IBOutlet weak var noneLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var manyImageView: UIImageView!
    @IBOutlet weak var fewImageView: UIImageView!
    @IBOutlet weak var noneImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manyImageView.tintColor = UIColor.plentyColor()
        self.fewImageView.tintColor = UIColor.fewColor()
        self.noneImageView.tintColor = UIColor.noneColor()
        
        self.continueButton.makeRoundedAndShadowed()
    }
    
    @IBAction func continuePressed(sender: AnyObject) {
    }
}
