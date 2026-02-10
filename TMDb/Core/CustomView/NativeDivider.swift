//
//  NativeDivider.swift
//  TMDb
//
//  Created by Macbook on 10/02/26.
//

import SwiftUI

struct NativeDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(UIColor.separator))
            .frame(height: 1.0 / UIScreen.main.scale)
            .padding(.vertical, 10)
    }
}
