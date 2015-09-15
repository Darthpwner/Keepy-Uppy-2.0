//
//  GameScene.swift
//  Keepy Uppy
//
//  Created by Matthew Allen Lin on 9/3/15.
//  Copyright (c) 2015 Matthew Allen Lin. All rights reserved.
//

//Actual game play scene
import SpriteKit
import AVFoundation

//Scoring algorithm: Tap the ball -> +1 , Hit a wall -> +1
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*Variables*/
    var canRestart = Bool()
    var gameStarted: Bool = false
    
    var scoreLabelNode = SKLabelNode()
    var background = SKSpriteNode()
    var ball = SKSpriteNode()
    var scoreZone = SKSpriteNode()
    var ground = SKSpriteNode()
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    
    var lives: Int = 1
    var score: NSInteger = 0
    /*End of variables*/
    
    /*Constants*/
    let gravityConstant: CGFloat = -6.0  //Constant for Physics World
    
    //Determine ball type
    let chooseBall = GetBallType.sharedInstance
    //Determine background type
    let chooseBackground = GetBackgroundType.sharedInstance
    
    //Constant factors for each ball
    let ballFriction: CGFloat = 0.3
    let ballMass: CGFloat = 0.5
    
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
    
    //Barrier factor
    let barrierFactor: CGFloat = 1.0
    /*Sets a barrier factor (ground and wall)*/
    
    //Category bit masks
    let groundCategory: UInt32 = 0x1 << 0
    let ballCategory: UInt32 = 0x1 << 1
    let wallCategory: UInt32 = 0x1 << 2
    /*End of Category bit masks*/
    
    let playGameplaySong = PlayGameplaySong.sharedInstance
    
    /*End of Constants*/

    override init(size: CGSize) {
        super.init(size: size)
        
        setUpGameAnchor()   //1
        
        assignBall()

        assignBackground()
        
        //Create the Physics of the game
        setUpPhysics()  //2
        
        //Add background
        setUpBackground() //3
        
        setUpscoreZone()    //4
        
        setUpWalls()    //5
        
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
//    override func didMoveToView(view: SKView) {
//        
//        canRestart = false  //Prevent restarts
//    }
    
    /*
        Directions in which the ball can move
                    ^
                    |
                <-  O ->
    */
    //Use to move the ball
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        //Keep ball in static position until user taps the screen
        if !gameStarted {
            self.physicsWorld.gravity = CGVectorMake( 0.0, gravityConstant)
            gameStarted = true
        }
        
        //Disabled to test other features of the game
//        if !self.ball.userInteractionEnabled {  //If the ball drops, stop playing
//            return
//        } //FIX THIS BUG
        
        //Recognizes only a tap on the ball
        let touch = touches.first as? UITouch
        super.touchesBegan(touches, withEvent:event)
       
        let positionInScene = touch!.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
    
        if let name = touchedNode.name {
            if name == "ball" {
                playSound("hit.mp3")
                
                /*Calculation algorithm constants*/
                let pos = touch!.locationInNode(self)
                let posX = pos.x / size.width   //0 to 1
                let posY = pos.y / size.height  //0 to 1
                let ballCenterX = ball.anchorPoint.x    //0.5
                let ballCenterY = ball.anchorPoint.y    //0.5
                let differenceRatioX = (1.0 - abs(ballCenterX - posX))  //Maximum impulse at the center (0 to 1)
                let differenceRatioY = (1.0 - abs(ballCenterY - posY))  //Maximum impulse at the center (0 to 1)
                /*End of calculation algorithm constants*/
                
                moveBall(posX, posY: posY, ballCenterX: ballCenterX, ballCenterY: ballCenterY, differenceRatioX: differenceRatioX, differenceRatioY: differenceRatioY)
                
                score++
                scoreLabelNode.text = String(score)
            }
        }
    }
    
    /*Calculation algorithm math*/
    func moveBall(posX: CGFloat, posY: CGFloat, ballCenterX: CGFloat, ballCenterY: CGFloat, differenceRatioX: CGFloat, differenceRatioY: CGFloat) -> Void {
        if posX < ballCenterX { //Ball moves right
            if chooseBall.ballType == BallType.BeachBall {
                ball.physicsBody?.applyImpulse(CGVectorMake((beachBallMultiplier * differenceRatioX * impulseFactor) % impulseFactor, impulseFactor * beachBallMultiplier * differenceRatioY))
            } else if chooseBall.ballType == BallType.Basketball {
                ball.physicsBody?.applyImpulse(CGVectorMake((basketBallMultiplier * differenceRatioX * impulseFactor) % impulseFactor, impulseFactor * basketBallMultiplier * differenceRatioY))
            } else {
                ball.physicsBody?.applyImpulse(CGVectorMake((bowlingBallMultiplier * differenceRatioX * impulseFactor) % impulseFactor, impulseFactor * bowlingBallMultiplier * differenceRatioY))
            }
        } else if posX > ballCenterX {  //Ball moves left
            if chooseBall.ballType == BallType.BeachBall {
                ball.physicsBody?.applyImpulse(CGVectorMake((-1 * beachBallMultiplier * differenceRatioX * impulseFactor) % impulseFactor, impulseFactor * beachBallMultiplier * differenceRatioY))
            } else if chooseBall.ballType == BallType.Basketball {
                ball.physicsBody?.applyImpulse(CGVectorMake((-1 * basketBallMultiplier * differenceRatioX * impulseFactor) % impulseFactor, impulseFactor * basketBallMultiplier * differenceRatioY))
            } else {
                ball.physicsBody?.applyImpulse(CGVectorMake((-1 * bowlingBallMultiplier * differenceRatioX * impulseFactor) % impulseFactor, impulseFactor * bowlingBallMultiplier * differenceRatioY))
            }
        } else {    //Ball moves straight up
            if chooseBall.ballType == BallType.BeachBall {
                ball.physicsBody?.applyImpulse(CGVectorMake(0, impulseFactor * beachBallMultiplier * differenceRatioY))
            } else if chooseBall.ballType == BallType.Basketball {
                ball.physicsBody?.applyImpulse(CGVectorMake(0, impulseFactor * basketBallMultiplier * differenceRatioY))
            } else {
                ball.physicsBody?.applyImpulse(CGVectorMake(0, impulseFactor * bowlingBallMultiplier * differenceRatioY))
            }
        }
    }
    /*End of Calculation algorithm math*/
    
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
            setPhysicsAttributesBasedOnBall(ballFriction, restitution: beachBallRestitution, mass: ballMass)
        } else if typeOfBall == BallType.Basketball {
            setPhysicsAttributesBasedOnBall(ballFriction, restitution: basketballRestitution, mass: ballMass)
        } else {
            setPhysicsAttributesBasedOnBall(ballFriction, restitution: bowlingBallRestitution, mass: ballMass)
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
        //Keep user static until game starts
        self.physicsWorld.gravity = CGVectorMake( 0.0, 0.0 )
        self.physicsWorld.contactDelegate = self
    }
    
    //3
    func setUpBackground() -> Void {
        self.background.name = "Background"
        self.background.anchorPoint = CGPointMake(anchorX, anchorY)
        self.background.size.height = self.size.height
        self.background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(background)
    }
    
    //4
    //BUGGY
    func setUpscoreZone() -> Void {
        self.scoreZone.name = "scoreZone"
        self.scoreZone.color = UIColor.redColor()
        self.scoreZone.position = CGPointMake(size.width / 2, (3 * size.height) / 4)
        self.scoreZone.size = CGSizeMake(size.width, barrierFactor)
        
        //Create an edge based body for the scoreZone
        self.scoreZone.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-size.width / 2, 0.0), toPoint: CGPointMake(size.width, 0.0))
        
        self.scoreZone.physicsBody?.affectedByGravity = false
        
        self.scoreZone.physicsBody?.allowsRotation = false
        
        self.addChild(self.scoreZone)
    }

    
    //5
    func setUpWalls() -> Void {
        /*Set up left wall*/
        self.leftWall.color = UIColor.greenColor()
        self.leftWall.name = "Left Wall"
        self.leftWall.position = CGPoint(x: 0.0, y: size.height / 2)
        self.leftWall.size = CGSizeMake(barrierFactor, size.height)
        
        //Create an edge based body for the left wall
        
        //Left wall extends from bottom of the screen all the way to twice the height of the screen from the center
        self.leftWall.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0.0, -size.height / 2), toPoint: CGPointMake(0.0, size.height * 2))
        
        self.leftWall.physicsBody?.categoryBitMask = wallCategory   //Assign the bit mask category for the left wall
        self.leftWall.physicsBody?.collisionBitMask = ballCategory  //Assigns the collision we care about for the left wall
        self.leftWall.physicsBody?.contactTestBitMask = ballCategory  //Assigns the contacts that we care about for the left wall
        
        self.leftWall.physicsBody?.affectedByGravity = false
        
        self.leftWall.physicsBody?.allowsRotation = false
        
        self.addChild(self.leftWall)
        /*End of Set up left wall*/
        
        /*Set up right wall*/
        self.rightWall.name = "Right Wall"
        self.rightWall.color = UIColor.greenColor()
        self.rightWall.position = CGPoint(x: size.width, y: size.height / 2) //Subtract barrierFactor from wall width
        self.rightWall.size = CGSizeMake(barrierFactor, size.height)
        
        //Create an edge based body for the right wall
        //Right wall extends from bottom of the screen all the way to twice the height of the screen from the center
        self.rightWall.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0.0, -size.height / 2), toPoint: CGPointMake(0.0, size.height))
        
        self.rightWall.physicsBody?.categoryBitMask = wallCategory  //Assign the bit mask category for the right wall
        self.rightWall.physicsBody?.collisionBitMask = ballCategory //Assigns the collision we care about for the right wall
        self.rightWall.physicsBody?.contactTestBitMask = ballCategory  //Assigns the contacts that we care about for the right wall
        
        self.rightWall.physicsBody?.affectedByGravity = false
            
        self.rightWall.physicsBody?.allowsRotation = false
            
        self.addChild(self.rightWall)
        /*End of Set up right wall*/
    }
    
    //6
    func setUpGround() -> Void {
        self.ground.name = "Ground"
        self.ground.color = UIColor.redColor()
        self.ground.position = CGPointMake(size.width / 2, 0.0)
        self.ground.size = CGSizeMake(size.width, barrierFactor)
        
        //Create an edge based body for the ground
        self.ground.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-size.width / 2, 0.0), toPoint: CGPointMake(size.width, 0.0))
        
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
        
        ball.physicsBody!.allowsRotation = true

        ball.anchorPoint = CGPointMake(anchorX, anchorY)
        
        
        self.ball.position = CGPointMake( CGRectGetMidX( self.frame ), (size.height))
        
        self.ball.name = "ball"
        self.ball.userInteractionEnabled = true
        
        ball.physicsBody?.usesPreciseCollisionDetection = true

        self.ball.physicsBody!.categoryBitMask = ballCategory    //Assigns the bit mask category for ball
        
        self.ball.physicsBody!.collisionBitMask = wallCategory | groundCategory //Assigns the collisions that the ball can have

        //Assigns the contacts that we care about for the ball
        self.ball.physicsBody!.contactTestBitMask = groundCategory
        addChild(self.ball)
    }
    
    //8
    func setUpScore() -> Void {
        self.scoreLabelNode.name = "Score"
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
    
    //Handle contact between nodes
    func didBeginContact(contact: SKPhysicsContact) {
        //The condition on left cause problems
        if ( contact.bodyA.categoryBitMask & groundCategory ) == groundCategory || ( contact.bodyB.categoryBitMask & groundCategory ) == groundCategory {
            
            score = 0
            scoreLabelNode.text = String(score)
            
            self.ball.physicsBody?.restitution = 0.0    //Prevents the ball from bouncing
            self.ball.userInteractionEnabled = false
            
            playGameplaySong.song.stop()
            playSound("gameover.mp3")   //Sound glitchy since the ball still bounces
            
        } else {
            score++
            scoreLabelNode.text = String(score)
        }
    }
}
