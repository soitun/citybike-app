//
//  CBObservingAnnotationView.swift
//  CityBike
//
//  Created by Tomasz Szulc on 25/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import MapKit

class ObservingAnnotationView: MKAnnotationView {
    typealias TheAnnotation = Stationable
    
    var theAnnotation: TheAnnotation { return annotation as! TheAnnotation }
    
    init(annotation: TheAnnotation, reuseIdentifier: String!) {
        super.init(annotation: annotation as! MKAnnotation, reuseIdentifier: reuseIdentifier)
        observe()
    }
    
    private func observe() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("notificationReceived:"), name: theAnnotation.station.id, object: nil)
    }
    
    func notificationReceived(notification: NSNotification) {
        // Do something with received notification
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Not to be used
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        fatalError("Don't use this. Use with T type instead.")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
