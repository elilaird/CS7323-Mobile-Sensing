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
    var currentLocation: String = "Dallas"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        
        print(weatherAPI.getWeatherFor("Dallas"))

    }

    // MARK: - Table view data source
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty{
            updateWeather(to: locationString)
        }
    }
    
    func updateWeather(to location: String) {
        print(weatherAPI.getWeatherFor(location))
        currentLocation = location
        self.tableView.reloadData()
    }
     
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = currentLocation
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SpecificWeather", sender: self)
    }
    
    

}
