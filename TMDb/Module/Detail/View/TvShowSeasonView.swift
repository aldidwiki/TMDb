//
//  TvShowSeasonView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 12/08/23.
//

import SwiftUI

struct TvShowSeasonView: View {
    @Environment(\.dismiss) private var dismiss

    let seasons: [TvShowSeasonModel]
    let selectedSeasonNumber: Int?
    let onSelect: (TvShowSeasonModel) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DetailSectionHeading("All Seasons")
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(seasons, id: \.seasonNumber) { season in
                            let isSelected = season.seasonNumber == selectedSeasonNumber
                            Button {
                                onSelect(season)
                                dismiss()
                            } label: {
                                TvShowSeasonItemView(season: season, isSelected: isSelected)
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(isSelected ? .isSelected : [])
                            .id(season.seasonNumber)
                        }
                    }
                    .padding(20)
                }
                .task {
                    if let selectedSeasonNumber {
                        proxy.scrollTo(selectedSeasonNumber, anchor: .center)
                    }
                }
            }
        }
        .background(DashboardDesign.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }
}

extension TvShowSeasonModel {
    var chipTitle: String {
        seasonNumber == 0 ? "Specials" : "Season \(seasonNumber)"
    }

    var displayName: String {
        seasonName.isEmpty ? chipTitle : seasonName
    }

    var episodeSummary: String {
        let count = episodeCount == 1 ? "1 episode" : "\(episodeCount) episodes"
        let year = String(seasonAirDate.prefix(4))
        return year.isEmpty ? count : "\(count) · \(year)"
    }
}
