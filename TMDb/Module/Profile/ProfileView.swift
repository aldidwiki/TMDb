//
//  ProfileView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Image("profile_pic")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            
            Text("Aldi Dwiki Prahasta")
                .font(.title)
                .fontWeight(.medium)
                .padding(.top, 32)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
