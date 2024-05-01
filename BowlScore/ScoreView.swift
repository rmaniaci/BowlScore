//
//  ScoreView.swift
//  BowlScore
//

import ComposableArchitecture
import SwiftUI

struct ScoreView: View {
    @Bindable var store: StoreOf<Score> // this is used to access the State.
    var body: some View {
        VStack {
            Text("Frame \(store.id)")
                       .foregroundColor(.white)
                       .font(.title)
                       .padding()
                       .frame(maxWidth: .infinity)
                       .background(store.isCurrentFrame ? .green :
                        Color.accentColor
                       )
                       .cornerRadius(12)
            HStack {
                Text("".scoreFormatter(ball: 1, value: store.ball1, score: store.state))
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor))
                Text("".scoreFormatter(ball: 2, value: store.ball2, score: store.state))
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor))
                if store.id == 10 {
                    Text("".scoreFormatter(ball: 3, value: store.ball3, score: store.state))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.title)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.accentColor))
                }
            }
            Text("".scoreFormatter(ball: 0, value: store.score, score: store.state))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.title)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(12)
    }
}
