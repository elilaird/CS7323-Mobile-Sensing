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
        
        /*
            Example city function calls for current weather:
         
                city.logAllKeys()
                print(city.currentDay.getCurrentPressure())
                print(city.currentDay.getLongatude())
                print(city.currentDay.getLatitude())
                print(city.currentDay.getCurrentWindSpeed())
                print(city.currentDay.getCurrentWindDirection())
                print(city.currentDay.getCurrentWeather())
                print(city.currentDay.getCurrentWeatherDesc())
         
         */
        
        /*
           Example city function calls for forecast weather:
        
               // First make a swift array in order to use
               let swiftarray = city.forecast as AnyObject as! [Day]
               print(swiftarray[7].getCurrentTemp())  // gets 7th day in forecast's temperature
         
           Note: all function calls are the same as the current day's weather, but
           you must specify the 'Day' object in the swift array.
        
        */
 
    }

    // MARK: - Table view data source
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty{
            city = City(cityName: locationString)
            print("New City!")
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
