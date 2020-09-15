//
//  AddressTableViewCell.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/23/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var placemarkNameLabel: UILabel!
    @IBOutlet weak var provinceNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
