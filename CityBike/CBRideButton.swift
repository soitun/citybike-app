//
//  CBRideButton.swift
//  CityBike
//
//  Created by Tomasz Szulc on 06/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

protocol CBRideButtonDelegate {
    func rideButtonDidStartAtTime(button:CBRideButton, timeInterval: NSTimeInterval) -> Void
    func rideButtonDidStopAfterTime(button:CBRideButton, timeInterval: NSTimeInterval) -> Void
}

class CBRideButton: CBButton {
    
    var delegate: CBRideButtonDelegate?
    
    private enum State {
        case Stop, Start
    }
    
    private var internalState: State = .Stop
    
    private var _onStopText: String!
    var onStopText: String! {
        set {
            _onStopText = newValue
            if self.internalState == .Stop {
                self.setTitle(newValue, forState: UIControlState.Normal)
            }
        }
        
        get {
            return self._onStopText
        }
    }
    
    var startTimeInterval: NSTimeInterval!
    private var timer: NSTimer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: Selector("tapped"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func tapped() {
        switch self.internalState {
        case .Stop:
            self.internalState = .Start
            self.startTimeInterval = NSDate().timeIntervalSince1970
            self.refreshWithTimeInterval(0)
            self.start()
            
        case .Start:
            self.internalState = .Stop
            self.stop()
        }
    }
    
    func startTimer() {
        self.internalState = .Start
        self.refresh()
        self.start()
    }
    
    private func start() {
        self.delegate?.rideButtonDidStartAtTime(self, timeInterval: self.startTimeInterval)
        self.timer?.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
    }
    
    @objc private func refresh() {
        let diff = NSDate().timeIntervalSince1970 - self.startTimeInterval
        self.refreshWithTimeInterval(diff)
    }
    
    private func refreshWithTimeInterval(ti: NSTimeInterval) {
        var seconds: Int = Int(ti % 60)
        var minutes: Int = Int((ti / 60) % 60)
        var hours: Int = Int(ti / 3600)
        
        
        let text = String(format: "%02d:%02d:%02d", arguments: [hours, minutes, seconds])
        
        UIView.setAnimationsEnabled(false)
        self.setTitle(text, forState: UIControlState.Normal)
        UIView.setAnimationsEnabled(true)
        self.layoutIfNeeded()
    }
    
    private func stop() {
        self.setTitle(self.onStopText, forState: UIControlState.Normal)
        self.timer?.invalidate()
        self.delegate?.rideButtonDidStopAfterTime(self, timeInterval: NSDate().timeIntervalSince1970 - self.startTimeInterval)
    }
}
