//
//  ModelView-ContentView.swift
//  HackingWithSwiftUI-BetterRest
//
//  Created by Michael Jones on 11/07/2026.
//

import CoreML
import Foundation

extension ContentView {
    @Observable
    class ViewModel {
        var wakeUp = defaultWakeTime
        var sleepAmount = 8.0
        var coffeeAmount = 1
        
        /// A Static computed property generating a Date object that represents a default wake-up time (7:00AM) on the current day.
        static var defaultWakeTime: Date {
            var components = DateComponents()
            components.hour = 7
            components.minute = 0
            return Calendar.current.date(from: components) ?? .now
        }
        
        /// Using CoreML, this computed property calculates and returns a string of the users ideal bedtime based on the wake-up time, desired amount of sleep and daily coffee intake.
        var sleepResults: String {
            do {
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                let hour = (components.hour ?? 0) * 60 * 60
                let minute = (components.minute ?? 0) * 60
                
                let prediction = try model.prediction(
                    wake: Double(
                        hour + minute
                    ),
                    estimatedSleep: sleepAmount,
                    coffee: Double(
                        coffeeAmount
                    )
                )
                
                let sleepTime = wakeUp - prediction.actualSleep
                
                return "Your ideal bedtime is...." + sleepTime.formatted(date: .omitted, time: .shortened)
            } catch {
                return "Error: Unable to calculate sleep time. Please try again."
            }
        }
    }
}
