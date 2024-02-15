//
//  PersonImageView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 15/02/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonImageView: View {
    @ObservedObject var personPresenter: PersonPresenter
    var personId: Int
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(personPresenter.personImages, id: \.filePath) { personImage in
                    WebImage(url: URL(string: API.profileImageBaseUrl + personImage.filePath))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            personPresenter.getPersonImage(personId: personId)
        }
    }
}

#Preview {
    PersonImageView(
        personPresenter: PersonPresenter(personUseCase: Injection.init().providePersonUseCase()),
        personId: 2112859
    )
}
