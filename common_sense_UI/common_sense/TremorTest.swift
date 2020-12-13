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
    let dataInterface = DataInterface()
    
    let darkBlue = UIColor(hex: "#0076b4bd")
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var runTestButton: UIButton!
    @IBOutlet weak var runningTestLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var runTestButtonNew: UIButton!
    
    @IBAction func cancelTestbuttonClick(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func testClick(_ sender: Any) {
        self.hideAndShow()
        
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
            self.dataInterface.saveTremorData(tremorMagnitude: avgMag)
            
            // Segue back to main
            self.segueToResults()
        }
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let startGrad = UIColor(red: 189/255, green: 234/255, blue: 238/255, alpha: 1.0).cgColor
        gradientLayer.colors = [startGrad, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
         
        self.cancelButton.layer.cornerRadius = 9
        self.cancelButton.backgroundColor = self.darkBlue
        self.cancelButton.setTitleColor(.white, for: .normal)
        
        self.runTestButtonNew.layer.cornerRadius = 9
        self.runTestButtonNew.backgroundColor = self.darkBlue
        self.runTestButtonNew.setTitleColor(.white, for: .normal)
        
        runTestButtonNew.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
    
    func hideAndShow(){
        DispatchQueue.main.async {
            self.runTestButtonNew.isHidden = true
            self.directionsLabel.isHidden = true
            self.runningTestLabel.isHidden = false
        }
    }
    
    // MARK: Run Evaluation
    @IBAction func runTestButton(_ sender: Any) {
        self.hideAndShow()
        
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
            self.dataInterface.saveTremorData(tremorMagnitude: avgMag)
            
            // Segue back to main
            self.segueToResults()
        }
    }
    
    func segueToResults(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tremorResult")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

}
