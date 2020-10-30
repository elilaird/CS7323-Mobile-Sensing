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
    var eyeFilters : [CIFilter]! = nil
    var mouthFilters : [CIFilter]! = nil
    var height: CGFloat = 0
    var width: CGFloat = 0
    let bridge = OpenCVBridge()
    lazy var videoManager:VideoAnalgesic! = {
        let tmpManager = VideoAnalgesic(mainView: self.view)
        tmpManager.setCameraPosition(position: .back)
        return tmpManager
    }()
    
    lazy var detector:CIDetector! = {
        // create dictionary for face detection
        // HINT: you need to manipulate these properties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh, CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        return detector
    }()
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        height = self.view.frame.height
        width = self.view.frame.width
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        self.bridge.setTransforms(self.videoManager.transform)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
        self.bridge.processType = 1
    
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
        let scaleHeight = retImage.extent.height/self.height
        let scaleWidth = retImage.extent.width/self.width
        
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
            if featureType == "mouth_smile" || featureType == "mouth_no_smile"{
                for filt in mouthFilters{
                    filt.setValue(retImage, forKey: kCIInputImageKey)
                    filt.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                    // could also manipulate the radius of the filter based on face size!
                    retImage = filt.outputImage!

                    self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
                    
                    let xLocation = Int(filterCenter.y * scaleHeight)
                    let yLocation = Int(filterCenter.x * scaleWidth)
                    
                    if featureType == "mouth_smile"{
                        self.bridge.smilingText(true, withXLocation: Int32(xLocation), withYLocation: Int32(yLocation))
                    }else{
                        self.bridge.smilingText(false, withXLocation: Int32(xLocation), withYLocation: Int32(yLocation))
                    }
                    retImage = self.bridge.getImage()
                }
            }
            
    
        }

        return retImage
    }
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation, CIDetectorSmile:true] as [String : Any]
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
                if f.hasSmile{
                    facialFeatures.append((featureType: "mouth_smile", location: f.mouthPosition))
                }else{
                    facialFeatures.append((featureType: "mouth_no_smile", location: f.mouthPosition))
                }
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
