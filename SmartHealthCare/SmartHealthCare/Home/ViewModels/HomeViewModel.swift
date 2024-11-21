//
//  HomeViewModel.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 07.11.24.
//

import Foundation

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}

class HomeViewModel: ObservableObject {
    let healthManager = HealthManager.shared
    
    @Published var calories: Int = 0
    @Published var exercise: Int = 0
    @Published var stand: Int = 0
    @Published var activities = [Activity]()
    @Published var count = 0
        
    init() {
        Task {
            do {
                try await healthManager.requestHealthKitAccess()
            } catch {
                print(error.localizedDescription)
            }
        }             
    }
    
    func updateUI(){
        fetchTodaySteps()
        fetchTodayCaloriesBurned()
        fetchTodayStandHours()
        fetchTodayExerciseTime()
        fetchTodayHeartRate()
        fetchTodayIrregularHeartRythmEvents()
        // fetchTodayRestingHeartRate()
    }
    
    func fetchTodayRestingHeartRate(){
        healthManager.fetchTodayRestingHeartRate {_ in }
    }
    
    func fetchTodayIrregularHeartRythmEvents() {
        healthManager.fetchTodayIrregularHeartRateRyhtmEvent {_ in }
    }
    
    func fetchTodayHeartRate() {
        healthManager.fetchTodayHeartRate {_ in }
    }
    
    func fetchTodayCaloriesBurned() {
        healthManager.fetchTodayCaloriesBurned { result in
            switch result {
            case .success(let calories):
                DispatchQueue.main.async {
                    self.calories = Int(calories)
                    let activity = Activity(id: UUID(), title: "Today Calories", subtitle: "Goal: 500", image: "flame", current: "\(Int(calories))")
                    
                    let row = self.activities.firstIndex(where: {$0.title == activity.title})
                    if(row == nil) {
                        self.activities.append(activity)
                    } else {
                        self.activities.remove(at: row!)
                        self.activities.append( activity)
                    }
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func fetchTodayExerciseTime() {
        healthManager.fetchTodayExerciseTime { result in
            switch result {
            case .success(let exercise):
                DispatchQueue.main.async {
                    self.exercise = Int(exercise)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func fetchTodayStandHours(){
        healthManager.fetchTodayStandHours { result in
            switch result {
            case .success(let hours):
                DispatchQueue.main.async {
                    self.stand = Int(hours)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func fetchTodaySteps() {
        healthManager.fetchTodaySteps { result in
            switch result {
            case .success((let activity, _)):
                DispatchQueue.main.async {
                    let row = self.activities.firstIndex(where: {$0.title == activity.title})
                    
                    if(row == nil) {
                        self.activities.append(activity)
                    } else {
                        self.activities.remove(at: row!)
                        self.activities.append(activity)
                    }
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}
