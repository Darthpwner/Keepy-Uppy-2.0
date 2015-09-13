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

//Scoring algorithm: Tap the ball -> +1 , Hit a wall -> +1 , Hit the ceiling -> + 2
//Max possible points per tap: +7 -> Tap the ball, Hit a wall, Hit the ceiling, hit the other wall

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*Variables*/
    var canRestart = Bool()
    var score: NSInteger = 0
    
    var scoreLabelNode = SKLabelNode()
    var background = SKSpriteNode()
    var ball = SKSpriteNode()
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
    
    //Barrier factor
    let barrierFactor: CGFloat = 1.0
    /*Sets a barrier factor (ground, wall, ceiling)*/
    
    //Category bit masks
    let groundCategory: UInt32 = 0x1 << 0
    let ballCategory: UInt32 = 0x1 << 1
    let wallCategory: UInt32 = 0x1 << 2
    let ceilingCategory: UInt32 = 0x1 << 3
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
        
        setUpCeiling()  //4 
        
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
                let pos = touch?.locationInNode(self)
                let posX = pos?.x
                let posY = pos?.y
                let ballCenterX = ball.anchorPoint.x
                let ballCenterY = ball.anchorPoint.y
                let differenceRatioX = (abs(ballCenterX - posX!) % 100.0) / 100.0
                let differenceRatioY = (abs(ballCenterY - posY!) % 100.0) / 100.0
                /*End of calculation algorithm constants*/
                
                moveBall(posX!, posY: posY!, ballCenterX: ballCenterX, ballCenterY: ballCenterY, differenceRatioX: differenceRatioX, differenceRatioY: differenceRatioY)
                
                score++
                scoreLabelNode.text = String(score)
            }
        }
    }
    
    /*Calculation algorithm math*/
    func moveBall(posX: CGFloat, posY: CGFloat, ballCenterX: CGFloat, ballCenterY: CGFloat, differenceRatioX: CGFloat, differenceRatioY: CGFloat) -> Void {
        if posX < ballCenterX { //Ball moves right
            if chooseBall.ballType == BallType.BeachBall {
                ball.physicsBody?.applyImpulse(CGVectorMake(impulseFactor * beachBallMultiplier * differenceRatioX, impulseFactor * beachBallMultiplier * differenceRatioY))
            } else if chooseBall.ballType == BallType.Basketball {
                ball.physicsBody?.applyImpulse(CGVectorMake(impulseFactor * basketBallMultiplier * differenceRatioX, impulseFactor * basketBallMultiplier * differenceRatioY))
            } else {
                ball.physicsBody?.applyImpulse(CGVectorMake(impulseFactor * bowlingBallMultiplier * differenceRatioX, impulseFactor * bowlingBallMultiplier * differenceRatioY))
            }
        } else if posX > ballCenterX {  //Ball moves left
            if chooseBall.ballType == BallType.BeachBall {
                ball.physicsBody?.applyImpulse(CGVectorMake(-1 * impulseFactor * beachBallMultiplier * differenceRatioX, impulseFactor * beachBallMultiplier * differenceRatioY))
            } else if chooseBall.ballType == BallType.Basketball {
                ball.physicsBody?.applyImpulse(CGVectorMake(-1 * impulseFactor * basketBallMultiplier * differenceRatioX, impulseFactor * basketBallMultiplier * differenceRatioY))
            } else {
                ball.physicsBody?.applyImpulse(CGVectorMake(-1 * impulseFactor * bowlingBallMultiplier * differenceRatioX, impulseFactor * bowlingBallMultiplier * differenceRatioY))
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
        self.background.name = "Background"
        self.background.anchorPoint = CGPointMake(anchorX, anchorY)
        self.background.size.height = self.size.height
        self.background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(background)
    }
    
    //4
    func setUpCeiling() -> Void {
        self.ceiling.name = "Ceiling"
        self.ceiling.color = UIColor.orangeColor()
        self.ceiling.position = CGPointMake(size.width / 2, size.height)
        self.ceiling.size = CGSizeMake(size.width, barrierFactor)
        
        //Create an edge based body for the ceiling
        self.ceiling.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-size.width / 2, 0.0), toPoint: CGPointMake(size.width / 2, 0.0))
        
        self.ceiling.physicsBody?.categoryBitMask = ceilingCategory //Assigns the bit mask category for the ceiling
        self.ceiling.physicsBody?.collisionBitMask = ballCategory //Assigns the collision we care about for the ceiling
        self.ceiling.physicsBody?.contactTestBitMask = ballCategory  //Assigns the contacts that we care about for the ceiling
        
        self.ceiling.physicsBody?.affectedByGravity = false
        
        self.ground.physicsBody?.allowsRotation = false
        
        self.addChild(self.ceiling)
    }
    
    //5
    func setUpWalls() -> Void {
        /*Set up left wall*/
        self.leftWall.color = UIColor.greenColor()
        self.leftWall.name = "Left Wall"
        self.leftWall.position = CGPoint(x: 0.0, y: size.height / 2)
        self.leftWall.size = CGSizeMake(barrierFactor, size.height)
        
        //Create an edge based body for the left wall
        self.leftWall.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0.0, -size.height / 2), toPoint: CGPointMake(0.0, size.height / 2))
        
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
        self.rightWall.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0.0, -size.height / 2), toPoint: CGPointMake(0.0, size.height / 2))
        
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
        
        
        self.ball.position = CGPointMake( CGRectGetMidX( self.frame ), (9 * size.height) / 10)
        
        self.ball.name = "ball"
        self.ball.userInteractionEnabled = true
        
        ball.physicsBody?.usesPreciseCollisionDetection = true

        self.ball.physicsBody!.categoryBitMask = ballCategory    //Assigns the bit mask category for ball
        
        self.ball.physicsBody!.collisionBitMask = wallCategory | ceilingCategory | groundCategory //Assigns the collisions that the ball can have

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
            
        } else if ( contact.bodyA.categoryBitMask & wallCategory) == wallCategory || ( contact.bodyB.categoryBitMask & wallCategory) == wallCategory {
            
            score++
            scoreLabelNode.text = String(score)
            
        } else {
            
            score += 2
            scoreLabelNode.text = String(score)
        }
    }
}
