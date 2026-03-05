//
//  TvShowImageGalleryView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 21/03/24.
//

import SwiftUI
import SDWebImageSwiftUI
import ImageViewerRemote

struct TvShowImageGalleryView: View {
    @State private var presenter: TvShowDetailPresenter
    @State var imgUrl = ""
    @State var showImageView = false
    
    private let tvShowId: Int
    
    init(tvShowUseCase: TvShowUseCase, tvShowId: Int) {
        _presenter = State(initialValue: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase))
        self.tvShowId = tvShowId
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(presenter.tvShowImages, id: \.filePath) { tvImage in
                    WebImage(url: URL(string: API.backdropBaseUrl + tvImage.filePath))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .cornerRadius(8)
                        .onTapGesture {
                            self.imgUrl = API.backdropBaseUrl + tvImage.filePath
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
            presenter.getTvShowBackdrop(tvShowId: tvShowId)
        }
    }
}

#Preview {
    TvShowImageGalleryView(
        tvShowUseCase: Injection.init().provideTvShowUseCase(),
        tvShowId: 82452
    )
}
