//
//  TextBox.swift
//  WATIsRain
//
//  Created by Dulwin Jayalath on 2015-06-29.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import Foundation
import UIKit

class TextBox : UITextField
{
    @IBInspectable
    var backgroundColour: UIColor = UIColor(red:197/255, green:202/255,blue:233/255,alpha:1.0) {
        didSet {
            updateLayerProperties()
        }
    }
    
    
    func updateLayerProperties() {
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = backgroundColour.CGColor
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.whiteColor()
        self.textColor = UIColor.whiteColor()
    }
    
}