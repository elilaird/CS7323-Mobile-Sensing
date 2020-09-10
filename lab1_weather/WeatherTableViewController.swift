//
//  WeatherTableViewController.swift
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit


class WeatherTableViewController: UITableViewController, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityPicker: UIPickerView!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var labelViewContainer: UIView!
    @IBOutlet weak var currentDetailsView: UIView!
    @IBOutlet weak var dismissDetailsButton: UIButton!
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    var weatherAPI = WeatherAPI()
    var city = City(cityName: "Dallas", andMetric: false)
    var pickerCities: [String] = [String]()
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchBar.delegate = self
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(changeBackground), userInfo: nil, repeats: true)
        
        // hide current weather details
        self.currentDetailsView.isHidden = true
        
        // make label clickable
        currentTempLabel.isUserInteractionEnabled = true
        let tapCurrentTemp = UITapGestureRecognizer.init(target: self, action: #selector(showCurrentWeatherDetail))
        currentTempLabel.addGestureRecognizer(tapCurrentTemp)
        
        self.forecast = self.city.forecast
//        self.currentTempLabel.text = String(Int(self.city.currentDay.getTemp()))
        
        self.updateCurrentWeather()
        // Connect data:
        self.cityPicker.delegate = self
        self.cityPicker.dataSource = self
//        self.tableView.tableHeaderView = self.createTableHeader()
        
        
        pickerCities = ["Dallas", "London", "Chicago"]
        
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
 
    }
    
    /*
     Timer
     */
    @objc func changeBackground(){
        let currColor = self.labelViewContainer.backgroundColor
        
        if currColor == .gray{
            self.labelViewContainer.backgroundColor = .systemIndigo
        }
        else{
            self.labelViewContainer.backgroundColor = .gray
        }
    }
    
    
    /*
     Current city display
     */
    
    @objc func showCurrentWeatherDetail(){
        self.currentDetailsView.isHidden = !self.currentDetailsView.isHidden
    }
    
    @IBAction func dismissCurrentDetails(_ sender: Any) {
        self.currentDetailsView.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCities.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerCities[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.updateWeather(to: pickerCities[row])
    }
    
    // formatting later.  If using this function, can't use 'titleForRow' as well
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let pickerLabel = UILabel()
//        pickerLabel.font = UIFont.systemFont(ofSize: 40)
//        pickerLabel.text = pickerCities[row]
//        return pickerLabel
//    }
    
    
    /*
     Current weather display
     */
    
//    func createTableHeader() -> UIView{
//        let headerView = UIView(frame: CGRect(x: 0, y: -75, width: view.frame.size.width, height: view.frame.size.width))
//        headerView.backgroundColor = .red
//        return headerView
//    }
    
    func updateCurrentWeather(){
        self.currentTempLabel.text = String(Int(self.city.currentDay.getTemp())) + "\u{00B0}"
        
        self.humidityLabel.text = String(Int(self.city.currentDay.getHumidity())) + "%"
        
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
//        print(weatherAPI.getCurrentWeather(for: location))
        city = City(cityName: location, andMetric: false) // until we get the toggle, I am setting this false
        forecast = self.city.forecast
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateCurrentWeather()
//            self.tableView.tableHeaderView = self.createTableHeader()
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let day:Day = forecast[indexPath.row] as! Day

        cell.day_label.text = String(day.getTheDayOfWeek())
        cell.temperature_label.text = String(round(day.getTemp()))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SpecificWeather", sender: self)
    }

}
