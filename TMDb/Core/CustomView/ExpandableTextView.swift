//
//  ExpandableTextView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 11/09/23.
//

import SwiftUI

struct ExpandableTextView: View {
    var textData: String
    var maxTextLength = 70
    
    @State var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(textData)
                .multilineTextAlignment(.leading)
                .modifier(AnimatingCellHeight(height: isExpanded ? CGFloat(Double(textData.count)/1.5) + 10 : CGFloat(maxTextLength)))
                .animation(.default, value: isExpanded)
            
            if textData.count > maxTextLength {
                Button {
                    isExpanded.toggle()
                } label: {
                    Label(isExpanded ? "Collapse" : "Expand", systemImage: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .labelStyle(CustomLabelStyle(spacing: 2))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
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
