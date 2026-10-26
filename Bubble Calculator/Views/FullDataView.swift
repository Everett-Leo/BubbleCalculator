//
//  FullDataView.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 10/5/26.
//

import SwiftUI

struct FullDataView: View {
    @State var selectedTarget: TARGET = .TOP_4
    
    var tournamentData: TournamentData
    var target: TARGET = .TOP_4
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("Bubble:")
                    Picker("Placement", selection: $selectedTarget) {
                        ForEach(TARGET.allCases.filter{$0.rawValue <= tournamentData.numberOfPlayers}) { placement in
                            Text("Top \(placement.rawValue)")
                        }
                    }
                }
                ForEach(tournamentData.tournamentBracket.indices, id:\.self) { i in
                    let filtered = tournamentData.tournamentBracket[i]
                    TournamentGraph(tournament: filtered, bubble: selectedTarget).padding()
                }
            }
        }
        .onAppear() {
            selectedTarget = target
        }
        .navigationTitle("\(tournamentData.numberOfPlayers) Player Bracket")
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
    let data = TournamentData(numPlayers: 13, bracket: [testTourney13PlayersSmaller, testTourney13PlayersLarger])
    let smallData = TournamentData(numPlayers: 4, bracket: [testTourney4Players])
    FullDataView(tournamentData: data, target: .TOP_4)
}
