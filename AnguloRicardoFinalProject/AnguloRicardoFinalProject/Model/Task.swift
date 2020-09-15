//
//  Task.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/18/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import Foundation
import CoreLocation

struct Task:Codable,Equatable{
    var projectName:String
    var description:String
    var address: FullAddress
    var startDate: Date
    var estimatedEndDate: Date
    var actualEndDate: Date
    var completed: Bool
    var summary: String
    var firIDs: [String]?
    var calendarID: String? 
    var toString:String{
        return "Project Name:\(projectName)\nDescription:\(description)\nAddress:\(address.toString)\nDate:\(startDate.description) to \(estimatedEndDate.description)"
    }
    
    init() {
        //initalize the task with default settings
        projectName = ""
        description = ""
        address = FullAddress()
        startDate = Date()
        estimatedEndDate = Date()
        actualEndDate = Date()
        completed = false
        summary = ""
        firIDs = nil
        calendarID = nil
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        //make this task adhere to equatable to be used in tasks model
        if lhs.projectName == rhs.projectName && lhs.description == rhs.description && lhs.startDate == rhs.startDate && lhs.estimatedEndDate == rhs.estimatedEndDate {
            return true
        }else{
            return false
        }
    }
    
}
