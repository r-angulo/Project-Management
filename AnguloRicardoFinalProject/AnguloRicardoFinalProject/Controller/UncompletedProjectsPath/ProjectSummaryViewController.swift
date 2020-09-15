//
//  ProjectSummaryViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/24/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class ProjectSummaryViewController: UIViewController, UITextViewDelegate{
    @IBOutlet weak var summaryTVOutlet: UITextView!
    @IBOutlet weak var displayMessageLabel: UILabel!
    @IBOutlet weak var continueButtonOutlet: UIButton!
    
    let CHARACTERLIMIT = 200
    var currentTask:Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryTVOutlet.delegate = self
        
        loadFromDefaults()
        enableDisableContinue()
        getCharsLeft()
        
        //create a gesture recognizer to remove keyboard when background is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadFromDefaults() //load data from defaults
        enableDisableContinue() //enable or disable continue button based on criteria
    }
    
    @objc func dismissKeyboard(){
        //hide the keyboard
        summaryTVOutlet.resignFirstResponder()
        
        //hide the border that was created
        summaryTVOutlet.layer.borderWidth = 0
        summaryTVOutlet.layer.borderColor = UIColor.clear.cgColor
        view.endEditing(true)
    }
    
    func getCharsLeft(){
        //calculate and display the number of characters the user is allowed to display
        if let descText = summaryTVOutlet.text{
            displayMessageLabel.text = "\(CHARACTERLIMIT - descText.count) \(NSLocalizedString("characters", comment: ""))"
        }
    }
    
    func enableDisableContinue(){
        //if there is text and its not empty in the text view , enable button else dont
        if let tvText = summaryTVOutlet.text {
            if tvText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                continueButtonOutlet.isEnabled = false
                continueButtonOutlet.backgroundColor = UIColor.darkGray
                continueButtonOutlet.setTitleColor(.lightGray, for: .normal)
            }else{
                continueButtonOutlet.isEnabled = true
                continueButtonOutlet.backgroundColor = UIColor.black
                continueButtonOutlet.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //when user types somethign recalculte text left and enable or disable button accordingly
        getCharsLeft()
        enableDisableContinue()
    }
    
    @IBAction func continueButtonClicked(_ sender: UIButton) {
        //if continue button is clicked, update or set "ProjectSummary" with contents of textview
        if let tvText = summaryTVOutlet.text {
            UserDefaults.standard.set(tvText, forKey: "ProjectSummary")
        }
    }
    
    func loadFromDefaults(){
        //if the key "projectsummary" is set, load its contents into the textview
        if let projectDescription = UserDefaults.standard.string(forKey: "ProjectSummary"){
            summaryTVOutlet.text = projectDescription
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            //if user presses return key, hide the border
            textView.resignFirstResponder()
            summaryTVOutlet.layer.borderWidth = 0
            summaryTVOutlet.layer.borderColor = UIColor.clear.cgColor
            return false
        }
        let str = ((summaryTVOutlet.text ?? "") + text)//get textview text
        
        //if the textview text is less than charater limit
        if str.count <= CHARACTERLIMIT {//show a border
            summaryTVOutlet.layer.borderWidth = 2.0
            summaryTVOutlet.layer.borderColor =  UIColor(red: 11.0/255, green: 136.0/255, blue: 254.0/255, alpha: 1.0).cgColor
            return true
        }else{//other wise if chars exceeds limit dont update text view and return max allowable char limit
            summaryTVOutlet.text = String(str.prefix(CHARACTERLIMIT))
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass in the current tast to the next view
        if segue.identifier == "completeSegue" {
            let nextVC = segue.destination as? ImagesSelectorViewController
            nextVC?.currentTask = self.currentTask
        }
    }
}
