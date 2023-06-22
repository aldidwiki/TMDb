//
//  CreditDetailItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreditDetailItemView: View {
    var creditModel: CreditModel
    
    var body: some View {
        HStack {
            creditPoster
            
            VStack(alignment: .leading) {
                Text(creditModel.name)
                    .fontWeight(.medium)
                    .font(.title3)
                    .lineLimit(2)
                
                Text(creditModel.characterName)
                    .fontWeight(.thin)
                    .lineLimit(2)
            }
            .padding(.leading)
        }
    }
}

extension CreditDetailItemView {
    var creditPoster: some View {
        WebImage(url: URL(string: API.profileImageBaseUrl + creditModel.profilePath))
            .resizable()
            .placeholder(content: {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .frame(width: 100, height: 130)
            .cornerRadius(6)
    }
}

struct CreditDetailItemView_Previews: PreviewProvider {
    static var previews: some View {
        CreditDetailItemView(creditModel: CreditModel(
            id: 73457,
            name: "Chris Pratt",
            profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
            characterName: "Peter Quill / Star-Lord",
            order: 0,
            popularity: 47.542,
            releaseDate: ""
        ))
    }
}
