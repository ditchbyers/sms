import SwiftUI
import Charts

struct HistoricDataView: View {
    
    @State private var selectedType: String = "Apple"
    let dataSource = ["Apple", "Mango", "Orange", "Banana", "Kiwi", "Watermelon"]
    
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Charts")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Horizontal container
                HStack(spacing: 20) {
                    // Picker on the left side with a fixed height and 50% width
                    Picker("Data Source", selection: $selectedType) {
                        ForEach(dataSource, id: \.self) { data in
                            Text(data)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .frame(height: 44)  // Same height as DatePicker


                    // DatePicker stack on the right side
                    VStack(alignment: .leading) {
                        DatePicker("", selection: $selectedStartDate, displayedComponents: .date)
                            .labelsHidden()
                            .background((Color(UIColor.secondarySystemBackground)))
                            .cornerRadius(8)
                        DatePicker("", selection: $selectedEndDate, displayedComponents: .date)
                            .labelsHidden()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)  // Takes up the remaining space
                }
                .padding()// Padding for the entire HStack
                
//                Chart {
//                    
//                }
            }
            .padding()
        }
    }
}

#Preview {
    HistoricDataView()
}
