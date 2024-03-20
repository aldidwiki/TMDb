//
//  ImageGalleryView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/03/24.
//

import SwiftUI
import SDWebImageSwiftUI
import ImageViewerRemote

struct ImageGalleryView: View {
    @ObservedObject var presenter: MovieDetailPresenter
    @State var imgUrl = ""
    @State var showImageView = false
    
    var contentId: Int
    
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
    ImageGalleryView(
        presenter: MovieDetailPresenter(
            detailUseCase: Injection.init().provideDetailUseCase(movieId: 693134),
            favoriteUseCase: Injection.init().provideFavoriteUseCase()),
        contentId: 693134
    )
}
