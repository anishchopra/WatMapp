//
//  Searchbar.swift
//  WatMapp
//
//  Created by Dulwin Jayalath on 2015-08-02.
//  Copyright (c) 2015 Anish Chopra, Dulwin Jayalath, Connor Ladly-Freeden. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SearchBar : UITextField
{
    var buildings: [Building] = [] {
        didSet {
            self.buildings = sorted(self.buildings, alphabetize)
            self.searchedBuildings = self.buildings
        }
    }
    
    var searchedBuildings: [Building] = []
    
    var selectedBuilding: Building = Building() {
        didSet {
            if self.selectedBuilding.fullName == "" {
                self.set = false;
                return;
            }
            self.set = true
            return
        }
    }
    
    var set: Bool = false
    
    @IBOutlet var table: UITableView! = nil {
        didSet {
            self.table.alpha = 0.0
            self.table.editing = false
        }
    }
    @IBOutlet weak var back: UIView! = nil {
        didSet {
            self.back.alpha = 0.0
            self.back.addBoxShadow()
        }
    }
    @IBOutlet weak var greyBack: UIView! = nil {
        didSet {
            self.greyBack.alpha = 0.0
        }
    }
    
    
    @IBAction func valuechanged( sender: SearchBar!) {
        if sender.text == "" || sender.text == nil {
            searchedBuildings = buildings
        }
        else {
           searchedBuildings = []
        }
        for building in self.buildings {
            if building.fullName.lowercaseString.rangeOfString(sender.text.lowercaseString) != nil
                || building.abbreviation.lowercaseString.rangeOfString(sender.text.lowercaseString) != nil {
                    searchedBuildings.append(building)
            }
        }
        
        table.reloadData()
    }
    
    func clear() {
        self.text = ""
        self.set = false
        self.searchedBuildings = self.buildings
        self.endEditing(true)
        table.reloadData()
    }
    
    func alphabetize (s1: Building, s2: Building) -> Bool {
        return s1.fullName < s2.fullName
    }
    
    func showSearchView() {
        greyBack.fadeIn(duration: 0.1)
        back.fadeIn(duration: 0.3, delay: 0.05)
        table.fadeIn(duration: 0.3, delay: 0.05)
        table.userInteractionEnabled = true
    }
    
    func hideSearchView() {
        greyBack.fadeOut(duration: 0.3, delay: 0.05)
        back.fadeOut(duration: 0.1)
        table.fadeOut(duration: 0.1)
        table.userInteractionEnabled = false
        self.endEditing(true)
    }

}