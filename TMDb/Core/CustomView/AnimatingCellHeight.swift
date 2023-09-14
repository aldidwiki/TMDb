//
//  AnimatingCellHeight.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 11/09/23.
//

import SwiftUI

struct AnimatingCellHeight: AnimatableModifier {
    var height: CGFloat = 0
    
    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }
    
    func body(content: Content) -> some View {
        content.frame(height: height, alignment: .topLeading)
    }
}
