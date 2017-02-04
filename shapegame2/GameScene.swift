//
//  GameScene.swift
//  shapegame2
//
//  Created by Cameron on 1/28/17.
//  Copyright © 2017 Cameron. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player : SKShapeNode!
    var touchIndicator : SKShapeNode!
    var boundaries: SKNode!
    var moving: SKNode!
    var moveBoundariesAndRemove: SKAction!
    var previousUpperY = CGFloat(200)
    var previousLowerY = CGFloat(200)
    var playerSize = CGFloat(20)
    var minOpeningSize: CGFloat!
    
    let playerCategory: UInt32 = 1 << 0
    let boundaryCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    override func didMove(to view: SKView) {
    
        setupWorld()
        setupPlayer()
        setupTouchIndicator()
        setupBoundaryMovement()
    }
    
    func setupWorld() {
        
        backgroundColor = SKColor.darkGray
        
        minOpeningSize = playerSize * 1.5
        self.physicsWorld.gravity = CGVector( dx: 0.0, dy: -5.0)
        self.physicsWorld.contactDelegate = self
    }
    
    func setupPlayer() {
        
        player = SKShapeNode(circleOfRadius: playerSize)
        player.position = CGPoint(x: (frame.size.width / 3), y: (frame.size.width / 2))
        player.fillColor = UIColor.white
        player.lineWidth = 0
        player.physicsBody = SKPhysicsBody(circleOfRadius: playerSize)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask =  boundaryCategory
        player.physicsBody?.contactTestBitMask = boundaryCategory
        addChild(player)
    }
    
    func setupTouchIndicator() {
        
        touchIndicator = SKShapeNode()
        touchIndicator.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 30, height: 30)).cgPath
        touchIndicator.lineWidth = 0
        touchIndicator.alpha = 0
        touchIndicator.zPosition = 1
        addChild(touchIndicator)
    }
    
    func setupBoundaryMovement() {
        
        moving = SKNode()
        self.addChild(moving)
        boundaries = SKNode()
        moving.addChild(boundaries)
        
        let distanceToMove = CGFloat(self.frame.size.width)
        let moveBoundaries = SKAction.moveBy(x: -distanceToMove - 200, y: 0.0, duration: TimeInterval(3))
        let removeBoundaries = SKAction.removeFromParent()
        moveBoundariesAndRemove = SKAction.sequence([moveBoundaries, removeBoundaries])
        
        let spawn = SKAction.run(spawnBoundaries)
        let delay = SKAction.wait(forDuration: TimeInterval(0.05))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        moving.speed = 0
    }
    
    func spawnBoundaries() {
        
        let boundaryPair = SKNode()
        let x = CGFloat(25)
        var lowerY = previousLowerY * randomNumber(lower: 0.76, upper: 1.25)
        var upperY = previousUpperY * randomNumber(lower: 0.76, upper: 1.25)
        
        let randomAddYEvent = UInt32(randomNumber(lower: 0, upper: 20))
        if (randomAddYEvent == 0) {
            lowerY += 200
        }
        else if (randomAddYEvent == 1) {
            upperY += 200
        }
        
        if ((lowerY + upperY) > (self.frame.maxY - minOpeningSize)) {
            
            let overflow = (lowerY + upperY - (self.frame.maxY - minOpeningSize)) / 2
            
            lowerY = max(lowerY - overflow, 0)
            upperY = max(upperY - overflow, 0)
        }
        
        previousLowerY = lowerY
        previousUpperY = upperY
        
        let upperBoundary = SKShapeNode(rectOf: CGSize(width: x, height: upperY))
        upperBoundary.fillColor = UIColor.white
        upperBoundary.position = CGPoint(x: frame.maxX, y: frame.maxY)
        upperBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: x, height: upperY))
        upperBoundary.physicsBody?.isDynamic = false
        upperBoundary.physicsBody?.categoryBitMask = boundaryCategory
        upperBoundary.physicsBody?.contactTestBitMask = playerCategory
        boundaryPair.addChild(upperBoundary)
        
        let lowerBoundary = SKShapeNode(rectOf: CGSize(width:x, height:lowerY))
        lowerBoundary.fillColor = UIColor.white
        lowerBoundary.position = CGPoint(x: frame.maxX, y: frame.minY)
        lowerBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: x, height: lowerY))
        lowerBoundary.physicsBody?.isDynamic = false
        lowerBoundary.physicsBody?.categoryBitMask = boundaryCategory
        lowerBoundary.physicsBody?.contactTestBitMask = playerCategory
        boundaryPair.addChild(lowerBoundary)
        
        boundaryPair.run(moveBoundariesAndRemove)
        
        boundaries.addChild(boundaryPair)
        
    }
    
    func touchMoved(touch: UITouch) {
        
        
        var touchLocation: CGPoint = touch.location(in: view)
        touchLocation = self.convertPoint(fromView: touchLocation)
        let scale = touch.force * 1.25
        touchIndicator.setScale(scale)
        touchLocation.x -= (touchIndicator.path?.boundingBox.width)! * scale / 2
        touchLocation.y -= (touchIndicator.path?.boundingBox.width)! * scale / 2
        touchIndicator.position = touchLocation
        
        //let r = 255 * (touch.force / 6.7)
        //let g = (255 * (max - scale)) / max
        //let g = CGFloat(0.0)
        //let b = CGFloat(0.0)
        //touchIndicator.fillColor = UIColor(red: r, green: g, blue: b, alpha: 0.7)
        touchIndicator.fillColor = .magenta
        touchIndicator.alpha = 0.75
        
        self.player.physicsBody?.velocity = CGVector( dx: 0.0, dy: ((self.player.physicsBody?.velocity.dy)! + (touch.force * touch.force)))
    }
    
    func touchEnded(touch: UITouch) {
        touchIndicator.alpha = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if moving.speed == 0 {
            self.resetScene()
        }
        
        for t in touches { self.touchMoved(touch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(touch: t) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchEnded(touch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(touch: t) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func resetScene() {
        
        moving.speed = 1
        player.speed = 1
        player.physicsBody?.velocity = CGVector()
        player.physicsBody?.collisionBitMask =  boundaryCategory
        boundaries.removeAllChildren()
        player.position = CGPoint(x: (frame.size.width / 3), y: (frame.size.width / 2))
        
        previousUpperY = CGFloat(200)
        previousLowerY = CGFloat(200)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        moving.speed = 0
        player.speed = 0
    }
    
    func randomNumber(lower: CGFloat, upper: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(lower - upper) + lower
    }
}
