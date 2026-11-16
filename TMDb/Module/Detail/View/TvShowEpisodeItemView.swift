//
//  TvShowEpisodeItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import SwiftUI

struct TvShowEpisodeItemView: View {
    let episodeModel: TvShowSeasonDetailModel

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
        let date = episodeModel.airDate.formatDateString(output: "MMM d, yyyy")
        let runtime = episodeModel.runtime > 0 ? episodeModel.runtime.formatRuntime() : ""
        let metadata = [date, runtime].filter { !$0.isEmpty }.joined(separator: " · ")

        VStack(alignment: .leading, spacing: 0) {
            if !episodeModel.stillPath.isEmpty {
                DetailArtwork(path: episodeModel.stillPath, baseURL: API.episodeStillBaseUrl)
                    .aspectRatio(16.0 / 9, contentMode: .fit)
                    .clipped()
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(episodeModel.episodeCode) · \(episodeModel.displayName)")
                    .font(.subheadline.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                if !metadata.isEmpty || episodeModel.rating > 0 {
                    HStack(spacing: 8) {
                        if episodeModel.rating > 0 {
                            Label(
                                episodeModel.rating.formatted(.number.precision(.fractionLength(1))),
                                systemImage: "star.fill"
                            )
                            .foregroundStyle(DashboardDesign.accent)
                        }
                        if !metadata.isEmpty {
                            Text(metadata)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
                }

                if !episodeModel.overview.isEmpty {
                    Text(episodeModel.overview)
                        .font(.footnote)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(DashboardDesign.surface)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
    }
}
