//
//  Calculator.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 7/28/26.
//

import Foundation

struct PlacementBubble: Equatable {
    var wins: Int
    var losses: Int
    var bubbleSize: Int
    
    static func == (lhs: PlacementBubble, rhs: PlacementBubble) -> Bool {
        return lhs.wins == rhs.wins && lhs.losses == rhs.losses && lhs.bubbleSize == rhs.bubbleSize
    }
}

struct PairUpPairDown {
    var lowerPlacementWins: Int
    var lowerPlacementLoses: Int
}

class Calculator: NSObject {
    private var size: Int
    private var maxNumberOfRounds: Int
    private var oneUndefeated: Bool
    
    init(numberOfPlayers:Int = 0, numberOfRounds:Int = 0, playUntilOneUndefeated: Bool = true) {
        size = numberOfPlayers
        maxNumberOfRounds = numberOfRounds
        oneUndefeated = playUntilOneUndefeated
    }
    
    func setSize(numberOfPlayers:Int) {
        size = numberOfPlayers
    }
    
    func setNumberOfRounds(numberOfRounds:Int) {
        maxNumberOfRounds = numberOfRounds
    }
    
    func setPlayUntilOneUndefeated(oneUndefeated:Bool) {
        self.oneUndefeated = oneUndefeated
    }
    
// MARK: Static Functions
    static func splitTournamentByNumberOfRounds(tournament:[SanitizedBubble]) -> [[SanitizedBubble]] {
        var filteredTournaments: [[SanitizedBubble]] = []
        
        for bubble in tournament {
            let numRounds = bubble.wins + bubble.losses
            
            var filterIndex = -1
            for i in 0..<filteredTournaments.count {
                let numFilteredRounds = filteredTournaments[i][0].wins + filteredTournaments[i][0].losses
                
                if numRounds == numFilteredRounds {
                    filterIndex = i
                }
            }
            
            if filterIndex >= 0 {
                filteredTournaments[filterIndex].append(bubble)
            }
            else {
                filteredTournaments.append([bubble])
            }
        }
        
        return filteredTournaments
    }
    
    static func sanitizeTournament(tournaments:[[PlacementBubble]]) -> [SanitizedBubble] {
        var sanitizedTournament:[SanitizedBubble] = []
        
        for tourney in tournaments {
            for bracket in tourney {
                var found = false
                for i in 0..<sanitizedTournament.count {
                    if sanitizedTournament[i].wins == bracket.wins && sanitizedTournament[i].losses == bracket.losses {
                        sanitizedTournament[i].allPossibleSizes.append(bracket.bubbleSize)
                        found = true
                    }
                }
                
                if !found {
                    sanitizedTournament.append(SanitizedBubble(wins: bracket.wins, losses: bracket.losses, averageSize: 0, maxSize: 0, minSize: 0, allPossibleSizes: [bracket.bubbleSize]))
                }
            }
        }
        
        for i in 0..<sanitizedTournament.count {
            sanitizedTournament[i].calculateSizes()
        }
        
        return sanitizedTournament
    }
    
    static func getAveragePlacementBubbleForTournament(tournament:[SanitizedBubble], placement:TARGET) -> Bubble {
        var openSlotsInBubble = placement.rawValue
        var theBubble = Bubble()
        
        for i in 0..<tournament.count {
            let record = tournament[i]
            if record.averageSize >= openSlotsInBubble {
                theBubble = Bubble(wins: record.wins, losses: record.losses, numPlayersWithRecord: record.averageSize, numPlayersIn: openSlotsInBubble)
                break
            }
            else {
                openSlotsInBubble -= record.averageSize
            }
        }
        
        return theBubble
    }
    
    static func getAllPlacementBubblesForTournament(tournament:[SanitizedBubble], placement:TARGET) -> AllBubbles {
        var max = Bubble(), average = Bubble(), min = Bubble()
        var maxOpenSlots = placement.rawValue, avgOpenSlots = placement.rawValue, minOpenSlots = placement.rawValue
        var foundMax = false, foundAvg = false, foundMin = false
        
        for i in 0..<tournament.count {
            let record = tournament[i]
            if !foundAvg {
                if record.averageSize >= avgOpenSlots {
                    average = Bubble(wins: record.wins, losses: record.losses, numPlayersWithRecord: record.averageSize, numPlayersIn: avgOpenSlots)
                    foundAvg = true
                }
                else {
                    avgOpenSlots -= record.averageSize
                }
            }
            
            if !foundMax {
                let maxSize = record.maxSize
                if maxSize >= maxOpenSlots {
                    max = Bubble(wins: record.wins, losses: record.losses, numPlayersWithRecord: maxSize, numPlayersIn: maxOpenSlots)
                    foundMax = true
                }
                else {
                    maxOpenSlots -= maxSize
                }
            }
            
            if !foundMin {
                let minSize = record.minSize
                if minSize >= minOpenSlots {
                    min = Bubble(wins: record.wins, losses: record.losses, numPlayersWithRecord: minSize, numPlayersIn: minOpenSlots)
                    foundMax = true
                }
                else {
                    minOpenSlots -= minSize
                }
            }
            
            if foundAvg && foundMax && foundMin {
                break
            }
        }
        
        return AllBubbles(maxBubble: max, averageBubble: average, minBubble: min)
    }
    
// MARK: Calculation Functions
    func calculateTournament() -> [[PlacementBubble]] {
        let startingBracket = [PlacementBubble(wins: 0, losses: 0, bubbleSize: self.size)]
        let finalBracket = self.RunTournament(bracket: startingBracket)
        return finalBracket
        
    }
    
    private func RunTournament(bracket: [PlacementBubble]) -> [[PlacementBubble]] {
        // loop through the data running rounds of the tournament until all tournaments are finished
        
        // calculate the first round to seed the data
        var currentRound = self.calculateNextRound(bracket: bracket)
        var nextRound:[[PlacementBubble]] = []
        
        // put a failsafe at 13 rounds (that is swiss until a single undefeated for a 8192 person event)
        let failSafe = 13
        var needAnotherRound = true
        
        while needAnotherRound {
            needAnotherRound = false
            nextRound = []
            for i in 0..<currentRound.count {
                // the x-0s have the number of rounds played in their wins
                let roundInstance = currentRound[i]
                let numRoundsPlayed = roundInstance[0].wins
                let numUndefeated = roundInstance[0].bubbleSize
                
                // if we have not played all the rounds that was set or haven't hit the failsafe number of rounds
                if numRoundsPlayed < failSafe {
                    if oneUndefeated {
                        if numUndefeated > 1 {
                            // play another round
                            needAnotherRound = true
                            let nextInstanceRound = calculateNextRound(bracket: roundInstance)
                            nextRound.append(contentsOf: nextInstanceRound)
                        }
                        else {
                            nextRound.append(roundInstance)
                        }
                    }
                    else {
                        if self.maxNumberOfRounds > 0 && numRoundsPlayed < self.maxNumberOfRounds {
                            // play another round
                            needAnotherRound = true
                            let nextInstanceRound = calculateNextRound(bracket: roundInstance)
                            nextRound.append(contentsOf: nextInstanceRound)
                        }
                        else {
                            nextRound.append(roundInstance)
                        }
                    }
                }
            }
            
            if nextRound.count > 0 {
                currentRound = nextRound
            }
        }
        
        return currentRound
    }
    
    private func calculateNextRound(bracket:[PlacementBubble]) -> [[PlacementBubble]] {
        var nextRoundBracket:[PlacementBubble] = []
        var pairUps = [PairUpPairDown]()
        // recursively calculate a tournament
        // if it is the final one return it
        var needPairUp = false
        var needBye = false
        for var bubble in bracket {
            // if we need a pair-up, grab a player from this placement for the pair-up
            if needPairUp {
                bubble.bubbleSize -= 1
                pairUps.append(PairUpPairDown(lowerPlacementWins: bubble.wins, lowerPlacementLoses: bubble.losses))
                needPairUp = false
            }
            // if there are an odd number of people in this placement we need a pair-up
            // take a player out of the placement for the pair-up
            if bubble.bubbleSize % 2 != 0 {
                if bubble.wins > 0 {
                    // if this bubble isn't the lowest bubble, we need a pairup/down
                    bubble.bubbleSize -= 1
                    needPairUp = true;
                }
                else {
                    // if this is the lowest bubble, we need a bye
                    needBye = true
                }
            }
            
            var winners, losers:PlacementBubble
            if nextRoundBracket.count > 0 {
                // if this isn't the first entry, grab the last output bracket (which would be the losers from the higher bracket this round) put the winners in there and make a new entry for the losers
                var winners = nextRoundBracket[nextRoundBracket.count - 1]
                winners.bubbleSize += bubble.bubbleSize / 2
                if needBye {
                    // if we need a bye, add it to the winners
                    winners.bubbleSize += 1
                    needBye = false
                }
                losers = PlacementBubble(wins: bubble.wins, losses: bubble.losses + 1, bubbleSize: bubble.bubbleSize / 2)
                nextRoundBracket[nextRoundBracket.count - 1] = winners
                nextRoundBracket.append(losers)
            }
            else {
                // if this is the first entry, split the placement into winners and losers, and put it into the output bracket
                winners = PlacementBubble(wins: bubble.wins + 1, losses: bubble.losses, bubbleSize: bubble.bubbleSize / 2)
                losers = PlacementBubble(wins: bubble.wins, losses: bubble.losses + 1, bubbleSize: bubble.bubbleSize / 2)
                if needBye {
                    // if we need a bye, add it to the winners
                    winners.bubbleSize += 1
                    needBye = false
                }
                nextRoundBracket.append(winners)
                nextRoundBracket.append(losers)
            }
        }
        
        if pairUps.count > 0 {
            let finalizedNextRound = self.calculatePairUps(bracket: nextRoundBracket, pairUps: pairUps)
            
            return finalizedNextRound
        }
        else {
            return [nextRoundBracket]
        }
    }
    
    private func calculatePairUps(bracket:[PlacementBubble], pairUps:[PairUpPairDown]) -> [[PlacementBubble]] {
        var outputBracket:[[PlacementBubble]] = []
        
        if(pairUps.count > 0) {
            // process all of the pair-up/pair-downs
            
            // get the total number of combinations for all of the pair-ups
            // 2^(number of pair-ups) is the number of all possible combinations
            let numCombinations = Int(powl(2, Double(pairUps.count)))
            for i in 0..<numCombinations {
                // get the binary representation of the combination as a string so we can preserve the number of characters that we need
                // 1 = higher seed wins
                // 0 = lower seed wins
                var bin = String(i, radix: 2)   // turn the current number into binary
                for _ in 0..<(pairUps.count - bin.count) {
                    // append 0s to the front of the number so we have the right number of characters
                    bin = "0" + bin
                }
                
                // go through each character to generate the new bracket for the current combination
                let characters = Array(bin)
                var nextRoundCopy = bracket
                for  j in 0..<characters.count {
                    let char = Int(String(characters[j]))
                    let pairup = pairUps[j]
                    
                    if(char == 1) {
                        // the higher seed won
                        // get the bubbles above and below the lower placement's loses to add those players in
                        // the higher seed will stay in the same loss bracket and the lower seed will move down a loss bracket
                        let higherId = nextRoundCopy.firstIndex(where: {$0.losses == pairup.lowerPlacementLoses - 1})
                        let lowerId = nextRoundCopy.firstIndex(where: {$0.losses == pairup.lowerPlacementLoses + 1})
                        if higherId != nil && lowerId != nil {
                            var higher = nextRoundCopy[higherId!]
                            var lower = nextRoundCopy[lowerId!]
                            higher.bubbleSize += 1
                            lower.bubbleSize += 1
                            nextRoundCopy[higherId!] = higher
                            nextRoundCopy[lowerId!] = lower
                        }
                    }
                    else {
                        // the lower seed won
                        // get the bubble for the lower placement's loses and add both players in there
                        // the higher seed moves down a loss bracket, while the lower seed stays in the same loss bracket
                        let bubbleId = nextRoundCopy.firstIndex(where: {$0.losses == pairup.lowerPlacementLoses})
                        if bubbleId != nil {
                            var bubble = nextRoundCopy[bubbleId!]
                            bubble.bubbleSize += 2
                            nextRoundCopy[bubbleId!] = bubble
                        }
                    }
                    
                    outputBracket.append(nextRoundCopy)
                }
            }
        }
        
        return outputBracket
    }
    
    private func sanitizeBrackets(tournament:[[PlacementBubble]]) -> [[PlacementBubble]] {
        // TODO: go through the all of the tournaments and remove all duplicate brackets
        return [[]]
    }
}
