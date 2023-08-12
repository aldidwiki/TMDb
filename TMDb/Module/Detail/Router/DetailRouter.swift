//
//  DetailRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import SwiftUI

class DetailRouter {
    func makePersonDetailView(for personId: Int) -> some View {
        let personUseCase = Injection.init().providePersonUseCase(personId: personId)
        return PersonView(presenter: PersonPresenter(personUseCase: personUseCase))
    }
    
    func makeCreditDetailView(for credits: [CreditModel]) -> some View {
        return CreditDetailView(presenter: CreditDetailPresenter(navigateType: NavigateType.personView), creditModelList: credits)
    }
    
    func makeTvShowSeasonView(for tvShowSeasonList: [TvShowSeasonModel]) -> some View {
        return TvShowSeasonView(tvShowSeasonList: tvShowSeasonList)
    }
}
