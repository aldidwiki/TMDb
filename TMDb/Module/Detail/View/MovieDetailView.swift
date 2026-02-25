//
//  DetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUIIntrospect

struct MovieDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var presenter: MovieDetailPresenter
    @State var showSheet = false
    
    @State private var bgColor: Color = .clear
    @State private var primaryColor: Color = .primary
    @State private var secondaryColor: Color = .primary
    
    var movieId: Int
    
    var body: some View {
        ZStack {
            if presenter.loadingState {
                ProgressView("Loading")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        VStack {
                            if !presenter.movie.backdropPath.isEmpty {
                                presenter.toMovieImageGallery(for: movieId) {
                                    movieBackdrop
                                }
                            }
                            
                            movieContentDetail
                                .padding([.top, .horizontal])
                            
                            movieContentUtils
                            
                            movieOverview
                        }
                        .padding(.bottom)
                        .background(bgColor)
                        
                        if !presenter.movie.cast.isEmpty {
                            movieCredits
                        }
                        
                        movieDetailInfo
                        
                        ExternalMediaView(
                            instagramId: presenter.movie.instagramId,
                            facebookId: presenter.movie.facebookId,
                            twitterId: presenter.movie.twitterId,
                            imdbId: presenter.movie.imdbId
                        )
                        .padding(.vertical)
                    }
                }
                .blur(radius: showSheet ? 6 : 0)
            }
        }.onAppear {
            if presenter.movie.id == 0 && presenter.movie.title.isEmpty {
                presenter.getMovie(movieId: movieId)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(presenter.movie.title)
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
                Text(presenter.movie.title)
                    .font(.headline)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(primaryColor)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if !presenter.isFavorite {
                        self.presenter.addFavorite(movie: self.presenter.movie)
                    } else {
                        self.presenter.deleteFavorite(movieId: self.presenter.movie.id)
                    }
                } label: {
                    Image(systemName: self.presenter.isFavorite ? "heart.fill" : "heart")
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(primaryColor)
                }.disabled(self.presenter.loadingState)
            }
        }
        .animation(.easeInOut, value: bgColor)
    }
}

extension MovieDetailView {
    var moviePoster: some View {
        WebImage(url: URL(string: API.imageBaseUrl + presenter.movie.posterPath))
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
    
    var movieBackdrop: some View {
        WebImage(url: URL(string: API.backdropBaseUrl + presenter.movie.backdropPath))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
    }
    
    var movieContentDetail: some View {
        HStack {
            moviePoster
            
            VStack {
                Text(presenter.movie.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(primaryColor)
                    .multilineTextAlignment(.center)
                
                Text(presenter.movie.releaseDate.formatDateString())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(secondaryColor)
                
                HStack {
                    if presenter.movie.runtime != 0 {
                        Text(presenter.movie.runtime.formatRuntime())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryColor)
                    }
                    
                    if !presenter.movie.certification.isEmpty {
                        Text("\u{2022}")
                            .foregroundStyle(secondaryColor)
                        
                        Text(presenter.movie.certification)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryColor)
                    }
                }
                
                Text(presenter.movie.genre)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(secondaryColor)
                    .padding(.top, 1)
                
                if !presenter.movie.tagline.isEmpty {
                    Text(presenter.movie.tagline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .italic()
                        .foregroundStyle(primaryColor)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal)
        }
    }
    
    var movieOverview: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .foregroundStyle(primaryColor)
                .padding([.top, .horizontal])
                .padding(.bottom, 1)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(presenter.movie.overview)
                .foregroundStyle(secondaryColor)
                .padding(.horizontal)
        }
    }
    
    var movieCredits: some View {
        VStack(alignment: .leading) {
            Text("Top Billed Cast")
                .padding(.horizontal)
                .font(.title2)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    ForEach(presenter.movie.cast.take(length: 10), id: \.id) { cast in
                        presenter.toPersonDetail(for: cast.id) {
                            CreditItemView(creditModel: cast, isPersonView: false)
                        }
                    }
                    
                    presenter.toCreditDetailView(for: presenter.movie.cast) {
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
    
    var movieDetailInfo: some View {
        VStack(alignment: .leading) {
            Text("Details")
                .padding([.top, .horizontal])
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Spacer()
                
                VStack {
                    Text("Status")
                    Text(presenter.movie.status)
                        .fontWeight(.thin)
                    
                    Spacer()
                    
                    Text("Budget")
                    Text(presenter.movie.budget.formatCurrency())
                        .fontWeight(.thin)
                }
                
                Spacer()
                
                VStack {
                    Text("Spoken Language")
                    Text(presenter.movie.spokenLanguage)
                        .fontWeight(.thin)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Text("Revenue")
                    Text(presenter.movie.revenue.formatCurrency())
                        .fontWeight(.thin)
                }
                
                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(.bottom)
    }
    
    var movieContentUtils: some View {
        HStack(alignment: .center) {
            Spacer()
            ZStack {
                CircularProgressView(progress: presenter.movie.rating / 10, lineWidth: 3, circularColor: secondaryColor)
                    .frame(width: 35, height: 35)
                
                Text((presenter.movie.rating / 10).toPercentage())
                    .font(.system(size: 11))
                    .foregroundStyle(primaryColor)
            }
            
            Text("User Score")
                .foregroundStyle(primaryColor)
            
            if presenter.movie.videos.count > 1 {
                Text("\u{FF5C}")
                    .foregroundStyle(primaryColor)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                movieTrailerBottomSheet
            } else {
                if let firstKey = presenter.movie.videos.first?.key {
                    Text("\u{FF5C}")
                        .foregroundStyle(primaryColor)
                        .fontWeight(.medium)
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
    
    var movieTrailerBottomSheet: some View {
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
            let totalHeight = CGFloat(presenter.movie.videos.count) * rowHeight + headerHeight
            
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
                .padding(.horizontal, 20)
                .padding(.top)
                
                List(presenter.movie.videos, id: \.id) { video in
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
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        MovieDetailView(
            presenter: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase),
            movieId: 436270
        )
    }
}
