//
//  ProjectDescriptionViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/19/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class ProjectDescriptionViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var projectDescTVLabel: UITextView!
    @IBOutlet weak var continueButtonLabel: UIButton!
    @IBOutlet weak var displayMessageLabel: UILabel!
    
    let DESCRIPTIONCHARACTERLIMIT = 200

    override func viewDidLoad() {
        super.viewDidLoad()
        projectDescTVLabel.becomeFirstResponder()
        loadFromDefaults()
        enableDisableContinue()
        getCharsLeft()
        
        //create a gesture recognizer to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //when view appears call these functions
        projectDescTVLabel.becomeFirstResponder()
        loadFromDefaults()
        enableDisableContinue()
    }
    
    @objc func dismissKeyboard(){
        //dismiss the keyboard when background is tapped and hides border of textfield
        projectDescTVLabel.resignFirstResponder()
        projectDescTVLabel.layer.borderWidth = 0
        projectDescTVLabel.layer.borderColor = UIColor.clear.cgColor
        view.endEditing(true)
    }

    func getCharsLeft(){
        //calculate and display in appropiate the number of characters a user is allowed to type in the textview
        if let descText = projectDescTVLabel.text{
            displayMessageLabel.text = "\(DESCRIPTIONCHARACTERLIMIT - descText.count) \(NSLocalizedString("characters", comment: ""))"
        }
    }
    

    
    func enableDisableContinue(){
        //if there is text in the textview, enable continue button
        if let tvText = projectDescTVLabel.text {
            if tvText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                continueButtonLabel.isEnabled = false
                continueButtonLabel.backgroundColor = UIColor.darkGray
                continueButtonLabel.setTitleColor(.lightGray, for: .normal)
            }else{
                continueButtonLabel.isEnabled = true
                continueButtonLabel.backgroundColor = UIColor.black
                continueButtonLabel.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //when textview text changes, check if contine button can be enabled, and update chars left label
        enableDisableContinue()
        getCharsLeft()
    }
    
    @IBAction func continueButtonClicked(_ sender: UIButton) {
        //if continue button is clicked
        //store its contents under the key "ProjectDescription" in userdefaults
        if let tvText = projectDescTVLabel.text {
            UserDefaults.standard.set(tvText, forKey: "ProjectDescription")
        }
    }
    
    func loadFromDefaults(){
        //if the user has previously set the text for this textview, put it in the text view
        if let projectDescription = UserDefaults.standard.string(forKey: "ProjectDescription"){
            projectDescTVLabel.text = projectDescription
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {//if user presses return key
            textView.resignFirstResponder()//dismiss key board and hide border
            projectDescTVLabel.layer.borderWidth = 0
            projectDescTVLabel.layer.borderColor = UIColor.clear.cgColor
            return false
        }
        
        let str = ((projectDescTVLabel.text ?? "") + text)//get the text from textview

        if str.count <= DESCRIPTIONCHARACTERLIMIT {//if its less than allowable limit, allow text to change
            projectDescTVLabel.layer.borderWidth = 2.0
            projectDescTVLabel.layer.borderColor = UIColor(red: 11.0/255, green: 136.0/255, blue: 254.0/255, alpha: 1.0).cgColor
            return true
        }else{
            //if more than allowable limit, do not allow text to change
            projectDescTVLabel.text = String(str.prefix(DESCRIPTIONCHARACTERLIMIT))
            return false
        }
    }
}
