//
//  StopwatchInterfaceController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation


class StopwatchInterfaceController: WKInterfaceController {
    @IBOutlet weak var button: WKInterfaceButton!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    
    private var stopwatchManager = RideManager()
    
    
    // MARK: Life cycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.setTitle(I18N.localizedString("stopwatch"))
    }

    override func willActivate() {
        super.willActivate()
        refreshButtonState()
        
        WormholeNotificationSystem.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.StopwatchStarted.rawValue, listener: { _ in
            dispatch_async(dispatch_get_main_queue()) { self.start(UserSettings.sharedInstance().getStartRideDate()!) }
        })
        
        WormholeNotificationSystem.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.StopwatchStopped.rawValue, listener: { _ in
            dispatch_async(dispatch_get_main_queue()) { self.stop() }
        })
    }
    
    @IBAction func actionButtonTapped() {
        self.stopwatchManager.isGoing == true ? stop() : start(NSDate())
    }
    
    
    // MARK: Private
    private func refreshButtonState() {
        if let startDate = UserSettings.sharedInstance().getStartRideDate() {
            start(startDate)
        } else {
            stop()
        }
    }
    
    private func start(startDate: NSDate) {
        let stopImage = UIImage(named: "watch-btn-stopwatch-stop")
        button.setBackgroundImage(stopImage)

        if self.stopwatchManager.isGoing == false {
            self.stopwatchManager.start(startDate, updateBlock: { (duration) -> Void in
                self.timeLabel.setText(duration.stringTimeRepresentationStyle2)
            })
        }
    }
    
    private func stop() {
        let startImage = UIImage(named: "watch-btn-stopwatch-play")
        button.setBackgroundImage(startImage)

        if self.stopwatchManager.isGoing == true {
            self.stopwatchManager.stop()
        }
        self.timeLabel.setText((0.0).stringTimeRepresentationStyle2)
    }
}
