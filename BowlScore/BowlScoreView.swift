//
//  BowlScoreView.swift
//  BowlScore
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<BowlScore>
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.scope(state: \.scoresArray, action: \.scoresAction)) { store in
                    ScoreView(store: store) // a list of all 10 frames.
                }
            }
            .navigationTitle(store.gameOver ? "Game Over" : "BowlScore")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(store.gameOver)
                }
            }
        }
        .onAppear {
            store.send(.createFrames)
        }
        .sheet(
            item: $store.scope(state: \.addScore, action: \.addScoreAction)) { addStore in
                NavigationStack {
                    AddScoreView(store: addStore)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: BowlScore.State(scoresArray: .mock)) {
            BowlScore()
        }
    )
}
