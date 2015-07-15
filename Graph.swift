//
//  Graph.swift
//  WatMapp
//
//  Created on 2015-06-21.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import MapKit

let INDOOR_PATH_WEIGHT_SCALE_FACTOR = 0.5

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
    2 entrances to use)
    */
    func bestPath(source : Vertex, target : Vertex, indoors : Bool) -> Path?{
        var weight = [Vertex : Double]() // weight[v] is the total weight from source to v
        var prev = [Vertex : Vertex?]() // prev[v] is the Vertex in the path before v
        var unvisited = Set<Vertex>() // the set of all Vertex's not visited by the algorithm
        
        // Set the total weight for each node from the source to infinity (except for the source, which is 0)
        // Also insert every node into the unvisited set
        for v in self.canvas {
            if (v == source || (v is Building && source is Building && (v as! Building).fullName == (source as! Building).fullName)) {
                weight[v] = 0
            }
            else {
                weight[v] = -1 // to represent infinity
            }
            prev[v] = nil
            unvisited.insert(v)
        }
        
        while unvisited.count != 0 {
            var u : Vertex = source // I have to set this to something
            var minDist : Double = -1
            
            // Set Vertex u to some node v with the minimum weight[v]
            // This will be set to the source Vertex for the first iteration
            for v in unvisited {
                if weight[v] >= 0 {
                    if ((minDist == -1) || (weight[v] < minDist)) {
                        minDist = weight[v]!
                        u = v // this is guaranteed to happen at least once
                    }
                }
            }
            
            // If the target node has been found, return the shortest path
            if (u == target || (u is Building && target is Building && (u as! Building).fullName == (target as! Building).fullName))
            {
                var p = Path(dest: u)
                var total = weight[u]!
                while (prev[u] != nil) {
                    u = (prev[u])!!
                    var newP : Path = Path(dest: u)
                    newP.next = p
                    
                    p = newP
                }
                p.total = total
                return p
            }
            
            unvisited.remove(u)
            
            // Set weight[v] and prev[v] for every neighbour v of u
            for e in u.neighbours {
                if (unvisited.contains(e.neighbour)) {
                    var alt : Double = Double()
                    alt = weight[u]!
                    if !e.isIndoors || !indoors {
                        alt += e.weight
                    }
                    else {
                        alt += e.weight * INDOOR_PATH_WEIGHT_SCALE_FACTOR
                    }
                    
                    if (weight[e.neighbour] == -1 || alt < weight[e.neighbour]) {
                        weight[e.neighbour] = alt
                        prev[e.neighbour] = u
                    }
                }
            }
        }
        
        // If the target node cannot be found, return nil
        return nil
        
    }
    
    // This takes in the abbreviation of 2 buildings and returns the best path by calling 
    // the other bestPath function
    func bestPath(building1 : String, building2 : String, isIndoors : Bool) -> Path?{
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
        
        return self.bestPath(b1!, target: b2!, indoors: isIndoors)
    }
}

// A Path is a linked list, and each Path structure contains a Vertex
class Path {
    var total : Double
    var destination : Vertex
    var next : Path!
    
    init(dest : Vertex) {
        self.total = 0
        self.destination = dest
    }
    
}

