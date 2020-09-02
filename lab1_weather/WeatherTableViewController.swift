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
    var city = City(cityName: "Dallas")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        

        
        print("***********************************")
        print(city.getForecastDict()) // Clay: NEED TO MAKE THIS WAIT FOR THE DATA TO ARRIVE
        print("***********************************")
        
    }

    // MARK: - Table view data source
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty{
            city = City(cityName: locationString)
            print("New City!")
            print(city.getForecastDict())
            print(locationString)
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
