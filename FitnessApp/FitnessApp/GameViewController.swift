//
//  GameViewController.swift
//  FitnessApp
//
//  Created by Matthew Lee on 10/14/20.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, arenaDelegateProtocol {
    var numLives = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        //setup game scene
        let scene = Arena(size: view.bounds.size)
        scene.lives = 5
        scene.gameController = self
        scene.lives = self.numLives
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // Dismiss game screen when lives are expended
    func endGame() {
        //Return to main screen
        dismiss(animated: true, completion: nil)
    }
    


}
