//
//  Searchbar.swift
//  WatMapp
//
//  Created by Dulwin Jayalath on 2015-08-02.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
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
    
    var selectedBuilding: Building = Building()
    
    @IBOutlet var table: UITableView! = nil
    
    
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
                    //searchedBuildings.insert(building)
                    searchedBuildings.append(building)
            }
        }
        
        table.reloadData()
    }
    
    func clear() {
        self.text = ""
        self.searchedBuildings = self.buildings
        self.endEditing(true)
        table.reloadData()
    }
    
    func alphabetize (s1: Building, s2: Building) -> Bool {
        return s1.fullName < s2.fullName
    }

}