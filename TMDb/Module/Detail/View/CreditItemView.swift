//
//  CreditItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreditItemView: View {
    var creditModel: CreditModel
    var isPersonView: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(.background)
                .shadow(radius: 4)
            
            VStack(alignment: .leading) {
                creditPoster
                
                Text(creditModel.name)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                
                Text(creditModel.characterName)
                    .fontWeight(.thin)
                    .padding(.horizontal, 6)
                    .padding(.bottom)
                
                Spacer()
            }
        }
        .frame(width: 120, height: 250)
    }
}

extension CreditItemView {
    var creditPoster: some View {
        WebImage(url: URL(string: API.profileImageBaseUrl + creditModel.profilePath))
            .resizable()
            .placeholder(content: {
                Image(systemName: isPersonView ? "photo" : "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .frame(width: 120, height: 150)
            .cornerRadius(6)
    }
}

struct CreditItemView_Previews: PreviewProvider {
    static var previews: some View {
        CreditItemView(
            creditModel: CreditModel(
                id: 73457,
                name: "Chris Pratt",
                profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                characterName: "Peter Quill / Star-Lord",
                order: 0,
                popularity: 47.542,
                releaseDate: ""
            ),
            isPersonView: true
        )
    }
}
