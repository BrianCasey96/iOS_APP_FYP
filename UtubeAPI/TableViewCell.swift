//
//  TableViewCell.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 13/01/2017.
//  Copyright © 2017 Casey, Brian. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {



    @IBOutlet var light: UILabel!
    @IBOutlet var temp: UILabel!
    @IBOutlet var date: UILabel!
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
