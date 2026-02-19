//
//  ExpandableTextView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 11/09/23.
//

import SwiftUI

struct ExpandableTextView: View {
    var textData: String
    var maxTextLine = 3
    
    @State var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(textData)
                .multilineTextAlignment(.leading)
                .lineLimit(isExpanded ? nil : maxTextLine)
                .transition(.opacity)
            
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isExpanded ? "Collapse" : "Expand")
                    Image(systemName: "chevron.up")
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                }
                .font(.system(size: 14))
                .fontWeight(.medium)
            }
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct ExpandableTextView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableTextView(
            textData: "Robb goes to war against the Lannisters. Jon finds himself struggling on deciding if his place is with Robb or the Night's Watch. Drogo has fallen ill from a fresh battle wound. Daenerys is desperate to save him."
        )
    }
}
