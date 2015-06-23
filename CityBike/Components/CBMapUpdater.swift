//
//  CBMapUpdater.swift
//  CityBike
//
//  Created by Tomasz Szulc on 14/06/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CBModel

struct CBStationProxy {
    var id: StationID
    var timestamp: NSDate
    var coordinate: CLLocationCoordinate2D
}

protocol CBMapUpdaterProtocol {
    func update(station: CDStation)
}

class CBMapUpdater {
    private var annotationViews = [CBStationAnnotationView]()
    private var stationProxies = [CBStationProxy]()
    
    func viewForAnnotation(annotation: CBAnnotation) -> CBStationAnnotationView {
        var view = annotationViews.filter({($0.annotation as? CBAnnotation)?.stationProxy.id == annotation.stationProxy.id}).first
        if view == nil {
            view = CBStationAnnotationView(annotation: annotation, reuseIdentifier: "CBStationAnnotationView")
            annotationViews.append(view!)
        }
        return view!
    }
    
    func update(map: MKMapView, updatedStations: [CDStation]) {
        let currentStationProxies = stationProxies
        var currentAnnotations = map.annotations
        var currentAnnotationViews = annotationViews

        /// Separate new, updated and not updated proxies
        var newProxies = [CBStationProxy]()
        var updatedProxies = [CBStationProxy]()
        var notUpdatedProxies = [CBStationProxy]()

        for station in updatedStations {
            if let stationProxy = currentStationProxies.filter({$0.id == station.id}).first {
                if stationProxy.timestamp != station.timestamp {
//                    println("UPDATE: \(station.name), \(station.timestamp) > \(stationProxy.timestamp)")
                    let updatedStationProxy = CBStationProxy(id: station.id, timestamp: station.timestamp, coordinate: station.coordinate)
                    updatedProxies.append(updatedStationProxy)
                } else {
//                    println("NOT: \(station.name), \(station.timestamp) > \(stationProxy.timestamp)")
                    notUpdatedProxies.append(stationProxy)
                }

            } else {
                let stationProxy = CBStationProxy(id: station.id, timestamp: station.timestamp, coordinate: station.coordinate)
//                println("NEW: \(station.name), \(station.timestamp) > \(stationProxy.timestamp)")
                newProxies.append(stationProxy)
            }
        }
        
        /// All currently available proxies
        let allProxies = newProxies + updatedProxies + notUpdatedProxies
        
        /// Remove not available annotations
        var annotationsToRemove = [CBAnnotation]()
        for annotation in currentAnnotations {
            if let annotation = annotation as? CBAnnotation where allProxies.filter({$0.id == annotation.stationProxy.id}).first == nil {
                annotationsToRemove.append(annotation)
                
                /// Remove annotation from map array
                for idx in 0 ..< currentAnnotations.count {
                    if currentAnnotations[idx] is CBAnnotation {
                        currentAnnotations.removeAtIndex(idx)
                        break
                    }
                }
                
                /// Remove old annotation views
                for idx in 0 ..< currentAnnotationViews.count {
                    if (currentAnnotationViews[idx].annotation as! CBAnnotation).stationProxy.id == annotation.stationProxy.id {
                        currentAnnotationViews.removeAtIndex(idx)
                        break
                    }
                }
            }
        }
        
        /// Add new annotations
        var annotationsToAdd = [CBAnnotation]()
        for proxy in newProxies {
            annotationsToAdd.append(CBAnnotation(stationProxy: proxy))
        }
        
        stationProxies = allProxies
        annotationViews = currentAnnotationViews
        map.removeAnnotations(annotationsToRemove)
        map.addAnnotations(annotationsToAdd)
        
        /// Update existing annotations
        for updatedProxy in updatedProxies {
            if let annView = self.annotationViews.filter({
                return ($0.annotation as? CBAnnotation)?.stationProxy.id == updatedProxy.id
            }).first {
                let station = updatedStations.filter({$0.id == (annView.annotation as! CBAnnotation).stationProxy.id}).first!
                annView.update(station)
            }
        }
        
        println("-------------------------------------------")
    }
}
