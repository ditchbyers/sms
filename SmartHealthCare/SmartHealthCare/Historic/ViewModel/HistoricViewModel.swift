import Foundation
import HealthKit

struct DataPoint: Identifiable, Equatable {
  let id = UUID()
  var date: Date
  var value1: Double
  var value2: Double?
}

enum ChartData {
  case discrete([DataPoint])
  case cumulative([DataPoint])
  
  var isEmpty: Bool {
          switch self {
          case .discrete(let data):
              return data.isEmpty
          case .cumulative(let data):
              return data.isEmpty
          }
      }
}

class HistoricViewModel: ObservableObject {
  var healthManager: HealthManager = HealthManager.shared

  @Published var pickerKeys: [(String, String)] = [("stepCount", "Steps")]
  @Published var selectedHealthType: String = "stepCount"
  @Published var selectedChartVariant: ChartOptions = .oneDay
  @Published var isLoading: Bool = false
  @Published var chartData: ChartData = .cumulative([])

  init() {
    self.pickerKeys = healthManager.healthData.map { (key, value) in
      return (key, value.title)
    }.sorted { $0.0 < $1.0 }
  }

  func fetchHistoricData() {
    self.isLoading = true
    DispatchQueue.global(qos: .userInitiated).async {
      let startDate = self.selectedChartVariant.startDate
      let interval = self.selectedChartVariant.interval
      let type = self.healthManager.getType(forKey: self.selectedHealthType)
      
      // Handle different health data types (HKQuantityType or HKCategoryType)
      if let quantityType = type as? HKQuantityType {
        self.fetchStatistics(for: quantityType, startDate: startDate, interval: interval)
      } else if let categoryType = type as? HKCategoryType {
        self.fetchSamples(for: categoryType, startDate: startDate)
      } else {
        print("Invalid health data type")
      }
    }
    
    self.isLoading = false
  }

  private func fetchSamples(for categoryType: HKCategoryType, startDate: Date) {
    healthManager.fetchSamples(forType: categoryType, startDate: startDate) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let samples):
          self.prepareSampleData(samples: samples)
        case .failure(let error):
          self.handleStatisticsError(error)
        }
      }
    }
  }

  private func fetchStatistics(
    for quantityType: HKQuantityType, startDate: Date, interval: DateComponents
  ) {
    healthManager.fetchStatistics(forType: quantityType, startDate: startDate, interval: interval) {
      result in
      DispatchQueue.main.async {
        switch result {
        case .success(let (statisticData, statisticOption)):
          self.handleStatisticsSuccess(
            statisticData: statisticData, statisticOption: statisticOption)
        case .failure(let error):
          self.handleStatisticsError(error)
        }
      }
    }
  }

  private func handleStatisticsSuccess(
    statisticData: [HKStatistics], statisticOption: HKStatisticsOptions
  ) {
    switch statisticOption {
    case .cumulativeSum:
      self.prepareCumulativeData(statistics: statisticData)
    case [.discreteMin, .discreteMax]:
      self.prepareDiscreteData(statistics: statisticData)
    default:
      print("Option unknown")
    }
  }

  private func handleStatisticsError(_ error: Error) {
    print("Error fetching statistics: \(error.localizedDescription)")
  }

  func prepareCumulativeData(statistics: [HKStatistics]) {
    var data: [DataPoint] = []

    for statistic in statistics {
      if let sum = statistic.sumQuantity() {
        data.append(
          DataPoint(
            date: statistic.startDate,
            value1: sum.doubleValue(
              for: self.healthManager.getUnit(forKey: self.selectedHealthType))
          )
        )
      }
    }
    self.chartData = .cumulative(data)
  }

  func prepareDiscreteData(statistics: [HKStatistics]) {
    var data: [DataPoint] = []

    for statistic in statistics {
      if let minQuantity = statistic.minimumQuantity(),
        let maxQuantity = statistic.maximumQuantity()
      {
        let unit = self.healthManager.getUnit(forKey: self.selectedHealthType)

        let minDouble = minQuantity.doubleValue(
          for: unit)
        let maxDouble = maxQuantity.doubleValue(
          for: unit)

        data.append(DataPoint(date: statistic.startDate, value1: minDouble, value2: maxDouble))
      }
    }
    self.chartData = .discrete(data)
  }

  func prepareSampleData(samples: [HKCategorySample]) {
    var data: [DataPoint] = []

    if samples.count == 0 {
      data.append(DataPoint(date: Date(), value1: 0.0))
    } else {
      for sample in samples {
        // Assuming that you want to track the sample date and value
        // You can modify how you get the value based on your actual data structure (e.g., $0.value is the actual measurement)

        let value = sample.value == 0 ? 1.0 : 0.0  // You can adjust this depending on what you want (e.g., standing or not standing)
        data.append(DataPoint(date: sample.startDate, value1: value))
      }
    }
    self.chartData = .cumulative(data)
  }
}
