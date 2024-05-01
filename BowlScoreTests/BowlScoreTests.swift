//
//  BowlScoreTests.swift
//  BowlScoreTests
//

@testable import BowlScore
import ComposableArchitecture
import XCTest

// NOTE: The code coverage numbers contain The Composable Architecture. The BowlScore app code coverage is 81%. Non-UI coverage is in the 96% range.
final class BowlScoreTests: XCTestCase {
    @MainActor func test_createFrames() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        
        var scoresArray: IdentifiedArrayOf<Score.State> = []
        for id in 1...10 { // for comparison of creating frames
            scoresArray.append(Score.State(id: id))
        }
        
        store.exhaustivity = .off
        
        // Act & Assert
        await store.send(.createFrames)
        store.assert {
            $0.scoresArray = scoresArray
            $0.scoresArray[id: 1]?.isCurrentFrame = true
        }
    }
    
    @MainActor func test_addButtonTapped() async {
        // Arrange
        var scoresArray: IdentifiedArrayOf<Score.State> = []
        for id in 1...10 {
            scoresArray.append(Score.State(id: id))
        }

        scoresArray[id: 1]?.ball1 = 5
        scoresArray[id: 1]?.isCurrentFrame = true

        let store = TestStore(initialState: BowlScore.State(scoresArray: scoresArray)) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.addButtonTapped)
        store.assert {
            $0.addScore = AddScore.State(pointsLeft: 5)
        }
    }
    
    @MainActor func test_addButtonTapped_10thFrame() async {
        // Arrange
        var scoresArray: IdentifiedArrayOf<Score.State> = []
        for id in 1...10 {
            scoresArray.append(Score.State(id: id))
        }

        scoresArray[id: 10]?.ball1 = 5
        scoresArray[id: 10]?.ball2 = 5
        scoresArray[id: 10]?.isCurrentFrame = true

        let store = TestStore(initialState: BowlScore.State(
            scoresArray: scoresArray,
            currentFrame: 10)) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.addButtonTapped)
        store.assert {
            $0.addScore = AddScore.State(pointsLeft: 10)
        }
    }
    
    @MainActor func test_saveScore_cancel() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.addButtonTapped)
        store.assert {
            $0.addScore = AddScore.State(pointsLeft: 10)
        }
        await store.send(\.addScoreAction.cancelButtonTapped)
    }

    @MainActor func test_saveScore_strike() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State(addScore: AddScore.State(textScore: "X", pointsLeft: 10))) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(\.addScoreAction.saveButtonTapped)
        store.assert {
            $0.addScore?.validatedScore = 10
        }
    }
    
    @MainActor func test_saveScore_miss() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State(addScore: AddScore.State(textScore: "", pointsLeft: 10))) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(\.addScoreAction.saveButtonTapped)
        store.assert {
            $0.addScore?.validatedScore = 0
        }
    }

    @MainActor func test_saveScore_invalid() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State(addScore: AddScore.State(textScore: "8", pointsLeft: 2))) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(\.addScoreAction.saveButtonTapped)
        store.assert {
            $0.addScore?.validatedScore = 0
            $0.addScore?.textScore = "Invalid entry"
        }
    }
    
    @MainActor func test_saveScore_normal() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State(addScore: AddScore.State(textScore: "8", pointsLeft: 10))) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(\.addScoreAction.saveButtonTapped)
        store.assert {
            $0.addScore?.validatedScore = 8
        }
    }
    
    @MainActor func test_calculateTotalScore_2Misses() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 0))
        await store.send(.calculateScore(score: 0))
    }
    
    @MainActor func test_calculateTotalScore_2RegularScores() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 3))
        await store.send(.calculateScore(score: 5))
    }
    
    @MainActor func test_calculateTotalScore_2Regular1Spare() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 3))
        await store.send(.calculateScore(score: 5))
        await store.send(.calculateScore(score: 8))
        await store.send(.calculateScore(score: 2))
    }
    
    @MainActor func test_calculateTotalScore_1Strike_frame1() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 10))
    }
    
    @MainActor func test_calculateTotalScore_1Strike2_regular() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 3))
        await store.send(.calculateScore(score: 5))
    }
    
    @MainActor func test_calculateTotalScore_1Spare_2Regular() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 8))
        await store.send(.calculateScore(score: 2))
        await store.send(.calculateScore(score: 5))
        await store.send(.calculateScore(score: 1))
    }
    
    @MainActor func test_calculateTotalScore_1Spare_1Strike() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 8))
        await store.send(.calculateScore(score: 2))
        await store.send(.calculateScore(score: 10))
        
    }
    
    @MainActor func test_calculateTotalScore_1Strike_1Spare() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 4))
        await store.send(.calculateScore(score: 5))
    }
    
    @MainActor func test_calculateTotalScore_2Strikes_1Regular() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State()) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.createFrames)
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 4))
        await store.send(.calculateScore(score: 40))
    }
    
    @MainActor func test_calculateTotalScore_9thFrameStrike_10thFrameSpare_gameOver() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State(scoresArray: .mockFrame10, currentFrame: 9)) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 5))
        await store.send(.calculateScore(score: 5))
        await store.send(.calculateScore(score: 5))
    }
    
    @MainActor func test_calculateTotalScore_9thFrameStrike_10thFrameRegular_gameOver() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State(scoresArray: .mockFrame10, currentFrame: 9)) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 5))
        await store.send(.calculateScore(score: 4))
    }
    
    @MainActor func test_calculateTotalScore_10thFrame2StrikesGameOver() async {
        // Arrange
        let store = TestStore(initialState: BowlScore.State(scoresArray: .mockFrame10, currentFrame: 9)) {
            BowlScore()
        }
        store.exhaustivity = .off

        // Act & Assert
        await store.send(.calculateScore(score: 3))
        await store.send(.calculateScore(score: 7))
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 10))
        await store.send(.calculateScore(score: 3))
    }
}
