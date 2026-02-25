//
//  TvShowDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUIIntrospect

struct TvShowDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var presenter: TvShowDetailPresenter
    @State var showSheet = false
    @State var isFavorite = false
    
    @State private var bgColor: Color = .clear
    @State private var primaryColor: Color = .primary
    @State private var secondaryColor: Color = .primary
    
    var tvShowId: Int
    
    var body: some View {
        ZStack {
            if presenter.loadingState {
                ProgressView("Loading")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        VStack {
                            if !presenter.tvShow.backdropPath.isEmpty {
                                presenter.toTvShowImageGallery(tvShowId: tvShowId) {
                                    tvBackdrop
                                }
                            }
                            
                            tvContentDetail
                                .padding([.top, .horizontal])
                            
                            tvContentUtils
                            
                            tvOverview
                        }
                        .padding(.bottom)
                        .background(bgColor)
                        
                        if !presenter.tvShow.credits.isEmpty {
                            tvCredits
                        }
                        
                        tvDetailInfo
                        
                        ExternalMediaView(
                            instagramId: presenter.tvShow.instagramId,
                            facebookId: presenter.tvShow.facebookId,
                            twitterId: presenter.tvShow.twitterId,
                            imdbId: presenter.tvShow.imdbId
                        )
                        .padding(.vertical)
                    }
                }
                .blur(radius: showSheet ? 6 : 0)
            }
        }.onAppear {
            if presenter.tvShow.id == 0 && presenter.tvShow.title.isEmpty {
                presenter.getTvShow(tvShowId: tvShowId)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(presenter.tvShow.title)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(bgColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.bold)
                        .foregroundStyle(primaryColor)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(presenter.tvShow.title)
                    .font(.headline)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(primaryColor)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if !presenter.isFavorite {
                        self.presenter.addFavorite(tvShowDetailModel: self.presenter.tvShow)
                    } else {
                        self.presenter.deleteFavorite(tvShowId: self.presenter.tvShow.id)
                    }
                } label: {
                    Image(systemName: self.presenter.isFavorite ? "heart.fill" : "heart")
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(primaryColor)
                }
                .disabled(self.presenter.loadingState)
            }
        }
        .animation(.easeInOut, value: bgColor)
    }
}

extension TvShowDetailView {
    var tvPoster: some View {
        WebImage(url: URL(string: API.imageBaseUrl + presenter.tvShow.posterPath))
            .resizable()
            .onSuccess(perform: { image, _, _ in
                image.extractPalette { bg, primary, secondary in
                    self.bgColor = bg
                    self.primaryColor = primary
                    self.secondaryColor = secondary
                }
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(height: 175)
    }
    
    var tvBackdrop: some View {
        WebImage(url: URL(string: API.backdropBaseUrl + presenter.tvShow.backdropPath))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
    }
    
    var tvContentDetail: some View {
        HStack {
            tvPoster
            
            VStack {
                Text(presenter.tvShow.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(primaryColor)
                
                Text(presenter.tvShow.releaseDate.formatDateString())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(secondaryColor)
                
                HStack {
                    if presenter.tvShow.runtime != 0 {
                        Text(presenter.tvShow.runtime.formatRuntime())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryColor)
                        
                        Text("\u{2022}")
                            .foregroundStyle(secondaryColor)
                    }
                    
                    Text(presenter.tvShow.contentRating)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(secondaryColor)
                }
                
                Text(presenter.tvShow.genre)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(secondaryColor)
                    .padding(.top, 1)
                
                if !presenter.tvShow.tagline.isEmpty {
                    Text(presenter.tvShow.tagline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .italic()
                        .foregroundStyle(secondaryColor)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal)
        }
    }
    
    var tvOverview: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .foregroundStyle(primaryColor)
                .padding([.top, .horizontal])
                .padding(.bottom, 1)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(presenter.tvShow.overview)
                .foregroundStyle(secondaryColor)
                .padding(.horizontal)
        }
    }
    
    var tvContentUtils: some View {
        HStack(alignment: .center) {
            Spacer()
            ZStack {
                CircularProgressView(progress: presenter.tvShow.rating / 10, lineWidth: 3, circularColor: secondaryColor)
                    .frame(width: 35, height: 35)
                
                Text((presenter.tvShow.rating / 10).toPercentage())
                    .font(.system(size: 11))
                    .foregroundStyle(primaryColor)
            }
            
            Text("User Score")
                .foregroundStyle(primaryColor)
            
            if presenter.tvShow.videos.count > 1 {
                Text("\u{FF5C}")
                    .fontWeight(.medium)
                    .foregroundStyle(primaryColor)
                    .padding(.horizontal)
                
                tvTrailerBottomSheet
            } else {
                if let firstKey = presenter.tvShow.videos.first?.key {
                    Text("\u{FF5C}")
                        .fontWeight(.medium)
                        .foregroundStyle(primaryColor)
                        .padding(.horizontal)
                    
                    Link(destination: URL(string: Constants.youtubeBaseUrl + firstKey)!) {
                        Label("Play Trailer", systemImage: "play.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(primaryColor)
                }
            }
            Spacer()
        }
        .padding(.top)
    }
    
    var tvTrailerBottomSheet: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label("Play Trailer", systemImage: "play.fill")
        }
        .buttonStyle(.plain)
        .foregroundStyle(primaryColor)
        .sheet(isPresented: $showSheet) {
            let rowHeight: CGFloat = 55
            let headerHeight: CGFloat = 100
            let totalHeight = CGFloat(presenter.tvShow.videos.count) * rowHeight + headerHeight
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("Choose Trailer")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        showSheet = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top)
                .padding(.horizontal, 20)
                
                List(presenter.tvShow.videos, id: \.id) { video in
                    Link(video.name, destination: URL(string: Constants.youtubeBaseUrl + video.key)!)
                        .buttonStyle(.plain)
                        .lineLimit(2)
                        .padding(.vertical, 1)
                }
                .listStyle(.plain)
                .introspect(.list, on: .iOS(.v17, .v18)) { tableView in
                    tableView.bounces = false
                    tableView.showsVerticalScrollIndicator = false
                }
            }
            .padding(.vertical)
            .presentationDragIndicator(.automatic)
            .presentationDetents([.height(totalHeight)])
            .presentationCornerRadius(30)
            .interactiveDismissDisabled(true)
        }
    }
    
    var tvCredits: some View {
        VStack(alignment: .leading) {
            Text("Top Billed Cast")
                .padding(.horizontal)
                .font(.title2)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    ForEach(presenter.tvShow.credits.take(length: 10), id: \.id) { cast in
                        presenter.toPersonView(for: cast.id) {
                            CreditItemView(creditModel: cast, isPersonView: false)
                        }
                    }
                    
                    presenter.toCreditDetailView(for: presenter.tvShow.credits) {
                        HStack {
                            Text("View more")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .padding(.top)
    }
    
    var tvDetailInfo: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Details")
                    .padding(.horizontal)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                presenter.toTvShowSeasonView(for: presenter.tvShow.seasons, title: presenter.tvShow.title, id: presenter.tvShow.id) {
                    Text("SEE SEASONS")
                        .padding(.horizontal)
                        .font(.subheadline)
                }
                
            }
            .padding(.bottom, 2)
            
            HStack(alignment: .top) {
                VStack {
                    Text("Status")
                    Text(presenter.tvShow.status)
                        .fontWeight(.thin)
                }
                .frame(maxWidth: 200)
                
                VStack {
                    Text("Spoken Language")
                    Text(presenter.tvShow.spokenLanguage)
                        .multilineTextAlignment(.center)
                        .fontWeight(.thin)
                }
                .frame(maxWidth: 200)
            }
            
            Spacer()
            
            HStack(alignment: .top) {
                VStack {
                    Text("Network")
                    ForEach(presenter.tvShow.networks) { network in
                        WebImage(url: URL(string: API.logoImageBaseUrl + network.logoPath))
                            .resizable()
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(width: 15, height: 15)
                    }
                }
                .frame(maxWidth: 200)
                
                VStack {
                    Text("Type")
                    Text(presenter.tvShow.type)
                        .fontWeight(.thin)
                }
                .frame(maxWidth: 200)
            }
        }
        .padding(.top)
        .padding(.bottom)
    }
}

struct TvShowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        TvShowDetailView(
            presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase, favoriteUseCase: favoriteUseCase),
            tvShowId: 114472
        )
    }
}
