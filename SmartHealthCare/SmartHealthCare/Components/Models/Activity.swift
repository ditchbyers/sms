//
//  Activity.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 07.11.24.
//

import Foundation

struct Activity: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let image: String
    var current: Int
}

