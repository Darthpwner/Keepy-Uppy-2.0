//
//  GameScene.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

//Actual game play scene
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var lives: Int = 3
    
    //Note: internal lets you use it in any other source file!
    //Determine ball type
    let chooseBall = GetBallType.sharedInstance
    //Determine background type
    let chooseBackground = GetBackgroundType.sharedInstance
    
    //From Flappy Bird example
    var temporaryBall: SKSpriteNode!
    var moving:SKNode!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    var background: SKSpriteNode!
    var ball: SKSpriteNode!
    //
    
    //Restitution == how much energy the physics body loses when it bounces
    let basketballRestitution: CGFloat = 0.5
    let beachBallRestitution: CGFloat = 0.8
    let bowlingBallRestiution: CGFloat = 0.2
    
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    override init(size: CGSize) {
        super.init(size: size)
        
        println("LOL INIT")
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        //Basketball and Bowling ball size is good
        //Beach ball is BAD!
        assignBall()
        println(chooseBall.ballType)

        assignBackground()
        
        //Add background
        setUpBackground(background)
        
        //Unknown
        addChild(gameLayer)
        
//        let gameBoardTexture = SKTexture(imageNamed: "Beach Background.jpg")
//        
        shapeLayer.position = LayerPosition
        gameLayer.addChild(shapeLayer)
    }

    required init(coder decoder: NSCoder) {
        super.init()
    }
    
    func playSound(sound: String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override func didMoveToView(view: SKView) {
        
        canRestart = false  //Prevent restarts
        
        // Creates the Physics of the game
        setUpPhysics()  //1
        
        //setUpBackground()   //2
        
        setUpGround()   //3
        
        setUpWalls()    //4
        
        setUpBall() //5
        
        createGround()  //6
        
        createRecords() //7
        /////////////////////////////////////////
        
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // we set the body defining the physics to our scene
        self.physicsBody = physicsBody
        
        // SkShapeNode is a primitive for drawing like with the AS3 Drawing API
        // it has built in support for primitives like a circle, so we pass a radius
        let shape = SKShapeNode(circleOfRadius: 20)
        // we set the color and line style
        shape.strokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
        shape.lineWidth = 4

        ball.setScale(0.5)
        ball.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        
        ball.position = CGPoint(x: size.width/2, y: size.height/2)  //Set the ball's position
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
        
        // create the ground
        var ground = SKNode()
        ground.position = CGPointMake(0, background.size.height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, background.size.height * 2.0))
        ground.physicsBody?.dynamic = false
        self.addChild(ground)

    }
    
    func assignBall() -> Void {
        if chooseBall.ballType == BallType.BeachBall {
            ball = SKSpriteNode(imageNamed: "Beach Ball.png")
        } else if chooseBall.ballType == BallType.Basketball {
            ball = SKSpriteNode(imageNamed: "Basketball.png")
        } else {
            ball = SKSpriteNode(imageNamed: "Bowling Ball.png")
        }
    }
    
    func assignBackground() -> Void {
        if chooseBackground.backgroundType == BackgroundType.Desert {
            background = SKSpriteNode(imageNamed: "Desert.jpg")
        } else if chooseBackground.backgroundType == BackgroundType.Beach {
            background = SKSpriteNode(imageNamed: "Beach.jpg")
        } else {
            background = SKSpriteNode(imageNamed: "Forest.png")
        }
    }

    //1
    func setUpPhysics() -> Void {
        self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 )
        self.physicsWorld.contactDelegate = self
    }
    
    //2
    func setUpBackground(background: SKSpriteNode!) -> Void {
        background.anchorPoint = CGPointMake(0.5, 0.5)
        background.size.height = self.size.height
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(background)
    }
    
    //3
    func setUpGround() -> Void {
        
    }
    
    //4
    func setUpWalls() -> Void {
        
    }
    
    //5
    func setUpBall() -> Void {
        
    }
    
    //6
    func createGround() -> Void {
        
    }
    
    //7
    func createRecords() -> Void {
        
    }
    
    // this defines the mass, roughness and bounciness
    func setPhysicsAttributes(friction: CGFloat, restitution: CGFloat, mass: CGFloat) -> Void {
        ball.physicsBody!.friction = friction
        ball.physicsBody!.restitution = restitution
        ball.physicsBody!.mass = mass
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
