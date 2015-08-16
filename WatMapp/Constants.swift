//
//  Constants.swift
//  WatMapp
//
//  Created by Anish Chopra on 2015-07-28.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation

// These are the coordinates that the map is initially centered on when the app first opens
let CAMPUS_LATITUDE = 43.4694856982904
let CAMPUS_LONGITUDE = -80.5478283333902

// These specify the zoom of the map on startup
let CAMPUS_LAT_DEL = 0.020
let CAMPUS_LONG_DEL = 0.020

// This is the plist where all of the map data is stored
let CAMPUS_PLIST_FILE_NAME = "uWaterloo"
let CAMPUS_PLIST_FILE_PATH = NSBundle.mainBundle().pathForResource(CAMPUS_PLIST_FILE_NAME, ofType: "plist")

// This is the plist where the user's preferred mode is chosen
let MODE_PLIST_FILE_NAME = "Mode"
let MODE_PLIST_FILE_PATH = NSBundle.mainBundle().pathForResource(MODE_PLIST_FILE_NAME, ofType: "plist")

// These are the scale constants used for the different mapping modes
let MODE1_SCALE_FACTOR = 0.5
let MODE2_SCALE_FACTOR = 0.1