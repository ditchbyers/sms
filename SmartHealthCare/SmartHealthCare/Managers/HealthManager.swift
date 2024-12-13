import Foundation
import HealthKit

enum StatisticsData {
  case statistics([HKStatistics])
  case option(HKStatisticsOptions)
}

class HealthManager: ObservableObject {
  static let shared = HealthManager()  // Create Singleton
  let healthstore = HKHealthStore()  // Healthkit Instance

  @Published var healthData: [String: HealthData] = [
    "stepCount": HealthData(
      id: UUID(),
      icon: "figure.walk",
      type: HKQuantityType.quantityType(forIdentifier: .stepCount),
      title: "Steps",
      subtitle: "Daily Step Count",
      unit: .count(),
      circle: false,
      goal: 10000
    ),
    "activeEnergyBurned": HealthData(
      id: UUID(),
      icon: "flame",
      type: HKQuantityType.quantityType(
        forIdentifier: .activeEnergyBurned),
      title: "Calories",
      subtitle: "Active Calories Burned",
      unit: .kilocalorie(),
      circle: true,
      color: .red,
      goal: 900
    ),
    "heartRate": HealthData(
      id: UUID(),
      icon: "heart",
      type: HKQuantityType.quantityType(forIdentifier: .heartRate),
      title: "Heart Rate",
      subtitle: "Average Heart Rate",
      unit: HKUnit(from: "count/min"),
      circle: false
    ),
    "appleExerciseTime": HealthData(
      id: UUID(),
      icon: "figure.run",
      type: HKQuantityType.quantityType(
        forIdentifier: .appleExerciseTime),
      title: "Exercise Time",
      subtitle: "Minutes of Exercise",
      unit: .minute(),
      circle: true,
      color: .green,
      goal: 50
    ),
    "irregularHeartRhythmEvent": HealthData(
      id: UUID(),
      icon: "bolt.heart",
      type: HKCategoryType.categoryType(
        forIdentifier: .irregularHeartRhythmEvent),
      title: "Irregular Heart Rhythm Event",
      subtitle: "Occurrences",
      unit: .count(),
      circle: false
    ),
    "appleStandHour": HealthData(
      id: UUID(),
      icon: "figure.stand",
      type: HKCategoryType.categoryType(forIdentifier: .appleStandHour),
      title: "Stand Hours",
      subtitle: "Hours Standing",
      unit: .count(),
      circle: true,
      color: .blue,
      goal: 3
    ),
  ]

  init() {
    Task {
      do {
        try await requestHealthKitAccess()  // Connect to Healthkit
      } catch {
        print(error.localizedDescription)
      }
    }
  }

  func requestHealthKitAccess() async throws {
    var healthTypes: Set<HKObjectType> = []

    for data in healthData.values {
      healthTypes.insert(data.type!)
    }

    try await healthstore.requestAuthorization(toShare: [], read: healthTypes)
  }

  func fetchStatistics(
    forType type: HKQuantityType, startDate: Date, interval: DateComponents,
    completion: @escaping (Result<([HKStatistics], HKStatisticsOptions), Error>) -> Void
  ) {
    let option = getHKStatisticsOption(forType: type)

    let query = HKStatisticsCollectionQuery(
      quantityType: type, quantitySamplePredicate: nil, options: option,
      anchorDate: Calendar.current.startOfDay(for: Date()), intervalComponents: interval)

    query.initialResultsHandler = { query, results, error in
      if let error = error {
        completion(.failure(error))
      }

      var stats: [HKStatistics] = []
      results?.enumerateStatistics(from: startDate, to: Date()) { statistics, _ in
        stats.append(statistics)
      }
      completion(.success((stats, option)))
    }

    healthstore.execute(query)
  }

  func fetchSamples(
    forType type: HKCategoryType, startDate: Date,
    completion: @escaping (Result<[HKCategorySample], Error>) -> Void
  ) {
    let predicate = HKQuery.predicateForSamples(
      withStart: Calendar.current.startOfDay(for: startDate), end: Date())

    let query = HKSampleQuery(
      sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil
    ) { _, results, error in
      guard let samples = results as? [HKCategorySample], error == nil else {
        completion(.failure(NSError()))
        return
      }
      completion(.success(samples))
    }

    healthstore.execute(query)
  }

  func getType(forKey key: String) -> HKSampleType {
    return (healthData[key]?.type)!
  }

  func getUnit(forKey key: String) -> HKUnit {
    return (healthData[key]?.unit)!
  }

  func getHKStatisticsOption(forType type: HKQuantityType) -> HKStatisticsOptions {
    switch type.aggregationStyle {
    case .cumulative:
      return .cumulativeSum
    case .discreteTemporallyWeighted:
      return [.discreteMin, .discreteMax]
    default:
      return []
    }
  }
}
