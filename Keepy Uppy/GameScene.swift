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
    
    /*Constants*/
    //Determine ball type
    let chooseBall = GetBallType.sharedInstance
    //Determine background type
    let chooseBackground = GetBackgroundType.sharedInstance
    
    //Restitution == how much energy the physics body loses when it bounces
    let basketballRestitution: CGFloat = 0.5
    let beachBallRestitution: CGFloat = 0.8
    let bowlingBallRestitution: CGFloat = 0.2
    
    //Linear damping == simulates fluid or air friction forces on the body
    let desertLinearDamping: CGFloat = 0.2
    let beachLinearDamping: CGFloat = 0.5
    let forestLinearDamping: CGFloat = 0.8
    
    //Angular damping == reduces the body’s rotational velocity
    let desertAngularDamping: CGFloat = 0.2
    let beachAngularDamping: CGFloat = 0.5
    let forestAngularDamping: CGFloat = 0.8
    
    //Beach ball scaling factor
    let beachBallScalingFactor: CGFloat = 0.1
    //Basketball scaling factor
    let basketBallScalingFactor: CGFloat = 0.3
    //Bowling ball scaling factor
    let bowlingBallScalingFactor: CGFloat = 0.5
    
    //Game Anchor coordinate points
    let gameAnchorX: CGFloat = 0
    let gameAnchorY: CGFloat = 0.5
    /*Sets the gameplay to be in the correct dimensions*/

    //Generic Anchor coordinate points
    let anchorX: CGFloat = 0.5
    let anchorY: CGFloat = 0.5
    /*Sets the background and ball to be in the correct dimensions*/

    /*End of Constants*/

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
        
       // setUpGround()   //4
        
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
        
        setUpGameAnchor()
        /////////////////////////////////////////
        
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        
        //self.frame confines the ball to the iOS screen
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        //Set the friction of that physicsBody to prevent the ball from slowing down when colliding with a border barrier
        physicsBody.friction = 0
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
        
        assignPhysicsAttributes(chooseBall.ballType!, typeOfBackground: chooseBackground.backgroundType!)
        
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
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        playSound("hit.mp3")
//        
//        //if directly underneath
//            moveBallUp()
//        //else if off to the side
//            //if mouse is to the right
//                moveBallLeft()
//            //else if mouse is to the left
//                //moveBallRight()
//        //else (combination of both)
//            //move combined vector
//    }
    
    /*Moving the ball*/
    func moveBallUp() -> Void {
        ball.physicsBody?.applyImpulse(CGVectorMake(0, 100))
    }
    
    func moveBallLeft() -> Void {
        ball.physicsBody?.applyImpulse(CGVectorMake(-100, 0))
    }
    
    func moveBallRight() -> Void {
        ball.physicsBody?.applyImpulse(CGVectorMake(100, 0))
    }
    /*End of Moving the ball*/
    
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
    
    func assignPhysicsAttributes(typeOfBall: BallType, typeOfBackground: BackgroundType) -> Void {
        if typeOfBall == BallType.BeachBall {
            setPhysicsAttributesBasedOnBall(0.3, restitution: beachBallRestitution, mass: 0.5)
        } else if typeOfBall == BallType.Basketball {
            setPhysicsAttributesBasedOnBall(0.3, restitution: basketballRestitution, mass: 0.5)
        } else {
            setPhysicsAttributesBasedOnBall(0.3, restitution: bowlingBallRestitution, mass: 0.5)
        }
        
        if typeOfBackground == BackgroundType.Desert {
            setPhysicsAttributesBasedOnBackground(desertLinearDamping, angularDamping: desertAngularDamping)
        } else if typeOfBackground == BackgroundType.Beach {
            setPhysicsAttributesBasedOnBackground(beachLinearDamping, angularDamping: beachAngularDamping)
        } else {
            setPhysicsAttributesBasedOnBackground(forestLinearDamping, angularDamping: forestAngularDamping)
        }
    }

    // this defines the mass, roughness and bounciness
    func setPhysicsAttributesBasedOnBall(friction: CGFloat, restitution: CGFloat, mass: CGFloat) -> Void {
        ball.physicsBody!.friction = friction
        ball.physicsBody!.restitution = restitution
        ball.physicsBody!.mass = mass
    }
    
    // this defines the linear and angular damping based on the background
    func setPhysicsAttributesBasedOnBackground(linearDamping: CGFloat, angularDamping: CGFloat) -> Void {
        ball.physicsBody!.linearDamping = linearDamping
        ball.physicsBody!.angularDamping = angularDamping
    }
    
    /*Setup functions*/
    //1
    func setUpGameAnchor() -> Void {
        anchorPoint = CGPointMake(gameAnchorX, gameAnchorY)
    }

    //2
    func setUpPhysics() -> Void {
        self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 )
        self.physicsWorld.contactDelegate = self
    }
    
    //3
    func setUpBackground() -> Void {
        self.background.anchorPoint = CGPointMake(anchorX, anchorY)
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

        ball.anchorPoint = CGPointMake(anchorX, anchorY)
        
        //These two lines are interchangeable
        self.ball.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        //self.ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        /**/
        
        ball.name = "ball"
        ball.userInteractionEnabled = false //what does this do?
        
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
