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
