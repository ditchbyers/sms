//
//  HealthManager.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 07.11.24.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDate: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }
}

struct stepData {
    let stepValue: Double
    let startDate: String
    let endDate: String
}

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    let healthstore = HKHealthStore()
    let dateFormatter = DateFormatter()
    
    init() {
        Task {
            do {
                try await requestHealthKitAccess()
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func requestHealthKitAccess() async throws {
        // QuantityTypes
        let steps               = HKQuantityType(.stepCount)
        let calories            = HKQuantityType(.activeEnergyBurned)
        let exercise            = HKQuantityType(.appleExerciseTime)
        let heartRate           = HKQuantityType(.heartRate)
        let restingHeartRate    = HKQuantityType(.restingHeartRate)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // CategoryTypes
        let stand                           = HKCategoryType(.appleStandHour)
        let irregularHeartRateRythmEvent    = HKCategoryType(.irregularHeartRhythmEvent)

        // Set der abgefragten Daten
        let healthTypes: Set = [steps, calories, exercise, stand, heartRate, irregularHeartRateRythmEvent, restingHeartRate]
        
        // Anfrage der ausgewählten Healthtypes
        // Öffnet HealthApp beim ersten Öffnen der SmartHealthCare App
        // und forder User auf Daten zur Abfrage freizugeben
        try await healthstore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    func fetchTodayRestingHeartRate(completion: @escaping(Result<[Double], Error>) -> Void) {
        let restingHeartRate = HKQuantityType(.restingHeartRate)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDate, end: Date())
        let query = HKSampleQuery(sampleType: restingHeartRate, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results,
            error in guard let samples = results as? [HKQuantitySample], error == nil else {
                completion(.failure(NSError()))
                return
            }
                        
            let restingHeartRateThreshold = 130.0  // Example threshold for resting heart rate (below 60 bpm is often considered resting)
            let restingHeartRates = samples.filter { sample in
                // Assuming values under 60 bpm are considered "resting"
                sample.quantity.doubleValue(for: .count().unitDivided(by: .minute())) < restingHeartRateThreshold
            }
                                
            if restingHeartRates.isEmpty {
                completion(.success([]))  // No resting heart rate samples found
            } else {
                // Extract the heart rate values from the samples
                let heartRates = restingHeartRates.map { sample in
                    sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
                }
                completion(.success(heartRates))  // Return an array of resting heart rates
            }
        }
        
        // Execute the query
        healthstore.execute(query)
    }
    
    func fetchTodayIrregularHeartRateRyhtmEvent(completion: @escaping(Result<Double, Error>) -> Void) {
        let events = HKCategoryType(.irregularHeartRhythmEvent)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDate, end: Date())
        let query = HKSampleQuery(sampleType: events, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results,
            error in guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            if(samples.count == 0){
                completion(.success(0.0))
            } else {
                let standCount = samples.filter({ $0.value == 0}).count
                completion(.success(Double(standCount)))
            }
        }
        
        healthstore.execute(query)
    }
    
    
    
    func fetchTodaySteps(completion: @escaping(Result<(Activity, [stepData]), Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDate, end: Date())
        
        let query = HKSampleQuery(sampleType: steps, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let watchValues = samples.filter { $0.device?.model == "Watch" }
            
            var stepCount = 0.0
            let stepValues = watchValues.map { watchValue in
                let stepValue = watchValue.quantity.doubleValue(for: .count())
                stepCount += stepValue
                
                // Create a stepData instance for each watch value
                return stepData(
                    stepValue: stepValue, // Get the step count
                    startDate: self.dateFormatter.string(from: watchValue.startDate), // Format the start date
                    endDate: self.dateFormatter.string(from: watchValue.endDate) // Format the end date
                )
            }
            
            print(stepValues)
            
            let activity = Activity(id: UUID(), title: "Today Steps", subtitle: "Goal: 800", image: "figure.walk", current: "\(Int(stepCount))")
            
            // Return the activity and the step values as a tuple
            completion(.success((activity, stepValues)))
        }
        
        healthstore.execute(query)
    }

    
    func fetchTodayCaloriesBurned(completion: @escaping(Result<Double, Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDate, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results,
            error in guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            completion(.success(caloriesBurned))
        }
        
        healthstore.execute(query)
    }
    
    func fetchTodayExerciseTime(completion: @escaping(Result<Double, Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDate, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) {_, results,
            error in guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError(domain: "com.pascalmay.SmartHealthCare", code: 1, userInfo: [NSLocalizedDescriptionKey: "An error occurred fetching exercise time"])))
                return
            }
            
            let exerciseTime = quantity.doubleValue(for: .minute())
            completion(.success(exerciseTime))
        }
        
        healthstore.execute(query)
    }
    
    func fetchTodayStandHours(completion: @escaping(Result<Double, Error>) -> Void) {
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDate, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results,
            error in guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            if(samples.count == 0){
                completion(.success(0.0))
            } else {
                let standCount = samples.filter({ $0.value == 0}).count
                completion(.success(Double(standCount)))
            }
        }
        
        healthstore.execute(query)
    }
    
    func fetchTodayHeartRate(completion: @escaping(Result<[Double], Error>) -> Void) {
        // Create the heart rate sample type
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDate, end: Date())
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results,
            error in guard let samples = results as? [HKQuantitySample], error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            if samples.isEmpty {
                completion(.success([]))  // No heart rate samples for today
            } else {
                // Extract heart rate values in bpm (beats per minute) from the samples
                let heartRates = samples.map { $0.quantity.doubleValue(for: .count().unitDivided(by: .minute())) }
                completion(.success(heartRates))  // Return an array of heart rates
            }
        }
        
        // Execute the query
        healthstore.execute(query)
    }
}
