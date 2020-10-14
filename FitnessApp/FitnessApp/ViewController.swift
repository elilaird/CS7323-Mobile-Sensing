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
    
    
    
    //core motion
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var goalSteps: Float = 1000.0
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.stepsToday.text = "\(newtotalSteps)"
            }
        }
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularProgress.trackClr = UIColor.cyan
        circularProgress.progressClr = UIColor.purple
        
        self.startActivityMonitoring()
        self.startPedometerMonitoring()

    }
    
    @IBAction func setGoal(_ sender: Any) {
        self.goalSteps = stepGoalSlider.value
        self.stepGoal.text = "\(self.goalSteps)"
    }
    
    
    
    //MARK: Circular Progress Utils
    
    func updateProgress(){
        let progress:Float = self.totalSteps / self.goalSteps
        circularProgress.setProgressWithAnimation(duration: 1.0, value: progress)
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
//                self.isWalking.text = "Walking: \(unwrappedActivity.walking)\n Still: \(unwrappedActivity.stationary)"
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
}

