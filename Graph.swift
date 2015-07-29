//
//  Graph.swift
//  WatMapp
//
//  Created on 2015-06-21.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import MapKit

// This allows Vertex's to be comparable (needed for the Hashable protocol)
func ==(lhs: Vertex, rhs : Vertex) -> Bool{
    return (lhs.location.latitude == rhs.location.latitude
    && lhs.location.longitude == rhs.location.longitude)
}

class Vertex : Hashable {
    var location : CLLocationCoordinate2D // {latitude, longitude}
    var neighbours : Array<Edge>
    
    // This is needed for the Hashable protocol
    var hashValue : Int {
        get {
            return (location.latitude * 1000).hashValue ^ (location.longitude * 1000).hashValue
        }
    }
    
    init(location : CLLocationCoordinate2D) {
        self.location = location
        self.neighbours = []
    }
    
    init() {
        self.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.neighbours = []
    }
    
    // Returns the distance between self and v (basic Pythagorean theorem)
    func distance(v : Vertex) -> Double{
        let latDel = fabs(self.location.latitude - v.location.latitude)
        let longDel = fabs(self.location.longitude - v.location.longitude)
        return sqrt(pow(latDel, 2.0) + pow(longDel, 2.0))
    }
}

class Building : Vertex {
    var fullName : String
    var abbreviation : String
    
    init(fullName : String, abbreviation : String, location : CLLocationCoordinate2D) {
        self.fullName = fullName
        self.abbreviation = abbreviation
        super.init(location: location)
    }
}

enum EdgeType {
    case OutdoorWalkway
    case IndoorWalkway
    case Bridge
    case OutdoorBridge
    case Tunnel
}

class Edge {
    var weight : Double
    var neighbour : Vertex
    var isIndoors : Bool
    var type : EdgeType
    
    init(distance : Double, neighbour : Vertex, type : EdgeType = EdgeType.OutdoorWalkway) {
        self.weight = distance
        self.neighbour = neighbour
        self.isIndoors = type == EdgeType.OutdoorWalkway || type == EdgeType.OutdoorBridge ? false : true
        self.type = type
    }
}

class Graph {
    var canvas : Set<Vertex> // stores all vertices (which in turn, stores all edges)
    var buildingCentres : Set<Building> // stores the centres of every building
    
    init() {
        self.canvas = Set()
        self.buildingCentres = Set()
    }
    
    // Adds a vertex to the canvas
    func addVertex(v : Vertex) {
        self.canvas.insert(v)
    }
    
    // This will look for the source and target vertex in the canvas, and if found,
    // it will add an edge between those 2 vertices
    func addEdge(source : Vertex, target : Vertex, type : EdgeType) {
        var s = self.findVertex(source.location)
        var t = self.findVertex(target.location)
        
        if (s == nil || t == nil) {
            return
        }
        
        let edge = Edge(distance: s!.distance(t!), neighbour: t!, type: type)
        s!.neighbours.append(edge)
        
        
        // Every edge works in both directions
        let reverseEdge = Edge(distance: t!.distance(s!), neighbour: s!, type : type)
        t!.neighbours.append(reverseEdge)
    }
    
    // Returns the vertex from the canvas with the same coordinates as source
    func findVertex(source : CLLocationCoordinate2D) -> Vertex? {
        let v = Vertex(location: source)
        let index = self.canvas.indexOf(v)
        if (index == nil) {
            return nil
        }
        return self.canvas[index!]
    }
    
    /* 
    Returns the best path between 2 vertices. If the vertices are of the type Building,
    then it will return the best path between the 2 buildings, which means that the path
    can be created between any 2 entrances of the buildings (the algorithm will find the best
    2 entrances to use).
    */
    func bestPath(source : Vertex, target : Vertex, mode : Int) -> Path?{
        var visited : Set<Vertex> = Set()
        var frontier: PathHeap = PathHeap()
        var finalPaths: PathHeap = PathHeap()
        
        visited.insert(source)
        
        // Use source edges to create the frontier
        func addInitialValuesToFrontier(src: Vertex) {
            for e in src.neighbours {
                var newPath: Path = Path()
                newPath.destination = e.neighbour
                newPath.previous = Path(dest: src)
                if (mode == 1) {
                    newPath.total = e.weight * (e.isIndoors ? MODE1_SCALE_FACTOR : 1)
                }
                else if (mode == 2) {
                    newPath.total = e.weight * (e.isIndoors ? MODE2_SCALE_FACTOR : 1)
                }
                else {
                    newPath.total = e.weight
                }
                newPath.edgeTypeToPath = e.type
                //add the new path to the frontier
                frontier.enQueue(newPath)
            }
        }
        
        if (source is Building) {
            // make sure every building entrance is added to the frontier
            let name = (source as! Building).fullName
            
            for v in self.canvas {
                if (v is Building && (v as! Building).fullName == name) {
                    let vb = v as! Building
                    addInitialValuesToFrontier(vb)
                }
            }
            
        }
        else {
            addInitialValuesToFrontier(source)
        }
        
        // Construct the best path
        var bestPath: Path = Path()
        
        while(frontier.count != 0) {
            // Use the greedy approach to obtain the best path
            bestPath = Path()
            bestPath = frontier.peek()
            
            visited.insert(bestPath.destination)
            
            // Remove the bestPath from the frontier
            frontier.deQueue()
            
            // Preserve the bestPaths that match destination
            if (bestPath.destination == target || (bestPath.destination is Building && target is Building && (bestPath.destination as! Building).fullName == (target as! Building).fullName)) {
                finalPaths.enQueue(bestPath)
                break
            }
            
            // Enumerate the bestPath edges
            for e in bestPath.destination.neighbours {
                if (!visited.contains(e.neighbour) && e.neighbour != bestPath.destination) {
                    var newPath: Path = Path()
                    newPath.destination = e.neighbour
                    newPath.previous = bestPath
                    if (mode == 1) {
                        newPath.total = bestPath.total + (e.isIndoors ? e.weight * MODE1_SCALE_FACTOR : 1)
                    }
                    else if (mode == 2) {
                        newPath.total = bestPath.total + (e.isIndoors ? e.weight * MODE2_SCALE_FACTOR : 1)
                    }
                    else {
                        newPath.total = bestPath.total + e.weight
                    }
                    newPath.edgeTypeToPath = e.type
                    
                    // Add the new path to the frontier
                    frontier.enQueue(newPath)
                }
            }
        }
        
        // Obtain the shortest path from the heap
        var shortestPath: Path! = Path()
        shortestPath = finalPaths.peek()
        return shortestPath
    }
    
    // This takes in the abbreviation of 2 buildings and returns the best path by calling 
    // the other bestPath function
    func bestPath(building1 : String, building2 : String, mode : Int) -> Path?{
        var b1 : Vertex?
        var b2 : Vertex?
        
        for v in self.canvas {
            if v is Building {
                if (v as! Building).abbreviation == building1 {
                    b1 = v
                }
                if (v as! Building).abbreviation == building2 {
                    b2 = v
                }
            }
        }
        
        if b1 == nil || b2 == nil {
            return nil
        }
        
        return self.bestPath(b1!, target: b2!, mode: mode)
    }
}

class Path {
    var total: Double!
    var destination: Vertex
    var previous: Path!
    var edgeTypeToPath : EdgeType!

    init() {
        destination = Vertex()
    }
    
    init(dest: Vertex) {
        destination = dest
    }
}

