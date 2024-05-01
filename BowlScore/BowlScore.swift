//
//  BowlScore.swift
//  BowlScore
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BowlScore {
    @ObservableState // conform to observable protocol.
    struct State: Equatable {
        @Presents var addScore: AddScore.State? // Presents the AddScore keypad.
        var scoresArray: IdentifiedArrayOf<Score.State> = [] // IdentifiedArrayOf is used because frames are uniquely identified.
        var currentFrame = 1 // start with frame 1
        var currentBall = Ball.ball1 // start with ball 1
        var cumulativeTotalScore = 0 // score that adds up over time
        var gameOver = false // set to true following the completion of frame 10.
    }

    // Fixed value for tenpin bowling.
    struct BowlScoreConstants: Equatable {
        static let numberOfPins = 10
    }

    // Used to determine which ball is being scored.
    enum Ball {
        case ball1
        case ball2
        case ball3
    }

    enum TotalScoreType {
        case score // scoring the current frame
        case previousFrameSpare(thisFrame: Int) // scoring the previous frame when on ball 1 of the current frame
        case previousFrameStrike(Ball2ScoreType = .score) // scoring the previous frame when on ball 2 of the current frame and recursively calling current unless the current frame is a spare or there is a ball 3 in the 10th frame
        case twoStrikesInARow(thisFrame: Int) // scoring the second from previous frame, only used when there are two strikes in a row
    }

    enum Ball2ScoreType {
        case score // regular score
        case spare // spare with no ball 3
        case ball3 // strike, spare, or score with a ball 3
    }

    // BindableAction exposes BindingAction, which is used to mutate state fields.
    enum Action: BindableAction, Sendable {
        case addButtonTapped
        case addScoreAction(PresentationAction<AddScore.Action>) // used to pull back from the child AddScore to the parent
        case ball1Score(score: Int)
        case ball2Score(score: Int)
        case ball3Score(score: Int)
        case binding(BindingAction<State>) // requirement for the BindableAction protocol.
        case calculateScore(score: Int) // Calculating an individual score.
        case calculateTotalScore(TotalScoreType = .score) // Calculating the total score on a frame.
        case createFrames // Used to populate the initial list.
        case nextFrame // Move the state to the next frame.
        case scoresAction(IdentifiedActionOf<Score>) // Used to integrate the parent BowlScore with the child Score.
    }

    // A Reducer is used to manage the state of the application and to return side effects, if any.
    var body: some Reducer<State, Action> {
        BindingReducer() // ensures that the bindable state is updated.
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                let ball1 = state.scoresArray[id: state.currentFrame]?.ball1 ?? 0 // balls are all optional here so this allows for safe unwrapping
                let ball2 = state.scoresArray[id: state.currentFrame]?.ball2 ?? 0
                
                let pointsLeft: Int // points left in a frame
                if (state.currentFrame == 10 && (ball1 == 10 || ball2 == 10) || ball1 + ball2 >= 10) { // tenth frame
                    pointsLeft = 10
                } else {
                    pointsLeft = BowlScoreConstants.numberOfPins - ball1 - ball2
                }

                state.addScore = AddScore.State(pointsLeft: pointsLeft)
                return .none

            // Returned from the AddScore child.
            case let .addScoreAction(.presented(.delegate(.saveScore(scoreToAdd)))):
                return Effect.send(.calculateScore(score: scoreToAdd))

            // Additional child actions that are not used at this time.
            case .addScoreAction(.dismiss),
                    .addScoreAction(.presented(.binding)), .addScoreAction(.presented(.cancelButtonTapped)), .addScoreAction(.presented(.saveButtonTapped)):
                return .none

            case let .ball1Score(score):
                let thisFrame = state.currentFrame // maintain copy of state locally so that it can be incremented in BowlScore.State to avoid duplication
                if score == BowlScoreConstants.numberOfPins && thisFrame != 10 { // strike
                    state.scoresArray[id: thisFrame]?.isCurrentFrame = false
                    state.currentFrame += 1
                    state.scoresArray[id: state.currentFrame]?.isCurrentFrame = true
                } else {
                    state.currentBall = .ball2
                }

                state.scoresArray[id: thisFrame]?.ball1 = score
                
                if thisFrame > 1 {
                    let previousScoreType = state.scoresArray[id: thisFrame - 1]
                    if previousScoreType?.score == nil { // this means that there was either a strike or spare that hasn't been calculated
                        let previousBall1 = previousScoreType?.ball1 ?? 0 // should never be 0
                        if previousScoreType?.ball1 == BowlScoreConstants.numberOfPins && thisFrame > 2 {
                            let secondFromPreviousScoreType = state.scoresArray[id: thisFrame - 2]
                            if secondFromPreviousScoreType?.score == nil { // at least two strikes in a row so first one needs to be calculated
                                return Effect.send(.calculateTotalScore(.twoStrikesInARow(thisFrame: thisFrame)))
                            }
                        }

                        let previousBall2 = previousScoreType?.ball2 ?? 0

                        if previousBall1 != BowlScoreConstants.numberOfPins &&
                            (previousBall1 + previousBall2 == BowlScoreConstants.numberOfPins) { // previous frame was a spare so needs to be calculated
                            return Effect.send(.calculateTotalScore(.previousFrameSpare(thisFrame: thisFrame)))
                        }

                        return .none
                    }
                }
                return .none

            case let .ball2Score(score):
                let ball1 = state.scoresArray[id: state.currentFrame]?.ball1 ?? 0
                state.scoresArray[id: state.currentFrame]?.ball2 = score
                if state.currentFrame == 10 && ball1 + score >= BowlScoreConstants.numberOfPins {
                    state.currentBall = .ball3 // extra ball
                } else {
                    state.currentBall = .ball1
                }

                if ball1 + score >= BowlScoreConstants.numberOfPins { // spare or extra ball on frame 10
                    if state.scoresArray[id: state.currentFrame - 1]?.score == nil && state.currentFrame > 1 { // previous frame is a strike here
                        if state.currentBall == .ball3 {
                            return Effect.send(.calculateTotalScore(.previousFrameStrike(.ball3))) // there is an extra ball on frame 10
                        }
                        return Effect.send(.calculateTotalScore(.previousFrameStrike(.spare))) // current frame is a spare
                    }

                    if state.currentBall == .ball3 {
                        return .none // ball 3 case
                    }
                    return Effect.send(.nextFrame) // no need to calculate otherwise.
                }

                if state.scoresArray[id: state.currentFrame - 1]?.score == nil && state.currentFrame > 1 { // previous frame is a strike here and there is no ball 3
                    return Effect.send(.calculateTotalScore(.previousFrameStrike(.score))) // current frame is standard
                }

                return Effect.send(.calculateTotalScore())

            // No need to move to the next frame or reset the current ball here.
            case let .ball3Score(score):
                state.scoresArray[id: state.currentFrame]?.ball3 = score
                return Effect.send(.calculateTotalScore())

            // Used to conform to the BindableAction protocol.
            case .binding:
                return .none

            // Switch to approriate ball based on the enum.
            case let .calculateScore(score):
                switch state.currentBall {
                case .ball1:
                    return Effect.send(.ball1Score(score: score))
                case .ball2:
                    return Effect.send(.ball2Score(score: score))
                case .ball3:
                    return Effect.send(.ball3Score(score: score))
                }

            case let .calculateTotalScore(totalScoreType):
               switch totalScoreType {
                case .score: // standard calculation at the end of a frame
                    let ball1 = state.scoresArray[id: state.currentFrame]?.ball1 ?? 0
                    let ball2 = state.scoresArray[id: state.currentFrame]?.ball2 ?? 0
                    let ball3 = state.scoresArray[id: state.currentFrame]?.ball3 ?? 0 // only will be present in 10th frame otherwise is 0
                    let cumulativeScore = state.cumulativeTotalScore + ball1 + ball2 + ball3
                    state.scoresArray[id: state.currentFrame]?.score = cumulativeScore
                    state.cumulativeTotalScore = cumulativeScore // add this even when in frame 10.
                    return Effect.send(.nextFrame) // move to the next frame even when in frame 10.
                
                case let .previousFrameSpare(thisFrame): // only dealing with ball 1 here which could be a strike, score, or miss
                    let ball1 = state.scoresArray[id: thisFrame]?.ball1 ?? 0 // thisFrame is used to keep the frame consistent regardless of strike.
                    let cumulativeScore = state.cumulativeTotalScore + 10 + ball1
                    state.scoresArray[id: thisFrame - 1]?.score = cumulativeScore
                    state.cumulativeTotalScore = cumulativeScore
                    return .none // in the case of a strike, next frame has already been advanced.

                case let .previousFrameStrike(ball2ScoreType): // used when on ball 2 and previous frame hasn't been calculated
                    let ball1 = state.scoresArray[id: state.currentFrame]?.ball1 ?? 0
                    let ball2 = state.scoresArray[id: state.currentFrame]?.ball2 ?? 0
                    let cumulativeScore = state.cumulativeTotalScore + 10 + ball1 + ball2
                    state.scoresArray[id: state.currentFrame - 1]?.score = cumulativeScore
                    state.cumulativeTotalScore = cumulativeScore

                    switch ball2ScoreType {
                    case .score: // regular score
                        return Effect.send(.calculateTotalScore())
                    case .spare: // spare
                        return Effect.send(.nextFrame)
                    case .ball3: // there is a third ball so calculate on the third round
                        return .none
                    }
                
                case let .twoStrikesInARow(thisFrame):
                    let ball1 = state.scoresArray[id: thisFrame]?.ball1 ?? 0
                    let cumulativeScore = state.cumulativeTotalScore + 20 + ball1
                    state.scoresArray[id: thisFrame - 2]?.score = cumulativeScore
                    state.cumulativeTotalScore = cumulativeScore
                    return .none // already decided whether to advance or not
                }
            case .createFrames:
                // Populate all of the frames.
                for id in 1...10 {
                    state.scoresArray.append(Score.State(id: id))
                }
                state.scoresArray[id: state.currentFrame]?.isCurrentFrame = true // current frame is 1
                return .none
            
            // Used when there is no calculation that needs tobe performed.
            case .nextFrame:
                state.scoresArray[id: state.currentFrame]?.isCurrentFrame = false
                state.currentFrame += 1
                if state.currentFrame == 11 {
                    state.gameOver = true // ends the game
                    return .none
                }
                state.scoresArray[id: state.currentFrame]?.isCurrentFrame = true
                return .none
            
            // Used to integrate with Scores. There are no actions currently on Scores so nothing is done here.
            case .scoresAction:
                return .none
            }
        }
        // The following statements integrate the child views of BowlScore. ifLet is a one to one relationship while forEach is a one to many.
        .ifLet(\.$addScore, action: \.addScoreAction) {
            AddScore()
        }
        .forEach(\.scoresArray, action: \.scoresAction) {
            Score()
        }
    }
}
