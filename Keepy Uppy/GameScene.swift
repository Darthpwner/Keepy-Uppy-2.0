//
//  GameScene.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

//Actual game play scene
import SpriteKit

//Scoring algorithm: Tap the ball -> +1 , Hit a wall -> +1 , Hit the ceiling -> + 2
//Max possible points per tap: +7 -> Tap the ball, Hit a wall, Hit the ceiling, hit the other wall

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*Variables*/
    //From Flappy Bird example
    var temporaryBall: SKSpriteNode!
    var moving:SKNode!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score: NSInteger = 0
    var background: SKSpriteNode!
    var ball: SKSpriteNode!
    
    var ground = SKSpriteNode()
    var ceiling = SKSpriteNode()
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    
    var lives: Int = 1
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
    
    //Impulse factor
    let impulseFactor: CGFloat = 100.0
    let beachBallMultiplier: CGFloat = 4.0
    let basketBallMultiplier: CGFloat = 3.0
    let bowlingBallMultiplier: CGFloat = 2.0
    
    //Game Anchor coordinate points
    let gameAnchorX: CGFloat = 0
    let gameAnchorY: CGFloat = 0
    /*Sets the gameplay to be in the correct dimensions*/

    //Generic Anchor coordinate points
    let anchorX: CGFloat = 0.5
    let anchorY: CGFloat = 0.5
    /*Sets the ball and background to be in the correct dimensions*/
    
    //Ground height
    let groundHeight: CGFloat = 1.0
    /*Sets the ground to be at the bottom of the screen*/
    
    //Category bit masks
    let groundCategory: UInt32 = 0x1 << 0
    let ballCategory: UInt32 = 0x1 << 1
    let wallCategory: UInt32 = 0x1 << 2
    let ceilingCategory: UInt32 = 0x1 << 3
    /*End of Category bit masks*/
    
    /*End of Constants*/

    override init(size: CGSize) {
        super.init(size: size)
        
        setUpGameAnchor()   //1
        
        assignBall()

        assignBackground()
        
        //Create the Phyiscs of the game
        setUpPhysics()  //2
        
        //Add background
        setUpBackground() //3
        
        setUpCeiling()  //4 TODO
        
        setUpWalls()    //5 TODO
        
        setUpGround()   //6
        
        setUpBall() //7
        
        setUpScore() //8
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
        ball.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.size.width / 2.0)
        ball.physicsBody?.dynamic = true
        
        assignPhysicsAttributes(chooseBall.ballType!, typeOfBackground: chooseBackground.backgroundType!)
        
        // this will allow the balls to rotate when bouncing off each other
        ball.physicsBody!.allowsRotation = true
        
        self.physicsWorld.contactDelegate = self    //EXPERIMENTAL
    }
    
    /*
        Directions in which the ball can move
                    ^
                    |
                <-  O ->
    */
    //Use to move the ball
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //Recognizes only a tap on the ball
        let touch = touches.first as? UITouch
        super.touchesBegan(touches , withEvent:event)
        
        let positionInScene = touch!.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
        
        if let name = touchedNode.name {
            if name == "ball" {
                playSound("hit.mp3")
                
                //if directly underneath
                moveBallUp()
                //else if off to the side
                //if mouse is to the right
                moveBallLeft()
                //else if mouse is to the left
                moveBallRight()
                //else (combination of both)
                //move combined vector
                
                score++
                scoreLabelNode.text = String(score)
            }
        }
    }
    
    /*Moving the ball*/
    func moveBallUp() -> Void {
        if chooseBall.ballType == BallType.BeachBall {
            ball.physicsBody?.applyImpulse(CGVectorMake(0, impulseFactor * beachBallMultiplier))
        } else if chooseBall.ballType == BallType.Basketball {
            ball.physicsBody?.applyImpulse(CGVectorMake(0, impulseFactor * basketBallMultiplier))
        } else {
            ball.physicsBody?.applyImpulse(CGVectorMake(0, impulseFactor * bowlingBallMultiplier))
        }
        
    }
    
    func moveBallLeft() -> Void {
        var random = -1 * CGFloat(Float(arc4random()))
        ball.physicsBody?.applyImpulse(CGVectorMake(random % impulseFactor, 0))
    }
    
    func moveBallRight() -> Void {
        var random = CGFloat(Float(arc4random()))
        ball.physicsBody?.applyImpulse(CGVectorMake(random % impulseFactor, 0))
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
    func setUpCeiling() -> Void {
        self.ceiling.color = UIColor.blueColor()
        self.ceiling.anchorPoint = CGPointMake(0, self.frame.size.height)   //?
        self.ceiling.position = CGPointMake(0.0, self.frame.size.height)   //?
        self.ceiling.size = CGSizeMake(self.frame.size.width, groundHeight)   //?
        
        //Create an edge based body for the ceiling
        self.ceiling.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0.0, self.frame.size.height), toPoint: CGPointMake(self.frame.size.width, self.frame.size.height))  //?
        
        self.ceiling.physicsBody?.categoryBitMask = ceilingCategory //Assigns the bit mask category for the ceiling
        self.ceiling.physicsBody?.collisionBitMask = ballCategory //Assigns the collision we care about for the ceiling
        
        self.ceiling.physicsBody?.affectedByGravity = false
        
        self.ground.physicsBody?.allowsRotation = false
        
        self.addChild(self.ceiling)
    }
    
    //5
    func setUpWalls() -> Void {
        /*Set up left wall*/
        self.leftWall.color = UIColor.greenColor()
        self.leftWall.anchorPoint = CGPointZero
        self.leftWall.position = CGPointZero
        self.leftWall.size = CGSizeMake(groundHeight, self.frame.size.height)   //?
        
        //Create an edge based body for the left wall
        self.leftWall.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0.0, self.frame.size.height), toPoint: CGPointMake(0.0, groundHeight)) //?
        
        self.leftWall.physicsBody?.categoryBitMask = wallCategory   //Assign the bit mask category for the left wall
        self.leftWall.physicsBody?.collisionBitMask = ballCategory  //Assigns the collision we care about for the left wall
        
        self.leftWall.physicsBody?.affectedByGravity = false
        
        self.leftWall.physicsBody?.allowsRotation = false
        
        self.addChild(self.leftWall)
        /*End of Set up left wall*/
            
        /*Set up right wall*/
        self.rightWall.color = UIColor.purpleColor()
        self.rightWall.anchorPoint = CGPointMake(self.frame.size.width, 0.0)  //?
        self.rightWall.position = CGPointMake(self.frame.size.width, 0.0) //?
        self.rightWall.size = CGSizeMake(groundHeight, self.frame.size.height)   //?
        
        //Create an edge based body for the right wall
        self.rightWall.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(self.frame.size.width, self.frame.size.height), toPoint: CGPointMake(self.frame.size.width, groundHeight)) //?
        
        self.rightWall.physicsBody?.categoryBitMask = wallCategory  //Assign the bit mask category for the right wall
        self.rightWall.physicsBody?.collisionBitMask = ballCategory //Assigns the collision we care about for the right wall
            
        self.rightWall.physicsBody?.affectedByGravity = false
            
        self.rightWall.physicsBody?.allowsRotation = false
            
        //self.addChild(self.rightWall)
        /*End of Set up right wall*/
    }
    
    //6
    func setUpGround() -> Void {
        
        //Change groundHeight to something else
        
        self.ground.color = UIColor.redColor()
        self.ground.anchorPoint = CGPointZero
        self.ground.position = CGPointZero
        self.ground.size = CGSizeMake(self.frame.size.width, groundHeight)
        
        //Create an edge based body for the gorund
        self.ground.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0.0, groundHeight), toPoint: CGPointMake(self.frame.size.width, groundHeight))
        
        self.ground.physicsBody?.categoryBitMask = groundCategory    //Assigns the bit mask category for ground
        self.ground.physicsBody?.contactTestBitMask = ballCategory  //Assigns the contacts that we care about for the ground
        
        self.ground.physicsBody?.affectedByGravity = false

        self.ground.physicsBody?.allowsRotation = false
        
        self.addChild(self.ground)
    }

    
    //7
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
        
        self.ball.name = "ball"
        self.ball.userInteractionEnabled = false
        
        ball.physicsBody?.usesPreciseCollisionDetection = true
        
        self.ball.physicsBody?.categoryBitMask = ballCategory    //Assigns the bit mask category for ball
        self.ball.physicsBody?.collisionBitMask = wallCategory | ceilingCategory //Assigns the collisions that the ball can have
        self.ball.physicsBody?.contactTestBitMask = groundCategory   //Assigns the contacts that we care about for the ball
        
        addChild(self.ball)  //Add ball to the display list
    }
    
    //8
    func setUpScore() -> Void {
        self.scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        self.scoreLabelNode.fontColor = UIColor.redColor()  //Set font color as red
        
        //Sets score to be center of the screen
        self.scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidY( self.frame))
        
        self.scoreLabelNode.zPosition = 100
        self.scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
    }
    /*End of setup functions*/
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //Handle contact between ball and ground
    func didBeginContact(contact: SKPhysicsContact) {
        if ( contact.bodyA.categoryBitMask & groundCategory ) == groundCategory || ( contact.bodyB.categoryBitMask & groundCategory ) == groundCategory {

            score = 0
            scoreLabelNode.text = String(score)
            
            self.ball.speed = 0 //TODO: FIGURE OUT HOW TO STOP GAME!
            
            playSound("gameover.mp3")
        } else if ( contact.bodyA.categoryBitMask & wallCategory) == wallCategory || ( contact.bodyB.categoryBitMask & wallCategory) == wallCategory {
            
            score++
            scoreLabelNode.text = String(score)
        } else {
            
            score += 2
            scoreLabelNode.text = String(score)
        }
    }
}
