//
//  ClearButton.swift
//  WATIsRain
//
//  Created by Dulwin Jayalath on 2015-06-30.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import MapKit

@IBDesignable
class ClearButton : OptionsButton
{
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
            icon.path = CGPath.rescaleForFrame(path: Paths.clear, frame: iconFrame)
            icon.bounds = CGPathGetBoundingBox(icon.path)
            icon.fillColor = iconColour.CGColor
            icon.position = CGPoint(x: CGRectGetWidth(self.bounds)/2, y: CGRectGetHeight(self.bounds)/2)
            icon.transform = CATransform3DIdentity
            icon.opacity = 1
            self.layer.addSublayer(icon)
        }
    }

}