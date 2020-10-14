//
//  ViewController.swift
//  FitnessApp
//
//  Created by Eli Laird on 10/12/20.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var circularProgress: CircularProgressView!
    
    @IBOutlet weak var stepGoal: UILabel!
    @IBOutlet weak var stepsYesterday: UILabel!
    @IBOutlet weak var stepsToday: UILabel!
    @IBOutlet weak var stepGoalSlider: UISlider!
    @IBOutlet weak var activity: UILabel!
    @IBOutlet weak var stepsTillGoal: UILabel!
    @IBOutlet weak var penguinGame: UIButton!
    
    
    //core motion
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
    //steps
    var goalSteps: Float = 500.0 {
        willSet(newGoal){
            DispatchQueue.main.async{
                self.saveGoal()
            }
        }
    }
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.stepsToday.text = "\(Int(newtotalSteps))"
                self.updateStepsTillGoal()
                self.updateProgress()
            }
        }
    }
    var yesterdaySteps: Float = 0.0 {
        willSet(steps){
            DispatchQueue.main.async {
                self.stepsYesterday.text = "\(Int(steps))"
            }
        }
    }

    
    //activity
    var currentActivity: String = "Stationary" {
        willSet(newactivity){
            DispatchQueue.main.async{
                self.activity.text = "\(newactivity)"
            }
        }
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularProgress.trackClr = UIColor.cyan
        circularProgress.progressClr = UIColor.purple
        
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        self.penguinGame.isEnabled = false
        
        self.loadGoal()
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = today.addingTimeInterval(-60*60*24)
        
        self.setTodaySteps(from: today, to: Date())
        
        self.updateStepsTillGoal()
        
        self.setYesterdaySteps(from: yesterday, to: today)
        

    }
    
    @IBAction func setGoal(_ sender: Any) {
        self.goalSteps = stepGoalSlider.value
        self.stepGoal.text = "\(Int(self.goalSteps))"
        self.updateStepsTillGoal()
        self.updateProgress()
    }
    
    func updateStepsTillGoal(){
        if Int(self.goalSteps - self.totalSteps) > 0 {
            self.stepsTillGoal.text = "\(Int(self.goalSteps - self.totalSteps))"
        }else{
            self.stepsTillGoal.text = "\(0)"
        }
    }
    
    func saveGoal() {
        UserDefaults.standard.set(self.goalSteps, forKey:"Goal")
    }
    
    func loadGoal() {
        if UserDefaults.standard.object(forKey:"Goal") == nil {
            self.saveGoal()
        }
        self.goalSteps = UserDefaults.standard.object(forKey:"Goal") as! Float
    }
    
    //MARK: Circular Progress Utils
    
    func updateProgress(){
        let progress:Float = self.totalSteps / self.goalSteps
        circularProgress.setProgressWithAnimation(duration: 1.0, value: progress)
        
        if self.totalSteps >= self.goalSteps {
            self.penguinGame.isEnabled = true
        }
    }

    // MARK: =====Activity Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
        
    }
    
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            DispatchQueue.main.async{
                let isWalking = unwrappedActivity.walking
                let isRunning = unwrappedActivity.running
                let isStationary = unwrappedActivity.stationary
                let isAutomotive = unwrappedActivity.automotive
                let isCycling = unwrappedActivity.cycling
                let unkown = unwrappedActivity.unknown
                
                if isWalking{
                    self.currentActivity = "Walking"
                } else if isRunning{
                    self.currentActivity = "Running"
                } else if isCycling{
                    self.currentActivity = "Cycling"
                } else if isAutomotive{
                    self.currentActivity = "Driving"
                } else if isStationary{
                    self.currentActivity = "Stationary"
                } else if unkown{
                    self.currentActivity = "Unkown"
                }
            }
        }
    }
    
    // MARK: =====Pedometer Methods=====
    func startPedometerMonitoring(){
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date(),
                                   withHandler: handlePedometer)
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?)->(){
        if let steps = pedData?.numberOfSteps {
            self.totalSteps = steps.floatValue
        }
    }
    
    func setTodaySteps(from today:Date, to now:Date){
        self.pedometer.queryPedometerData(from: today, to: now, withHandler: handlePedometer)
    }
    
    func handleYesterdayPedometer(_ pedData:CMPedometerData?, error:Error?)->(){
        if let yestSteps = pedData?.numberOfSteps {
            self.yesterdaySteps = yestSteps.floatValue
        }
    }
    
    //get previous steps
    func setYesterdaySteps(from yesterday:Date, to today:Date){
        self.pedometer.queryPedometerData(from: yesterday, to: today, withHandler: handleYesterdayPedometer)
    }
}

