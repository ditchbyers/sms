import SwiftUI

struct SMCTabView: View {
    @State var selectedTab = "Home"
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var historicViewModel = HistoricViewModel()

    init() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color("Bordeau"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.bordeau
        ]
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
            TabView(selection: $selectedTab) {
              HomeView(viewModel: homeViewModel)
                    .tag("Home")
                    .tabItem {
                        Image(systemName: "house")
                    }

                HistoricDataView(viewModel: historicViewModel)
                    .tag("Historic")
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
            }
            .onChange(of: selectedTab) { tab in
                self.selectedTab = tab
                if self.selectedTab == "Home" {
                    homeViewModel.fetchHomeData()
                } else {
                    historicViewModel.fetchHistoricData()
                }
            }
            .onAppear {
                homeViewModel.fetchHomeData()
                historicViewModel.fetchHistoricData()
            }
        }
    }

#Preview {
    SMCTabView()
}
