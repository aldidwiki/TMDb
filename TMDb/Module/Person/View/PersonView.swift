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
                        
                        personalInfo
                        
                        personBiography
                        
                        personCredits
                    }
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
        WebImage(url: URL(string: API.profileImageBaseUrl + presenter.person.profilePath))
            .resizable()
            .placeholder(content: {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .cornerRadius(8)
            .frame(width: 200, height: 300)
    }
    
    var personalInfo: some View {
        VStack {
            Text("Personal Info")
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Birthday")
                    let birthday = presenter.person.birthday.formatDateString()
                    let age = presenter.person.birthday.ageFormatter()
                    Text(!birthday.isEmpty ? "\(birthday) (\(age) years old)" : "-")
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
            .padding(.top, 1)
        }
        .padding(.top)
        .padding(.horizontal)
    }
    
    var personBiography: some View {
        VStack {
            Text("Biography")
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(presenter.person.biography)
                .fontWeight(.thin)
                .multilineTextAlignment(.leading)
                .padding(.top, 1)
        }
        .padding(.top)
        .padding(.horizontal)
    }
    
    var personCredits: some View {
        VStack {
            Text("Known For")
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(presenter.person.credits, id: \.id) { cast in
                        presenter.linkBuilder(movieId: cast.id) {
                            CreditItemView(creditModel: cast)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .padding(.bottom)
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        let personUseCase = Injection.init().providePersonUseCase(personId: 73457)
        PersonView(presenter: PersonPresenter(personUseCase: personUseCase))
    }
}
