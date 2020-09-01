//
//  WeatherTableViewController.swift
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit


class WeatherTableViewController: UITableViewController {

  
    override func viewDidLoad() {
        super.viewDidLoad()


        
        var weatherAPI = WeatherAPI()
        print(weatherAPI.getDataFor("Dallas"))

    }

    // MARK: - Table view data source
    

    
    func getWeatherForLocation(location:String) {
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    

}
