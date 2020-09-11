//
//  WeatherTableViewController.swift
//  lab1_weather
//
//  Created by Eli Laird on 8/31/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit


class WeatherTableViewController: UITableViewController, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, settingsDelegateProtocol{
    
    
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var cellControl: UISegmentedControl!
    @IBOutlet weak var cityPicker: UIPickerView!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var labelViewContainer: UIView!
    @IBOutlet weak var currentDetailsView: UIView!
    @IBOutlet weak var dismissDetailsButton: UIButton!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    var weatherAPI = WeatherAPI()
    var city = City(cityName: "Dallas", andMetric: false)
    var pickerCities: [String] = [String]()
    var timer: Timer!
    var settingsButton: UIImageView!
    var fontSize: Int!
    var daysToDisplay: Int!
    var isMetric: Bool!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingsButton = UIImageView.init(image: UIImage(systemName: "gear"))
        self.fontSize = 17
        self.daysToDisplay = 10
        self.isMetric = false
        
        //searchBar.delegate = self
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(changeBackground), userInfo: nil, repeats: true)
        
        // hide current weather details
        self.currentDetailsView.isHidden = true
        
        // make label clickable
        currentTempLabel.isUserInteractionEnabled = true
        let tapCurrentTemp = UITapGestureRecognizer.init(target: self, action: #selector(showCurrentWeatherDetail))
        currentTempLabel.addGestureRecognizer(tapCurrentTemp)
        
        self.forecast = self.city.forecast
        
        self.updateCurrentWeather()
        
        // Connect data:
        self.cityPicker.delegate = self
        self.cityPicker.dataSource = self
        

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
        
        print(city.currentDay.getTheDayOfWeek())
 
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
    
    func updateCurrentWeather(){
        self.currentTempLabel.text = String(Int(self.city.currentDay.getTemp())) + "\u{00B0}"
        
        self.humidityLabel.text = String(Int(self.city.currentDay.getHumidity())) + "%"
        self.pressureLabel.text = "\(self.city.currentDay.getPressure())"
    }
    
    @IBAction func segmentSelected(_ sender: Any) {
        self.updateForecast()
        self.tableView.reloadData()
    }

    
    

    // MARK: - Table view data source
    var forecast:NSMutableArray = []
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty{
            self.updateWeather(to: locationString)
        }
    }
    
    
    
    func updateForecast(){
        self.forecast = self.city.forecast
    }
    
    
    func updateWeather(to location: String) {
        city = City(cityName: location, andMetric: self.isMetric) // until we get the toggle, I am setting this false
        DispatchQueue.main.async {
            self.updateForecast()
            self.tableView.reloadData()
            self.updateCurrentWeather()
        }
        displayLoadingAlert()
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
        return self.daysToDisplay
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell_identifier:String
        
        switch self.cellControl.selectedSegmentIndex {
        case 0:
            cell_identifier = "Cell1"
        case 1:
            cell_identifier = "Cell2"
        case 2:
            cell_identifier = "Cell3"
        default:
            cell_identifier = "Cell1"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_identifier, for: indexPath) as! CustomTableViewCell
        let day:Day = forecast[indexPath.row] as! Day

        cell.configure(with: day, as: cell_identifier)
        cell.day_label.font = cell.day_label.font.withSize(CGFloat(self.fontSize))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SpecificWeather", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SpecificWeather"{
            let attributeView = segue.destination as? WeatherAttributeViewController
            let dayIndex = sender as? IndexPath
            attributeView?.city = self.city.getLocation()
            attributeView?.day = self.forecast[dayIndex!.row] as? Day
            
        }
        if segue.identifier == "settings"{
            let secondVC: SettingsViewController = segue.destination as! SettingsViewController
            secondVC.delegate = self
            secondVC.fontSize = Float(self.fontSize)
            secondVC.daysToDisplay = Double(self.daysToDisplay)
            secondVC.isMetric = self.city.isMetric
        }
        /*
        if let attributeView = segue.destination as? WeatherAttributeViewController,
           let cell = sender as? CustomTableViewCell,
           let day = cell.day_label?.text {
            attributeView.city = self.city.getLocation()
            print("worked")
            
        }*/
    }

    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .white
    }
    
    
    func saveSettings(fontSize: Int, metric: Bool, daysToDisplay: Int) {
        self.fontSize = fontSize
        self.isMetric = metric
        self.daysToDisplay = daysToDisplay
        self.updateWeather(to: self.city.getLocation())
        self.tableView.reloadData()
    }
}
