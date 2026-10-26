//
//  TournamentGraph.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 10/1/26.
//

import SwiftUI
import Charts

struct TournamentGraph: View {
    var tournament: [SanitizedBubble]
    var bubble: TARGET
    
    var body: some View {
        let numRounds = tournament[0].wins + tournament[0].losses
        Text("\(numRounds) Rounds")
        Chart {
            ForEach(tournament, id:\.wins) { bracket in
                LineMark(
                    x: .value("Record", "\(bracket.wins)/\(bracket.losses)"),
                    y: .value("Number of Players", bracket.maxSize),
                    series: .value("Plot", "Upper"))
                .foregroundStyle(.green)
                LineMark(
                    x: .value("Record", "\(bracket.wins)/\(bracket.losses)"),
                    y: .value("Number of Players", bracket.minSize),
                    series: .value("Plot", "Lower"))
                .foregroundStyle(.red)
                LineMark(
                    x: .value("Record", "\(bracket.wins)/\(bracket.losses)"),
                    y: .value("Number of Players", bracket.averageSize),
                    series: .value("Plot", "Average"))
                .foregroundStyle(.blue)
            }
            
            let allBrackets = Calculator.getAllPlacementBubblesForTournament(tournament: tournament, placement: bubble)
        }
        .chartForegroundStyleScale(["Maximum Size": .green, "Average Size": .blue, "Minimum Size": .red])
        .frame(height: 250.0)
        
        HStack {
            Spacer()
            VStack {
                List(tournament) { item in
                    Text("\(item.wins)-\(item.losses) record: \(item.averageSize)")
                }
                .listStyle(.inset)
                .frame(height: 125)
            }
            Spacer()
            VStack {
                Text("Top \(bubble.rawValue) bubble record:")
                Text("\(getBubbleString())")
            }
            Spacer()
        }
    }
    
    func getBubbleString() -> String {
        let bubbleBracket = Calculator.getAveragePlacementBubbleForTournament(tournament: tournament, placement: bubble)
        return "\(bubbleBracket.wins)-\(bubbleBracket.losses)"
    }
}

#Preview {
    let testTourney4Players = [
        SanitizedBubble(wins: 2, losses: 0, averageSize: 1, maxSize: 1, minSize: 1, allPossibleSizes: [1]),
        SanitizedBubble(wins: 1, losses: 1, averageSize: 2, maxSize: 2, minSize: 2, allPossibleSizes: [2]),
        SanitizedBubble(wins: 0, losses: 2, averageSize: 1, maxSize: 1, minSize: 1, allPossibleSizes: [1])]
    let testTourney13PlayersSmaller = [
        SanitizedBubble(wins: 3, losses: 0, averageSize: 1, maxSize: 1, minSize: 1, allPossibleSizes: [1,1,1,1]),
        SanitizedBubble(wins: 2, losses: 1, averageSize: 6, maxSize: 7, minSize: 6, allPossibleSizes: [6,6,6,7]),
        SanitizedBubble(wins: 1, losses: 2, averageSize: 4, maxSize: 6, minSize: 4, allPossibleSizes: [4,6,4,4]),
        SanitizedBubble(wins: 0, losses: 3, averageSize: 0, maxSize: 1, minSize: 0, allPossibleSizes: [0,0,0,1])
    ]
    let testTourney13PlayersLarger = [
        SanitizedBubble(wins: 4, losses: 0, averageSize: 1, maxSize: 1, minSize: 1, allPossibleSizes: [1,1,1,1,1,1,1,1,1,1]),
        SanitizedBubble(wins: 3, losses: 1, averageSize: 3, maxSize: 4, minSize: 3, allPossibleSizes: [3,3,3,3,3,3,3,4,3,4]),
        SanitizedBubble(wins: 2, losses: 2, averageSize: 4, maxSize: 6, minSize: 4, allPossibleSizes: [4,5,5,6,4,5,6,4,6,4]),
        SanitizedBubble(wins: 1, losses: 3, averageSize: 4, maxSize: 6, minSize: 3, allPossibleSizes: [5,3,6,4,5,3,3,4,3,4]),
        SanitizedBubble(wins: 0, losses: 4, averageSize: 0, maxSize: 1, minSize: 0, allPossibleSizes: [0,1,0,1,0,1,0,0,0,0])
    ]
    TournamentGraph(tournament: testTourney13PlayersLarger, bubble: .TOP_4)
}
