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
    @State var showMoreButton = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(textData)
                .multilineTextAlignment(.leading)
                .lineLimit(isExpanded ? nil : maxTextLine)
                .background(
                    // This hidden Text measures the "true" height without limits
                    Text(textData)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(GeometryReader { fullState in
                            Color.clear.onAppear {
                                // We compare this hidden height with the constrained height
                                // (Logic handled via an overlay or PreferenceKey in complex cases,
                                // but for simple detection, we measure against a constrained proxy)
                            }
                        })
                        .hidden()
                )
                .background(detectTruncation)
            
            if showMoreButton && !textData.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.up")
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                        Text(isExpanded ? "Collapse" : "Expand")
                    }
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private var detectTruncation: some View {
        GeometryReader { geometry in
            Color.clear.onAppear {
                determineTruncation(geometry: geometry)
            }
            // Re-run logic if biography or orientation changes
            .onChange(of: textData) { _, _ in
                determineTruncation(geometry: geometry)
            }
        }
    }
    
    private func determineTruncation(geometry: GeometryProxy) {
        // Create a constraint-free version of the text to see how much space it WANTs
        let totalSize = textData.boundingRect(
            with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)],
            context: nil
        )
        
        if totalSize.height > geometry.size.height {
            showMoreButton = true
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
