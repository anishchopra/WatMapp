//
//  Directions.swift
//  WatMapp
//
//  Created by Anish Chopra on 2015-07-28.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation

class PathComponent {
    var startNode : Vertex
    var endNode : Vertex
    var type : EdgeType
    
    init() {
        startNode = Vertex()
        endNode = Vertex()
        type = EdgeType.OutdoorWalkway
    }
}

func getPathComponents(path: Path) -> [PathComponent] {
    var components : [PathComponent] = []
    
    var prevType : EdgeType = path.edgeTypeToPath!
    var prevBuilding : Building? = path.destination as? Building
    
    var pc = PathComponent()
    pc.endNode = path.destination
    pc.type = prevType
    
    components.append(pc)
    
    var p = path.previous
    
    while (p != nil) {
        if (p.edgeTypeToPath == prevType &&
            (prevBuilding == nil && !(p.destination is Building) || prevBuilding != nil && !(p.destination is Building) || prevBuilding != nil &&  (p.destination as! Building).fullName == prevBuilding!.fullName)
            ) {
            p = p.previous
            continue
        }
        else {
            components[0].startNode = p!.destination
            if (p.previous != nil) {
                var newPC = PathComponent()
                newPC.endNode = p!.destination
                newPC.type = p!.edgeTypeToPath!
                components = [newPC] + components
                prevType = p.edgeTypeToPath!
            }
            if (p!.destination is Building) {
                prevBuilding = p!.destination as? Building
            }
        }
        p = p.previous
    }
    
    return components
}

func getDirections(path: Path) -> [String] {
    var directions : [String] = []
    
    let components = getPathComponents(path)
    
    for (var i = 0; i < components.count; i++) {
        let c = components[i]
        
        var action = ""
        
        if c.type == EdgeType.Bridge || c.type == EdgeType.OutdoorBridge {
            action = "Take the bridge "
        }
        else if c.type == EdgeType.Tunnel {
            action = "Take the tunnel "
        }
        else if c.type == EdgeType.IndoorWalkway {
            action = "Walk inside "
        }
        else {
            action = "Walk outside "
        }
        var direction = ""
        
        if c.startNode is Building && c.endNode is Building {
            if (c.startNode as! Building).fullName == (c.endNode as! Building).fullName {
                continue
            }
            direction = action + "from " + (c.startNode as! Building).abbreviation +
            " to " + (c.endNode as! Building).abbreviation
        }
        else if c.startNode is Building && !(c.endNode is Building) {
            var nextBuilding : Building!
            for (var j = i + 1; j < components.count; j++) {
                let comp = components[j]
                if comp.startNode is Building {
                    nextBuilding = comp.startNode as! Building
                    break
                }
                else if comp.endNode is Building {
                    nextBuilding = comp.endNode as! Building
                    break
                }
            }
            
            direction = action + "from " + (c.startNode as! Building).abbreviation +
            " towards "
            
            if (nextBuilding == nil) {
                direction += "your destination" // this shouldn't happen if the destination is a building
            }
            else {
                direction += nextBuilding.abbreviation
            }
        }
        else if !(c.startNode is Building) && c.endNode is Building {
            direction = action + "to " + (c.endNode as! Building).abbreviation
        }
        else {
            var nextBuilding : Building!
            for (var j = i + 1; j < components.count; j++) {
                let comp = components[j]
                if comp.startNode is Building {
                    nextBuilding = comp.startNode as! Building
                    break
                }
                else if comp.endNode is Building {
                    nextBuilding = comp.endNode as! Building
                    break
                }
            }
            
            if (nextBuilding == nil) {
                direction = action + "towards your destination"
            }
            else {
                direction = action + "towards " + nextBuilding.abbreviation
            }
        }
        
        directions.append(direction)
    }
    
    return directions
}

func printDirections(path: Path) {
    let directions = getDirections(path)
    
    for d in directions {
        println(d)
    }
}