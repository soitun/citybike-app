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


struct CBStationProxy {
    var id: String
    var timestamp: String
    var coordinate: CLLocationCoordinate2D
}

protocol CBMapUpdaterProtocol {
    func update(station: CDStation)
}

class CBMapUpdater {
    private var annotationViews = [CBStationAnnotationView]()
    private var stationProxies = [CBStationProxy]()
    
    func viewForAnnotation(annotation: CBAnnotation) -> CBStationAnnotationView {
        for annotationView in self.annotationViews {
            if let cbAnnotation = (annotationView.annotation as? CBAnnotation) {
                if cbAnnotation.stationProxy.id == annotation.stationProxy.id {
                    return annotationView
                }
            }
        }
        
        let view = CBStationAnnotationView(annotation: annotation, reuseIdentifier: "CBStationAnnotationView")
        self.annotationViews.append(view)
        return view
    }
    
    
    func update(map: MKMapView, updatedStations: [CDStation]) {
        let currentStationProxies = self.stationProxies
        var currentAnnotations = map.annotations
        var currentAnnotationViews = self.annotationViews

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
            if let annotation = annotation as? CBAnnotation {
                if allProxies.filter({$0.id == annotation.stationProxy.id}).first == nil {
                    annotationsToRemove.append(annotation)
                    
                    /// Remove annotation from map array
                    var idx = 0
                    for onMapAnnotation in currentAnnotations {
                        if onMapAnnotation is CBAnnotation {
                            currentAnnotations.removeAtIndex(idx)
                            break
                        }
                        
                        idx++
                    }
                    
                    /// Remove old annotation views
                    idx = 0
                    for view in currentAnnotationViews {
                        if (view.annotation as! CBAnnotation).stationProxy.id == annotation.stationProxy.id {
                            currentAnnotationViews.removeAtIndex(idx)
                            break
                        }
                        
                        idx++;
                    }
                }
            }
        }
        
        /// Add new annotations
        var annotationsToAdd = [CBAnnotation]()
        for proxy in newProxies {
            annotationsToAdd.append(CBAnnotation(stationProxy: proxy))
        }
        
        
        self.stationProxies = allProxies
        self.annotationViews = currentAnnotationViews
        map.removeAnnotations(annotationsToRemove)
        map.addAnnotations(annotationsToAdd)
        
        /// Update existing annotations
        for updatedProxy in updatedProxies {
            if let annotationView = self.annotationViews.filter({
                if let annotation = ($0.annotation as? CBAnnotation) {
                    return annotation.stationProxy.id == updatedProxy.id
                }
                
                return false
            }).first {
                let station = updatedStations.filter({$0.id == (annotationView.annotation as! CBAnnotation).stationProxy.id}).first!
                annotationView.update(station)
            }
        }
        
        println("-------------------------------------------")
    }
}
