//
//  CBStopwatchInterfaceController.swift
//  CityBike
//
//  Created by Tomasz Szulc on 21/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import WatchKit
import Foundation


class CBStopwatchInterfaceController: WKInterfaceController {
    @IBOutlet weak var button: WKInterfaceButton!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    
    private var stopwatchManager = CBRideManager()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        refreshButtonState()
        
        CBWormhole.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.StopwatchStarted.rawValue, listener: { _ in
            self.start(CBUserSettings.sharedInstance().getStartRideDate()!)
        })
        
        CBWormhole.sharedInstance.listenForMessageWithIdentifier(CBWormholeNotification.StopwatchStopped.rawValue, listener: { _ in
            self.stop()
        })
    }
    
    private func refreshButtonState() {
        if let startDate = CBUserSettings.sharedInstance().getStartRideDate() {
            start(startDate)
        } else {
            stop()
        }
    }
    
    @IBAction func actionButtonTapped() {
        self.stopwatchManager.isGoing == true ? stop() : start(NSDate())
    }
    
    private func start(startDate: NSDate) {
        button.setBackgroundColor(UIColor.noneColor())
        button.setTitle(NSLocalizedString("STOP RIDE", comment: ""))

        if self.stopwatchManager.isGoing == false {
            self.stopwatchManager.start(startDate, updateBlock: { (duration) -> Void in
                self.timeLabel.setText(duration.stringTimeRepresentationStyle2)
            })
        }
    }
    
    private func stop() {
        button.setBackgroundColor(UIColor.plentyColor())
        button.setTitle(NSLocalizedString("START A RIDE", comment: ""))

        if self.stopwatchManager.isGoing == true {
            self.stopwatchManager.stop()
        }
        self.timeLabel.setText((0.0).stringTimeRepresentationStyle2)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
