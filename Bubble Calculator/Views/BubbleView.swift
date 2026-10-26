//
//  BubbleView.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 10/5/26.
//

import SwiftUI

struct BubbleView: View {
    @State var selectedTarget:TARGET = .TOP_4
    
    @ObservedObject var tournamentData: TournamentData
    
    var body: some View {
        VStack {
            Text("\(tournamentData.numberOfPlayers) player tournament")
                .padding(.top, 10)
                .foregroundColor(.black)
            HStack {
                Text("Target Placement")
                    .foregroundColor(.black)
                Picker("Placement", selection: $selectedTarget) {
                    ForEach(TARGET.allCases.filter{$0.rawValue <= tournamentData.numberOfPlayers}) { placement in
                        Text("Top \(placement.rawValue)")
                    }
                }
            }
            .padding(.horizontal)
            VStack {
                ForEach(tournamentData.tournamentBracket.indices, id:\.self) { i in
                    let bracket = tournamentData.tournamentBracket[i]
                    VStack {
                        Text("\(bracket[0].wins) Rounds")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Text("Top \(selectedTarget.rawValue) bubble: \(getBubbleLocation(bracket: bracket))")
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
                NavigationLink(destination: FullDataView(tournamentData: tournamentData)) {
                    Text("See Full Breakdown")
                }
                .padding()
            }
            .background{
                Color.calcLightGrey
            }
        }
        .background{
            LinearGradient(colors: [Color.calcOrange, Color.calcYellow], startPoint: .leading, endPoint: .trailing)
        }
        .cornerRadius(20)
    }
    
    func getBubbleLocation(bracket:[SanitizedBubble]) -> String {
        let bubble = Calculator.getAveragePlacementBubbleForTournament(tournament: bracket, placement: selectedTarget)
        
        return "\(bubble.numPlayersIn)/\(bubble.numPlayersWithRecord) players with a \(bubble.wins)-\(bubble.losses) record"
    }
}

#Preview {
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
    var data = TournamentData(numPlayers: 13, bracket: [testTourney13PlayersSmaller, testTourney13PlayersLarger])
    BubbleView(tournamentData: data)
}
