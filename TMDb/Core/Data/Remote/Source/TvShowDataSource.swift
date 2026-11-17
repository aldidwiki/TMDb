//
//  TvShowDataSource.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Combine

protocol TvShowDataSourceProtocol {
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailResponse, Error>
    func getSimilarTvShows(tvShowId: Int, page: Int) -> AnyPublisher<TvResponse, Error>
    func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) -> AnyPublisher<TvShowSeasonDetailResponse, Error>
    func getTvShowBackdrops(tvId: Int) -> AnyPublisher<ImageResponse, Error>
}

final class TvShowDataSource: NSObject {
    private override init() {}

    static let sharedInstance: TvShowDataSource = TvShowDataSource()
}

extension TvShowDataSource: TvShowDataSourceProtocol {
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailResponse, Error> {
        TMDbRequest.value("tv/\(tvShowId)", parameters: ["append_to_response": "content_ratings,videos,aggregate_credits,external_ids"])
    }

    func getSimilarTvShows(tvShowId: Int, page: Int) -> AnyPublisher<TvResponse, Error> {
        TMDbRequest.value("tv/\(tvShowId)/similar", parameters: ["page": page])
    }

    func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) -> AnyPublisher<TvShowSeasonDetailResponse, Error> {
        TMDbRequest.value("tv/\(tvShowId)/season/\(seasonNumber)")
    }

    func getTvShowBackdrops(tvId: Int) -> AnyPublisher<ImageResponse, Error> {
        TMDbRequest.value("tv/\(tvId)/images")
    }
}
