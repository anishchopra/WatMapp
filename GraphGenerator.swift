//
//  GraphGenerator.swift
//  WatMapp
//
//  Created on 2015-06-24.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// An annotation is just a pin on a map
class Annotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    init(coordinate : CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = ""
        self.subtitle = ""
        super.init()
    }
    
    init(coordinate : CLLocationCoordinate2D, title : String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = ""
        super.init()
    }
}

class GraphGenerator {
    var fileName : String
    var graph : Graph
    
    init(fileName : String) {
        self.fileName = fileName
        self.graph = Graph()
        self.graph = self.getGraph()
    }
    
    // Take the data from the plist and convert it to a Graph
    func getGraph() -> Graph{
        let filePath = NSBundle.mainBundle().pathForResource(self.fileName, ofType: "plist")
        let path = "/Users/Anish/Dropbox/iOS Applications/WatMapp/uWaterloo.plist"
        let properties = NSDictionary(contentsOfFile: filePath!)
        
        let pathVertices = properties!["pathVertices"] as! NSArray
        let buildingVertices = properties!["buildingVertices"] as! NSArray
        let edges = properties!["edges"] as! NSArray
        var g = Graph()
        
        for pv in pathVertices {
            let location = (pv as! NSString).componentsSeparatedByString(",")
            let p = CLLocationCoordinate2D(latitude: location[0].doubleValue!, longitude: location[1].doubleValue!)
            let v = Vertex(location: p)
            g.addVertex(v)
        }
        
        for bv in buildingVertices {
            let info = bv as! NSArray
            let fullName = info[0] as! String
            let shortName = info[1] as! String
            let location = (info[2] as! NSString).componentsSeparatedByString(",")
            let p = CLLocationCoordinate2D(latitude: location[0].doubleValue!, longitude: location[1].doubleValue!)
            let v = Building(fullName: fullName, abbreviation: shortName, location: p)
            g.addVertex(v)
            
        }
        
        for e in edges {
            let info = e as! NSArray
            let location1 = (info[0] as! NSString).componentsSeparatedByString(",")
            let p1 = CLLocationCoordinate2D(latitude: location1[0].doubleValue!, longitude: location1[1].doubleValue!)
            let location2 = (info[1] as! NSString).componentsSeparatedByString(",")
            let p2 = CLLocationCoordinate2D(latitude: location2[0].doubleValue!, longitude: location2[1].doubleValue!)
            var v1 = g.findVertex(p1)
            var v2 = g.findVertex(p2)
            
            if (v1 == nil) {
                println(p1.latitude.description + "," + p1.longitude.description)
            }
            if (v2 == nil) {
                println(p2.latitude.description + "," + p2.longitude.description)
            }
            let typeString = info[2] as! String
            var type : EdgeType
            switch(typeString) {
                case let x where x == "OutdoorWalkway":
                    type = EdgeType.OutdoorWalkway
                case let x where x == "IndoorWalkway":
                    type = EdgeType.IndoorWalkway
                case let x where x == "Bridge":
                    type = EdgeType.Bridge
                case let x where x == "OutdoorBridge":
                    type = EdgeType.OutdoorBridge
                case let x where x == "Tunnel":
                    type = EdgeType.Tunnel
                default:
                    type = EdgeType.OutdoorWalkway
                
            }
            g.addEdge(v1!, target: v2!, type: type)
        }
        
        return g
        
    }
    
    // The following three functions are for development purposes only:
    
    // Draw every vertex and edge from the graph. This is simply for development purposes.
    func drawFullGraph(mapView : MKMapView) {
        for v in self.graph.canvas {
            for e in v.neighbours {
                let p1 = Path(dest: v)
                let p2 = Path(dest: e.neighbour)
                p1.next = p2
                let plg = PolyLineGenerator(path: p1)
                let plgOverlay = plg.createPolyLineOverlay()
                mapView.addOverlay(plgOverlay)
            }
        }
    }
    
    // Draw every vertex that isn't connected to anything or is connected to only 1 vertex (aka dead end)
    func drawLooseEnds(mapView : MKMapView) {
        for v in self.graph.canvas {
            if (v.neighbours.count == 0 || v.neighbours.count == 1) && !(v is Building) {
                let a = Annotation(coordinate: v.location)
                mapView.addAnnotation(a)
            }
        }
    }
    
    // Draw every building entrance
    func drawBuildingEntrances(mapView : MKMapView) {
        for v in self.graph.canvas {
            if v is Building {
                let a = Annotation(coordinate: v.location, title: (v as! Building).abbreviation)
                mapView.addAnnotation(a)
            }
        }
    }
}