//
//  CircularProgressView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color("primary_color").opacity(0.5),
                    lineWidth: self.lineWidth
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color("primary_color"),
                    style: StrokeStyle(
                        lineWidth: self.lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.25, lineWidth: 5)
    }
}
