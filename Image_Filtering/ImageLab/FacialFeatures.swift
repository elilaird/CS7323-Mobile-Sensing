//
//  ViewController.swift
//  ImageLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//
import UIKit
import AVFoundation

class FacialFeatures: UIViewController   {

    //MARK: Class Properties
    @IBOutlet weak var smilingLabel: UILabel!
    var eyeFilters : [CIFilter]! = nil
    var mouthFilters : [CIFilter]! = nil
    let bridge = OpenCVBridge()
    lazy var videoManager:VideoAnalgesic! = {
        let tmpManager = VideoAnalgesic(mainView: self.view)
        tmpManager.setCameraPosition(position: .back)
        return tmpManager
    }()
    
    lazy var detector:CIDetector! = {
        // create dictionary for face detection
        // HINT: you need to manipulate these properties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh,
                            CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        return detector
    }()
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bridge.smilingText(true)
        
//        self.view.bringSubviewToFront(smilingLabel);
        smilingLabel.layer.zPosition = 1;
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.bringSubviewToFront(smilingLabel);
        smilingLabel.layer.zPosition = 1
    }
    
    //MARK: Setup filtering
    func setupFilters(){
        eyeFilters = []
        mouthFilters = []
        
        var filterPinch = CIFilter(name:"CIBumpDistortion")!
        filterPinch.setValue(-1, forKey: "inputScale")
        filterPinch.setValue(75, forKey: "inputRadius")
        mouthFilters.append(filterPinch)
        
        
        filterPinch = CIFilter(name:"CITwirlDistortion")!
        filterPinch.setValue(20, forKey: "inputRadius")
        filterPinch.setValue(20, forKey: "inputAngle")
        eyeFilters.append(filterPinch)
        
    }
    
    
    //MARK: Apply filters and apply feature detectors
    func applyFiltersToFaces(inputImage:CIImage, facialFeatures:[(String, CGPoint)])->CIImage{
        var retImage = inputImage
        
        for (featureType, filterCenter) in facialFeatures {
            
            //do for each filter (assumes all filters have property, "inputCenter")
            if featureType == "eye"{
                for filt in eyeFilters{
                    filt.setValue(retImage, forKey: kCIInputImageKey)
                    filt.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                    // could also manipulate the radius of the filter based on face size!
                    retImage = filt.outputImage!
                }
            }
            if featureType == "mouth"{
                for filt in mouthFilters{
                    filt.setValue(retImage, forKey: kCIInputImageKey)
                    filt.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                    // could also manipulate the radius of the filter based on face size!
                    retImage = filt.outputImage!
                }
            }
    
        }
        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
        self.bridge.smilingText(true)
        self.bridge.processFinger()
//        let rect = CGRect(origin: point, size: image.size)
//        "Smiling".draw(in: rect, withAttributes: textFontAttributes)
//        smilingLabel.layer.zPosition = 1;
        return retImage
    }
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    func getFacialFeatures(faces:[CIFaceFeature])-> [(String, CGPoint)] {
        
        var facialFeatures:[(featureType: String, location: CGPoint)] = []
        
        // for each face
        for f in faces{
            // get the left eye, right eye, and mouth
            if f.hasLeftEyePosition{
                facialFeatures.append((featureType: "eye", location: f.leftEyePosition))
            }
            if f.hasRightEyePosition{
                facialFeatures.append((featureType: "eye", location: f.rightEyePosition))
            }
            if f.hasMouthPosition{
                facialFeatures.append((featureType: "mouth", location: f.mouthPosition))
            }
        }
        return facialFeatures
        
    }
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        
        // detect faces
        let faces = getFaces(img: inputImage)
        
        // get facial features
        let facialFeatures = getFacialFeatures(faces: faces)
        
        // if no faces, just return original image
        if faces.count == 0 { return inputImage }
        
        //otherwise apply the filters to the faces
        return applyFiltersToFaces(inputImage: inputImage, facialFeatures: facialFeatures)
    }
}
