//
//  HealthChart.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 10.12.24.
//

import Charts
import HealthKit
import SwiftUI

struct ChartWithData: View {
  var data: ChartData
  var unit: Calendar.Component
  @Binding var chartXSelection: Date?
  @State private var chartYSelection: Any?

  var body: some View {
    VStack(alignment: .leading) {
      Text("test")
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 4)
            .foregroundStyle(Color.accentColor.opacity(0.2))
        }
      switch data
      {
      case .cumulative(let data):
        Chart(data, id: \.date) { d in
          BarMark(
            x: .value("Date", d.date, unit: unit),
            y: .value("Value", d.value1),
            width: .fixed(10)
          )
          // let _ = print(chartSelection)
          if let chartXSelection {

            RuleMark(x: .value("Month", chartXSelection, unit: unit))
              .foregroundStyle(.gray.opacity(0.5))
              .annotation(
                position: .top,
                overflowResolution: .init(x: .fit, y: .disabled)
              ) {
                ZStack {
                  // let _ = print("chartXSelection")
                  Text("test")
                }
                .padding()
                .background {
                  RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.accentColor.opacity(0.2))
                }
              }

          }
        }
        .chartXSelection(value: $chartXSelection)
        .chartGesture { chartProxy in
          DragGesture(minimumDistance: 0)
            .onChanged {
              chartProxy.selectXValue(at: $0.location.x)
            }
        }
        .animation(.easeInOut(duration: 1), value: data)

      case .discrete(let data):
        Chart(data, id: \.date) { d in
          BarMark(
            x: .value("Date", d.date, unit: unit),
            yStart: .value("BPM Min", d.value1),
            yEnd: .value("BPM Max", d.value2!),
            width: .fixed(10)
          )
          .clipShape(Capsule()).foregroundStyle(.red)
        }.animation(.easeInOut(duration: 1), value: data)
      }
    }
  }
}
