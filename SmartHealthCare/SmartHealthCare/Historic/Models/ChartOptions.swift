import Foundation

enum ChartOptions: Int, CaseIterable {
  case oneHour
  case oneDay
  case oneWeek
  case oneMonth
  case sixMonth
  case oneYear

  var calendarComponent: Calendar.Component {
    switch self {
    case .oneHour: return .minute
    case .oneDay: return .hour
    case .oneWeek: return .weekday
    case .oneMonth: return .weekday
    case .sixMonth: return .month
    case .oneYear: return .month
    }
  }

  var interval: DateComponents {
    switch self {
    case .oneHour:
      return DateComponents(minute: 1)
    case .oneDay:
      return DateComponents(hour: 1)
    case .oneWeek:
      return DateComponents(day: 1)
    case .oneMonth:
      return DateComponents(day: 1)
    case .sixMonth:
      return DateComponents(day: 1)
    case .oneYear:
      return DateComponents(day: 1)
    }
  }

  var startDate: Date {
    let currentDate = Date()
    switch self {
    case .oneHour:
      return Calendar.current.date(bySetting: .minute, value: 0, of: currentDate)!
        .addingTimeInterval(-3600)
    case .oneDay:
      return Calendar.current.startOfDay(for: currentDate)
    case .oneWeek:
      return Calendar.current.startOfDay(
        for: Calendar.current.date(byAdding: .day, value: -6, to: Date())!)
    case .oneMonth:
      return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
    case .sixMonth:
      return Calendar.current.date(bySetting: .day, value: 1, of: Calendar.current.date(byAdding: .month, value: -6, to: Date())!)!
    case .oneYear:
      return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
    }
  }

  var displayString: String {
    switch self {
    case .oneHour: return "H"
    case .oneDay: return "D"
    case .oneWeek: return "W"
    case .oneMonth: return "M"
    case .sixMonth: return "6M"
    case .oneYear: return "Y"
    }
  }
}
