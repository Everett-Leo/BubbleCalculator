//
//  TournamentData.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 10/5/26.
//

import Foundation
import Combine

class TournamentData: ObservableObject, Identifiable, Hashable {
    @Published var numberOfPlayers: Int
    @Published var tournamentBracket: [[SanitizedBubble]]
    let id = UUID()
    
    init(numPlayers: Int, bracket: [[SanitizedBubble]]) {
        numberOfPlayers = numPlayers
        tournamentBracket = bracket
    }
    
    static func == (lhs: TournamentData, rhs: TournamentData) -> Bool {
        if lhs.numberOfPlayers != rhs.numberOfPlayers {
            return false
        }
        
        if lhs.tournamentBracket.count != rhs.tournamentBracket.count {
            return false
        }
        
        for i in 0..<lhs.tournamentBracket.count {
            for j in 0..<lhs.tournamentBracket[i].count {
                if lhs.tournamentBracket[i][j] != rhs.tournamentBracket[i][j] {
                    return false
                }
            }
        }
        
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(numberOfPlayers)
        hasher.combine(tournamentBracket)
        hasher.combine(id)
    }
}
