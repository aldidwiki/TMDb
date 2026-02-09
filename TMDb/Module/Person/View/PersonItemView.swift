//
//  PersonItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/10/23.
//

import SwiftUI

struct PersonItemView: View {
    var personPopular: PersonPopularModel
    
    var body: some View {
        HStack {
            PosterView(posterType: .person(path: personPopular.profilePath))
            
            Text(personPopular.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
}

#Preview {
    PersonItemView(personPopular: PersonPopularModel(
        id: 976,
        name: "Jason Statham",
        profilePath: "/whNwkEQYWLFJA8ij0WyOOAD5xhQ.jpg"
    ))
}
