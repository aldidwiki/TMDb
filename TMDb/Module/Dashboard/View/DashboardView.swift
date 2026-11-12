import SwiftUI

struct DashboardView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.openURL) private var openURL
    @State private var presenter: DashboardPresenter
    @State private var showsExplore = false
    @State private var showsTrailerError = false
    @State private var carouselProgress: CGFloat = 0

    init(detailUseCase: DetailUseCase) {
        _presenter = State(initialValue: DashboardPresenter(detailUseCase: detailUseCase))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                insetContent(
                    Text("TMDb")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(DashboardDesign.accent)
                        .padding(.bottom, 26)
                        .accessibilityAddTraits(.isHeader)
                )

                trendingSection
                    .padding(.bottom, 10)

                insetContent(
                    VStack(alignment: .leading, spacing: 24) {
                        nowPlayingSection
                        genreSection
                    }
                )
            }
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(DashboardDesign.background.ignoresSafeArea())
        .preferredColorScheme(.light)
        .alert("Trailer unavailable", isPresented: $showsTrailerError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The trailer couldn’t be opened. Please try again later.")
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            insetContent(sectionTitle("Trending Now"))
                .padding(.bottom, 15)

            trendingCarousel

            HStack(spacing: 6) {
                ForEach(presenter.trendingMovies.indices, id: \.self) { index in
                    let emphasis = max(0, 1 - abs(carouselProgress - CGFloat(index)))
                    Capsule()
                        .fill(DashboardDesign.indicator)
                        .overlay {
                            Capsule()
                                .fill(DashboardDesign.accent)
                                .opacity(Double(emphasis))
                        }
                        .frame(width: 6 + 12 * emphasis, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Trending movies")
            .accessibilityValue("\(presenter.selectedPage + 1) of \(presenter.trendingMovies.count)")
            .accessibilityAdjustableAction { direction in
                withAnimation {
                    switch direction {
                    case .increment:
                        presenter.selectedPage = min(presenter.selectedPage + 1, presenter.trendingMovies.count - 1)
                    case .decrement:
                        presenter.selectedPage = max(presenter.selectedPage - 1, 0)
                    @unknown default:
                        break
                    }
                }
            }
        }
    }

    private var trendingCarousel: some View {
        GeometryReader { geometry in
            let viewportWidth = geometry.size.width
            let inset = max(DashboardDesign.contentInset, (viewportWidth - DashboardDesign.contentWidth) / 2)
            let cardWidth = max(0, viewportWidth - inset * 2)
            let cardSpacing: CGFloat = 12
            let lastPage = CGFloat(max(0, presenter.trendingMovies.count - 1))
            let isRightToLeft = layoutDirection == .rightToLeft
            let viewport = "trendingCarouselViewport"

            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(presenter.trendingMovies.indices, id: \.self) { index in
                        featuredCard(presenter.trendingMovies[index])
                            .frame(width: cardWidth)
                    }
                }
                .scrollTargetLayout()
                .onGeometryChange(for: CGFloat.self) { geometry in
                    let frame = geometry.frame(in: .named(viewport))
                    let leading = isRightToLeft ? viewportWidth - frame.maxX : frame.minX
                    let progress = (inset - leading) / (cardWidth + cardSpacing)
                    return min(max(0, progress), lastPage)
                } action: { progress in
                    carouselProgress = progress
                }
            }
            .contentMargins(.horizontal, inset, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(
                id: Binding<Int?>(
                    get: { presenter.selectedPage },
                    set: { if let page = $0 { presenter.selectedPage = page } }
                ),
                anchor: .center
            )
            .scrollIndicators(.hidden)
            .coordinateSpace(.named(viewport))
        }
        .frame(height: 250)
    }

    private func insetContent<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
            .padding(.horizontal, DashboardDesign.contentInset)
            .frame(maxWidth: .infinity)
    }

    private func featuredCard(_ movie: DashboardPresenter.FeaturedMovie) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .accessibilityHidden(true)
                Text(movie.rating)
                    .font(.system(size: 11, weight: .bold))
            }
            .frame(minWidth: 52, minHeight: 24)
            .background(DashboardDesign.mediaFooter, in: RoundedRectangle(cornerRadius: 8))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rating \(movie.rating) out of 10")

            Spacer(minLength: 12)

            Text(movie.title)
                .font(.system(size: 22, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            Text(movie.metadata)
                .font(.system(size: 12, weight: .medium))
                .padding(.top, 2)

            trailerButton(movie)
                .padding(.top, 13)
        }
        .foregroundStyle(DashboardDesign.surface)
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(alignment: .bottom) {
            DashboardDesign.mediaFooterGradient.frame(height: 120)
        }
        .background(DashboardDesign.color(movie.backdrop))
        .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }

    private func trailerButton(_ movie: DashboardPresenter.FeaturedMovie) -> some View {
        let isLoading = presenter.loadingTrailerID == movie.id

        return Button {
            presenter.loadTrailer(for: movie) { url in
                guard let url else {
                    showsTrailerError = true
                    return
                }

                openURL(url) { accepted in
                    showsTrailerError = !accepted
                }
            }
        } label: {
            HStack(spacing: 5) {
                if isLoading {
                    ProgressView()
                        .tint(DashboardDesign.surface)
                        .controlSize(.small)
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                }
                Text("Watch Trailer")
            }
            .font(.system(size: 13, weight: .semibold))
            .frame(width: 170, height: 42)
        }
        .buttonStyle(TrailerButtonStyle())
        .disabled(isLoading)
    }

    private var nowPlayingSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            sectionHeader("Now Playing")

            HStack(spacing: 15) {
                ForEach(presenter.nowPlaying) { poster in
                    VStack {
                        Spacer(minLength: 0)

                        Text(poster.title)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(DashboardDesign.surface)
                            .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                            .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .background(alignment: .bottom) {
                        DashboardDesign.mediaFooterGradient.frame(height: 72)
                    }
                    .background(DashboardDesign.color(poster.color))
                    .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                }
            }
        }
    }

    private var genreSection: some View {
        let spacing: CGFloat = 6
        let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)

        return VStack(alignment: .leading, spacing: 11) {
            sectionHeader("Browse by Genre")

            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(presenter.genres) { genre in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(genre.monogram)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(DashboardDesign.color(genre.accent))
                            .frame(width: 24, height: 24)
                            .background(DashboardDesign.color(genre.accent).opacity(0.12), in: Circle())
                            .accessibilityHidden(true)

                        Text(genre.title)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(DashboardDesign.text)
                            .padding(.top, 8)

                        Text(genre.titleCount)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(DashboardDesign.secondaryText)
                            .padding(.top, 4)
                    }
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 78)
                    .background(DashboardDesign.color(genre.background), in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(DashboardDesign.text)
            .accessibilityAddTraits(.isHeader)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            sectionTitle(title)
            Spacer(minLength: 8)
            Button {
                showsExplore = true
            } label: {
                HStack(spacing: 4) {
                    Text("See All")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9, weight: .semibold))
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DashboardDesign.accent)
                .frame(width: 95, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("See all, \(title)")
        }
    }
}

private struct TrailerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(DashboardDesign.surface)
            .background(
                configuration.isPressed ? DashboardDesign.accentPressed : DashboardDesign.accent,
                in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
            )
    }
}

enum DashboardDesign {
    static let contentWidth: CGFloat = 560
    static let contentInset: CGFloat = 18
    static let background = color(0xF9F9FF)
    static let surface = color(0xFFFFFF)
    static let border = color(0xE2E6F4)
    static let accent = color(0x3B4CCA)
    static let accentPressed = color(0x2D3CA8)
    static let text = color(0x0F172A)
    static let secondaryText = color(0x64748B)
    static let mediaFooter = color(0x141B2B)
    static let mediaFooterGradient = LinearGradient(
        colors: [mediaFooter.opacity(0.95), mediaFooter.opacity(0)],
        startPoint: .bottom,
        endPoint: .top
    )
    static let indicator = color(0xDCE2F7)
    static let controlRadius: CGFloat = 12

    static func color(_ hex: UInt32) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

#Preview {
    DashboardView(detailUseCase: Injection().provideDetailUseCase())
}
