//
//  Map Initialization.swift
//  WATMapp
//
//  Created on 2015-06-25.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class OpenStreetTileOverlay : MKTileOverlay {
    override func URLForTilePath(path: MKTileOverlayPath) -> NSURL! {
        let fileName = path.z.description + "," + path.x.description + "," + path.y.description
        let myFilePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "png")
        if  myFilePath != nil {
            return NSURL(fileURLWithPath: myFilePath!)
        }
        else {
            var url = "http://c.tile.openstreetmap.org/"+path.z.description + "/" + path.x.description + "/" + path.y.description + ".png"
            return NSURL(string: url)
        }
    }
}

func initializeMap(mapView : MKMapView) {
    // Set initial location to show entire campus
    let campusLocation = CLLocationCoordinate2D(latitude: CAMPUS_LATITUDE, longitude: CAMPUS_LONGITUDE)
    let span = MKCoordinateSpan(latitudeDelta: CAMPUS_LAT_DEL, longitudeDelta: CAMPUS_LONG_DEL)
    let region = MKCoordinateRegion(center: campusLocation, span: span)
    mapView.region = region
    
    // Use openstreetmap tiles instead of apple maps tiles
    let overlayPath = "http://c.tile.openstreetmap.org/{z}/{x}/{y}.png"
    let overlay = OpenStreetTileOverlay(URLTemplate: overlayPath)
    overlay.canReplaceMapContent = true // don't bother loading Apple Maps
    
    mapView.addOverlay(overlay)
}
