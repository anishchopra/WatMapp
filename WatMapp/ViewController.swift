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

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    var lineOverlay:MKOverlay? = nil
    
    @IBOutlet weak var searchBoxHeightConstraint: NSLayoutConstraint!
    // This is the map view that is shown on Main.storyboard
    @IBOutlet weak var campusMapView: MKMapView!
    
    @IBOutlet weak var modeSelector: UIView!
    
    @IBOutlet weak var greyBack: UIView!
    
    @IBOutlet weak var search: SearchBar!
    @IBOutlet weak var destination: SearchBar!
    var whichText: String = ""
    
    @IBOutlet weak var searchHolder: UIView!
    
    @IBOutlet weak var searchTableBack: UIView!
    var searchHolderHeight: CGFloat = 0
    @IBOutlet var searchTable: UITableView!
    @IBOutlet weak var destTableBack: UIView!
    @IBOutlet var destTable: UITableView!
    
    // This should have been "modeButton"
    @IBOutlet weak var optionsButton: OptionsButton!
    // Should have been modes
    @IBOutlet var options: Array<UIButton> = []
    
    @IBOutlet weak var findCampus: FindCampusButton!
    @IBOutlet weak var findMe: FindMeButton!
    @IBOutlet weak var back: OptionsButton!
    // Location services manager, and variable to store user location
    var locationManager : CLLocationManager!
    var currentLocation : CLLocationCoordinate2D!
    
     @IBOutlet weak var directionButton: CircleButton!
    
    var gg = GraphGenerator(filePath: CAMPUS_PLIST_FILE_PATH!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.campusMapView.delegate = self
        initializeMap(self.campusMapView)
        
        directionButton.alpha = 0.0
        directionButton.enabled = false
        
        // SETUP SEARCHVIEW -- WILL BE HIDDEN AT START
        searchTableBack.addBoxShadow()
        greyBack.alpha = 0.0
        searchTable.alpha = 0.0
        searchTableBack.alpha = 0.0
        searchTable.dataSource = self
        searchTable.delegate = self
        searchTable.editing = false
        // SETUP SearchBar
        searchHolder.addBoxShadow()
        search.buildings = Array(self.gg.graph.buildingCentres)
        search.table = searchTable
        search.greyBack = greyBack
        search.back = searchTableBack
        searchHolderHeight = searchHolder.frame.height
        back.alpha = 0.0
        back.enabled = false
        
        // SETUP DESTINATION SEARCH VIEW AND SEARCH BAR
        destTableBack.addBoxShadow()
        destination.alpha = 0.0
        destination.userInteractionEnabled = false
        destination.greyBack = greyBack
        destTable.alpha = 0.0
        destTableBack.alpha = 0.0
        destTable.dataSource = self
        destTable.delegate = self
        destTable.editing = false
        destination.buildings = Array(self.gg.graph.buildingCentres)
        destination.table = destTable
        destination.back = destTableBack
        
        // SETUP MODE SELECTION VIEW - DEFAULTS TO VALUE IN Mode.pList
        modeSelector.hidden = true
        modeSelector.addBoxShadow()
        self.setOptionTitleColour(options, active: options[mode])
        
        // Sample route
        self.drawPath()
        
        // Setup location manager so we can show user locations on the map
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
            lineView.strokeColor = UIColor(red:63/255.0, green:81/255.0, blue:181/255.0, alpha:1.0)
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
                sender.goToUser(self.currentLocation, mapView: self.campusMapView)
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
        
        // For debug purposes, remove later
        //println("MV:\(campusMapView.userLocation)")
        //println(" \(currentLocation.latitude), \(currentLocation.longitude)")
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
    
    @IBAction func backUp(sender: OptionsButton) {
        // Button shadow animation
        sender.touchUp()
    }
    
    @IBAction func backDown(sender: OptionsButton) {
        sender.touchDown()
        if whichText == "s" {
            search.hideSearchView()
        }
        else {
            destination.hideSearchView()
        }
        sender.fadeOut(duration: 0.1)
        sender.enabled = false
        
    }
    
    
    @IBAction func directionsUp(sender: CircleButton) {
        // Button shadow animation
        sender.touchUp()
    }
    
    @IBAction func directionsDown(sender: CircleButton) {
        sender.touchDown()
    }
    
    @IBAction func optionsUp(sender: OptionsButton) {
        if !(sender is ClearButton) {
            self.modeSelector.hidden = !self.modeSelector.hidden
            sender.touchUp()
        }
    }
    
    @IBAction func mode1UpInside(sender: UIButton) {
        self.modeSelector.hidden = true
        setOptionTitleColour(options, active: sender)
        mode = 0
        self.drawPath()
    }
    
    @IBAction func mode2UpInside(sender: UIButton) {
        self.modeSelector.hidden = true
        self.setOptionTitleColour(options, active: sender)
        mode = 1
        self.drawPath()
    }
    
    @IBAction func mode3UpInside(sender: UIButton) {
        self.modeSelector.hidden = true
        self.setOptionTitleColour(options, active: sender)
        mode = 2
        self.drawPath()
    }
    
    @IBAction func clearDown(sender: ClearButton) {
        sender.touchDown()
        
        // Hide mode
        self.modeSelector.hidden = true
        
        // Go back to mapview
        self.search.hideSearchView()
        self.destination.hideSearchView()
        
        // clear search
        search.clear()
        
        // activate map buttons
        findMe.enabled = true
        findCampus.enabled = true
        
        destination.clear()
        destination.fadeOut(duration: 0.1)
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
            self.searchHolder.setHeight(self.searchHolderHeight, heightConstraint: self.searchBoxHeightConstraint)
        }
        destination.userInteractionEnabled = false
        
        directionButton.fadeOut(duration: 0.1)
        directionButton.enabled = true
        
    }
    
    @IBAction func clearUpInside(sender: ClearButton) {
        sender.touchUp()
    }
    
    @IBAction func textDown(sender: SearchBar) {
        if ( sender.placeholder == "Search" ) {
            whichText = "s"
            destTable.alpha = 0.0
            destTableBack.alpha = 0.0
            destination.fadeOut(duration: 0.1)
            UIView.animateWithDuration(0.1) {
                self.view.layoutIfNeeded()
                self.searchHolder.setHeight(self.searchHolderHeight, heightConstraint: self.searchBoxHeightConstraint)
            }
            destination.userInteractionEnabled = false
        }
        else {
            whichText = "d"
            searchTable.alpha = 0.0
            searchTableBack.alpha = 0.0
        }
        
        self.modeSelector.hidden = true
        sender.showSearchView()
        findMe.enabled = false
        findCampus.enabled = false
        back.enabled = true
        back.fadeIn(duration: 0.2)
    }
    
    func setOptionTitleColour(buttons: Array<UIButton>, active: UIButton) {
        for button in buttons {
            button.setTitleColor(UIColor(red:33/255.0, green:33/255.0, blue:33/255.0, alpha:1.0), forState: UIControlState.Normal)
        }
        active.setTitleColor(UIColor(red:255/255.0, green:64/255.0, blue:129/255.0, alpha:1.0), forState: UIControlState.Normal)
    }
    
    func drawPath() {
        // when the mode is changed remove the old path
        if lineOverlay != nil {
            self.campusMapView.removeOverlay(lineOverlay)
        }
        
        var start = search.selectedBuilding.abbreviation
        var end = destination.selectedBuilding.abbreviation
        
        if ( start != end && start != "" && end != "" ) {
            var p = gg.graph.bestPath(start, building2: end, mode: mode)
            printDirections(p!)
            var lineGenerator = PolyLineGenerator(path: p!)
            lineOverlay = lineGenerator.createPolyLineOverlay()
            
            self.campusMapView.addOverlay(lineOverlay)
            
            self.directionButton.fadeIn(duration: 0.2, delay: 0.25)
            self.directionButton.enabled = true
        }
    }
    
    // Stuff for tableview protocol -- needed to control search table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if whichText == "s" {
            return self.search.searchedBuildings.count
        }
        else {
            return self.destination.searchedBuildings.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("buildingCell", forIndexPath: indexPath) as! UITableViewCell
        
        if whichText == "s" {
            cell.textLabel!.text = self.search.searchedBuildings[advance(self.search.searchedBuildings.startIndex, indexPath.row)].fullName
        }
        else {
            cell.textLabel!.text = self.destination.searchedBuildings[advance(self.destination.searchedBuildings.startIndex, indexPath.row)].fullName
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow()
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
        
        if whichText == "s" {
            search.text = currentCell!.textLabel!.text
            search.endEditing(true)
            self.search.hideSearchView()
            search.selectedBuilding = search.searchedBuildings[indexPath!.row]
            
            UIView.animateWithDuration(0.2) {
                self.view.layoutIfNeeded()
                self.searchHolder.setHeight(2*self.searchHolderHeight, heightConstraint: self.searchBoxHeightConstraint)
                self.searchBoxHeightConstraint.constant = 2*self.searchHolderHeight
            }
            destination.fadeIn(duration: 0.3, delay: 0.1)
            destination.userInteractionEnabled = true
        }
        else {
            destination.text = currentCell!.textLabel!.text
            destination.endEditing(true)
            self.destination.hideSearchView()
            destination.selectedBuilding = destination.searchedBuildings[indexPath!.row]
        }
        
        back.fadeOut(duration: 0.1)
        back.enabled = false
        
        self.drawPath()
        
        // activate map buttons
        findMe.enabled = true
        findCampus.enabled = true
    }
    // End search table stuff
}

