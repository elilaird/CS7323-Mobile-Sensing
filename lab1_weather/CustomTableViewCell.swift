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
    
    func configure(with day:Day){
        self.day_label.text = String(day.getTheDayOfWeek())
        self.temperature_label.text = "\(round(day.getTemp()))°"
       
        let weather_condition = day.getWeather()
        
        switch weather_condition {
        case "Clear":
            self.weather_icon.image = UIImage(named:"clear")
        case "Clouds":
            self.weather_icon.image = UIImage(named:"Cloudy")
        case "Snow":
            self.weather_icon.image = UIImage(named:"Snowy")
        case "Rain","Drizzle":
            self.weather_icon.image = UIImage(named:"Rainy")
        case "Thunderstorm":
            self.weather_icon.image = UIImage(named:"Thunderstorms")
        case "Mist","Smoke","Haze","Dust","Fog","Sand","Ash","Squall","Tornado":
            self.weather_icon.image = UIImage(named:"Wind")
        default:
            self.weather_icon.image = UIImage(named:"clear")
        }
    }

}
