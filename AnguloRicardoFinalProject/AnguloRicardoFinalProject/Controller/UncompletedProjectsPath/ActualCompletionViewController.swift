//
//  ActualCompletionViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/21/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class ActualCompletionViewController: UIViewController {
    @IBOutlet weak var checkBoxOutlet: UIButton!
    @IBOutlet weak var continueButtonLabel: UIButton!
    @IBOutlet weak var timePickerOutlet: UIDatePicker!
    
    var didTimePickerChange = false
    var checkBoxIsClicked = false
    var currentTask:Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load picker view initially with the minimum date set to the start date
        timePickerOutlet.minimumDate = currentTask.startDate
        
        //create round button
        checkBoxOutlet.layer.cornerRadius =  0.5 * checkBoxOutlet.bounds.size.width
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFromDefaults() //load data from defaults when view appears again
    }
    
    @IBAction func checkBoxClicked(_ sender: UIButton) {
        //when check box is clicked, change the global bool that keeps track and call handlecheckbox
        checkBoxIsClicked = !checkBoxIsClicked
        handleCheckBox()
    }
    
    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        didTimePickerChange = true //change didTimePickerChange to true
    }
    
    @IBAction func continueButtonClicked(_ sender: UIButton) {
        //store the picker views selected data in actualEndDate
        UserDefaults.standard.set(timePickerOutlet.date, forKey: "actualEndDate")
        
        //update the checkBoxIsClicked with the global respective boolean
        UserDefaults.standard.set(checkBoxIsClicked, forKey: "checkBoxIsClicked")
    }
    
    
    func enableDisableContinue(){
        //if either the user changed picker value or check box was clicked
        if  didTimePickerChange || checkBoxIsClicked { //then enable continue button
            continueButtonLabel.isEnabled = true
            continueButtonLabel.backgroundColor = UIColor.black
            continueButtonLabel.setTitleColor(.white, for: .normal)
        }else{//otherwise show it as disables
            continueButtonLabel.isEnabled = false
            continueButtonLabel.backgroundColor = UIColor.darkGray
            continueButtonLabel.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    func loadFromDefaults(){
        //load the end date from defaults into pikcer if its set
        if let actualEndDate = UserDefaults.standard.object(forKey: "actualEndDate"){
            timePickerOutlet.date = actualEndDate as? Date ?? Date()
        }
        if UserDefaults.standard.bool(forKey: "checkBoxIsClicked"){
            //if check box was clicked before, update global var accordintly
            checkBoxIsClicked = true
        }else{
            checkBoxIsClicked = false
        }
        handleCheckBox()//update check box depending on previous actions
    }
    
    func handleCheckBox(){
        //if checkbox was marked as cliked
        if checkBoxIsClicked{//change apperance to show it selected and disable picker view
            checkBoxOutlet.backgroundColor = UIColor.blue
            timePickerOutlet.date = currentTask.estimatedEndDate
            timePickerOutlet.isEnabled = false
        }else{
            //otherwise enable picker view
            checkBoxOutlet.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
            timePickerOutlet.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if complete segue pressed, passed in the current tasks 
        if segue.identifier == "completeSegue" {
            let nextVC = segue.destination as? ProjectSummaryViewController
            nextVC?.currentTask = self.currentTask
        }
    }
}
