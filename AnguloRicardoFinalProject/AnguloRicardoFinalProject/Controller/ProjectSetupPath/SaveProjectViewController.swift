//
//  SaveProjectViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/19/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit
import Foundation
import EventKit

class SaveProjectViewController: UIViewController {
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var aboutTVOutlet: UITextView!
    @IBOutlet weak var addToCalendarButton: UIButton!
    
    let dateFormatter = DateFormatter()
    var newTask: Task = Task()//create a new task instance to later save in the model
    private var tasksModel = TasksService.shared//load the instance of the task service
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //set the style for date formatted
        //set date format aased on language
        if let lang = Locale.autoupdatingCurrent.languageCode, lang == "es"{
            dateFormatter.locale = Locale(identifier: "es_419")
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, d MMMM YYYY")
        }else{
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d YYYY")
        }
        
        loadFromUserDefaults()//load data from previous view into new model
        
        //update labels to show data from new task object
        projectNameLabel.text = newTask.projectName
        aboutTVOutlet.text = newTask.description
        addressLabel.text     = newTask.address.toString
        
        //style the data label to show start and end data
        let topLineDate       = dateFormatter.string(from: newTask.startDate)
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        let bottomLinePart1   = dateFormatter.string(from: newTask.startDate)
        let bottomLinePart2   = dateFormatter.string(from: newTask.estimatedEndDate)
        dateLabel.text = "\(topLineDate)\n\(bottomLinePart1) - \(bottomLinePart2)"
        
        //give the calendar button a border and border color
        addToCalendarButton.layer.borderWidth = 3
        addToCalendarButton.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //when view appears again, reload data from defaults in case user changed it
        loadFromUserDefaults()
    }
    
    func loadFromUserDefaults(){
        //load the data created in previous view into their respective variable names
        guard let projectName = UserDefaults.standard.string(forKey: "ProjectName") else{
            return
        }
        
        guard let projectDescription = UserDefaults.standard.string(forKey: "ProjectDescription") else{
            return
        }
        
        let longitude = UserDefaults.standard.double(forKey: "longitude")
        let latitude = UserDefaults.standard.double(forKey: "latitude")
        let addressText = UserDefaults.standard.string(forKey: "AddressName") ?? ""
        let cityText    = UserDefaults.standard.string(forKey: "City") ?? ""
        let zipCodeText =  UserDefaults.standard.string(forKey: "ZipCode") ?? ""
        let stateText   =  UserDefaults.standard.string(forKey: "State") ?? ""
        let countryText   =  UserDefaults.standard.string(forKey: "Country") ?? ""
        
        let projectStartDate = UserDefaults.standard.object(forKey: "ProjectStartDate") as? Date
        let estimatedEndDate = UserDefaults.standard.object(forKey: "EstimatedEndDate") as? Date
        
        //with the newly created variables, update the new task object with that data
        newTask.projectName = projectName
        newTask.description = projectDescription
        
        newTask.address = FullAddress(address: addressText, city: cityText, zipCode: zipCodeText, state: stateText, country: countryText, longitude: longitude, latitude: latitude)
        
        newTask.startDate = projectStartDate ?? Date()
        newTask.estimatedEndDate = estimatedEndDate ?? Date()
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        //clear user defaults to get ready for next creation
        UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        //insert this new task into our persisten data model
        tasksModel.insertNewTask(newTask: newTask)
    }
    
    @IBAction func addToCalendarClicked(_ sender: UIButton) {
        let eStore : EKEventStore = EKEventStore()//create an event store object
        eStore.requestAccess(to: .event) { (success, error) in//attempt to request acccess
            if (success) && (error == nil) {//if accesss was successful
                //create a new event with the data from new task
                let e:EKEvent = EKEvent(eventStore: eStore)
                e.title = self.newTask.projectName
                e.startDate = self.newTask.startDate
                e.endDate = self.newTask.estimatedEndDate
                e.notes = self.newTask.description
                e.calendar = eStore.defaultCalendarForNewEvents
                
                do {
                    //attempt to save it in users calendar with a unique identifier
                    try eStore.save(e, span: .thisEvent)
                    self.newTask.calendarID = e.eventIdentifier//save the identifier into our task
                } catch let error as NSError {
                    print("Event Store Error \(error)")
                }
                DispatchQueue.main.async {
                    //update button to show successful add
                    self.addToCalendarButton.setTitle(NSLocalizedString("added", comment: ""), for: .normal)
                    self.addToCalendarButton.setTitleColor(UIColor.green, for: .normal)
                    self.addToCalendarButton.isEnabled = false
                }
            }
            else{
                //if unsuccesful in granting acccess, show error message
                DispatchQueue.main.async {
                    self.addToCalendarButton.setTitle("Error Adding to Calendar", for: .normal)
                    self.addToCalendarButton.setTitleColor(UIColor.red, for: .normal)
                    self.addToCalendarButton.isEnabled = false
                }
            }
        }
    }
}
