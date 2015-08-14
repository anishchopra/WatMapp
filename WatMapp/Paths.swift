//
//  Paths.swift
//  WATIsRain
//
//  Created by Dulwin Jayalath on 2015-06-28.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation
import UIKit

struct Paths
{
    // Find me icon path
    static var findme : CGPath {
        var findme = UIBezierPath()
        findme.moveToPoint(CGPointMake(120, 68))
        findme.addCurveToPoint(CGPointMake(112, 60), controlPoint1: CGPointMake(115.58, 68), controlPoint2: CGPointMake(112, 64.42))
        findme.addCurveToPoint(CGPointMake(120, 52), controlPoint1: CGPointMake(112, 55.58), controlPoint2: CGPointMake(115.58, 52))
        findme.addCurveToPoint(CGPointMake(128, 60), controlPoint1: CGPointMake(124.42, 52), controlPoint2: CGPointMake(128, 55.58))
        findme.addCurveToPoint(CGPointMake(120, 68), controlPoint1: CGPointMake(128, 64.42), controlPoint2: CGPointMake(124.42, 68))
        findme.closePath()
        findme.moveToPoint(CGPointMake(137.88, 62))
        findme.addCurveToPoint(CGPointMake(122, 77.88), controlPoint1: CGPointMake(136.96, 70.34), controlPoint2: CGPointMake(130.34, 76.96))
        findme.addLineToPoint(CGPointMake(122, 82))
        findme.addLineToPoint(CGPointMake(118, 82))
        findme.addLineToPoint(CGPointMake(118, 77.88))
        findme.addCurveToPoint(CGPointMake(102.12, 62), controlPoint1: CGPointMake(109.66, 76.96), controlPoint2: CGPointMake(103.04, 70.34))
        findme.addLineToPoint(CGPointMake(98, 62))
        findme.addLineToPoint(CGPointMake(98, 58))
        findme.addLineToPoint(CGPointMake(102.12, 58))
        findme.addCurveToPoint(CGPointMake(118, 42.12), controlPoint1: CGPointMake(103.04, 49.66), controlPoint2: CGPointMake(109.66, 43.04))
        findme.addLineToPoint(CGPointMake(118, 38))
        findme.addLineToPoint(CGPointMake(122, 38))
        findme.addLineToPoint(CGPointMake(122, 42.12))
        findme.addCurveToPoint(CGPointMake(137.88, 58), controlPoint1: CGPointMake(130.34, 43.04), controlPoint2: CGPointMake(136.96, 49.66))
        findme.addLineToPoint(CGPointMake(142, 58))
        findme.addLineToPoint(CGPointMake(142, 62))
        findme.addLineToPoint(CGPointMake(137.88, 62))
        findme.closePath()
        findme.moveToPoint(CGPointMake(120, 46))
        findme.addCurveToPoint(CGPointMake(106, 60), controlPoint1: CGPointMake(112.26, 46), controlPoint2: CGPointMake(106, 52.26))
        findme.addCurveToPoint(CGPointMake(120, 74), controlPoint1: CGPointMake(106, 67.74), controlPoint2: CGPointMake(112.26, 74))
        findme.addCurveToPoint(CGPointMake(134, 60), controlPoint1: CGPointMake(127.74, 74), controlPoint2: CGPointMake(134, 67.74))
        findme.addCurveToPoint(CGPointMake(120, 46), controlPoint1: CGPointMake(134, 52.26), controlPoint2: CGPointMake(127.74, 46))
        findme.closePath()
        return findme.CGPath
    }
    
    static var home: CGPath {
        var home = UIBezierPath()
        home.moveToPoint(CGPointMake(116, 76))
        home.addLineToPoint(CGPointMake(116, 64))
        home.addLineToPoint(CGPointMake(124, 64))
        home.addLineToPoint(CGPointMake(124, 76))
        home.addLineToPoint(CGPointMake(134, 76))
        home.addLineToPoint(CGPointMake(134, 60))
        home.addLineToPoint(CGPointMake(140, 60))
        home.addLineToPoint(CGPointMake(120, 42))
        home.addLineToPoint(CGPointMake(100, 60))
        home.addLineToPoint(CGPointMake(106, 60))
        home.addLineToPoint(CGPointMake(106, 76))
        home.addLineToPoint(CGPointMake(116, 76))
        home.closePath()
        return home.CGPath
    }
    
    static var options: CGPath {
        var options = UIBezierPath()
        options.moveToPoint(CGPointMake(70, 33))
        options.addCurveToPoint(CGPointMake(74, 37), controlPoint1: CGPointMake(72.2, 33), controlPoint2: CGPointMake(74, 34.8))
        options.addCurveToPoint(CGPointMake(70, 41), controlPoint1: CGPointMake(74, 39.2), controlPoint2: CGPointMake(72.2, 41))
        options.addCurveToPoint(CGPointMake(66, 37), controlPoint1: CGPointMake(67.8, 41), controlPoint2: CGPointMake(66, 39.2))
        options.addCurveToPoint(CGPointMake(70, 33), controlPoint1: CGPointMake(66, 34.8), controlPoint2: CGPointMake(67.8, 33))
        options.closePath()
        options.moveToPoint(CGPointMake(70, 29))
        options.addCurveToPoint(CGPointMake(66, 25), controlPoint1: CGPointMake(67.8, 29), controlPoint2: CGPointMake(66, 27.2))
        options.addCurveToPoint(CGPointMake(70, 21), controlPoint1: CGPointMake(66, 22.8), controlPoint2: CGPointMake(67.8, 21))
        options.addCurveToPoint(CGPointMake(74, 25), controlPoint1: CGPointMake(72.2, 21), controlPoint2: CGPointMake(74, 22.8))
        options.addCurveToPoint(CGPointMake(70, 29), controlPoint1: CGPointMake(74, 27.2), controlPoint2: CGPointMake(72.2, 29))
        options.closePath()
        options.moveToPoint(CGPointMake(70, 17))
        options.addCurveToPoint(CGPointMake(66, 13), controlPoint1: CGPointMake(67.8, 17), controlPoint2: CGPointMake(66, 15.2))
        options.addCurveToPoint(CGPointMake(70, 9), controlPoint1: CGPointMake(66, 10.8), controlPoint2: CGPointMake(67.8, 9))
        options.addCurveToPoint(CGPointMake(74, 13), controlPoint1: CGPointMake(72.2, 9), controlPoint2: CGPointMake(74, 10.8))
        options.addCurveToPoint(CGPointMake(70, 17), controlPoint1: CGPointMake(74, 15.2), controlPoint2: CGPointMake(72.2, 17))
        options.closePath()
        return options.CGPath
    }
    
    static var clear: CGPath {
        var clear = UIBezierPath()
        clear.moveToPoint(CGPointMake(133, 49.18))
        clear.addLineToPoint(CGPointMake(130.18, 52))
        clear.addLineToPoint(CGPointMake(119, 40.82))
        clear.addLineToPoint(CGPointMake(107.82, 52))
        clear.addLineToPoint(CGPointMake(105, 49.18))
        clear.addLineToPoint(CGPointMake(116.18, 38))
        clear.addLineToPoint(CGPointMake(105, 26.82))
        clear.addLineToPoint(CGPointMake(107.82, 24))
        clear.addLineToPoint(CGPointMake(119, 35.18))
        clear.addLineToPoint(CGPointMake(130.18, 24))
        clear.addLineToPoint(CGPointMake(133, 26.82))
        clear.addLineToPoint(CGPointMake(121.82, 38))
        clear.addLineToPoint(CGPointMake(133, 49.18))
        clear.closePath()
        return clear.CGPath
    }
    
    static var back: CGPath {
        var back = UIBezierPath()
        back.moveToPoint(CGPointMake(40, 26))
        back.addLineToPoint(CGPointMake(15.66, 26))
        back.addLineToPoint(CGPointMake(26.84, 37.18))
        back.addLineToPoint(CGPointMake(24, 40))
        back.addLineToPoint(CGPointMake(8, 24))
        back.addLineToPoint(CGPointMake(24, 8))
        back.addLineToPoint(CGPointMake(26.82, 10.82))
        back.addLineToPoint(CGPointMake(15.66, 22))
        back.addLineToPoint(CGPointMake(40, 22))
        back.addLineToPoint(CGPointMake(40, 26))
        back.closePath()
        return back.CGPath
    }
    
    static var directions: CGPath {
        var directions = UIBezierPath()
        directions.moveToPoint(CGPointMake(156.6, 88.6))
        directions.addLineToPoint(CGPointMake(174.6, 70.6))
        directions.addCurveToPoint(CGPointMake(177.42, 70.6), controlPoint1: CGPointMake(175.38, 69.82), controlPoint2: CGPointMake(176.64, 69.82))
        directions.addLineToPoint(CGPointMake(195.42, 88.6))
        directions.addCurveToPoint(CGPointMake(195.42, 91.42), controlPoint1: CGPointMake(196.2, 89.38), controlPoint2: CGPointMake(196.2, 90.64))
        directions.addLineToPoint(CGPointMake(177.42, 109.42))
        directions.addCurveToPoint(CGPointMake(174.6, 109.42), controlPoint1: CGPointMake(176.64, 110.2), controlPoint2: CGPointMake(175.38, 110.2))
        directions.addLineToPoint(CGPointMake(156.6, 91.42))
        directions.addCurveToPoint(CGPointMake(156.6, 88.6), controlPoint1: CGPointMake(155.82, 90.66), controlPoint2: CGPointMake(155.82, 89.4))
        directions.closePath()
        directions.moveToPoint(CGPointMake(172.02, 95.02))
        directions.addLineToPoint(CGPointMake(172.02, 90.02))
        directions.addLineToPoint(CGPointMake(180.02, 90.02))
        directions.addLineToPoint(CGPointMake(180.02, 96.02))
        directions.addLineToPoint(CGPointMake(184.02, 96.02))
        directions.addLineToPoint(CGPointMake(184.02, 88.02))
        directions.addCurveToPoint(CGPointMake(182.02, 86.02), controlPoint1: CGPointMake(184.02, 86.92), controlPoint2: CGPointMake(183.12, 86.02))
        directions.addLineToPoint(CGPointMake(172.02, 86.02))
        directions.addLineToPoint(CGPointMake(172.02, 81.02))
        directions.addLineToPoint(CGPointMake(165.02, 88.02))
        directions.addLineToPoint(CGPointMake(172.02, 95.02))
        directions.closePath()
        return directions.CGPath
    }
    
    // Circle
    static func circle(inFrame: CGRect) -> CGPath {
        let circle = UIBezierPath(ovalInRect: inFrame)
        return circle.CGPath
    }
}