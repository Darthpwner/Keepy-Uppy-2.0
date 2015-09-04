//
//  GameScene.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    //Restitution == how much energy the physics body loses when it bounces
    let basketballRestitution: CGFloat = 0.5
    let beachBallRestitution: CGFloat = 0.8
    let bowlingBallRestiution: CGFloat = 0.2
    
    //Add feature to have more balls later
    let ball = SKSpriteNode(imageNamed: "Basketball.jpg");
    //let ball = SKSpriteNode(imageNamed: "Beach Ball.jpg");
    //let ball = SKSpriteNode(imageNamed: "Bowling Ball.jpg");
    
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
        
        ball.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)  //Set the ball's position
        addChild(ball)  //Add ball to the display list
        
        // this is the most important line, we define the body
        ball.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.size.width/2)  //Not sure why this needs to be shape???
        
        //if basketball
        setPhysicsAttributes(0.3, restitution: basketballRestitution, mass: 0.5)
        //else if beach ball
        //setPhysicsAttributes(0.3, restitution: beachBallRestitution, mass: 0.5)
        //else (bowling ball)
        //setPhysicsAttributes(0.3, restitution: bowlingBallRestiution, mass: 0.5)

        // this will allow the balls to rotate when bouncing off each other
        ball.physicsBody!.allowsRotation = true
    }
    
    // this defines the mass, roughness and bounciness
    func setPhysicsAttributes(friction: CGFloat, restitution: CGFloat, mass: CGFloat) {
        ball.physicsBody!.friction = friction
        ball.physicsBody!.restitution = restitution
        ball.physicsBody!.mass = mass
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
