//
//  PersonItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/10/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonItemView: View {
    var personPopular: PersonPopularModel
    
    var body: some View {
        HStack {
            profileImage
            
            Text(personPopular.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
}

extension PersonItemView {
    var profileImage: some View {
        WebImage(url: URL(string: API.profileImageBaseUrl + personPopular.profilePath))
            .resizable()
            .placeholder(content: {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(width: 100, height: 100)
            .cornerRadius(20)
    }
}

#Preview {
    PersonItemView(personPopular: PersonPopularModel(
        id: 976,
        name: "Jason Statham",
        profilePath: "/whNwkEQYWLFJA8ij0WyOOAD5xhQ.jpg"
    ))
}
