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

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    let healthstore = HKHealthStore()
    
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
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKCategoryType(.appleStandHour)
        
        let healthTypes: Set = [steps, calories, exercise, stand]
        
        try await healthstore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    func fetchTodaySteps(completion: @escaping(Result<Activity, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in guard let quantity = result?.sumQuantity(), error == nil else {
            completion(.failure(NSError()))
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: UUID(), title: "Today Steps", subtitle: "Goal: 800", image: "figure.walk", current: "\(Int(stepCount))")
            completion(.success(activity))
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
        
            print(samples)
            print(samples.map({ $0.value }))
            
            if(samples.count == 0){
                completion(.success(0.0))
            } else {
                let standCount = samples.filter({ $0.value == 0}).count
                completion(.success(Double(standCount)))
            }
        }
        
        healthstore.execute(query)
    }
    
}

