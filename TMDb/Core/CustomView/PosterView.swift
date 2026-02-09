//
//  PosterView.swift
//  TMDb
//
//  Created by Macbook on 09/02/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct PosterView: View {
    let posterType: PosterURLType
    
    var placeHolderSystemName: String = "photo"
    var width: CGFloat = 100
    var height: CGFloat = 140
    
    var body: some View {
        WebImage(url: posterType.url)
            .resizable()
            .placeholder(content: {
                Image(systemName: self.placeHolderSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.width / 2, height: self.height / 2)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFill()
            .frame(width: self.width, height: self.height)
            .cornerRadius(8)
            .clipped()
    }
}

enum PosterURLType  {
    case movie(path: String)
    
    var url: URL? {
        switch self {
        case .movie(let path):
            return URL(string: API.imageBaseUrl + path)
        }
    }
}
