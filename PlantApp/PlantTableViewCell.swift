//
//  PlantTableViewCell.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 28/02/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class PlantTableViewCell: UITableViewCell {

    @IBOutlet var img: UIImageView!
    
    @IBOutlet var plantName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
