//
//  CBSelectNetworkPopupVC.swift
//  CityBike
//
//  Created by Tomasz Szulc on 04/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class CBSelectNetworkPopupVC: UIViewController {
    
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet weak var doNotShowAgainButton: UIButton!
    @IBOutlet private weak var containerCenterYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.makeShadowed()
        self.closeButton.makeRoundedAndShadowed()
        self.doNotShowAgainButton.makeRoundedAndShadowed()
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismiss()
    }
    
    @IBAction func doNotShowPressed(sender: AnyObject) {
        NSUserDefaults.setDoNotShowAgainNoBikeNetworks(true)
        self.dismiss()
    }
    
    private func dismiss() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}