import SwiftUI

struct ChartButtons: View {
    @AppStorage("animationModeKey") var animationsMode: ChartOptions = .oneHour
    @StateObject var viewModel: HistoricViewModel
    @Binding var chartXSelection: Date?
    let color = Color.indigo
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChartOptions.allCases.indices, id: \.self) { index in
                let mode = ChartOptions.allCases[index]
                let makeDivider = index < ChartOptions.allCases.count - 1
                
                Button {
                    chartXSelection = nil
                    animationsMode = mode
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Update selected index and trigger background sliding
                        viewModel.selectedChartVariant = mode
                        viewModel.fetchHistoricData()
                    }
                } label: {
                    VStack {
                        Text(mode.displayString)
                            .font(.caption)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.primary)
                    .padding(13)
                }
                
                if makeDivider {
                    if !(index == animationsMode.rawValue || (index + 1) == animationsMode.rawValue) {
                        Divider()
                            .frame(width: 0, height: 35)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            GeometryReader { proxy in
                let caseCount = ChartOptions.allCases.count
                color.opacity(0.1)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: proxy.size.width / CGFloat(caseCount))
                    // Offset the background horizontally based on the selected animation mode
                    .offset(x: proxy.size.width / CGFloat(caseCount) * CGFloat(animationsMode.rawValue))
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.3), value: animationsMode)
    }
}
