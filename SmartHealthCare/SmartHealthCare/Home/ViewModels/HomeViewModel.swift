import Foundation
import HealthKit

class HomeViewModel: ObservableObject {
  var healthManager: HealthManager = HealthManager.shared
  var isLoading: Bool = false

  @Published var circle: [CircleValues] = []
  @Published var activities: [Activity] = []

  func fetchHomeData() {
    self.isLoading = true
    self.circle = []
    self.activities = []

    DispatchQueue.global(qos: .userInitiated).async {
      for key in self.healthManager.healthData.keys.sorted() {
        let type = self.healthManager.getType(forKey: key)

        // Handle different health data types (HKQuantityType or HKCategoryType)
        if let quantityType = type as? HKQuantityType {
          self.fetchStatistics(
            forKey: key,
            forType: quantityType,
            startDate: Calendar.current.startOfDay(for: Calendar.current.startOfDay(for: Date())),
            interval: DateComponents(day: 1))
        } else if let categoryType = type as? HKCategoryType {
          self.fetchSamples(
            forKey: key,
            forType: categoryType,
            startDate: Calendar.current.startOfDay(for: Calendar.current.startOfDay(for: Date())))
        } else {
          print("Invalid health data type")
        }
      }
    }
    self.isLoading = false
    
    print(self.circle)
  }

  private func fetchSamples(
    forKey key: String, forType categoryType: HKCategoryType, startDate: Date
  ) {
    healthManager.fetchSamples(forType: categoryType, startDate: startDate) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let samples):
          self.prepareSampleData(forKey: key, samples: samples)
        case .failure(let error):
          self.handleStatisticsError(error)
        }
      }
    }
  }

  private func fetchStatistics(
    forKey key: String,
    forType quantityType: HKQuantityType, startDate: Date, interval: DateComponents
  ) {
    healthManager.fetchStatistics(forType: quantityType, startDate: startDate, interval: interval) {
      result in
      DispatchQueue.main.async {
        switch result {
        case .success(let (statisticData, statisticOption)):
          self.handleStatisticsSuccess(
            forKey: key,
            statisticData: statisticData, statisticOption: statisticOption)
        case .failure(let error):
          self.handleStatisticsError(error)
        }
      }
    }
  }

  private func handleStatisticsSuccess(
    forKey key: String, statisticData: [HKStatistics], statisticOption: HKStatisticsOptions
  ) {
    switch statisticOption {
    case .cumulativeSum:
      self.prepareCumulativeData(forKey: key, statistics: statisticData)
    case [.discreteMin, .discreteMax]:
      self.prepareDiscreteData(forKey: key, statistics: statisticData)
    default:
      print("Option unknown")
    }
  }

  private func handleStatisticsError(_ error: Error) {
    print("Error fetching statistics: \(error.localizedDescription)")
  }

  func prepareCumulativeData(forKey key: String, statistics: [HKStatistics]) {
    let d = healthManager.healthData[key]

    if let sum = statistics[0].sumQuantity() {
      let value = sum.doubleValue(for: self.healthManager.getUnit(forKey: key))

      self.activities.append(
        Activity(title: d!.title, subtitle: d!.subtitle, image: d!.icon, current: Int(value)))

      if d!.circle {
        self.circle.append(
          CircleValues(goal: d!.goal!, color: d!.color!, progress: Int(value), title: d!.title))
      }
    } else {
      self.activities.append(
        Activity(title: d!.title, subtitle: d!.subtitle, image: d!.icon, current: 0))

      if d!.circle {
        self.circle.append(
          CircleValues(goal: d!.goal!, color: d!.color!, progress: 0, title: d!.title))
      }
    }
  }

  func prepareDiscreteData(forKey key: String, statistics: [HKStatistics]) {
    let d = healthManager.healthData[key]

    if let minQuantity = statistics[0].minimumQuantity(),
      let maxQuantity = statistics[0].maximumQuantity()
    {
      let unit = self.healthManager.getUnit(forKey: key)

      let minDouble = minQuantity.doubleValue(
        for: unit)
      let maxDouble = maxQuantity.doubleValue(
        for: unit)
      
      self.activities.append(
        Activity(title: d!.title, subtitle: d!.subtitle, image: d!.icon, current: Int(minDouble)))
    }
  }

  func prepareSampleData(forKey key: String, samples: [HKCategorySample]) {
    let d = healthManager.healthData[key]

    if samples.count == 0 {
      self.activities.append(Activity(title: d!.title, subtitle: d!.subtitle, image: d!.icon, current: 0))
      
      if(d!.circle) {
        self.circle.append(CircleValues(goal: d!.goal!, color: d!.color!, progress: 0, title: d!.title))
      }
      
    } else {
      let value = samples.filter({ $0.value == 0 }).count
      self.activities.append(Activity(title: d!.title, subtitle: d!.subtitle, image: d!.icon, current: value))
      
      if(d!.circle) {
        self.circle.append(CircleValues(goal: d!.goal!, color: d!.color!, progress: Int(value), title: d!.title))
      }
    }
  }
}
