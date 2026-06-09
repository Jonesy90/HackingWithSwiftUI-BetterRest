//
//  ContentView.swift
//  HackingWithSwiftUI-BetterRest
//
//  Created by Michael Jones on 04/06/2026.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    //Static Variable. This means it belongs to the 'ContentView' Struct itself, rather than an instance of 'ContentView'.
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep:")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily Coffee Consumption")
                        .font(.headline)
                    
                    //Specialised form of the markdown, which is common in free-text.
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20, step: 1)
                }
            }
            .navigationTitle(Text("Better Rest"))
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", action: {})
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    /// Uses CoreML model to predict the ideal time to go to bed based on when the user wants to wake up, how much sleep they want and how often they drink coffee.
    private func calculateBedtime() {
        do {
            // Sets up the ML environment and creates an instance of the CoreML model (SleepCalculator).
            let config = MLModelConfiguration() // The configuration settings for create or updating a CoreML model.
            let model = try SleepCalculator(configuration: config) // Reads all the data and sends back a predicted output.
            
            // Extracts the hour and minute from the wakeUp @State property.
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // Calls to create a prediction using wake, estimatedSleep and coffee as parameters.
            // Returns a prediction that contains 'actualSleep', which is how much sleep the user actually needs (in seconds).
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            // Calculates what time the user should go to bed.
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            // If anything goes wrong (e.g., model failing to load, an error message will appear instead.
            alertTitle = "Error"
            alertMessage = "Something went wrong. Please try again."
        }
        
        // Triggers the Alert view to show one of the results (Prediction or Error message).
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
