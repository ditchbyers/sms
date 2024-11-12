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
    
    var body: some View {
        // NavigationStack only in iOS 16.0 >
        ScrollView(showsIndicators: false) {
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
                                .foregroundColor(.bordeau)
                            Text("\(viewModel.calories)")
                                .bold()
                        }
                        
                        .padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Active")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.bordeau)
                            Text("\(viewModel.exercise)")
                                .bold()
                            
                        }
                        
                        .padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stand")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.bordeau)
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
                    Spacer()
                    Button (action: {
                        print("test")
                    }) {
                        Text("Show more")
                            .padding(.all, 10)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(20)
                            
                    }
                }
                .padding(.horizontal)
                                
                if !viewModel.activities.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                        ForEach(viewModel.activities, id: \.id){
                            activity in ActivityCard(activity: activity)
                        }
                    }.padding(.horizontal)
                }
                
                if !viewModel.activityDictionary.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                        ForEach(Array(viewModel.activityDictionary.values), id: \.id) {
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
            }.onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // Call the updateUI method when the app becomes active (reopened)
                    viewModel.updateUI()
                }
            }.onAppear {
                viewModel.updateUI()
            }
            
        }
    }
}

#Preview {
    HomeView()
}
