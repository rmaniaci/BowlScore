//
//  Score.swift
//  BowlScore
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Score {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: Int // unique identifier that represents the current frame
        var ball1: Int?
        var ball2: Int?
        var ball3: Int? // This is only called during ball 3.
        var score: Int? // Total score.
        var isCurrentFrame = false
    }

    // Used by BowlScore, the parent, to create a relationship with the child. In the future this can be used for actions that can be accessed in BowlScore.
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}
