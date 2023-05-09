//
//  PersonView.swift
//  TMDb
//
//  Created by Aldi Dwiki" Prahasta on 08/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonView: View {
    @ObservedObject var presenter: PersonPresenter
    
    var body: some View {
        ZStack {
            if presenter.loadingState {
                ProgressView("Loading")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        profilePoster
                        
                        Text(presenter.person.name)
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("Personal Info")
                            .font(.title2)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                        personalInfo
                        
                        Text("Biography")
                            .font(.title2)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                        
                        Text(presenter.person.biography ?? "-")
                            .fontWeight(.thin)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }.onAppear {
            presenter.getPerson()
        }
    }
}

extension PersonView {
    var profilePoster: some View {
        WebImage(url: URL(string: API.profileImageBaseUrl + (presenter.person.profilePath ?? "")))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .cornerRadius(8)
            .frame(width: 200, height: 300)
    }
    
    var personalInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Birthday")
                Text("\(presenter.person.birthday.formatDateString()) (\(presenter.person.birthday.ageFormatter()) years old)")
                    .fontWeight(.thin)
                
                Spacer()
                
                Text("Place of Birth")
                Text(presenter.person.birthplace)
                    .fontWeight(.thin)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Known For")
                Text(presenter.person.knownFor)
                    .fontWeight(.thin)
                
                Spacer()
                
                Text("Gender")
                Text(String(presenter.person.gender))
                    .fontWeight(.thin)
            }
            .padding(.trailing)
        }
        .padding(.top, 2)
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        let personUseCase = Injection.init().providePersonUseCase(personId: 73457)
        PersonView(presenter: PersonPresenter(personUseCase: personUseCase))
    }
}
