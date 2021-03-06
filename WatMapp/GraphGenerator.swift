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

class GraphGenerator {
    var filePath : String
    var graph : Graph
    
    init(filePath : String) {
        self.filePath = filePath
        self.graph = Graph()
        self.graph = self.getGraph()
    }
    
    // Take the data from the plist and convert it to a Graph
    func getGraph() -> Graph{
        let properties = NSDictionary(contentsOfFile: self.filePath)
        
        var uniqueStrings : [String] = []
        
        let pathVertices = properties!["pathVertices"] as! NSArray
        let buildingVertices = properties!["buildingVertices"] as! NSArray
        let edges = properties!["edges"] as! NSArray
        let centres = properties!["buildingCentres"] as! NSArray
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
            if info.count == 4 {
                v.floorInfo = info[3] as? String
            }
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
                    println(typeString)
                    type = EdgeType.OutdoorWalkway
                
            }
            g.addEdge(v1!, target: v2!, type: type)
        }
        
        for bc in centres {
            let info = bc as! NSArray
            let location = (info[2] as! NSString).componentsSeparatedByString(",")
            let p = CLLocationCoordinate2D(latitude: location[0].doubleValue!, longitude: location[1].doubleValue!)
            var b : Building = Building(fullName: info[0] as! String, abbreviation: info[1] as! String, location: p)
            g.buildingCentres.insert(b)
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
                p1.previous = p2
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
                let a = PinOverlay(coordinate: v.location)
                mapView.addAnnotation(a)
            }
        }
    }
    
    // Draw every building entrance
    func drawBuildingEntrances(mapView : MKMapView) {
        for v in self.graph.canvas {
            if v is Building {
                let a = PinOverlay(coordinate: v.location, title: (v as! Building).abbreviation)
                mapView.addAnnotation(a)
            }
        }
    }
    
    func drawBuildingCentres(mapView : MKMapView) {
        for b in self.graph.buildingCentres {
            let a = PinOverlay(coordinate: b.location, title: b.abbreviation)
            mapView.addAnnotation(a)
        }
    }
    
    func drawIndoorEdges(mapView : MKMapView) {
        for v in self.graph.canvas {
            for e in v.neighbours {
                if e.isIndoors {
                    var p = Path(dest: v)
                    p.previous = Path(dest: e.neighbour)
                    var lineGenerator = PolyLineGenerator(path: p)
                    var lineOverlay = lineGenerator.createPolyLineOverlay()
                    
                    mapView.addOverlay(lineOverlay)
                }
            }
        }
    }
    
    func drawOutdoorEdges(mapView : MKMapView) {
        for v in self.graph.canvas {
            for e in v.neighbours {
                if e.isIndoors == false {
                    var p = Path(dest: v)
                    p.previous = Path(dest: e.neighbour)
                    var lineGenerator = PolyLineGenerator(path: p)
                    var lineOverlay = lineGenerator.createPolyLineOverlay()
                    
                    mapView.addOverlay(lineOverlay)
                }
            }
        }
    }
}