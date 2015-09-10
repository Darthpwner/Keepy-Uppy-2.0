# Keepy-Uppy-2.0
The goal of Keepy Uppy is to keep a ball in the air as long as possible to 
score points. Players can accumulate more points by doing various tricks.
A player can select from three balls (beach ball, basketball, and bowling ball)
and each ball has unique bounciness, mass, and friction properties. The physics
engine is derived from SpriteKit. Each of the three possible backgrounds
(desert, beach, and forest) has unique characteristics as well.

The game consists of four UIViewControllers: 1) Title Page, 2) Choose Ball
Page, 3) Choose Background Page, 4) GamePlay Page

Scoring: The scoring system is pretty simple. A single tap earns you 1 point,
colliding against either the left wall or the right wall will earn you 2 points
, and colliding against the ceiling earns you 3 points