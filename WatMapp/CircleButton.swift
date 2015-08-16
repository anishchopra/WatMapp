//
//  Button.swift
//  WATIsRain
//
//  Created by Dulwin Jayalath on 2015-06-28.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import MapKit

class CircleButton : UIButton
{
    internal var icon : CAShapeLayer!
    internal var circle : CAShapeLayer!
    
    @IBInspectable
    var lineWidth: CGFloat = 1 {
        didSet {
            updateLayerProperties()
        }
    }
    
    @IBInspectable
    var iconColour: UIColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha:50) {
        didSet {
            updateLayerProperties()
        }
    }
    
    @IBInspectable
    var shape: String = "findme" {
        didSet {
            updateLayerProperties()
        }
    }

    
    @IBInspectable
    var circleColour: UIColor = UIColor(red:0.0, green:0.0,blue:0.0,alpha:1.0) {
        didSet {
            updateLayerProperties()
        }
    }
    
    @IBInspectable
    var inactiveColour: UIColor = UIColor(red:0.0, green:0.0,blue:0.0,alpha:1.0) {
        didSet {
            updateLayerProperties()
        }
    }
    
    @IBAction func down() {
        self.touchDown()
    }
    
    @IBAction func up() {
        self.touchUp()
    }
    
    func updateLayerProperties() {
    }
    
    func frameWithInset() -> CGRect {
        return CGRectInset(self.bounds, lineWidth/2, lineWidth/2)
    }
    
    func touchDown() {
        circle.shadowOpacity = 0.7
        circle.shadowRadius = 4
    }
    
    func touchUp() {
        circle.shadowOpacity = 0.5
        circle.shadowRadius = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createLayersIfNeeded()
        updateLayerProperties()
    }
    
    func createLayersIfNeeded() {
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
            circle.shadowColor = UIColor(red:0, green:0,blue:0,alpha:1.0).CGColor;
            circle.shadowOpacity = 0.5;
            circle.shadowRadius = 2;
            circle.shadowOffset = CGSizeMake(0, 0);
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
            case "directions":
                icon.path = CGPath.rescaleForFrame(path: Paths.directions, frame: iconFrame)
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