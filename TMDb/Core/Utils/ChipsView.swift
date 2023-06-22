//
//  ChipsView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 21/06/23.
//

import SwiftUI

struct ChipsView: View {
    @Binding var isPopularSelected: Bool
    @Binding var isNameSelected: Bool
    @Binding var isCharactedSelected: Bool
    
    var body: some View {
        HStack {
            Text("popular")
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .font(.system(size: 12))
                .foregroundColor(isPopularSelected ? Color.white : Color.black)
                .background(isPopularSelected ? Color("primary_color") : Color.white)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("primary_color"), lineWidth: 1.5)
                )
                .onTapGesture {
                    withAnimation {
                        if !isPopularSelected {
                            isPopularSelected.toggle()
                        }
                        if isNameSelected {
                            isNameSelected.toggle()
                        }
                        if isCharactedSelected {
                            isCharactedSelected.toggle()
                        }
                    }
                }
            
            Text("name")
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .font(.system(size: 12))
                .foregroundColor(isNameSelected ? Color.white : Color.black)
                .background(isNameSelected ? Color("primary_color") : Color.white)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("primary_color"), lineWidth: 1.5)
                )
                .onTapGesture {
                    withAnimation {
                        if !isNameSelected {
                            isNameSelected.toggle()
                        }
                        if isPopularSelected {
                            isPopularSelected.toggle()
                        }
                        if isCharactedSelected {
                            isCharactedSelected.toggle()
                        }
                    }
                }
            
            Text("character")
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .font(.system(size: 12))
                .foregroundColor(isCharactedSelected ? Color.white : Color.black)
                .background(isCharactedSelected ? Color("primary_color") : Color.white)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("primary_color"), lineWidth: 1.5)
                )
                .onTapGesture {
                    withAnimation {
                        if !isCharactedSelected {
                            isCharactedSelected.toggle()
                        }
                        if isNameSelected {
                            isNameSelected.toggle()
                        }
                        if isPopularSelected {
                            isPopularSelected.toggle()
                        }
                    }
                }
        }
    }
}
