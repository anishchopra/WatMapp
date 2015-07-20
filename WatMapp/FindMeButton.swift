//
//  FindMeButton.swift
//  WATIsRain
//
//  Created by Dulwin Jayalath on 2015-06-28.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import MapKit

@IBDesignable
class FindMeButton : CircleButton
{
    var centered: Bool! = false {
        didSet {
            self.updateColor();
        }
    }
    
    func updateColor() {
        if centered == true {
            icon.fillColor = iconColour.CGColor
        } else {
            icon.fillColor = inactiveColour.CGColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createLayersIfNeeded()
        updateLayerProperties()
    }
    
    func goToUser(userLocation : CLLocationCoordinate2D, mapView : MKMapView) {
        // Set location to show users current location
        if ( self.onCampus(userLocation) ) {
            adjustMap(userLocation, mapView, latDel: 0.01, longDel: 0.01)
            self.centered = true
        }
    }
    
    func onCampus( location : CLLocationCoordinate2D) -> Bool {
        return (location.latitude <= CAMPUS_LATITUDE+CAMPUS_LAT_DEL
            && location.latitude >= CAMPUS_LATITUDE-CAMPUS_LAT_DEL
            && location.longitude <= CAMPUS_LONGITUDE+CAMPUS_LONG_DEL
            && location.longitude >= CAMPUS_LONGITUDE-CAMPUS_LONG_DEL)
    }
}