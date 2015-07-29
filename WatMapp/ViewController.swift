//
//  ViewController.swift
//  WatMapp
//
//  Created on 2015-06-21.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import UIKit
import MapKit

var mode : Int {
    get {
        //var modeDictionary = NSDictionary(contentsOfFile: MODE_PLIST_FILE_PATH!)
        //return (modeDictionary!["Mode"] as! String).toInt()!
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("Mode.plist")
        var fileManager = NSFileManager.defaultManager()
        if (!(fileManager.fileExistsAtPath(path)))
        {
            var bundle : NSString = NSBundle.mainBundle().pathForResource("Mode", ofType: "plist")!
            fileManager.copyItemAtPath(bundle as String, toPath: path, error:nil)
        }
        
        let modeDictionary = NSDictionary(contentsOfFile: path)
        return (modeDictionary!["Mode"] as! String).toInt()!
    }
    set (value) {
        var modeDictionary : NSDictionary = ["Mode" : value.description]
        //modeDictionary.writeToFile(MODE_PLIST_FILE_PATH!, atomically: false)
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("Mode.plist")

        modeDictionary.writeToFile(path, atomically: false)
    }
}

class ViewController: UIViewController, MKMapViewDelegate {
    
    // This is the map view that is shown on Main.storyboard
    @IBOutlet weak var campusMapView: MKMapView!
    
    @IBOutlet weak var modeSelector: UIView!
    
    @IBOutlet weak var optionsButton: OptionsButton!
    // Location services manager, and variable to store user location
    var locationManager : CLLocationManager!
    var currentLocation : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.campusMapView.delegate = self
        initializeMap(self.campusMapView)
        
        modeSelector.hidden = true
        modeSelector.layer.shadowColor = UIColor(red:0, green:0,blue:0,alpha:1.0).CGColor;
        modeSelector.layer.shadowOpacity = 0.5;
        modeSelector.layer.shadowRadius = 2;
        modeSelector.layer.shadowOffset = CGSizeMake(0, 1.5);
        
        var gg = GraphGenerator(filePath: CAMPUS_PLIST_FILE_PATH!)
        //gg.drawFullGraph(self.campusMapView)
        
        // Sample route
        var p = gg.graph.bestPath("UWP", building2: "PAC", mode: mode)
        printDirections(p!)
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
        sender.touchDown()
    }
    
    @IBAction func optionsUp(sender: OptionsButton) {
        if !(sender is ClearButton) {
            self.modeSelector.hidden = !self.modeSelector.hidden
            sender.touchUp()
        }
    }
    
    @IBAction func mode1Down(sender: UIButton) {
    }
    
    @IBAction func mode1UpInside(sender: UIButton) {
        self.modeSelector.hidden = true
        mode = 0
    }
    
    @IBAction func mode1UpOutside(sender: UIButton) {
    }
    
    @IBAction func mode2Down(sender: UIButton) {
    }
    
    @IBAction func mode2UpInside(sender: UIButton) {
        self.modeSelector.hidden = true
        mode = 1
    }
    
    @IBAction func mode3Down(sender: UIButton) {
    }
    
    @IBAction func mode3UpInside(sender: UIButton) {
        self.modeSelector.hidden = true
        mode = 2
    }
    
    @IBAction func clearDown(sender: ClearButton) {
        sender.touchDown()
    }
    
    @IBAction func clearUpInside(sender: ClearButton) {
        sender.touchUp()
    }
    
    @IBAction func textDown(sender: TextBox) {
        performSegueWithIdentifier("search", sender: sender)
    }
}

