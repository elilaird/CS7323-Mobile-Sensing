//
//  TremorTest.swift
//  common_sense
//
//  Created by Clay Harper on 12/12/20.
//

import Foundation
import UIKit
import CoreMotion

class Tremortest: UIViewController, URLSessionDelegate {
    
    // MARK: Class Properties
    let operationQueue = OperationQueue()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    
    var ringBuffer = RingBuffer()
    let animation = CATransition()
    let motion = CMMotionManager()

    
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var holdPhoneLabel: UILabel!
    
    
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = 0.5
        
        
        // setup core motion handlers
        startMotionUpdates()

    }
    
    // MARK: Core Motion Updates
    func startMotionUpdates(){
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 1.0/200
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration {
            self.ringBuffer.addNewData(xData: accel.x, yData: accel.y, zData: accel.z)
        }
    }
    
    // MARK: Run Evaluation
    @IBAction func runTestButton(_ sender: Any) {
        // Wait a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            // Get the data from the buffer
            let xData = self.ringBuffer.x
            let yData = self.ringBuffer.y
            let zData = self.ringBuffer.z
            var mags = [Double](repeating:0, count:xData.count)
            
            for i in 0...xData.count - 1{
                mags[i] = fabs(xData[i])+fabs(yData[i])+fabs(zData[i])
            }
            
            // Get the average data magnitude
            let sumArray = Float(mags.reduce(0, +))
            let avgMag: Float = sumArray/Float(mags.count)
            
            print("Average magnitude: \(avgMag)")
            
            // Save the average magnitude
            
            // Segue back to main
            self.segueBackToMain()
        }
    }
    
    func segueBackToMain(){
        
        // Return to main screen
        if let mainView = self.navigationController?.viewControllers.first{
            self.navigationController?.popToViewController(mainView, animated: true)
        }
    }

}
