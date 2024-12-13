//
//  ChartView.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 13.12.24.
//

import SwiftUI

struct ChartView: View {
  @StateObject var viewModel: HistoricViewModel
  @Binding var chartXSelection: Date?

  var body: some View {
    ZStack {
      if viewModel.isLoading || viewModel.chartData.isEmpty {
        ChartPlaceholder()
      } else {
        ChartWithData(
          data: viewModel.chartData, unit: viewModel.selectedChartVariant.calendarComponent,
          chartXSelection: $chartXSelection)
      }
    }
    .frame(minHeight: 500, maxHeight: 500)
  }
}
