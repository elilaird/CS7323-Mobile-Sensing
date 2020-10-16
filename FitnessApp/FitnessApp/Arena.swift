//
//  Arena.swift
//  FitnessApp
//
//  Created by Matthew Lee on 10/14/20.
//

import UIKit
import SpriteKit
import CoreMotion

// Use delegation to signal view to return to main screen
protocol arenaDelegateProtocol {
    func endGame()
}

class Arena:SKScene, SKPhysicsContactDelegate {
    
    var gameController: arenaDelegateProtocol? = nil

    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    func startMotionUpdates(){
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
    }
    
    // MARK: Main Sprites
    let penguin = SKSpriteNode(imageNamed: "penguin")
    let hotChocolate = SKSpriteNode(imageNamed: "hot_chocolate")
    let scoreLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    let livesLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    //var playingField = Array(repeating: Array(repeating: false, count: 5), count: 5)
    
    // Keep track of score and lives
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    var lives:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.livesLabel.text = "Lives: \(newValue)"
            }
        }
    }
    
    // Set up arena for the first time
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        // Swipe to exit game
        let swipe : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
        swipe.direction = .right
        self.view?.addGestureRecognizer(swipe)
        
        // start motion for gravity
        self.startMotionUpdates()
        self.generatePlayingField()
        self.addSidesAndTop()
        self.addHotChocolate()
        self.addPenguin()
        
        self.addLives()
        self.addScore()

    }
    
    // MARK: Generate Sprites
    func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width*0.25, y: size.height*0.925)
        
        self.addChild(scoreLabel)
    }
    
    func addLives(){
        livesLabel.text = "Lives: 0"
        livesLabel.fontSize = 30
        livesLabel.fontColor = SKColor.white
        livesLabel.position = CGPoint(x: size.width*0.75, y: size.height*0.925)
        self.addChild(livesLabel)
    }
    
    // Add penguin to scene
    func addPenguin(){
        penguin.size = CGSize(width:size.width*0.1,height:size.height * 0.08)
        penguin.position = CGPoint(x: size.width/2, y: size.height*0.1)
        
        penguin.physicsBody = SKPhysicsBody(rectangleOf:penguin.size)
        penguin.physicsBody?.restitution = 0.5
        penguin.physicsBody?.isDynamic = true
        penguin.physicsBody?.contactTestBitMask = 0x00000001
        penguin.physicsBody?.collisionBitMask = 0x00000001
        penguin.physicsBody?.categoryBitMask = 0x00000001
        penguin.physicsBody?.allowsRotation = false
        
        self.addChild(penguin)
    }
    
    // Add hot chocolate goal
    func addHotChocolate(){
        hotChocolate.size = CGSize(width:size.width*0.15,height:size.height * 0.07)
        hotChocolate.position = CGPoint(x: size.width/2, y: size.height*(1-0.1375))
        hotChocolate.physicsBody = SKPhysicsBody(rectangleOf:hotChocolate.size)
        hotChocolate.physicsBody?.isDynamic = true
        hotChocolate.physicsBody?.pinned = true
        hotChocolate.physicsBody?.allowsRotation = false
        hotChocolate.name = "hotChocolate"
        
        self.addChild(hotChocolate)
    }
    
    // Generate orca or hole in the ice at a location
    func addObstacleAtPoint(_ point:CGPoint){
        let obstacleType = Bool.random()
        var obstacleSprite = ""
        if(obstacleType){
            obstacleSprite = "orca"
        }else{
            obstacleSprite = "hole"
        }
        
        let obstacle = SKSpriteNode(imageNamed: obstacleSprite)
        obstacle.name = "obstacle"
        
        obstacle.color = UIColor.red
        obstacle.size = CGSize(width:size.width*0.18,height:size.height * 0.1)
        obstacle.position = point
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf:obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.pinned = true
        obstacle.physicsBody?.allowsRotation = false
        
        self.addChild(obstacle)
    }
    
    // Create borders of arena
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        let bottom = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.05,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.05,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.2)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        bottom.size = CGSize(width:size.width,height:size.height*0.05)
        bottom.position = CGPoint(x:size.width*0.5, y:0)
        
        for obj in [left,right, top, bottom]{
            obj.color = UIColor.blue
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // Randomly generate playing field based on rough grid
    // Add more obstacles as score increases
    func generatePlayingField(){
        // Set up obstacles
        var playingField = Array(repeating: Array(repeating: false, count: 5), count: 4)
        for i in Range(0...min(self.score,3)){
            playingField[i][Int.random(in: Range(0...4))] = true
        }
        for (i, row) in playingField.enumerated(){
            for (j, col) in row.enumerated(){
                if col == true {
                    let w = size.width*(0.025 + (CGFloat(j) * 0.19) + 0.095)
                    let h = size.height*(0.185 + (CGFloat(i) * 0.16) + 0.08)
                    self.addObstacleAtPoint(CGPoint(x: w, y: h))
                }
            }
        }
    }
    
    // Reset field and penguin position
    func resetField(){
        self.children.filter({ $0.name == "obstacle" }).forEach({
            $0.removeFromParent()
        })
        penguin.removeFromParent()
        addPenguin()
        self.generatePlayingField()

    }
    
    // Close game if player hits an obstacle with 0 lives, other wise lose life and reset penguin
    func onHitObstacle(){
        // Return to main screen
        if lives == 0{
            if self.gameController != nil  {
                self.gameController?.endGame()
            }
        }else{
            lives += -1
            penguin.removeFromParent()
            addPenguin()
        }
    }
    
    // Reset game and increment score
    func onReachGoal(){
        self.score += 1
        self.resetField()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "obstacle" || contact.bodyB.node?.name == "obstacle" {
            onHitObstacle()
        }else if contact.bodyA.node?.name == "hotChocolate" || contact.bodyB.node?.name == "hotChocolate" {
            onReachGoal()
        }
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer){
        self.gameController?.endGame()
    }
    
    
    
}

