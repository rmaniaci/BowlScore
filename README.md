# BowlScore

Tracks the score of a single game of bowling using an application written in SwiftUI and The Composable Architecture. The interface accepts the result of each ball bowled and calculates the correct score, including spares and strikes. The interface also indicates if the 10th frame includes a third ball.

The results of ball rolls are input one at a time, sequentially. The interface assigns the scores to the correct frames. Based on the current conditions, the interface sanitizes the inputs to only allow valid scores to be entered. The score is displayed and updated as the rolls are entered.

## Example

Input: Strike, 7, Spare, 9, Miss, Strike, Miss, 8, 8, Spare, Miss, 6, Strike, Strike, Strike, 8, 1

| Frame |  1 | 2  | 3  | 4  | 5  | 6  | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Input| X  |  7 / |  9 - | X  | - 8  |  8 / |  - 6 |  X | X  |  X 8 1 |
|Score|  20 | 39  |  48 | 66  | 74  |  84 |  90 |  120 | 148  | 167  |

## Bowling Game
* A game of bowling consists of 10 frames, in two balls are rolled per frame to attempt to knock down all ten pins.
* If all ten pins are knocked down in those two turns in the 10th frame, an extra bonus chance is awarded.
* A strike is defined as knocking down all ten pins in the first ball of a frame, signified with an X
* A spare is defined as knocking down all the remaining pins in the second ball of a frame, signified with a /
* A miss is defined as zero pins being knocked down on a roll, signified with a -

## Scoring Rules
* Generally, 1 point per pin knocked down.
* Strike - Score of 10 (for knocking down all ten pins), plus the total of the next two rolls
* Spare - Score of 10, plus the total number of pins knocked down on the next roll only
* Each frame displays the cumulative score up to that point for all complete frames. If a frame has a strike or spare, the score for that frame is not displayed until sufficient subsequent rolls have been input
