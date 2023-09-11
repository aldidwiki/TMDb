//
//  CustomLabelStyle.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 11/09/23.
//

import SwiftUI

struct CustomLabelStyle: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
