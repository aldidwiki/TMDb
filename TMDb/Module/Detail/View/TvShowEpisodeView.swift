//
//  TvShowEpisodeView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import SwiftUI

struct TvShowEpisodeView: View {
    @State private var query = ""

    let season: TvShowSeasonModel
    let episodes: [TvShowSeasonDetailModel]

    private var filteredEpisodes: [TvShowSeasonDetailModel] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return episodes }

        let number = Int(term.first?.lowercased() == "e" ? String(term.dropFirst()) : term)
        return episodes.filter { episode in
            episode.episodeNumber == number || episode.displayName.localizedCaseInsensitiveContains(term)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let inset = max(20, (geometry.size.width - DashboardDesign.contentWidth) / 2)

            VStack(alignment: .leading, spacing: 0) {
                DetailToolbar(title: "Episodes")
                    .padding(.horizontal, inset)

                VStack(alignment: .leading, spacing: 8) {
                    Text(season.displayName)
                        .font(.title2.bold())
                        .foregroundStyle(DashboardDesign.text)
                        .accessibilityAddTraits(.isHeader)

                    searchField
                }
                .padding(.horizontal, inset)
                .padding(.vertical, 12)

                let results = filteredEpisodes
                if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(results, id: \.episodeNumber) { episode in
                                TvShowEpisodeItemView(episodeModel: episode)
                            }
                        }
                        .padding(.horizontal, inset)
                        .padding(.bottom, 20)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
        .background(DashboardDesign.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .tint(DashboardDesign.accent)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .accessibilityHidden(true)
            TextField("Search by title or episode number", text: $query)
                .font(.subheadline)
                .foregroundStyle(DashboardDesign.text)
                .submitLabel(.search)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .foregroundStyle(DashboardDesign.secondaryText)
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                .strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
    }
}

extension TvShowSeasonDetailModel {
    var episodeCode: String {
        String(format: "E%02d", episodeNumber)
    }

    var displayName: String {
        name.isEmpty ? "Episode \(episodeNumber)" : name
    }
}
