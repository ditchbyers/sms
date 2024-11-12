//
//  WorkoutCard.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 07.11.24.
//

import SwiftUI

struct WorkoutCard: View {
    @State var workout: Workout
    
    var body: some View {
        HStack {
            Image(systemName: workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(workout.color)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(10)
            
            VStack(spacing: 16) {
                HStack {
                    Text(workout.title).font(.title3).bold()
                    Spacer()
                    Text(workout.duration)
                }
                
                HStack {
                    Text(workout.date)
                    Spacer()
                    Text(workout.calories)
                }
            }
        }.padding(.horizontal)

    }
}

#Preview {
    WorkoutCard(workout: Workout(id: 3, title: "Running", image: "figure.run", duration: "23 min", date: "3. Aug 2024", calories: "512 kcal", color: .red))
}
