//
//  Bubble_CalculatorApp.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 7/28/26.
//

import SwiftUI
import CoreData

@main
struct Bubble_CalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(TournamentData(numPlayers: 0, bracket: []))
        }
    }
}
