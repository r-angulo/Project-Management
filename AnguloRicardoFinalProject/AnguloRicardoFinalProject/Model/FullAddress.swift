//
//  FullAddress.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/19/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import Foundation

struct FullAddress:Codable {
    var address:String
    var city:String
    var zipCode:String
    var state:String
    var country:String
    var longitude: Double
    var latitude: Double
    var toString:String{
        return "\(address), \(state), \(city), \(country) \(zipCode)"
    }
    
    init() {
        //initalize full address with default settings
        address = ""
        city = ""
        zipCode = ""
        state = ""
        country = ""
        longitude = 0.0
        latitude = 0.0
    }
    
    init(address: String,city:String,zipCode: String,state:String,country:String, longitude:Double,latitude:Double){
        //initalize full address with settings passed in 
        self.address = address
        self.city = city
        self.zipCode = zipCode
        self.state = state
        self.country = country
        self.longitude = longitude
        self.latitude = latitude
    }
}
