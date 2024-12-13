//
//  JSONPrinter.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 12.12.24.
//

import Foundation

func printChartData(chartData: ChartData) {
    switch chartData {
    case .discrete(let data):
      printDiscrete(data: data)
        
    case .cumulative(let data):
      printCumulative(data: data)
    }
}

func printCumulative(data: [DataPoint]) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
    
    let jsonArray: [[String: Any]] = data.map { item in
        return [
          "date": dateFormatter.string(from: item.date),
          "value": item.value1
        ]
    }
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    } else {
        print("Failed to serialize data.")
    }
}

func printDiscrete(data: [DataPoint]) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
    
    let jsonArray: [[String: Any]] = data.map { item in
        return [
          "date": dateFormatter.string(from: item.date),
          "value1": item.value1,
          "value2": item.value2!
        ]
    }
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    } else {
        print("Failed to serialize data.")
    }
}
