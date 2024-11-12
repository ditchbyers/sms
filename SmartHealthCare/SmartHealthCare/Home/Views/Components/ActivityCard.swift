//
//  SwiftUIView.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 07.11.24.
//

import SwiftUI

struct ActivityCard: View {
    @State var activity: Activity
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6).cornerRadius(15)
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.title)
                        
                        Text(activity.subtitle).font(.caption)
                    }
                    Spacer()
                    Image(systemName: activity.image).foregroundColor(.green)
                }
                Text(activity.current).bold().font(.title).padding(.top)
            }
            .padding()
        }
    }
}

#Preview {
    ActivityCard(activity: Activity(id: UUID(), title: "Today Steps", subtitle: "Goal: 10,000", image: "figure.walk", current: "6,123"))
}
