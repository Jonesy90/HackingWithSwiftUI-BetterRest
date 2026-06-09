//
//  ContentView.swift
//  HackingWithSwiftUI-BetterRest
//
//  Created by Michael Jones on 04/06/2026.
//

/*
 Hacking With SwiftUI - Better Rest : Challenges
 1. Replace each VStack in our form with a Section, where the text view is the title of the section. Do you prefer this layout or the VStack layout? It’s your app – you choose! - DONE!
 2. Replace the “Number of cups” stepper with a Picker showing the same range of values. - DONE!
 3. Change the user interface so that it always shows their recommended bedtime using a nice and large font. You should be able to remove the “Calculate” button entirely. - DONE!
*/

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    //Static Variable. This means it belongs to the 'ContentView' Struct itself, rather than an instance of 'ContentView'.
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var sleepResults: String {
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
            
            return "Your ideal bedtime is..." + sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            return "Error: Unable to calculate sleep time. Please try again."
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?"){
                    DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep:") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily Coffee Consumption"){
                    Picker("Coffee Consumption", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("^[\($0) cup](inflect: true)") //Specialised form of the markdown, which is common in free-text.
                                .tag($0)
                        }
                    }
                }
                
                Text(sleepResults)
                    .font(.title3)
            }
            .navigationTitle(Text("Better Rest"))
        }
    }
}

#Preview {
    ContentView()
}
