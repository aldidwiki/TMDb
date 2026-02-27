//
//  ImageGalleryView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/03/24.
//

import SwiftUI
import SDWebImageSwiftUI
import ImageViewerRemote

struct MovieImageGalleryView: View {
    @State private var presenter: MovieDetailPresenter
    @State var imgUrl = ""
    @State var showImageView = false
    
    private let contentId: Int
    
    init(detailUseCase: DetailUseCase, favoriteUseCase: FavoriteUseCase, contentId: Int) {
        _presenter = State(initialValue: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
        self.contentId = contentId
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(presenter.movieImages, id: \.filePath) { movieImage in
                    WebImage(url: URL(string: API.backdropBaseUrl + movieImage.filePath))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .cornerRadius(8)
                        .onTapGesture {
                            self.imgUrl = API.backdropBaseUrl + movieImage.filePath
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
            presenter.getMovieBackdrops(movieId: contentId)
        }
    }
}

#Preview {
    MovieImageGalleryView(
        detailUseCase: Injection.init().provideDetailUseCase(),
        favoriteUseCase: Injection.init().provideFavoriteUseCase(),
        contentId: 693134
    )
}
