//
//  ProjectNameViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/19/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class ProjectNameViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var projectNameTFOutlet: UITextField!
    @IBOutlet weak var continueButtonLabel: UIButton!
    @IBOutlet weak var displayMessageLabel: UILabel!
    
    let PROJNAMECHARACTERLIMIT = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        //when the view loads call these functions
        projectNameTFOutlet.delegate = self
        projectNameTFOutlet.becomeFirstResponder()
        loadFromDefaults()
        enableDisableContinue()
        getCharsLeft()

        //create a gesture recognizer to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //when the view appears, call these functions
        projectNameTFOutlet.becomeFirstResponder()
        loadFromDefaults()
        enableDisableContinue()
        getCharsLeft()
    }
    
    func getCharsLeft(){
        //calculate and display in appropiate the number of characters a user is allowed to type in
        if let projNameText = projectNameTFOutlet.text{
            displayMessageLabel.text = "\(PROJNAMECHARACTERLIMIT - projNameText.count) \(NSLocalizedString("characters", comment: ""))"
        }
    }

    func enableDisableContinue(){
        //check the text field
        //if there is text and its less than the allowed character limit, allow user to continue
        //otherwise do not allow them to continue
        if let tfText = projectNameTFOutlet.text {
            if tfText.isEmpty {
                continueButtonLabel.isEnabled = false
                continueButtonLabel.backgroundColor = UIColor.darkGray
                continueButtonLabel.setTitleColor(.lightGray, for: .normal)
            }else{
                if (tfText.count <= PROJNAMECHARACTERLIMIT){
                    continueButtonLabel.isEnabled = true
                    continueButtonLabel.backgroundColor = UIColor.black
                    continueButtonLabel.setTitleColor(.white, for: .normal)
                }
            }
        }
    }
    
    @IBAction func projNameEditingChanged(_ sender: UITextField) {
        //when the textfield changes,
        //check if continue button can be enable and update the chars left label
        enableDisableContinue()
        getCharsLeft()
    }
    
    @IBAction func projNameEditingBegin(_ sender: UITextField) {
        //when the editing begins, style the textfield to highlight the border
        projectNameTFOutlet.layer.borderWidth = 2.0
        projectNameTFOutlet.layer.borderColor = UIColor(red: 11.0/255, green: 136.0/255, blue: 254.0/255, alpha: 1.0).cgColor
    }
    
    @IBAction func projNameEditingEnded(_ sender: UITextField) {
        //when the user is done editing, hide the previous border that was created
        projectNameTFOutlet.layer.borderWidth = 0
        projectNameTFOutlet.layer.borderColor = UIColor.clear.cgColor
    }
        
    @IBAction func continueBtnClicked(_ sender: UIButton) {
        //if the continue button is clicked
        //create a userdefault key 'ProjectName' and set it with the value from the textfield
        if let tfText = projectNameTFOutlet.text{
            UserDefaults.standard.set(tfText, forKey: "ProjectName")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if user clicks return key
        //hide the keyboard and the border that was created
        textField.resignFirstResponder()
        projectNameTFOutlet.layer.borderWidth = 0
        projectNameTFOutlet.layer.borderColor = UIColor.clear.cgColor
        return true
    }
    
    func loadFromDefaults(){
        //when called, if the user has previously set text in textfield
        //it will retrieve it from userdefaults and set current TF text to that
        if let projectName = UserDefaults.standard.string(forKey: "ProjectName"){
            projectNameTFOutlet.text = projectName
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = ((projectNameTFOutlet.text ?? "") + string)//get the current text
        
        if str.count <= PROJNAMECHARACTERLIMIT {//if the text count is less than allowed
              return true//update textfield
        }
        //otherwise, return only the first max allowed characters and dont update tf with new text
        projectNameTFOutlet.text = String(str.prefix(PROJNAMECHARACTERLIMIT))
        return false
    }
 
    @objc func dismissKeyboard(){
    //dismiss the keyboard when background is tapped and hides border of textfield
        projectNameTFOutlet.resignFirstResponder()
        projectNameTFOutlet.layer.borderWidth = 0
        projectNameTFOutlet.layer.borderColor = UIColor.clear.cgColor
        view.endEditing(true)
    }
}
