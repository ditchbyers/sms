//
//  Title.swift
//  SmartHealthCare
//
//  Created by May, Pascal_Rene on 13.12.24.
//

import SwiftUI

struct Heading: View {
  var title: String
  
  var body: some View {
    Text(title)
      .font(.largeTitle)
      .bold()
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.bottom)
  }
}
