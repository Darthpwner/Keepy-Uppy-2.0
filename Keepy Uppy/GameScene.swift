//
//  GameScene.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //Add feature to have more balls later
    let ball = SKSpriteNode(imageNamed: "Basketball.jpg");
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }

    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "Load Screen.jpg")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
    runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))
    }
    
    func playSound(sound: String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override func didMoveToView(view: SKView) {
        // we live in a world with gravity on the y axis
        self.physicsWorld.gravity = CGVectorMake(0, -6)
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        let physicsBody = SKPhysicsBody (edgeLoopFromRect: self.frame)
        // we set the body defining the physics to our scene
        self.physicsBody = physicsBody
        
        // SkShapeNode is a primitive for drawing like with the AS3 Drawing API
        // it has built in support for primitives like a circle, so we pass a radius
        let shape = SKShapeNode(circleOfRadius: 20)
        // we set the color and line style
        shape.strokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
        shape.lineWidth = 4
        
        // we add each circle to the display list
        self.addChild(shape)
        
        // this is the most important line, we define the body
        shape.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.size.width/2)
        // this defines the mass, roughness and bounciness
        shape.physicsBody!.friction = 0.3
        shape.physicsBody!.restitution = 0.8
        shape.physicsBody!.mass = 0.5
        // this will allow the balls to rotate when bouncing off each other
        shape.physicsBody!.allowsRotation = true

        
        ball.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)  //Set the ball's position
        addChild(ball)  //Add ball to the display list
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.size.width/2)
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
