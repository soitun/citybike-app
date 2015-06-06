//
//  CBHowToVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBHowToVC: UIViewController {

    @IBOutlet private weak var welcomeToLabel: UILabel!
    @IBOutlet private weak var cityBikeLabel: UILabel!
    @IBOutlet private weak var bikesLabel: UILabel!
    @IBOutlet private weak var slotsLabel: UILabel!
    @IBOutlet private weak var manyLabel: UILabel!
    @IBOutlet private weak var fewLabel: UILabel!
    @IBOutlet private weak var noneLabel: UILabel!
    @IBOutlet private weak var continueButton: CBButton!
    @IBOutlet private weak var manyImageView: UIImageView!
    @IBOutlet private weak var fewImageView: UIImageView!
    @IBOutlet private weak var noneImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manyImageView.tintColor = UIColor.plentyColor()
        self.fewImageView.tintColor = UIColor.fewColor()
        self.noneImageView.tintColor = UIColor.noneColor()
        
        self.continueButton.makeStyleReddish()
    }
    
    @IBAction func continuePressed(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowMap", sender: nil)
    }
}
