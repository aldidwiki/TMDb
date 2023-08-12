//
//  EmptyView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 26/11/22.
//

import SwiftUI

struct EmptyView: View {
    var emptyTitle: String
    
    var body: some View {
        Text(emptyTitle)
            .font(.title)
            .fontWeight(.medium)
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView(emptyTitle: "No Movies Found")
    }
}
