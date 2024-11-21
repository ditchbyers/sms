//
//  HomeView.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 07.11.24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    //@State private var isShowingHistoricDataView: Bool =  false  // Manage the path stack

    var body: some View {
        // NavigationStack only in iOS 16.0 >
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Welcome")
                        .font(.largeTitle)
                        .padding()
                    
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Calories")
                                    .font(.callout)
                                    .bold()
                                Text("\(viewModel.calories)")
                                    .bold()
                            }
                            
                            .padding(.bottom)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active")
                                    .font(.callout)
                                    .bold()
                                Text("\(viewModel.exercise)")
                                    .bold()
                                
                            }
                            
                            .padding(.bottom)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stand")
                                    .font(.callout)
                                    .bold()
                                Text("\(viewModel.stand)")
                                    .bold()
                                
                            }
                        }
                        
                        Spacer()
                        
                        ZStack{
                            ProgressCircle(progress: $viewModel.calories, color: .red, goal: 800)
                            
                            ProgressCircle(progress: $viewModel.exercise, color: .green, goal: 60)
                                .padding(.all, 20)
                            
                            ProgressCircle(progress: $viewModel.stand, color: .blue, goal: 12)
                                .padding(.all, 40)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Text("Fitness Activitiy")
                            .font(.title2)
    //                    Spacer()
    //                    NavigationLink(destination: HistoricDataView(), isActive: $isShowingHistoricDataView) { EmptyView() }
    //                    Button("Go to HistoricDataView") {
    //                        self.isShowingHistoricDataView = true
    //                    }
                        .padding()
                        
                    }
                    .padding(.horizontal)
                                    
                    if !viewModel.activities.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                            ForEach(viewModel.activities, id: \.id){
                                activity in ActivityCard(activity: activity)
                            }
                        }.padding(.horizontal)
                    }
                    
                    
    //                HStack {
    //                    Text("Recent Workouts")
    //                        .font(.title2)
    //                    Spacer()
    //                    NavigationLink {
    //                        EmptyView()
    //                    } label: {
    //                        Text("Show more")
    //                            .padding(.all, 10)
    //                            .foregroundColor(.white)
    //                            .background(.blue)
    //                            .cornerRadius(20)
    //
    //                    }
    //                }
    //                .padding(.horizontal)
    //                .padding(.top)
                    
    //                LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 1)) {
    //                    ForEach(viewModel.mockWorkouts, id: \.id){
    //                        workout in WorkoutCard(workout: workout)
    //                    }
    //                }
                }.padding(.bottom)
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // Call the updateUI method when the app becomes active (reopened)
                    viewModel.updateUI()
                }
            }.onAppear {
                viewModel.updateUI()
            }
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    HomeView()
}
