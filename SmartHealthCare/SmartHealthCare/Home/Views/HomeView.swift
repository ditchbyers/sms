import SwiftUI

struct HomeView: View {
  @StateObject var viewModel: HomeViewModel

  @State private var gradientEndPoint: Double = 0
  var heightPercentage: Double = 0.5
  var maxHeight: Double = 200
  var minHeight: Double = 0
  var startColor: Color = Color.purple
  var endColor: Color = Color.white
  var navigationTitle: String = "Summary"

  private func calculateEndPointForScrollPosition(scrollPosition: Double) -> Double {
    let absoluteScrollPosition = abs(scrollPosition)
    let endPoint = heightPercentage - (heightPercentage / maxHeight) * absoluteScrollPosition
    return endPoint.clamped(to: 0...heightPercentage)
  }

  private func checkScrollPositionAndGetEndPoint(scrollPosition: Double) -> Double {
    let isScrollPositionLowerThanMinHeight = scrollPosition < minHeight
    return isScrollPositionLowerThanMinHeight
      ? calculateEndPointForScrollPosition(scrollPosition: scrollPosition)
      : heightPercentage
  }

  private func onScrollPositionChange(scrollPosition: Double) {
    gradientEndPoint = checkScrollPositionAndGetEndPoint(scrollPosition: scrollPosition)
  }

  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        ScrollView {
          VStack(alignment: .leading) {
            LazyVStack {
              if !viewModel.circle.isEmpty {
                let screenHeight = geometry.size.height
                let maxHeight = screenHeight * 0.3  // 20% of screen height

                HStack {
                  VStack(alignment: .leading) {
                    // Text
                    ForEach(viewModel.circle, id: \.id) { circle in
                      VStack(alignment: .leading, spacing: 5) {
                        Text(circle.title)
                          .font(.callout)
                          .bold()
                        Text("\(circle.progress)")
                          .bold()
                      }
                      .padding(.bottom)
                    }
                  }

                  // Circles
                  ZStack {
                    ForEach(viewModel.circle.indices, id: \.self) { index in
                      ProgressCircle(
                        progress: viewModel.circle[index].progress,
                        color: viewModel.circle[index].color,
                        goal: viewModel.circle[index].goal
                      )
                      .padding(.all, CGFloat(index * 20))
                    }
                  }
                  .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(10)
                .frame(maxHeight: maxHeight)  // This ensures the HStack's height is limited to 20% of the device height
                .padding()
              }

              if !viewModel.activities.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 1)) {
                  ForEach(viewModel.activities, id: \.id) { activity in
                    ActivityCard(activity: activity)
                  }
                }
                .padding(.horizontal)
              }
            }
            .coordinateSpace(name: "scroll")
            .background(
              GeometryReader { geometry in
                Color.clear.preference(
                  key: ScrollOffsetPreferenceKey.self,
                  value: geometry.frame(in: .named("scroll")).origin
                )
              }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
              onScrollPositionChange(scrollPosition: value.y)
            }
          }
        }
        .background(
          LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .top,
            endPoint: UnitPoint(x: 0.5, y: gradientEndPoint)
          )
          .ignoresSafeArea()
        )
      }
      .navigationTitle("Summary")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink(destination: HistoricDataView(viewModel: HistoricViewModel())) {
            HStack {
              Text("Go to Settings")
              Image(systemName: "gear")
                .resizable()
                .frame(width: 24, height: 24)
            }
            .foregroundStyle(.black)
          }
        }
      }
      .onAppear {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UINavigationBar.appearance().standardAppearance = appearance

        let exposedAppearance = UINavigationBarAppearance()
        exposedAppearance.backgroundEffect = .none
        exposedAppearance.shadowColor = .clear
        UINavigationBar.appearance().scrollEdgeAppearance = exposedAppearance
      }
    }
  }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGPoint = .zero

  static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

extension Comparable {
  func clamped(to r: ClosedRange<Self>) -> Self {
    let min = r.lowerBound
    let max = r.upperBound
    return self < min ? min : (max < self ? max : self)
  }
}
