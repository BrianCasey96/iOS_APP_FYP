//
//  DetailsTableViewCell.swift
//  PlantApp
//
//  Created by Casey, Brian on 27/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet var time: UILabel!
    @IBOutlet var temp: UILabel!
    @IBOutlet var light: UILabel!
    @IBOutlet var moisture: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
