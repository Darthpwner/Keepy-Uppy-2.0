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
    
    /*Constants*/
    //Determine ball type
    let chooseBall = GetBallType.sharedInstance
    //Determine background type
    let chooseBackground = GetBackgroundType.sharedInstance
    
    //Restitution == how much energy the physics body loses when it bounces
    let basketballRestitution: CGFloat = 0.5
    let beachBallRestitution: CGFloat = 0.8
    let bowlingBallRestitution: CGFloat = 0.2
    
    //Beach ball scaling factor
    let beachBallScalingFactor: CGFloat = 0.1
    //Basketball scaling factor
    let basketBallScalingFactor: CGFloat = 0.3
    //Bowling ball scaling factor
    let bowlingBallScalingFactor: CGFloat = 0.5
    
    //Game Anchor coordinate points
    let anchorX: Double = 0
    let anchorY: Double = 0.5   //y = 0.5 let's the ball drop to the bottom
    /*End of Constants*/
    
    /*Variables*/
    //From Flappy Bird example
    var temporaryBall: SKSpriteNode!
    var moving:SKNode!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    var background: SKSpriteNode!
    var ball: SKSpriteNode!
    var ground = SKNode()
    //
    
    var lives: Int = 3
    /*End of variables*/
    

//    let gameLayer = SKNode()
//    let shapeLayer = SKNode()
//    let LayerPosition = CGPoint(x: 6, y: -6)
//    
    override init(size: CGSize) {
        super.init(size: size)
        
        setUpGameAnchor()   //1
        
        assignBall()
        println(chooseBall.ballType)

        assignBackground()
        
        //Create the Phyiscs of the game
        setUpPhysics()  //2
        
        //Add background
        setUpBackground() //3
        
        setUpGround()   //4
        
        setUpWalls()    //5 TODO
        
        setUpBall() //6
        
        setUpRecords() //7 TODO
        
        //Unknown
//        addChild(gameLayer)
//       
//        shapeLayer.position = LayerPosition
//        gameLayer.addChild(shapeLayer)
        //
    }

    required init(coder decoder: NSCoder) {
        super.init()
    }
    
    func playSound(sound: String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    //Use this for gameplay
    override func didMoveToView(view: SKView) {
        
        canRestart = false  //Prevent restarts
        

        /////////////////////////////////////////
        
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        
        //FIX THIS LINE! THIS CAUSES THE CONSTRAINT PROBLEM!
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: background.frame)
        //FIX THIS LINE!
        
        // we set the body defining the physics to our scene
        self.physicsBody = physicsBody
        
        //WHY IS THIS NEEDED??????
        // SkShapeNode is a primitive for drawing like with the AS3 Drawing API
        // it has built in support for primitives like a circle, so we pass a radius
        let shape = SKShapeNode(circleOfRadius: 20)
        // we set the color and line style
        shape.strokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
        shape.lineWidth = 4

        // this is the most important line, we define the body
        ball.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.size.width/2.0)
        ball.physicsBody?.dynamic = true
        
        assignPhysicsAttributes(chooseBall.ballType!)
        
        // this will allow the balls to rotate when bouncing off each other
        ball.physicsBody!.allowsRotation = true
    }
    
    /*
        Directions in which the ball can move
                    ^
                    |
                <-  O ->
    */
    //Use to move the ball
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        //let moveBallUp = SKAction.moveToY(self.ball.size.height += 1.0, duration: 0.4)
        
        //let moveBallLeft = SKAction.moveToX(self.ball.size.width += -1.0, duration: 0.4)
        
        //let moveBallRight = SKAction.moveToX(self.ball.position += 1.0, duration: 0.4)
    
        //if directly underneath
            //moveBallUp
        //else if off to the side
            //if mouse is to the right
                //moveBallLeft
            //else if mouse is to the left
                //moveBallRight
        //else (combination of both)
            //move combined vector
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
    
    func assignPhysicsAttributes(typeOfBall: BallType) -> Void {
        if typeOfBall == BallType.BeachBall {
            setPhysicsAttributes(0.3, restitution: beachBallRestitution, mass: 0.5)
        } else if typeOfBall == BallType.Basketball {
            setPhysicsAttributes(0.3, restitution: basketballRestitution, mass: 0.5)
        } else {
            setPhysicsAttributes(0.3, restitution: bowlingBallRestitution, mass: 0.5)
        }
    }

    // this defines the mass, roughness and bounciness
    func setPhysicsAttributes(friction: CGFloat, restitution: CGFloat, mass: CGFloat) -> Void {
        ball.physicsBody!.friction = friction
        ball.physicsBody!.restitution = restitution
        ball.physicsBody!.mass = mass
    }
    
    /*Setup functions*/
    //1
    func setUpGameAnchor() -> Void {
        anchorPoint = CGPoint(x: anchorX, y: anchorY)
    }

    //2
    func setUpPhysics() -> Void {
        self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 )
        self.physicsWorld.contactDelegate = self
    }
    
    //3
    func setUpBackground() -> Void {
        self.background.anchorPoint = CGPointMake(0.5, 0.5)
        self.background.size.height = self.size.height
        self.background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(background)
    }
    
    //4
    func setUpGround() -> Void {
        self.ground.position = CGPointMake(0, background.size.height)
        self.ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, background.size.height * 2.0))
        self.ground.physicsBody?.dynamic = false
        self.addChild(self.ground)
    }
    
    //5
    func setUpWalls() -> Void {
        
    }
    
    //6
    func setUpBall() -> Void {
        if chooseBall.ballType == BallType.BeachBall {
            self.ball.setScale(beachBallScalingFactor)
        } else if chooseBall.ballType == BallType.Basketball {
            self.ball.setScale(basketBallScalingFactor)
        } else {
            self.ball.setScale(bowlingBallScalingFactor)
        }
        
        ball.anchorPoint = background.anchorPoint
        
        self.ball.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        
        addChild(ball)  //Add ball to the display list
    }
    
    //7
    func setUpRecords() -> Void {
        
    }
    /*End of setup functions*/
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
