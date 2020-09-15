//
//  UncompletedTaskViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/20/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class UncompletedTaskViewController: UIViewController {
    @IBOutlet weak var overdueLabel: UILabel!
    @IBOutlet weak var projectDescTV: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var currentTask:Task!
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentTask.projectName//set title of view to the project name
        
         
        //if the task is overdue, display over due label
        if currentTask.estimatedEndDate < Date(){
            overdueLabel.alpha = 1.0
        }else{
            overdueLabel.alpha = 0.0
        }
        
        projectDescTV.text = currentTask.description
        
        //format start date label as so and set it label to it
        if let lang = Locale.autoupdatingCurrent.languageCode, lang == "es"{
            dateFormatter.locale = Locale(identifier: "es_419")
            dateFormatter.setLocalizedDateFormatFromTemplate("d MMM YYYY @ h:mm a")
        }else{
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM d YYYY @ h:mm a")
        }
        
        let dateTextTop = dateFormatter.string(from: currentTask.startDate)
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        let dateTextBottom = dateFormatter.string(from: currentTask.startDate)
        startDateLabel.text = "\(dateTextTop)\n\(dateTextBottom)"
        
        //format end time label as so and set its label to it
        endDateLabel.text = dateFormatter.string(from: currentTask.estimatedEndDate)
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if the user clicked complete button
        if segue.identifier == "completeSegue" {
            let actualCompletionVC = segue.destination as! ActualCompletionViewController
            
            actualCompletionVC.currentTask = self.currentTask //pass current tasks
            
            //delete the data in defaults to allow for new data to be input
            UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        
        //if the user selected go to map button
        if segue.identifier == "toMapSegue" {
            //send them to the map view with the current task
            let mapVC = segue.destination as? GoogleMapViewController
            mapVC?.currentTask = self.currentTask
        }
    }
}
