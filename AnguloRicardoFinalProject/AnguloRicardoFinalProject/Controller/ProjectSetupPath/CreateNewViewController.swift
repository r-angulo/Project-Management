//
//  CreateNewViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/19/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class CreateNewViewController: UIViewController {
    @IBOutlet weak var inspirationQuoteLabel: UILabel!
    var inspirationalQuotes:[String] = []
    let authors = ["Jim Rohn",
                   "Thomas Jefferson",
                   "Thomas Edison",
                   "George Lorimer",
                   "Robert Louis Stevenson",
                   "Henry Ford",
                   "Dale Carnegie",
                   "Saint Francis",
                   "Martin Luther King, Jr.",
                   "Joseph Barbara",
                   "Seneca"
                    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        //return the approatite string from the localized strings file
        for i in 1...11 {
            inspirationalQuotes.append(NSLocalizedString("quote\(i)", comment: ""))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //every time the view will appear, select a random quore from the array above
        let index = Int.random(in: 0 ..< inspirationalQuotes.count)
        self.inspirationQuoteLabel.text = "\"\(inspirationalQuotes[index])\"\n\n-\(authors[index])"
    }
    
    @IBAction func startButtonPress(_ sender: UIButton) {
        //clear defaults in case there is anything in there before starting a new project
        UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
             UserDefaults.standard.removeObject(forKey: key)
         }
    }
    


}
