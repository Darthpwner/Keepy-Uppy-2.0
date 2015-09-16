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
    var gameEnded: Bool = false
    
    var scoreLabelNode = SKLabelNode()  //Displays points when ball is moved above scoreZone
    var highScoreLabelNode = SKLabelNode()  //Displays the high score when the game is over
    var highScoreMessageNode = SKLabelNode()   //Message if you set a high score
    
    var background = SKSpriteNode()
    var ball = SKSpriteNode()
    var scoreZone = SKSpriteNode()
    var dangerZone = SKSpriteNode()
    var ground = SKSpriteNode()
    var ceiling = SKSpriteNode()
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    
    var score: NSInteger = 0    //Updated when ball is above scoreZone
    var highScore: NSInteger = 0    //Updated after the game ends if the player's score is his/her high score
    
    var pointsObtained: NSInteger = 0   //Used whenever the ball is tapped or a wall is struck
    /*End of variables*/
    
    /*Constants*/
    let gravityConstant: CGFloat = -9.8  //Constant for Physics World
    
    //Determine ball type
    let chooseBall = GetBallType.sharedInstance
    //Determine background type
    let chooseBackground = GetBackgroundType.sharedInstance
    
    //Constant factors for each ball
    let ballFriction: CGFloat = 0.3
    let ballMass: CGFloat = 0.5
    
    //Restitution == how much energy the physics body loses when it bounces
    let beachBallRestitution: CGFloat = 0.8
    let basketballRestitution: CGFloat = 0.5
    let bowlingBallRestitution: CGFloat = 0.2
    
    //Linear damping == simulates fluid or air friction forces on the body
    let desertLinearDamping: CGFloat = 0.2
    let beachLinearDamping: CGFloat = 0.5
    let forestLinearDamping: CGFloat = 0.8
    
    //Angular damping == reduces the body’s rotational velocity
    let desertAngularDamping: CGFloat = 0.0
    let beachAngularDamping: CGFloat = 0.5
    let forestAngularDamping: CGFloat = 1.0
    
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
    
    //scoreZone thickness
    let scoreZoneThickness: CGFloat = 5.0
    /*Sets the scoreZone thickness constant*/
    
    //dangerZone thickness
    let dangerZoneThickness: CGFloat = 5.0
    /*Sets the dangerZone thickness constant*/
    
    //Category bit masks
    let groundCategory: UInt32 = 0x1 << 0
    let ballCategory: UInt32 = 0x1 << 1
    let wallCategory: UInt32 = 0x1 << 2
    let ceilingCategory: UInt32 = 0x1 << 3
    let scoreZoneCategory: UInt32 = 0x1 << 4
    let dangerZoneCategory: UInt32 = 0x1 << 5
    /*End of Category bit masks*/
    
    let playGameplaySong = PlayGameplaySong.sharedInstance
    
    var timeDelay = 2.65    //Length of gameover.mp3
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
        
        setUpScoreZone()    //4
        
        setUpDangerZone()   //5
        
        setUpCeiling()  //6
        
        setUpWalls()    //7
        
        setUpGround()   //8
        
        setUpBall() //9
        
        setUpScore() //10
    }

    required init(coder decoder: NSCoder) {
        super.init()
    }
    
    func playSound(sound: String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
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
        
        //Recognizes only a tap on the ball
        let touch = touches.first as? UITouch
        super.touchesBegan(touches, withEvent:event)
       
        let positionInScene = touch!.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
    
        tapBall(touchedNode, touchParam: touch)
    }
    
    func tapBall(touchedNode: SKNode, touchParam: UITouch?) {
        if let name = touchedNode.name {
            if name == "ball" {
                let pos = touchParam!.locationInNode(self)
                let rawPosY = pos.y
                if rawPosY <= (4 * size.height) / 5 {
                    playSound("hit.mp3")
                    
                    /*Calculation algorithm constants*/
                    let posX = pos.x / size.width   //0 to 1
                    let posY = pos.y / size.height  //0 to 1
                    let ballCenterX = ball.anchorPoint.x    //0.5
                    let ballCenterY = ball.anchorPoint.y    //0.5
                    let differenceRatioX = (1.0 - abs(ballCenterX - posX))  //Maximum impulse at the center (0 to 1)
                    let differenceRatioY = (1.0 - abs(ballCenterY - posY))  //Maximum impulse at the center (0 to 1)
                    /*End of calculation algorithm constants*/
                    
                    moveBall(posX, posY: posY, ballCenterX: ballCenterX, ballCenterY: ballCenterY, differenceRatioX: differenceRatioX, differenceRatioY: differenceRatioY)
                    
                    if rawPosY <= size.height / 5 { //Tap in the danger zone
                        pointsObtained += 3
                        //println(pointsObtained)
                    } else {    //Tap in the middle zone
                        pointsObtained++
                        //println(pointsObtained)
                    }
                }
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
    func setUpScoreZone() -> Void {
        self.scoreZone.name = "scoreZone"
        self.scoreZone.color = UIColor.blackColor()
        self.scoreZone.position = CGPointMake(size.width / 2, (4 * size.height) / 5)
        self.scoreZone.size = CGSizeMake(size.width,scoreZoneThickness)
        
        //Create an edge based body for the scoreZone
        self.scoreZone.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-size.width / 2, 0.0), toPoint: CGPointMake(size.width, 0.0))
        
        self.scoreZone.physicsBody?.categoryBitMask = scoreZoneCategory
        self.scoreZone.physicsBody?.contactTestBitMask = ballCategory
        
        self.scoreZone.physicsBody?.affectedByGravity = false
        
        self.scoreZone.physicsBody?.allowsRotation = false
        
        self.addChild(self.scoreZone)
    }

    //5
    func setUpDangerZone() -> Void {
        self.dangerZone.name = "dangerZone"
        self.dangerZone.color = UIColor.redColor()
        self.dangerZone.position = CGPointMake(size.width / 2, size.height / 5)
        self.dangerZone.size = CGSizeMake(size.width, dangerZoneThickness)
    
        //Create an edge based body for the scoreZone
        self.dangerZone.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-size.width / 2, 0.0), toPoint: CGPointMake(size.width, 0.0))
    
        self.dangerZone.physicsBody?.categoryBitMask = dangerZoneCategory
        self.dangerZone.physicsBody?.contactTestBitMask = ballCategory
    
        self.dangerZone.physicsBody?.affectedByGravity = false
    
        self.dangerZone.physicsBody?.allowsRotation = false
    
        self.addChild(self.dangerZone)
    }
    
    //6
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
    
    //7
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
    
    //8
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
    
    //9
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
        ball.physicsBody?.dynamic = true    //Enable ball to move
        
        assignPhysicsAttributes(chooseBall.ballType!, typeOfBackground: chooseBackground.backgroundType!)
        
        ball.physicsBody!.allowsRotation = true

        ball.anchorPoint = CGPointMake(anchorX, anchorY)
        
        //Start the ball at the score zone
        self.ball.position = CGPointMake( CGRectGetMidX( self.frame ), (4 * size.height) / 5)
        
        self.ball.name = "ball"
        self.ball.userInteractionEnabled = false    //Needs to be false to allow contact
        
        ball.physicsBody?.usesPreciseCollisionDetection = true

        self.ball.physicsBody!.categoryBitMask = ballCategory    //Assigns the bit mask category for ball
        
        self.ball.physicsBody!.collisionBitMask = wallCategory | groundCategory | ceilingCategory //Assigns the collisions that the ball can have

        //Assigns the contacts that we care about for the ball
        self.ball.physicsBody!.contactTestBitMask = groundCategory | scoreZoneCategory | dangerZoneCategory
        addChild(self.ball)
    }
    
    //10
    func setUpScore() -> Void {
        self.scoreLabelNode.name = "Score"
        self.scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        self.scoreLabelNode.fontColor = UIColor.blackColor()  //Set font color as black
    
        //Sets score to be center of the screen
        self.scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidY( self.frame))
        
        self.scoreLabelNode.zPosition = 100
        self.scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
    }
    /*End of setup functions*/
    
    /*High score functions*/
    //Sets the message to be displayed if the user sets the high score
    func setUpHighScoreMessage() -> Void {
        self.highScoreMessageNode.name = "highScoreMessage"
        self.highScoreMessageNode = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        self.highScoreMessageNode.fontColor = UIColor.redColor()    //Set the font color as red
        
        //Sets high score message to be below the score
        self.highScoreMessageNode.position = CGPointMake(CGRectGetMidX(self.frame), (4 * self.frame.height) / 10)
        self.highScoreMessageNode.zPosition = 100
        self.highScoreMessageNode.text = String("New High Score!")
        self.addChild(highScoreMessageNode)
    }
    
    //Load previous high scores
    func loadPreviousHighScore() -> Void {
        var highScoreDefault = NSUserDefaults.standardUserDefaults()
        
        if highScoreDefault.valueForKey("highScore") != nil {
            highScore = highScoreDefault.valueForKey("highScore") as! NSInteger!
        }
    }
    
    //Set up high score after game ends
    func setUpHighScore() -> Void {
        
        loadPreviousHighScore() //Get the previous high score
        
        if score > highScore {
            highScore = score
            
            var highScoreDefault = NSUserDefaults.standardUserDefaults()
            highScoreDefault.setValue(highScore, forKey: "highScore")
            highScoreDefault.synchronize()
            
            setUpHighScoreMessage() //Print high score message if a new high score was obtained
        }
        
        self.highScoreLabelNode.name = "highScore"
        self.highScoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        self.highScoreLabelNode.fontColor = UIColor.redColor()    //Set font color as red
        
        //Sets high score to be above the score
        self.highScoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), (6 * self.frame.height) / 10)
        
        self.highScoreLabelNode.zPosition = 100
        self.highScoreLabelNode.text = String(highScore)
        self.addChild(highScoreLabelNode)
    }
    /*End of High score functions*/
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //Handle contact between nodes
    func didBeginContact(contact: SKPhysicsContact) {
        if ( contact.bodyA.categoryBitMask & groundCategory ) == groundCategory || ( contact.bodyB.categoryBitMask & groundCategory ) == groundCategory {   //Ball hits ground

            self.ball.physicsBody?.dynamic = false  //Prevents user from tapping the ball when it hits the ground
            self.ball.userInteractionEnabled = true //Prevents user from making the tap noise if they try to tap the ball
            
            playGameplaySong.song.stop()
            playSound("gameover.mp3")
            
            //Set up the high score display
            setUpHighScore()
            
            //Return to home screen if you tap the screen after the game ends
            delay(timeDelay) {
                self.gameEnded = true
            }
        } else if ( contact.bodyA.categoryBitMask & wallCategory) == wallCategory || (contact.bodyB.categoryBitMask & wallCategory) == wallCategory { //Ball hits a wall
            
            pointsObtained++
        } else if ( contact.bodyA.categoryBitMask & ceilingCategory) == ceilingCategory || ( contact.bodyB.categoryBitMask & ceilingCategory) == ceilingCategory {  //Ball hits ceiling
            
            pointsObtained += 3
        } else { //Ball goes through scoreZone
            let posOfBall: CGFloat = ball.position.y

            if posOfBall > (4 * size.height) / 5 {
                playSound("scorepoints.mp3")
                score += pointsObtained
                scoreLabelNode.text = String(score)
                pointsObtained = 0
            }
        }
    }
}
