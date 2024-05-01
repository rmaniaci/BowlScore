//
//  String+Extensions.swift
//  BowlScore
//

import Foundation

extension String {
    // Custom extension to properly display scores. Ball represents the ball being formatted, score represents the current value being added, and score is used to  represent the previous values in the frame.
    func scoreFormatter(ball: Int, value: Int?, score: Score.State) -> String {
        switch value {
        case 10 where ball == 1: return "X" // strike
        case 10 where ball >= 2: return "/" // spare
        case 0 where ball != 0: return "-" // miss
        case nil: return "" // blank
        default:
            let ball1 = score.ball1 ?? 0, ball2 = score.ball2 ?? 0, ball3 = score.ball3 ?? 0
            if ball1 + ball2 + ball3 == 10 && ball == 2 { return "/" } // spare
            return "\(value ?? 0)" // default, 0 is used to avoid unwrapping.
        }
    }
}
