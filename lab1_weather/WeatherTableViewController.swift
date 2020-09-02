//
//  WeatherTableViewController.swift
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit


class WeatherTableViewController: UITableViewController, UISearchBarDelegate {


    
    @IBOutlet weak var searchBar: UISearchBar!
    var weatherAPI = WeatherAPI()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
//        print(weatherAPI.getCurrentWeather(for: "Dallas"))
        print(weatherAPI.getForecastFor("Dallas"))
        
    }

    // MARK: - Table view data source
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty{
            print(weatherAPI.getCurrentWeather(for: locationString))
            //print(locationString)
        }
    }

    
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
