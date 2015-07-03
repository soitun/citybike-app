//
//  ViewController.swift
//  Demo
//
//  Created by Tomasz Szulc on 04/07/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CityBikesAPI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let syncManager: CBSyncManager = CBSyncManager()
        syncManager.delegate = self
        syncManager.start()
//        syncManager.stop()
        
        let network: CBNetwork = CBNetwork()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

