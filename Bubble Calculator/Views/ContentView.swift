//
//  ContentView.swift
//  Bubble Calculator
//
//  Created by Everett Leo on 7/28/26.
//

import SwiftUI
import Charts
import CoreData
import UIKit

struct ContentView: View {
    @EnvironmentObject var tournamentData: TournamentData
    @State var numPlayers = 4
    @State var numRounds = 1
    @State var untilUndefeated = true
    @State private var errorPresented = false
    @State var theBubble: String = ""
    @State var showingSpinner = false
    
    @FocusState private var numPlayersIsFocused: Bool
    @FocusState private var numRoundsIsFocused: Bool
    
    var calc: Calculator = Calculator()
    
    var body: some View {
        NavigationView {
            VStack {
                VStack{
                    HStack {
                        Text("# of Players:")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .font(.system(size: 20, weight: .bold))
                        TextField("", value: $numPlayers, format:.number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .focused($numPlayersIsFocused)
                    }
                    .padding(.top)
                    HStack {
                        Text("# of Rounds:")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .font(.system(size: 20, weight: .bold))
                        TextField("", value:$numRounds, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .focused($numRoundsIsFocused)
                            .disabled(untilUndefeated)
                    }
                    .padding(.top, 15)
                    Toggle(isOn: $untilUndefeated, label: {
                        Text("Play until 1 undefeated")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight:.bold))
                    })
                    .padding(.horizontal)
                    .padding(.top, 15)
                    Button(action:startCalculation) {
                        if showingSpinner {
                            ProgressView()
                                .tint(.white)
                                .controlSize(.large)
                                .frame(width:300, height:50)
                        }
                        else {
                            Text("Calculate Placement")
                                .foregroundColor(.white)
                                .frame(width: 300, height:50)
                                .font(.system(size: 18, weight:.bold))
                        }
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.calcButtonBlue)
                    )
                    .alert("Hold Up!", isPresented:$errorPresented, actions: {}, message: {
                        Text("You need to play more than one round if you don't play until one undefeated")
                    })
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .padding(.top, 30)
                    .cornerRadius(10)
                }
                .background {
                    LinearGradient(colors: [Color.calcLightBlue, Color.calcDarkBlue], startPoint: .top, endPoint: .bottom)
                }
                .cornerRadius(20)
                .padding(.top, 50)
                if tournamentData.tournamentBracket.count > 0 {
                    BubbleView(tournamentData: tournamentData)
                }
                Spacer()
            }
            .padding()
            .background {
                Color.calcBGBlue
            }
            .ignoresSafeArea()
        }
        .navigationTitle("")
    }
    
    func startCalculation() {
        if !showingSpinner && !untilUndefeated && numRounds == 0 {
            errorPresented = true
            return
        }
        
        numPlayersIsFocused = false
        numRoundsIsFocused = false
                        
        showingSpinner = true
        DispatchQueue.global(qos:.background).async {
            var tournament:[[SanitizedBubble]] = []
            
            calc.setSize(numberOfPlayers: numPlayers)
            calc.setNumberOfRounds(numberOfRounds: numRounds)
            calc.setPlayUntilOneUndefeated(oneUndefeated: untilUndefeated)
            let unsanitizedTournament = calc.calculateTournament()
            let sanitizedTournament = Calculator.sanitizeTournament(tournaments: unsanitizedTournament)
            
            tournament = Calculator.splitTournamentByNumberOfRounds(tournament: sanitizedTournament)
            
            DispatchQueue.main.async {
                tournamentData.tournamentBracket = tournament
                tournamentData.numberOfPlayers = numPlayers
                print(tournamentData.tournamentBracket)
                showingSpinner = false
            }
        }
    }
    
    func getFilteredTargets() -> [Int] {
        let arr = TARGET.AllCases()
        var filtered:[Int] = []
        
        for i in 0..<arr.count {
            let tg = arr[i].rawValue
            
            if(tg < numPlayers) {
                filtered.append(tg)
            }
        }
        
        return filtered
    }
}

#Preview {
    let data = TournamentData(numPlayers: 0, bracket: [])
    ContentView().environmentObject(data)
}
