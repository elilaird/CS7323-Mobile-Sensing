//
//  WeatherCollectionController.swift
//  lab1_weather
//
//  Created by Matthew on 9/7/20.
//  Copyright © 2020 Mobile Sensing. All rights reserved.
//

import UIKit

class WeatherCollectionController: UICollectionViewController {
    
    var day:Day? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttributeTile", for: indexPath) as! AttributeCollectionViewCell
        cell.backgroundColor = UIColor.blue
        cell.attributeTitle.text = "Yo"
        cell.attributeValue.text = "Yo"
            
            
        return cell
    }

}
