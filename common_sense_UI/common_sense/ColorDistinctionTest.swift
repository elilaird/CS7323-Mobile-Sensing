//
//  ColorDistinctionTest.swift
//  common_sense
//
//  Created by Clay Harper on 12/6/20.
//

import Foundation
import UIKit

class ColorDistinction: UIViewController, URLSessionDelegate {

    @IBOutlet weak var leftColorView: UIView!
    @IBOutlet weak var rightColorView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    // New cleaner variables
    let operationQueue = OperationQueue()
    var currentDeltaE: Float = 1.0 // Start with the same value in the adjustor
    var currentColorPair = ColorPair(leftColor: Color(r: 0, g: 0, b: 0), rightColor: Color(r: 0, g: 0, b: 0))
    var colorPairsAtDeltaE: [ColorPair] = []
    var currentDeltaEAffirmativeCount: Int = 0
    var perceptibilityScore: Float = 0
    
    let deAdjustor = DeltaEAdjustor()
    let dataInterface = DataInterface()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        yesButton.layer.cornerRadius = 30
        yesButton.layer.borderWidth = 5
        yesButton.layer.borderColor = UIColor.green.cgColor
//        yesButton.backgroundColor = .green
        
        noButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        noButton.layer.cornerRadius = 30
        noButton.layer.borderWidth = 5
        noButton.layer.borderColor = UIColor.red.cgColor
        
        // Get the delta E value that we want to investigate from the DeltaEAdjustor (starts at 1)
        currentDeltaE = deAdjustor.adjustDeltaE()
        
        // Get data
        serverGetColorsSetup(deltaE: currentDeltaE)
    }
    
    
    @IBAction func yesClick(_ sender: Any) {
        // Add to affirmative answers
        currentDeltaEAffirmativeCount += 1

        // Setup the next comparison
        setupNextComparison()
    }
    
    @IBAction func noClick(_ sender: Any) {
        // Still testing
        
        // Setup the next comparison
        setupNextComparison()

    }
    
    func setupNextComparison(){
        // Get the next color pair
        getNextPair()
        
        // Update the UI
        displayComparison()
    }
    
    func isLastComparison() -> Bool{
        return deAdjustor.shouldAdjustDeltaE()
    }
    
    func displayComparison(){
        let leftColor = currentColorPair.leftColor
        let rightColor = currentColorPair.rightColor
        
        DispatchQueue.main.async {
            self.leftColorView.layer.backgroundColor = UIColor(red: leftColor.r/255, green: leftColor.g/255, blue: leftColor.b/255, alpha: 1.0).cgColor
            self.rightColorView.layer.backgroundColor = UIColor(red: rightColor.r/255, green: rightColor.g/255, blue: rightColor.b/255, alpha: 1.0).cgColor
        }
    }
    
    func segueToResults(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "visionResult")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func getNextPair(){

        // If no more comparisons at the current deltaE, get new colors -- TOD0: make work with deltaE ajdust algo
        // If went through all 3 pairs or (2/3 have already been answered yes/no) -- best 2/3 (not working for 2 no's for some reason)
        if colorPairsAtDeltaE.count == 0 || (currentDeltaEAffirmativeCount == 0 && colorPairsAtDeltaE.count == 1) || currentDeltaEAffirmativeCount == 2{
            // Use algo to get new deltaE
            if currentDeltaEAffirmativeCount == 2{
                deAdjustor.updateCouldDistinguish(couldDistinguishCurrentDeltaE: true)
            }else{
                deAdjustor.updateCouldDistinguish(couldDistinguishCurrentDeltaE: false)
            }
            
            // Check if we have enough affirmative answers
            if isLastComparison(){
                // Calculate the perceptibility score
                perceptibilityScore = deAdjustor.calculatePerceptibilityScore()
                print("Perceptibility score: \(perceptibilityScore)")
                
                dataInterface.savePerceptibilityData(perceptibilityScore: perceptibilityScore)
                
                // Segue back to main screen
                segueToResults()
            }
            
            // Request pairs from server with deltaE values
            currentDeltaE = deAdjustor.adjustDeltaE()
            
            // If we got a new delta E of greater than 40, done
            if currentDeltaE > 40{
                perceptibilityScore = 0.0
                print("Perceptibility score: \(perceptibilityScore)")
                
                dataInterface.savePerceptibilityData(perceptibilityScore: perceptibilityScore)
                
                // Segue back to main screen
                segueToResults()
            }
            
            // Get new pairs
            serverGetColorsSetup(deltaE: currentDeltaE)
            
            // Reset variables
            currentDeltaEAffirmativeCount = 0
        }else{
            // Set the current pair
            currentColorPair = colorPairsAtDeltaE.removeFirst()
        }
    }
    
    
    // MARK: Server Utilities
    func serverGetColorsSetup(deltaE: Float) {
        // create a GET request for new color pairs
        let baseURL = "\(SERVER_URL)/GetColorDeltaE?delta=" + String(deltaE)
        
        let getUrl = URL(string: baseURL)
        let request: URLRequest = URLRequest(url: getUrl!)
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    print("Response:\n%@",response!) // **** Should show that we had an issue connecting to the server and return to the main screen
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    // Set the list of colorPairsAtDeltaE
                    if jsonDictionary["PairA"] != nil{
                        self.convertDictToColorPairs(with: jsonDictionary)
                        self.currentColorPair = self.colorPairsAtDeltaE.removeFirst()
                        self.displayComparison()
                    }
                
                }
                
        })
        
        dataTask.resume() // start the task
    }
    
    func convertDictToColorPairs(with dict:NSDictionary){
        
        let pairA = dict["PairA"]
        let pairB = dict["PairB"]
        let pairC = dict["PairC"]
        var newPairs: [ColorPair] = []
        
        for pair in [pairA, pairB, pairC]{
            newPairs.append(getPair(pairDict: pair as! NSDictionary))
        }

        // Set self attributes for the current color pairs
        self.colorPairsAtDeltaE = newPairs
    }
    
    func getPair(pairDict: NSDictionary) -> ColorPair{
        let colorAStr = pairDict["colorA"]
        let colorBStr = pairDict["colorB"]
        
        let colorA = colorFromString(colorStr: colorAStr as! String)
        let colorB = colorFromString(colorStr: colorBStr as! String)
        
        return ColorPair(leftColor: colorA, rightColor: colorB)
    }

    func colorFromString(colorStr: String) -> Color{
        var startStr = colorStr
        // Remove parenthesis and spaces
        startStr = startStr.replacingOccurrences(of: "(", with: "")
        startStr = startStr.replacingOccurrences(of: ")", with: "")
        startStr = startStr.replacingOccurrences(of: " ", with: "")
        
        //Split the string by commas
        let strNumbers = startStr.components(separatedBy: ",")
        
        // Make a color and return it
        return Color(r: CGFloat(Int(strNumbers[0])!), g: CGFloat(Int(strNumbers[1])!), b: CGFloat(Int(strNumbers[2])!))
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }
    
}

extension Collection where Iterator.Element == Int {
    var convertToDouble: [Double] {
        return compactMap{ Double($0) }
    }
    var convertToFloat: [Float] {
        return compactMap{ Float($0) }
    }
}
