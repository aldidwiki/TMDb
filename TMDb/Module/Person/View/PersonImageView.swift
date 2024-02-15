//
//  PersonImageView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 15/02/24.
//

import SwiftUI
import SDWebImageSwiftUI
import ImageViewerRemote

struct PersonImageView: View {
    @ObservedObject var personPresenter: PersonPresenter
    @State var imgUrl = ""
    @State var showImageView = false
    
    var personId: Int
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(personPresenter.personImages, id: \.filePath) { personImage in
                    WebImage(url: URL(string: API.profileOriginalBaseUrl + personImage.filePath))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .cornerRadius(8)
                        .onTapGesture {
                            self.imgUrl = API.profileOriginalBaseUrl + personImage.filePath
                            self.showImageView.toggle()
                        }
                }
            }
            .padding(.horizontal)
        }
        .overlay {
            ImageViewerRemote(imageURL: $imgUrl, viewerShown: $showImageView, closeButtonTopRight: true)
        }
        .onAppear {
            personPresenter.getPersonImage(personId: personId)
        }
    }
}

#Preview {
    PersonImageView(
        personPresenter: PersonPresenter(personUseCase: Injection.init().providePersonUseCase()),
        personId: 2112859
    )
}
