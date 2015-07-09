//
//  PathAnnotation.swift
//  WatMapp
//
//  Created on 2015-06-23.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import MapKit

class PolyLineGenerator {
    var path : Path
    
    init(path : Path) {
        self.path = path
    }
    
    // This will use "path" to return a map overlay which displays the path
    func createPolyLineOverlay() -> MKPolyline{
        var pointsToUse : [CLLocationCoordinate2D] = []
        
        var pathToDisplay : Path? = self.path
        
        while (pathToDisplay != nil) {
            pointsToUse.append(pathToDisplay!.destination.location)
            
            pathToDisplay = pathToDisplay?.next
        }
        
        let pathPolyLine = MKPolyline(coordinates: &pointsToUse, count: pointsToUse.count)
        
        return pathPolyLine
    }
}
