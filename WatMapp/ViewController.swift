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
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("Mode.plist")

        modeDictionary.writeToFile(path, atomically: false)
    }
}

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    var lineOverlay:MKOverlay? = nil
    
    @IBOutlet weak var stepsView: UIView!
    
    @IBOutlet weak var stepsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stepsTableView: UITableView!
    
    @IBOutlet weak var directionsButtonBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBoxHeightConstraint: NSLayoutConstraint!
    // This is the map view that is shown on Main.storyboard
    @IBOutlet weak var campusMapView: MKMapView!
    
    @IBOutlet weak var modeSelector: UIView!
    
    @IBOutlet weak var search: SearchBar!
    @IBOutlet weak var destination: SearchBar!
    var whichText: String = ""
    
    @IBOutlet weak var searchHolder: UIView!
    
    var searchHolderHeight: CGFloat = 0
    
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
    
    var currentSteps : [String] = []
    
    @IBOutlet weak var directionButton: CircleButton!
    
    var searching: Bool = false
    
    var gg = GraphGenerator(filePath: CAMPUS_PLIST_FILE_PATH!)
    
    // State variable tracks state of view
    // 0 = mapview
    // 1 = start search view
    // 2 = start selected
    // 3 = destination search view
    var state: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Map")

        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.campusMapView.delegate = self
        initializeMap(self.campusMapView)
        
        directionButton.alpha = 0.0
        directionButton.enabled = false
        
        stepsView.hidden = true
        stepsView.addBoxShadow()
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        stepsTableView.editing = false
        
        // SETUP SEARCHVIEW -- WILL BE HIDDEN AT START
        search.table.dataSource = self
        search.table.delegate = self
        // SETUP SearchBar
        searchHolder.addBoxShadow()
        search.buildings = Array(self.gg.graph.buildingCentres)
        searchHolderHeight = searchHolder.frame.height
        
        back.alpha = 0.0
        back.enabled = false
        
        // SETUP DESTINATION SEARCH VIEW AND SEARCH BAR
        destination.alpha = 0.0
        destination.userInteractionEnabled = false
        destination.table.dataSource = self
        destination.table.delegate = self
        destination.buildings = Array(self.gg.graph.buildingCentres)

        
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
    
    func removePins() {
        for p in self.campusMapView.annotations {
            if p is PinOverlay {
                self.campusMapView.removeAnnotation(p as! PinOverlay)
            }
        }
    }
    
    // This is needed for the MKMapViewDelegate protocol to add overlays to the map
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is OpenStreetTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        else if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor(red:63/255.0, green:81/255.0, blue:181/255.0, alpha:1.0)
            lineView.lineWidth = 1.5
            
            return lineView
        }
        
        return nil
    }

    
    // This is needed to add annotations to the map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !annotation.isEqual(self.campusMapView.userLocation){
            let identifier = "buildingPin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            view.image = UIImage(named: "pin")
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
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        // Get user locations
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        currentLocation = locationObj.coordinate
    }
    
    @IBAction func toCampusDown(sender: FindCampusButton) {
        // When button pressed reload map to user location
        sender.goToCampus(self.campusMapView)
        
        // Button shadow animation
        sender.touchDown()
    }
    
    @IBAction func backDown(sender: OptionsButton) {
        sender.touchDown()
        if whichText == "s" {
            search.hideSearchView()
            
            if (self.search.set) {
                UIView.animateWithDuration(0.2) {
                    self.view.layoutIfNeeded()
                    self.searchHolder.setHeight(2*self.searchHolderHeight, heightConstraint: self.searchBoxHeightConstraint)
                    self.searchBoxHeightConstraint.constant = 2*self.searchHolderHeight
                }
                self.destination.fadeIn(duration: 0.3, delay: 0.1)
                self.destination.userInteractionEnabled = true
                self.destination.endEditing(true)
                self.destination.hideSearchView()
            }
        }
        else {
            destination.hideSearchView()
        }
        sender.fadeOut(duration: 0.1)
        sender.enabled = false
        self.searching = false
    }
    
    @IBAction func directionsUp(sender: CircleButton) {
        // Button shadow animation
        sender.touchUp()
        
        if (stepsView.hidden) {
            directionsButtonBottomSpaceConstraint.constant += 100
            stepsView.frame.origin.y = UIScreen.mainScreen().bounds.height
            stepsView.hidden = false
            UIView.animateWithDuration(0.5, animations: {
                self.view.layoutIfNeeded()
            })
            let height = UIScreen.mainScreen().bounds.height - directionButton.frame.origin.y - directionButton.frame.height / 2
            stepsViewHeightConstraint.constant = height
        }
        else {
            UIView.animateWithDuration(0.5, animations: {
                self.directionButton.frame.origin.y += 100
                self.stepsView.frame.origin.y = UIScreen.mainScreen().bounds.height
                }, completion: { finished in
                    self.directionsButtonBottomSpaceConstraint.constant -= 100
                    self.stepsView.hidden = true
                    self.view.layoutIfNeeded()
                })
        }
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
        
        // clear search
        self.search.clear()

        self.destination.clear()
        self.destination.fadeOut(duration: 0.1)
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
            self.searchHolder.setHeight(self.searchHolderHeight, heightConstraint: self.searchBoxHeightConstraint)
        }
        self.destination.userInteractionEnabled = false
        
        
        self.directionButton.fadeOut(duration: 0.1)
        self.directionButton.enabled = true
        
        if (!self.stepsView.hidden) {
            self.directionsButtonBottomSpaceConstraint.constant -= 100;
            self.stepsView.hidden = true
        }
        
        self.campusMapView.removeOverlay(self.lineOverlay)
        
        if (self.whichText == "d" && self.searching == true) {
            self.whichText = "s"
            self.destination.table.alpha = 0.0
            self.destination.back.alpha = 0.0
            self.destination.table.userInteractionEnabled = false
            self.search.showSearchView()
        }
        
        
        removePins()
    }

    @IBAction func textDown(sender: SearchBar) {
        if ( sender.placeholder == "Search" ) {
            self.whichText = "s"
            self.destination.table.alpha = 0.0
            self.destination.back.alpha = 0.0
            self.destination.fadeOut(duration: 0.1)
            UIView.animateWithDuration(0.1) {
                self.view.layoutIfNeeded()
                self.searchHolder.setHeight(self.searchHolderHeight, heightConstraint: self.searchBoxHeightConstraint)
            }
            self.destination.userInteractionEnabled = false
        }
        else {
            whichText = "d"
            self.search.table.alpha = 0.0
            self.search.back.alpha = 0.0
        }
        
        self.modeSelector.hidden = true
        sender.showSearchView()
        
        self.findMe.enabled = false
        self.findCampus.enabled = false
        self.back.enabled = true
        self.back.fadeIn(duration: 0.2)
        self.searching = true
    }
    
    func setOptionTitleColour(buttons: Array<UIButton>, active: UIButton) {
        for button in buttons {
            button.setTitleColor(UIColor(red:33/255.0, green:33/255.0, blue:33/255.0, alpha:1.0), forState: UIControlState.Normal)
        }
        active.setTitleColor(UIColor(red:255/255.0, green:64/255.0, blue:129/255.0, alpha:1.0), forState: UIControlState.Normal)
    }
    
    func drawPath() {
        // Google Analytics: Update number of paths calculated
        let tracker = GAI.sharedInstance().defaultTracker
        var dict = GAIDictionaryBuilder.createEventWithCategory("WatMapp", action: "Calculated", label: "Route", value: 1).build()
        tracker.send(dict as [NSObject : AnyObject])
        
        // when the mode is changed remove the old path
        if self.lineOverlay != nil {
            self.campusMapView.removeOverlay(lineOverlay)
        }
        
        if (self.search.text == "" || self.destination.text == "") {
            return;
        }
        
        var start = self.search.selectedBuilding.abbreviation
        var end = self.destination.selectedBuilding.abbreviation
        
        if ( start != end && start != "" && end != "" ) {
            var p = self.gg.graph.bestPath(start, building2: end, mode: mode)
            self.currentSteps = getDirections(p!)
            var lineGenerator = PolyLineGenerator(path: p!)
            self.lineOverlay = lineGenerator.createPolyLineOverlay()
            
            self.campusMapView.addOverlay(self.lineOverlay)
            
            self.directionButton.fadeIn(duration: 0.2, delay: 0.25)
            self.directionButton.enabled = true
        }
        
        self.stepsTableView.reloadData()
        self.stepsTableView.setContentOffset(CGPointZero, animated: true)
    }
    
    // Stuff for tableview protocol -- needed to control search table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.isEqual(self.stepsTableView)) {
            return self.currentSteps.count
        }
        if whichText == "s" {
            return self.search.searchedBuildings.count
        }
        else {
            return self.destination.searchedBuildings.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView.isEqual(self.stepsTableView)) {
            let cell = tableView.dequeueReusableCellWithIdentifier("stepCell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel!.text = self.currentSteps[indexPath.row]
            cell.textLabel!.numberOfLines = 0
            
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("buildingCell", forIndexPath: indexPath) as! UITableViewCell
        
        if self.whichText == "s" {
            cell.textLabel!.text = self.search.searchedBuildings[advance(self.search.searchedBuildings.startIndex, indexPath.row)].fullName
        }
        else {
            cell.textLabel!.text = self.destination.searchedBuildings[advance(self.destination.searchedBuildings.startIndex, indexPath.row)].fullName
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView.isEqual(self.stepsTableView)) {
            return;
        }
        let indexPath = tableView.indexPathForSelectedRow()
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
        
        if self.whichText == "s" {
            self.search.text = currentCell!.textLabel!.text
            self.search.endEditing(true)
            self.search.hideSearchView()
            self.search.selectedBuilding = self.search.searchedBuildings[indexPath!.row]
            
            UIView.animateWithDuration(0.2) {
                self.view.layoutIfNeeded()
                self.searchHolder.setHeight(2*self.searchHolderHeight, heightConstraint: self.searchBoxHeightConstraint)
                self.searchBoxHeightConstraint.constant = 2*self.searchHolderHeight
            }
            self.destination.fadeIn(duration: 0.3, delay: 0.1)
            self.destination.userInteractionEnabled = true
            self.searching = false
        }
        else {
            self.destination.text = currentCell!.textLabel!.text
            self.destination.endEditing(true)
            self.destination.hideSearchView()
            self.destination.selectedBuilding = destination.searchedBuildings[indexPath!.row]
            self.searching = false
        }
        
        self.back.fadeOut(duration: 0.1)
        self.back.enabled = false
        
        self.drawPath()
        
        // activate map buttons
        self.findMe.enabled = true
        self.findCampus.enabled = true
        
        removePins()
        
        if self.search.text != "" {
            let pin = PinOverlay(buildingFullName: self.search.selectedBuilding.fullName, graph: self.gg.graph)
            self.campusMapView.addAnnotation(pin)
        }
        
        if (self.destination.text != "") {
            let pin = PinOverlay(buildingFullName: self.destination.selectedBuilding.fullName, graph: self.gg.graph)
            self.campusMapView.addAnnotation(pin)
        }
        
    }
    // End search table stuff
}

