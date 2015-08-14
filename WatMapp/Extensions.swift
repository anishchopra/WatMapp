//
//  Button.swift
//  WATIsRain
//
//  Created by Dulwin Jayalath on 2015-06-28.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation
import UIKit

extension CGPath {
    class func rescaleForFrame(#path: CGPath, frame: CGRect) -> CGPath{
        let boundingBox = CGPathGetBoundingBox(path);
        let boundingBoxAspectRatio = CGRectGetWidth(boundingBox)/CGRectGetHeight(boundingBox);
        let viewAspectRatio = CGRectGetWidth(frame)/CGRectGetHeight(frame);
        
        var scaleFactor: CGFloat = 1.0;
        if (boundingBoxAspectRatio > viewAspectRatio) {
            scaleFactor = CGRectGetWidth(frame)/CGRectGetWidth(boundingBox);
        } else {
            scaleFactor = CGRectGetHeight(frame)/CGRectGetHeight(boundingBox);
        }
        
        var scaleTransform = CGAffineTransformIdentity;
        scaleTransform = CGAffineTransformScale(scaleTransform, scaleFactor, scaleFactor);
        scaleTransform = CGAffineTransformTranslate(scaleTransform, -CGRectGetMinX(boundingBox), -CGRectGetMinY(boundingBox));
        let scaledSize = CGSizeApplyAffineTransform(boundingBox.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
        let centerOffset = CGSizeMake((CGRectGetWidth(frame)-scaledSize.width)/(scaleFactor*2.0), (CGRectGetHeight(frame)-scaledSize.height)/(scaleFactor*2.0));
        scaleTransform = CGAffineTransformTranslate(scaleTransform, centerOffset.width, centerOffset.height);
        return CGPathCreateCopyByTransformingPath(path, &scaleTransform);
    }
}

extension UIView {
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
    
    func slideInFromTop(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromTop = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromTop.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromTop.type = kCATransitionPush
        slideInFromTop.subtype = kCATransitionFromTop
        slideInFromTop.duration = duration
        slideInFromTop.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromTop.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.addAnimation(slideInFromTop, forKey: "slideInFromTopTransition")
    }
    
    func addBoxShadow() {
        self.layer.shadowColor = UIColor(red:0, green:0,blue:0,alpha:1.0).CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2;
        self.layer.shadowOffset = CGSizeMake(0, 1.5);
    }
    
    func setHeight(height: CGFloat, heightConstraint: NSLayoutConstraint) {
        var frame: CGRect = self.frame
        frame.size.height = height
        self.frame = frame
        heightConstraint.constant = height
    }
}
