//
//  CertificationResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct MovieCertificationResponse: Decodable {
    let region: String?
    let movieCertificationResponseModel: [MovieCertificationResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case region = "iso_3166_1"
        case movieCertificationResponseModel = "release_dates"
    }
}

struct MovieCertificationResponseModel: Decodable {
    let certification: String?
    
    private enum CodingKeys: String, CodingKey {
        case certification
    }
}
