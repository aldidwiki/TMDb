//
//  PersonImageView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 15/02/24.
//

import SwiftUI
import SDWebImageSwiftUI
import ImageViewerRemote

struct PersonImageView: View {
    @State private var personPresenter: PersonPresenter
    @State var imgUrl = ""
    @State var showImageView = false

    private let personId: Int
    
    init(
        personUseCase: PersonUseCase,
        favoriteUseCase: FavoriteUseCase,
        personId: Int
    ) {
        _personPresenter = State(initialValue: PersonPresenter(
            personUseCase: personUseCase,
            favoriteUseCase: favoriteUseCase
        ))
        self.personId = personId
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(personPresenter.personImages, id: \.filePath) { personImage in
                    WebImage(url: URL(string: API.profileOriginalBaseUrl + personImage.filePath))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .cornerRadius(8)
                        .onTapGesture {
                            self.imgUrl = API.profileOriginalBaseUrl + personImage.filePath
                            self.showImageView.toggle()
                        }
                }
            }
            .padding(.horizontal)
        }
        .overlay {
            ImageViewerRemote(imageURL: $imgUrl, viewerShown: $showImageView, closeButtonTopRight: true)
        }
        .onAppear {
            personPresenter.getPersonImage(personId: personId)
        }
    }
}

#Preview {
    PersonImageView(
        personUseCase: Injection.init().providePersonUseCase(),
        favoriteUseCase: Injection.init().provideFavoriteUseCase(),
        personId: 0
    )
}
