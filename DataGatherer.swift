//
//  DataGatherer.swift
//  WatMapp
//
//  Created on 2015-06-25.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import UIKit
import MapKit

func saveData(dataPoints : [CLLocationCoordinate2D], filePath :  String) {
    let path = "/Users/Anish/Dropbox/iOS Applications/WatMapp/uWaterloo.plist"

    var properties = NSMutableDictionary(contentsOfFile: path)!
    
    for (var i=0; i < dataPoints.count; i++) {
        if (i == 0) {
            if (startWithBuilding) {
                var locationString = dataPoints[i].latitude.description + "," + dataPoints[i].longitude.description
                var plistBuildingVertex : Array = [startBuildingFullName, startBuildingShortName, locationString]
                var anyObj = plistBuildingVertex as AnyObject?!
                properties["buildingVertices"]!.addObject(plistBuildingVertex)
            }
            else {
                properties["pathVertices"]!.addObject(dataPoints[i].latitude.description + "," + dataPoints[i].longitude.description)
            }
        }
        else {
            if (i == dataPoints.count - 1) {
                if (endWithBuilding) {
                    var locationString = dataPoints[i].latitude.description + "," + dataPoints[i].longitude.description
                    var plistBuildingVertex : Array = [endBuildingFullName, endBuildingShortName, locationString]
                    properties["buildingVertices"]!.addObject(plistBuildingVertex)
                }
                else {
                    properties["pathVertices"]!.addObject(dataPoints[i].latitude.description + "," + dataPoints[i].longitude.description)
                }
            }
            else {
                properties["pathVertices"]!.addObject(dataPoints[i].latitude.description + "," + dataPoints[i].longitude.description)
            }
            var edgeData : [String] = []
            edgeData.append(dataPoints[i-1].latitude.description + "," + dataPoints[i-1].longitude.description)
            edgeData.append(dataPoints[i].latitude.description + "," + dataPoints[i].longitude.description)
            var edgeType : String
            switch (type) {
            case let x where x == EdgeType.IndoorWalkway:
                edgeType = "IndoorWalkway"
            case let x where x == EdgeType.Bridge:
                edgeType = "Bridge"
            case let x where x == EdgeType.OutdoorBridge:
                edgeType = "OutdoorBridge"
            case let x where x == EdgeType.Tunnel:
                edgeType = "Tunnel"
            default:
                edgeType = "OutdoorWalkway"
            }
            edgeData.append(edgeType)
            properties["edges"]!.addObject(edgeData)
        }
    }
    
    properties.writeToFile(path, atomically: false)
}