//
//  WeatherAttributesViewController.swift
//  lab1_weather
//
//  Created by Matthew on 9/9/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//
import UIKit

class WeatherAttributeViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var cityImageScrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var city = "Dallas"
    var day:Day? = nil
    var attributes = [String]()
    var attributeValues = [String]()
    var attributeUnits = [String]()
    
    lazy private var headerImage: UIImageView? = {
        return UIImageView.init(image: UIImage(named: "\(city)_Sky.jpg"))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        // Do any additional setup after loading the view.
        if let size = self.headerImage?.image?.size{
            self.cityImageScrollView.addSubview(self.headerImage!)
            self.cityImageScrollView.contentSize = size
            self.cityImageScrollView.delegate = self
            let scale = self.cityImageScrollView.bounds.width / size.width
            self.cityImageScrollView.minimumZoomScale = scale
            self.cityImageScrollView.maximumZoomScale = scale*2
            self.cityImageScrollView.zoomScale = scale
            
        }
        
        self.attributes.append("Pressure")
        self.attributes.append("Wind")
        self.attributes.append("Humidity")
        
        self.attributeValues.append(String(self.day!.getPressure()))
        self.attributeValues.append(String(self.day!.getWindSpeed()))
        self.attributeValues.append(String(self.day!.getHumidity()))
        
        self.attributeUnits.append("atm")
        self.attributeUnits.append("mph")
        self.attributeUnits.append("%")
        
    }
    
    func viewForZooming(in cityImageScrollView: UIScrollView) -> UIView? {
        return self.headerImage
    }
    

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.attributes.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttributeTile", for: indexPath) as! AttributeCollectionViewCell
        cell.backgroundColor = UIColor.blue
        cell.attributeTitle.text = self.attributes[indexPath.row]
        cell.attributeValue.text = self.attributeValues[indexPath.row]
        cell.attributeUnits.text = self.attributeUnits[indexPath.row]
        return cell
    }

}

