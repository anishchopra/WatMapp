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
class FindCampusButton : CircleButton
{
    func goToCampus(mapView : MKMapView) {
        // Set location to show entire campus
        //adjustMap(CLLocationCoordinate2D(latitude: CAMPUS_LATITUDE, longitude: CAMPUS_LONGITUDE), mapView)
        let center = CLLocationCoordinate2D(latitude: CAMPUS_LATITUDE, longitude: CAMPUS_LONGITUDE)
        let span = MKCoordinateSpan(latitudeDelta: CAMPUS_LAT_DEL, longitudeDelta: CAMPUS_LONG_DEL)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
}