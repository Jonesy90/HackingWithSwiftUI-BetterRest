//
//  ContentView.swift
//  HackingWithSwiftUI-BetterRest
//
//  Created by Michael Jones on 04/06/2026.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?"){
                    DatePicker("Please enter time", selection: $viewModel.wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep:") {
                    Stepper("\(viewModel.sleepAmount.formatted()) hours", value: $viewModel.sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily Coffee Consumption"){
                    Picker("Coffee Consumption", selection: $viewModel.coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("^[\($0) cup](inflect: true)") //Specialised form of the markdown, which is common in free-text.
                                .tag($0)
                        }
                    }
                }
                
                Text(viewModel.sleepResults)
                    .font(.title3)
            }
            .navigationTitle(Text("Better Rest"))
        }
    }
}

#Preview {
    ContentView()
}
