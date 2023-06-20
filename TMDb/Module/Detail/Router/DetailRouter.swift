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
    
    func makeCreditDetailView(for credits: [CreditModel], presenter: DetailPresenter) -> some View {
        return CreditDetailView(presenter: presenter, creditModelList: credits)
    }
}
