//
//  CustomTableViewCell.swift
//  lab1_weather
//
//  Created by Eli Laird on 9/9/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var day_label: UILabel!
    @IBOutlet weak var weather_icon: UIImageView!
    @IBOutlet weak var temperature_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
