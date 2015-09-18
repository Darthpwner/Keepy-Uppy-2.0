# Keepy-Uppy-2.0
The goal is to keep the ball in the air as long as possible and try to 
accumulate points!

Each ball has a different level of bounciness:
- Beach Ball (most bounce)
- Basketball (medium bounce)
- Bowling Ball (least bounce)

Each background has a different damping factor:
- Desert (most air time)
- Beach (medium air time)
- Forest (least air time)

Scoring and Rules: You cannot tap the ball when it is in the score zone.
Your score is only incremented if you get the ball above the score zone.
Each tap in the middle zone is worth 1 point.
- Colliding with a wall earns an additional point.
- Colliding with the ceiling earns an extra 3 points.
Taps in the danger zone (below the red line) are worth 3 points.

UI Design: I used six scenes in my Storyboard. 
1) Navigation Controller Scene: Used to redirect back to the Title Page Scene 
if the player lost the game.
2) Title Page Scene: Links to the Rules Page and Choose Ball Page. It has an 
animated GIF that is currently fetching its animation from a hardcoded URL. 
This needs to be modified later because this does not render in a place without
Internet. There is also an issue if you go back to this page regarding the 
music that needs to be accounted for.
3) Rules Page Scene: Displays the rules of the game that were shown above in
this README file. There is a problem with white space on larger screens like
the iPad or iPhone 6 Plus.
4) Choose Ball Scene: Lets you choose between a ball from the options of a 
beach ball, a basketball, or a bowling ball
5) Choose Background Scene: Lets you choose between a background from the 
options of a Desert, a Beach, or a Forest
6) Game View Controller Scene: Handles all the gameplay.

Gameplay Functionality: The game play takes place in GameScene.swift. It is 
currently in very messy form and needs to be refactored to adhere to MVC 
principles. I used SpriteKit's physics engine to set conditions such as
gravity, mass, density, restitution, and impulse factors that occur when you
tap the ball. Upon losing, the player has the option of tapping the screen to
start the game over.

Images: The images were simple background and ball images obtained off Google 
Images. All rights reserved to the owners of the images.

Sounds: 
Original:
The sounds were adopted from another project tutorial I was working on
called Swiftris. I obtained the gameover.mp3 and scorepoints.mp3 sounds from 
Swiftris. I found the hit.mp3 sound on the Internet. The gameplay.mp3 and 
start.mp3 are from "Sweet Georgia Brown" by Brother Bones and "Wimbledon - 
Intro - Theme Song". All rights are reserved for the owners of these two audio
tracks.
Modified:
The sounds were now taken off various free to download sites. All of the music
is approved for usage if I give the owners credit, which I did on the splash
screen.

Challenges I encountered: One of the biggest challenges was creating the ball
bouncing algorithm. At MHacks 6, I was fortunate enough to have the guidance
of several bright Apple Engineers who taught me how to access the 
SKSpriteNode's position. From here, I created an algorithm based on the ratio
of the ball's Anchor Point relative to the position where it was tapped. This
provided directional control. For example, clicking on the left should have the
ball jump to the right, whereas clicking on the right should have the ball jump
to the left. It was also very annoying having to deal with copyright issues, so
I had to use royalty free music and stock images.

Notable bugs that I need to fix: 1) Ask people input about high scores
2) Make the Choose Ball and Choose Background pages more lively. It seems a bit
dull for now.
3) Refactor the code to adhere more closely to MVC principles.

Official release versions:
Keepy Uppy 1.0: bb5d5cc80956678ff6a3f1f2ccebf96857cc30e6