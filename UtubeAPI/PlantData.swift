//
//  PlantData.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 27/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import Foundation
import CoreLocation

struct PlantData {
    
    let moisture: String
    let temp: String
    let light: String 
    let date: String
    
    init(moisture: String, temp: String, light: String, date: String) {
        self.moisture = moisture
        self.temp = temp
        self.light = light
        self.date = date
    }
}
