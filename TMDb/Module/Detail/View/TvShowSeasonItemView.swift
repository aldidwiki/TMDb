//
//  TvShowSeasonItemView.swift
//  TMDb
//

import SwiftUI

struct TvShowSeasonItemView: View {
    let season: TvShowSeasonModel
    let isSelected: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(season.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)
                Text(season.episodeSummary)
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(DashboardDesign.accent)
                    .accessibilityHidden(true)
            }
        }
        .padding(12)
        .background(isSelected ? DashboardDesign.surfaceDim : DashboardDesign.surface, in: shape)
        .overlay {
            shape.strokeBorder(isSelected ? DashboardDesign.accent : DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("TvShowSeasonItemView") {
    TvShowSeasonItemView(season: PreviewFixtures.season, isSelected: true)
}
#endif
