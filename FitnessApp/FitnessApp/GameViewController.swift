//
//  GameViewController.swift
//  FitnessApp
//
//  Created by Matthew Lee on 10/14/20.
//

import UIKit
import SpriteKit

protocol gameDelegateProtocol {
    func disableGameButton()
}

class GameViewController: UIViewController, arenaDelegateProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        //setup game scene
        let scene = Arena(size: view.bounds.size)
        scene.lives = 5
        scene.gameController = self
        let skView = view as! SKView // the view in storyboard must be an SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func endGame() {
        //Return to main screen
        dismiss(animated: true, completion: nil)
    }
    


}
