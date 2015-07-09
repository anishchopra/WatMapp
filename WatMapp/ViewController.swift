//
//  ViewController.swift
//  WatMapp
//
//  Created on 2015-06-21.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import UIKit
import MapKit

// These are the coordinates that the map is initially centered on when the app first opens
let CAMPUS_LATITUDE = 43.472285
let CAMPUS_LONGITUDE = -80.544858

// These specify the zoom of the map on startup
let CAMPUS_LAT_DEL = 0.025
let CAMPUS_LONG_DEL = 0.025

// This is the plist where all of the map data is stored
let PLIST_FILE_NAME = "uWaterloo"

var dataPoints : [CLLocationCoordinate2D] = []

// These are needed for the data gathering tool
let type = EdgeType.OutdoorWalkway
let startWithBuilding = true
let endWithBuilding = false
let startBuildingFullName = "Environment 2"
let startBuildingShortName = "EV2"
let endBuildingFullName = "Environment 3"
let endBuildingShortName = "EV3"

class ViewController: UIViewController, MKMapViewDelegate {
    
    // This is the map view that is shows on Main.storyboard
    @IBOutlet weak var campusMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.campusMapView.delegate = self
        initializeMap(self.campusMapView)
        
        var gg = GraphGenerator(fileName: PLIST_FILE_NAME)
        gg.drawFullGraph(campusMapView)
        //gg.drawLooseEnds(campusMapView)
        //gg.drawBuildingEntrances(campusMapView)
        
        /* Sample route
        var p = gg.graph.bestPath("AL", building2: "V1", isIndoors: true)
        var lineGenerator = PolyLineGenerator(path: p!)
        var lineOverlay = lineGenerator.createPolyLineOverlay()
        self.campusMapView.addOverlay(lineOverlay) */
        
        /* Only uncomment this if you are adding points to the map. PLEASE TALK TO ANISH BEFORE
        DOING THIS!!! There are lots of things that can go wrong if you don't use this tool
        EXACTLY the way you're supposed to. I didn't exactly have time to make it user friendly.*/
        
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        recognizer.numberOfTapsRequired = 1
        self.campusMapView.addGestureRecognizer(recognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is needed for the MKMapViewDelegate protocol to add overlays to the map
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is OpenStreetTileOverlay {
            
            return MKTileOverlayRenderer(overlay: overlay)
        }
        else if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.blueColor()
            lineView.lineWidth = 1
            
            return lineView
        }
        return nil
    }
    
    // This is needed to add annotations to the map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? Annotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    // The following functions are needed for the data gathering tool:
    
    // This is the tap gesture recognizer that temporarily stores the point you just touched
    func handleTap(recognizer : UITapGestureRecognizer) {
        let touchLocation = recognizer.locationInView(self.campusMapView)
        var locationCoordinate : CLLocationCoordinate2D = self.campusMapView.convertPoint(touchLocation, toCoordinateFromView: self.campusMapView)
        //println(locationCoordinate.latitude.description)
        for v in GraphGenerator(fileName: PLIST_FILE_NAME).graph.canvas {
            if fabs(locationCoordinate.latitude - v.location.latitude) <= 0.000009 && fabs(locationCoordinate.longitude - v.location.longitude) < 0.000009 {
                locationCoordinate = v.location
                println("SAME POINT USED")
                println(locationCoordinate.latitude.description)
                println(locationCoordinate.longitude.description)
            }
        }
        
        for v in dataPoints {
            if fabs(locationCoordinate.latitude - v.latitude) <= 0.000009 && fabs(locationCoordinate.longitude - v.longitude) < 0.000009 {
                locationCoordinate = v
                println("SAME POINT USED")
                println(locationCoordinate.latitude.description)
                println(locationCoordinate.longitude.description)
            }
        }
        
        if dataPoints.count != 0 {
            var v1 = Vertex(location: dataPoints[dataPoints.count-1])
            var v2 = Vertex(location: locationCoordinate)
            var p1 = Path(dest: v1)
            var p2 = Path(dest: v2)
            p1.next = p2
            let plg = PolyLineGenerator(path: p1)
            let overlay = plg.createPolyLineOverlay()
            campusMapView.addOverlay(overlay)
        }
        
        dataPoints.append(locationCoordinate)
    }
    
    // This is needed to allow detection of shaking (for the data gathering tool)
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Shaking stops creating the path you were just building and saves it to the plist
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        var overlays : Array<AnyObject!> = Array<AnyObject!>()
        for o in self.campusMapView.overlays {
            if (o is MKPolyline) {
                overlays.append(o)
            }
        }
        self.campusMapView.removeOverlays(overlays)
        
        let filePath = NSBundle.mainBundle().pathForResource(PLIST_FILE_NAME, ofType: "plist")
        
        saveData(dataPoints, filePath!)
        
        dataPoints = []
        
        var generator = GraphGenerator(fileName: "uWaterloo")
        generator.drawFullGraph(self.campusMapView)
    }
    
    
}

