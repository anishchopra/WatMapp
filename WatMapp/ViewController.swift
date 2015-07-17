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
let PLIST_FILE_PATH = NSBundle.mainBundle().pathForResource(PLIST_FILE_NAME, ofType: "plist")

class ViewController: UIViewController, MKMapViewDelegate {
    
    // This is the map view that is shows on Main.storyboard
    @IBOutlet weak var campusMapView: MKMapView!
    
    // Location services manager, and variable to store user location
    var locationManager : CLLocationManager!
    var currentLocation : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.campusMapView.delegate = self
        initializeMap(self.campusMapView)

        var gg = GraphGenerator(filePath: PLIST_FILE_PATH!)
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
    
    @IBAction func findMeDown(sender: FindMeButton) {
        // When button pressed reload map to user location
        if self.currentLocation != nil {
            if sender.onCampus(self.currentLocation) {
                sender.goToUser(self.currentLocation, mapView : self.campusMapView)
            }
            else {
                let alertController = UIAlertController(title: "",
                    message: "It appears as though you are off campus.",
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else {
            let alertController = UIAlertController(title: "",
                message: "We can't seem to find your location, please make sure location services is on!",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        // Button shadow animation
        sender.touchDown()
    }
    
    @IBAction func findMeUp(sender: FindMeButton) {
        // Button shadow animation
        sender.touchUp()
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        // Get user locations
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        currentLocation = locationObj.coordinate
        
        println("MV:\(campusMapView.userLocation)")
        
        // For debug purposes, remove later
        println(" \(currentLocation.latitude), \(currentLocation.longitude)")
    }
    
    @IBAction func toCampusDown(sender: FindCampusButton) {
        // When button pressed reload map to user location
        sender.goToCampus(self.campusMapView)
        
        // Button shadow animation
        sender.touchDown()
    }
    
    @IBAction func toCampusUp(sender: FindCampusButton) {
        // Button shadow animation
        sender.touchUp()
    }
    
    @IBAction func optionsDown(sender: OptionsButton) {
        // Button shadow animation
        sender.touchDown()
    }
    
    @IBAction func optionsUp(sender: OptionsButton) {
        // Button shadow animation
        sender.touchUp()
    }
    
    @IBAction func textDown(sender: TextBox) {
        performSegueWithIdentifier("search", sender: sender)
    }
}

