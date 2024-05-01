//
//  BowlScoreApp.swift
//  BowlScore
//

import ComposableArchitecture
import SwiftUI

// The main app view.
@main
struct BowlScoreApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: BowlScore.State()) {
                    BowlScore()
                }
            )
        }
    }
}
