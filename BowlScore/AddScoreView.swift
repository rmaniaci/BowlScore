//
//  AddScoreView.swift
//  BowlScore
//

import ComposableArchitecture
import SwiftUI

struct AddScoreView: View {
    @Bindable var store: StoreOf<AddScore>
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(store.textScore) // Text is used instead of a TextField to take advantage of the custom keypad.
                    .foregroundColor(store.textScore == "Invalid entry" ? .red : .primary)
            }.padding([.leading, .trailing])
            Divider()
            KeyPad(string: $store.textScore)
            Button("Save") {
                store.send(.saveButtonTapped)
            }
            .disabled(store.textScore.isEmpty || store.textScore == "Invalid entry")
        }
        .font(.largeTitle)
            .padding()
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
                .font(.largeTitle)
            }
        }
    }
}

// Custom keypad to demonstrate SwiftUI.
struct KeyPad: View {
    @Binding var string: String
    var body: some View {
        VStack {
            KeyRow(keys: ["1", "2", "3"])
            KeyRow(keys: ["4", "5", "6"])
            KeyRow(keys: ["7", "8", "9"])
            KeyRow(keys: ["X", "0", "⌫"]) // X means Strike here
        }.environment(\.keyButtonAction, self.keyPressed(_:))
    }

    // Only a single value can be entered at once.
    func keyPressed(_ key: String) {
        switch key {
        case "⌫": string = ""
        default: string = key
        }
    }
}

// Represents one of three rows of keys.
struct KeyRow: View {
    var keys: [String]
    var body: some View {
        HStack {
            ForEach(keys, id: \.self) { key in
                KeyButton(key: key)
            }
        }
    }
}

// Represents an individual key button that can be tapped to input a value.
struct KeyButton: View {
    var key: String
    var body: some View {
        Button(action: { self.action(self.key) }) {
            Color.clear
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor))
                .overlay(Text(key))
        }
    }

    enum ActionKey: EnvironmentKey {
        static var defaultValue: (String) -> Void { { _ in } }
    }

    @Environment(\.keyButtonAction) var action: (String) -> Void
}

// Computed property that represents tapping on a key.
extension EnvironmentValues {
    var keyButtonAction: (String) -> Void {
        get { self[KeyButton.ActionKey.self] }
        set { self[KeyButton.ActionKey.self] = newValue }
    }
}

#Preview {
    NavigationStack {
        AddScoreView(
            store: Store(
                initialState: AddScore.State(pointsLeft: 10)
            ) {
                AddScore()
            }
        )
    }
}

