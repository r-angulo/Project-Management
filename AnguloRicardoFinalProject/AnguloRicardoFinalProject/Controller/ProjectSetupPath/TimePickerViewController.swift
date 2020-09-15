//
//  TimePickerViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/20/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class TimePickerViewController: UIViewController {
    @IBOutlet weak var timePickerOutlet: UIDatePicker!
    @IBOutlet weak var continueButtonLabel: UIButton!
    
    override func viewDidLoad() {
        //when the view loads, disable button and set the minimum date to start date
        super.viewDidLoad()
        buttonIsEnabled(false)
        loadFromDefaults()
        if let startDate = UserDefaults.standard.object(forKey: "ProjectStartDate"){
            buttonIsEnabled(true)
            timePickerOutlet.minimumDate = startDate as? Date
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //when the view appears, disable button and load data from defaults if any
        super.viewWillAppear(animated)
        buttonIsEnabled(false)
        loadFromDefaults()
    }
    
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        //when the user changes the picker, enable the continue button
        buttonIsEnabled(true)
    }
    
    @IBAction func continueButtonClicked(_ sender: UIButton) {
        //if the user clicks continue, set the key "EstimatedEndDate" to the value of the picker

        UserDefaults.standard.set(timePickerOutlet.date, forKey: "EstimatedEndDate")
    }

    func loadFromDefaults(){
        //if there is a stored end date, load it into the current picker view
        if let savedDate = UserDefaults.standard.object(forKey: "EstimatedEndDate"){
            timePickerOutlet.date = savedDate as? Date ?? Date()
            buttonIsEnabled(true)
        }
    }

    func buttonIsEnabled(_ enabled:Bool){
        //enable or disable the button based on boolean and show respective styling 
        if enabled{
            continueButtonLabel.isEnabled = true
            continueButtonLabel.backgroundColor = UIColor.black
            continueButtonLabel.setTitleColor(.white, for: .normal)
        }else{
            continueButtonLabel.isEnabled = false
            continueButtonLabel.backgroundColor = UIColor.darkGray
            continueButtonLabel.setTitleColor(.lightGray, for: .normal)
        }
    }

}
