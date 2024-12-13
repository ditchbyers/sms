//
//  ChartPicker.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 13.12.24.
//

import SwiftUI

struct ChartPicker: View {
  @StateObject var viewModel: HistoricViewModel

  var body: some View {
    HStack {
      Picker("Data Source", selection: $viewModel.selectedHealthType) {
        ForEach(viewModel.pickerKeys, id: \.0) { key, value in
          Text(value).tag(key)
        }
      }
      .background(Color(.systemGray6))
      .cornerRadius(10)
      .onChange(of: viewModel.selectedHealthType) { _ in
        viewModel.fetchHistoricData()
      }
    }
  }
}
