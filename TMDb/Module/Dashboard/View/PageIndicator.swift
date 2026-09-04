//
//  PageIndicator.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct PageIndicator: View {
    @Binding var currentIndex: Int?
    var totalItems: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalItems, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color("cinematic_primary") : Color.gray.opacity(0.25))
                    .frame(width: index == currentIndex ? 30 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
    }
}

#Preview {
    PageIndicator(
        currentIndex: .constant(0),
        totalItems: 10
    )
}
