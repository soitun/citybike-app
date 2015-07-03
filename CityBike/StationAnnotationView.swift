//
//  CBStationAnnotationView2.swift
//  CityBike
//
//  Created by Tomasz Szulc on 25/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit
import Model

class StationAnnotationView: MKAnnotationView {

    @IBOutlet private var bikesCircle: UIImageView!
    @IBOutlet private var bikesLabel: UILabel!
    @IBOutlet private var customView: UIView!

    private var previousFreeBikes = 0
    var stationProxy: StationProxy!

    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.bounds = CGRectMake(0, 0, 50, 30)
        self.stationProxy = (annotation as! StationAnnotation).stationProxy
        configureUI()
        configure(stationProxy)
        observe()
    }
    
    
    private func observe() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("notificationReceived:"), name: stationProxy.id, object: nil)
    }
    
    private func finishObserving() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        finishObserving()
    }

    
    func configure(proxy: StationProxy) {
        bikesCircle.tintColor = UIColor.colorForValue(proxy.freeBikes, min: 0, max: proxy.totalSlots)
        bikesLabel.text = "\(proxy.freeBikes)/\(proxy.totalSlots)"
        
        if previousFreeBikes != proxy.freeBikes {
            previousFreeBikes = proxy.freeBikes
            bikesCircle.bounce(0.1)
        }
    }
    
    func notificationReceived(notification: NSNotification) {
        if self.annotation == nil {
            finishObserving()
            return
        }
        
        if let station = Station.fetchWithAttribute("id", value: stationProxy.id, context: CoreDataStack.sharedInstance().mainContext).first as? Station {
            let proxy = StationProxy(station: station)
            (self.annotation as! StationAnnotation).stationProxy = proxy
            configure(proxy)
        }
    }

    // MARK: Private
    private func configureUI() {
        let nib = UINib(nibName: "StationAnnotationView", bundle: NSBundle.mainBundle())
        nib.instantiateWithOwner(self, options: nil).first
        
        if customView != nil {
            self.addSubview(customView)
        }
    }
   
    
    // MARK: Not to be used
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}