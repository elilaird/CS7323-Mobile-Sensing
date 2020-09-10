//
//  WeatherTableViewController.swift
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit


class WeatherTableViewController: UITableViewController, UISearchBarDelegate {


    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    

    var weatherAPI = WeatherAPI()
    lazy var city = City()

    
    override func viewWillAppear(_ animated: Bool) {
        displayLoadingAlert()
        super.viewWillAppear(animated)
        dismiss(animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchBar.delegate = self
        
        city = City(cityName: "Dallas", andMetric: false)
        self.cityName.text = self.city.getLocation()
        self.forecast = city.forecast
        
        /*
            Example city function calls for current weather:
         
                city.logAllKeys()
                print(city.currentDay.getPressure())
                print(city.currentDay.getLongatude())
                print(city.currentDay.getLatitude())
                print(city.currentDay.getWindSpeed())
                print(city.currentDay.getWindDirection())
                print(city.currentDay.getWeather())
                print(city.currentDay.getWeatherDesc())
         
                print(city.currentDay.getTheDayOfWeek())
         
         */
        
        /*
           Example city function calls for forecast weather:
        
               // First make a swift array in order to use
               let swiftarray = city.forecast as AnyObject as! [Day]
               print(swiftarray[7].getTemp())  // gets 7th day in forecast's temperature
         
           Note: all function calls are the same as the current day's weather, but
           you must specify the 'Day' object in the swift array.
        
        */
        
        print(city.currentDay.getTheDayOfWeek())
 
    }

    // MARK: - Table view data source
    var forecast:NSMutableArray = []
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty{
            self.updateWeather(to: locationString)
        }
    }
    
    func updateWeather(to location: String) {
        displayLoadingAlert()
        city = City(cityName: location, andMetric: false) // until we get the toggle, I am setting this false
        cityName.text = city.getLocation()
        self.tableView.reloadData()
        dismiss(animated: false, completion: nil)
    }
    
    func displayLoadingAlert(){
        let alert = UIAlertController(title: nil, message: "Loading Weather...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
     
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return city.forecast.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let day:Day = forecast[indexPath.row] as! Day
        cell.textLabel?.text = String(day.getWeather())
//        print(day.dayDict)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SpecificWeather", sender: self)
    }

}
