//
//  SearchPresenter.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Combine

class SearchPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let searchUseCase: SearchUseCase
    
    init(searchUseCase: SearchUseCase) {
        self.searchUseCase = searchUseCase
    }
    
    
}
