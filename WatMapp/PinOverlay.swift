//
//  PinOverlay.swift
//  WatMapp
//
//  Created by Anish Chopra on 2015-08-15.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation
import UIKit
import MapKit

func getBuilding(buildingFullName: String, graph: Graph) -> Building!{
    for bc in graph.buildingCentres {
        if bc.fullName == buildingFullName {
            return bc
        }
    }
    
    return nil
}

class PinOverlay : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    init(buildingFullName: String, graph: Graph) {
        let b = getBuilding(buildingFullName, graph)
        self.coordinate = b.location
        self.title = b.fullName
        self.subtitle = b.abbreviation
    }
}

