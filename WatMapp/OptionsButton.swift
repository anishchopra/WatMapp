//
//  OptionsButton.swift
//  WATIsRain
//
//  Created by Dulwin Jayalath on 2015-06-30.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//


import Foundation
import UIKit
import QuartzCore
import MapKit

@IBDesignable
class OptionsButton : CircleButton
{
    //func goToCampus(mapView : MKMapView) {
        // Set location to show entire campus
    //    adjustMap(CLLocationCoordinate2D(latitude: CAMPUS_LATITUDE, longitude: CAMPUS_LONGITUDE), mapView)
    //}
    
    var clickColour: UIColor = UIColor(red:197/255, green:202/255,blue:233/255,alpha:1.0) {
        didSet {
            updateLayerProperties()
        }
    }
    
    override func touchDown() {
        circle.strokeColor = clickColour.CGColor
        circle.fillColor = clickColour.CGColor
    }
    
    override func touchUp() {
        circle.strokeColor = circleColour.CGColor
        circle.fillColor = circleColour.CGColor
    }
    
    @IBAction override func up() {
        self.touchUp()
    }
    
    @IBAction override func down() {
        self.touchDown()
    }
    
    override func createLayersIfNeeded() {
        if  circle == nil {
            circle = CAShapeLayer()
            circle.path = Paths.circle(frameWithInset())
            circle.bounds = frameWithInset()
            circle.lineWidth = lineWidth
            circle.strokeColor = circleColour.CGColor
            circle.fillColor = circleColour.CGColor
            circle.position = CGPoint(x: CGRectGetWidth(self.bounds)/2, y: CGRectGetHeight(self.bounds)/2)
            circle.transform = CATransform3DIdentity
            circle.masksToBounds = false;
            circle.opacity = 1
            self.layer.addSublayer(circle)
        }
        
        if icon == nil {
            var iconFrame = self.bounds
            iconFrame.size.width = CGRectGetWidth(iconFrame)/2.5
            iconFrame.size.height = CGRectGetHeight(iconFrame)/2.5
            
            icon = CAShapeLayer()
            
            switch ( shape ) {
            case "findme":
                icon.path = CGPath.rescaleForFrame(path: Paths.findme, frame: iconFrame)
            case "home":
                icon.path = CGPath.rescaleForFrame(path: Paths.home, frame: iconFrame)
            case "options":
                icon.path = CGPath.rescaleForFrame(path: Paths.options, frame: iconFrame)
            case "back":
                icon.path = CGPath.rescaleForFrame(path: Paths.back, frame: iconFrame)
            default:
                icon.path = CGPath.rescaleForFrame(path: Paths.findme, frame: iconFrame)
            }
            
            icon.bounds = CGPathGetBoundingBox(icon.path)
            icon.fillColor = iconColour.CGColor
            icon.position = CGPoint(x: CGRectGetWidth(self.bounds)/2, y: CGRectGetHeight(self.bounds)/2)
            icon.transform = CATransform3DIdentity
            icon.opacity = 1
            self.layer.addSublayer(icon)
        }
    }
}