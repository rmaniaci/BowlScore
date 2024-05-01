//
//  IdentifiedArray+Extensions.swift
//  BowlScore
//

import ComposableArchitecture

// Mock games that can be input for display or testing.
extension IdentifiedArray where ID == Score.State.ID, Element == Score.State {
    static let mock: Self = [
        Score.State(
            id: 1,
            ball1: 10,
            isCurrentFrame: true
        )
    ]
    static let mockFrame10: Self = [
        Score.State(
            id: 1,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: true
        ),
        Score.State(
            id: 2,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: true
        ),
        Score.State(
            id: 3,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: false
        ),
        Score.State(
            id: 4,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: false
        ),
        Score.State(
            id: 5,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: false
        ),
        Score.State(
            id: 6,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: false
        ),
        Score.State(
            id: 7,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: false
        ),
        Score.State(
            id: 8,
            ball1: 0,
            ball2: 0,
            ball3: 0,
            score: 0,
            isCurrentFrame: false
        ),
        Score.State(
            id: 9,
            isCurrentFrame: true
        )
    ]
}
