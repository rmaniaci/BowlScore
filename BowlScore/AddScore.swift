//
//  AddScore.swift
//  BowlScore
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddScore {
    @ObservableState
    struct State: Equatable {
        var textScore = "" // what is displayed in the text field
        let pointsLeft: Int // how many points are left in the frame
        var validatedScore = 0 // the score that is added
    }
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case cancelButtonTapped // returns to main view
        case delegate(Delegate)
        case saveButtonTapped

        // Enables communication with BowlScore (the parent in this case)
        @CasePathable
        enum Delegate: Equatable {
            case saveScore(Int)
        }
    }
    @Dependency(\.dismiss) var dismiss // allows for AddScore to be dismissed without an explicit Action.
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            case .delegate:
                return .none
            case .saveButtonTapped:
                switch state.textScore {
                case "X": // strike
                    state.validatedScore = 10
                case "":
                    state.validatedScore = 0
                default:
                    state.validatedScore = Int(state.textScore) ?? 0 // 0 should never happen in this case
                }
                guard state.validatedScore <= state.pointsLeft else { // entered a score with more pins than what remains
                    state.validatedScore = 0
                    state.textScore = "Invalid entry"
                    return .none
                }
                // .run wraps an asynchronous function that can emit actions any number of times.
                return .run { [scoreToSave = state.validatedScore] send in
                    await send(.delegate(.saveScore(scoreToSave)))
                    await self.dismiss()
                }
            }
        }
    }
}
