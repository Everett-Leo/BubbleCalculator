//
//  DataStructs.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 10/5/26.
//

import Foundation

enum ROUTE: Hashable {
    case details(id: Int)
}

enum TARGET:Int, CaseIterable, Identifiable {
    case TOP_4 = 4
    case TOP_8 = 8
    case TOP_16 = 16
    case TOP_32 = 32
    case TOP_64 = 64
    case TOP_128 = 128
    case TOP_256 = 256
    var id: Self {self}
}

struct SanitizedBubble: Identifiable, Hashable {
    var id: String {"\(wins)/\(losses)"}
    var wins: Int
    var losses: Int
    var averageSize: Int
    var maxSize: Int
    var minSize: Int
    var allPossibleSizes: [Int]
    
    mutating func calculateSizes() {
        var totalSize = 0
        var max = -1
        var min = -1
        for i in 0..<allPossibleSizes.count {
            totalSize += allPossibleSizes[i]
            
            if max == -1 {
                max = allPossibleSizes[i]
            }
            if min == -1 {
                min = allPossibleSizes[i]
            }
            
            if(allPossibleSizes[i] > max) {
                max = allPossibleSizes[i]
            }
            if(allPossibleSizes[i] < min) {
                min = allPossibleSizes[i]
            }
        }
        
        maxSize = max
        minSize = min
        averageSize = totalSize / allPossibleSizes.count
    }
}

struct Bubble {
    var wins: Int = 0
    var losses: Int = 0
    var numPlayersWithRecord:Int = 0
    var numPlayersIn: Int = 0
}

struct AllBubbles {
    var maxBubble: Bubble
    var averageBubble: Bubble
    var minBubble: Bubble
}
