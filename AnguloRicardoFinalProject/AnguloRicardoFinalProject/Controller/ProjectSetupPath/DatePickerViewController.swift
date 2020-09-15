//
//  DatePickerViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/19/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class DatePickerViewController: UIViewController {
    @IBOutlet weak var datePickerLabel: UIDatePicker!
    @IBOutlet weak var continueButtonLabel: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        //start the button as disabled when user first enters screen
        datePickerLabel.minimumDate = Date()//make the current date the minimum date for the picker view
        buttonIsEnabled(false)
        loadFromDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //when view appears, have the continue button disabled and load date from defaults
        buttonIsEnabled(false)
        loadFromDefaults()
    }
    
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        //if the user changes the picker, enable the continue button
        buttonIsEnabled(true)
    }
    
    @IBAction func continueButtonClicked(_ sender: UIButton) {
        //when user clicks the continue button, update or set the key "ProjectStartDate" with selected date
        UserDefaults.standard.set(datePickerLabel.date, forKey: "ProjectStartDate")
    }
    
    func loadFromDefaults(){
        //if there is a stored date under the key project start date, retrieve it and show it on the picker
        if let savedDate = UserDefaults.standard.object(forKey: "ProjectStartDate"){
            datePickerLabel.date = savedDate as? Date ?? Date()
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
