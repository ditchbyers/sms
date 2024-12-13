import Foundation
import SwiftUICore
import HealthKit

struct HealthData {
  var id: UUID
  var icon: String
  var type: HKSampleType?  // Can be either HKQuantityType or HKCategoryType
  var title: String
  var subtitle: String
  var unit: HKUnit
  var circle: Bool
  var color: Color?
  var goal: Int?
}
