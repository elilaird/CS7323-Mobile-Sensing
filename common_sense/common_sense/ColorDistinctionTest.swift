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
    var affirmativeAnswersDeltaE:[Float] = []
    let numAffirmativeRequired = 10
    var currentDeltaE: Float = 30 // Start with the same value in the adjustor
    var currentColorPair = ColorPair(leftColor: Color(r: 0, g: 0, b: 0), rightColor: Color(r: 0, g: 0, b: 0))
    var colorPairsAtDeltaE: [ColorPair] = []
    var currentDeltaEAffirmativeCount: Int = 0
    
    let deAdjustor = DeltaEAdjustor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the first comparison
//        colorPairsAtDeltaE = dummyGetColorsWithDeltaE()
//        serverGetColors(deltaE: currentDeltaE)
//
//        // Since async call, this can cause an issue.
//        currentColorPair = colorPairsAtDeltaE.removeFirst()
//        displayComparison()
        
        // Might be good for loading in the future: https://www.raywenderlich.com/35-alamofire-tutorial-getting-started
        serverGetColorsSetup(deltaE: currentDeltaE)
        
        print(calculatePerceptibilityScore(deltaE: 0))
        print(calculatePerceptibilityScore(deltaE: 7))
        
    }
    
    
    @IBAction func yesClick(_ sender: Any) {
        // Add to affirmative answers
        affirmativeAnswersDeltaE.append(currentDeltaE)
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
        return deAdjustor.dummyShouldAdjustDeltaE()
    }
    
    func displayComparison(){
        let leftColor = currentColorPair.leftColor
        let rightColor = currentColorPair.rightColor
        
        DispatchQueue.main.async {
            self.leftColorView.layer.backgroundColor = UIColor(red: leftColor.r/255, green: leftColor.g/255, blue: leftColor.b/255, alpha: 1.0).cgColor
            self.rightColorView.layer.backgroundColor = UIColor(red: rightColor.r/255, green: rightColor.g/255, blue: rightColor.b/255, alpha: 1.0).cgColor
        }
    }
    
    func segueBackToMain(){
        
        // Return to main screen
        if let mainView = self.navigationController?.viewControllers.first{
            self.navigationController?.popToViewController(mainView, animated: true)
        }
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
                // Segue back to main screen
                segueBackToMain()  // Deallocate these variables or is this done automatically?? -- TODO
            }
            
            
            // Request pairs from server with deltaE values
            
            // DUMMY DATA: just making it run right now
//            colorPairsAtDeltaE = dummyGetColorsWithDeltaE()
            serverGetColors(deltaE: 5.0)
            
            // Reset variables
            currentDeltaEAffirmativeCount = 0
        }
        
        // Set the current pair
        currentColorPair = colorPairsAtDeltaE.removeFirst()
    }
    
    func serverGetColors(deltaE: Float) {
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
                    
//                    // This better be an integer
//                    if let dsid = jsonDictionary["dsid"]{
//                        self.dsid = dsid as! Int
//                    }
                    self.convertDictToColorPairs(with: jsonDictionary)
                }
                
        })
        
        dataTask.resume() // start the task
    }
    
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
                    
//                    // This better be an integer
//                    if let dsid = jsonDictionary["dsid"]{
//                        self.dsid = dsid as! Int
//                    }
                    self.convertDictToColorPairs(with: jsonDictionary)
                    self.currentColorPair = self.colorPairsAtDeltaE.removeFirst()
                    self.displayComparison()
                }
                
        })
        
        dataTask.resume() // start the task
    }
    
    func convertDictToColorPairs(with dict:NSDictionary){
        
        let pairA = dict["PairA"]
        let pairB = dict["PairB"]
        let pairC = dict["PairC"]
        var newPairs: [ColorPair] = []
        print(dict)
        
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
    
    
    // DUMMY FUNCTIONS FOR RIGHT NOW
    func dummyGetColorsWithDeltaE() -> [ColorPair]{

        var colors: [ColorPair] = []
        
        for _ in 1...3{
            var rr = Int.random(in: 0..<256)
            var rg = Int.random(in: 0..<256)
            var rb = Int.random(in: 0..<256)
            
            var (cr, cg, cb) = dummyMakeCGFloatColor(color: (rr, rg, rb))
            let color = Color(r: cr, g: cg, b: cb)
            
            rr = Int.random(in: 0..<256)
            rg = Int.random(in: 0..<256)
            rb = Int.random(in: 0..<256)
            
            (cr, cg, cb) = dummyMakeCGFloatColor(color: (rr, rg, rb))
            let color2 = Color(r: cr, g: cg, b: cb)
            
            colors.append(ColorPair(leftColor: color, rightColor: color2))
        }
        
        return colors
    }
    
    func dummyMakeCGFloatColor(color: (Int, Int, Int)) -> (CGFloat, CGFloat, CGFloat){
        let (r, g, b) = color
        let newR = CGFloat(r)
        let newG = CGFloat(g)
        let newB = CGFloat(b)
        return (newR, newG, newB)
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
