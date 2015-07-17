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

class ViewController: UIViewController, MKMapViewDelegate {
    
    // This is the map view that is shows on Main.storyboard
    @IBOutlet weak var campusMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.campusMapView.delegate = self
        initializeMap(self.campusMapView)

        var gg = GraphGenerator(fileName: PLIST_FILE_NAME)
        gg.drawFullGraph(self.campusMapView);
        
        // Sample route
        var p = gg.graph.bestPath("DWE", building2: "PAC", isIndoors: false)
        var lineGenerator = PolyLineGenerator(path: p!)
        var lineOverlay = lineGenerator.createPolyLineOverlay()
        self.campusMapView.addOverlay(lineOverlay) 
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
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
}

