//
//  CompletedTaskTableViewCell.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 5/6/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class CompletedTaskTableViewCell: UITableViewCell {
    //NOTE: attempted to pair both main tables to same cell, but xcode kept throwing errors
    //duplicating with different name fixed solution
    @IBOutlet weak var completedTaskName: UILabel!
    @IBOutlet weak var completedDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
