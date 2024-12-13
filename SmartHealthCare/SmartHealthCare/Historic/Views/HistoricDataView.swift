import Charts
import Foundation
import SwiftUI
import SwiftUICharts

struct HistoricDataView: View {
  @StateObject var viewModel: HistoricViewModel
  @State private var chartXSelection: Date? = nil

  var body: some View {
    VStack(alignment: .leading) {
      Heading(title: "Charts")
      ChartPicker(viewModel: viewModel)
      ChartButtons(viewModel: viewModel, chartXSelection: $chartXSelection)
      ChartView(viewModel: viewModel, chartXSelection: $chartXSelection)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .padding(.horizontal)
  }
}
