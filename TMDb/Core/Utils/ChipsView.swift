//
//  ChipsView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 21/06/23.
//

import SwiftUI

struct ChipsView: View {
    @Binding var isSelected: (popular: Bool, name: Bool, character: Bool, recent: Bool)
    let isPersonCredit: Bool
    
    var body: some View {
        HStack {
            Text("popularity")
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .font(.system(size: 12))
                .foregroundColor(isSelected.popular ? Color.white : Color.black)
                .background(isSelected.popular ? Color("chips_color") : Color.white)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("chips_color"), lineWidth: 1.5)
                )
                .onTapGesture {
                    withAnimation {
                        if !isSelected.popular {
                            isSelected.popular.toggle()
                        }
                        if isSelected.name {
                            isSelected.name.toggle()
                        }
                        if isSelected.character {
                            isSelected.character.toggle()
                        }
                        if isSelected.recent {
                            isSelected.recent.toggle()
                        }
                    }
                }
            
            Text("name")
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .font(.system(size: 12))
                .foregroundColor(isSelected.name ? Color.white : Color.black)
                .background(isSelected.name ? Color("chips_color") : Color.white)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("chips_color"), lineWidth: 1.5)
                )
                .onTapGesture {
                    withAnimation {
                        if !isSelected.name {
                            isSelected.name.toggle()
                        }
                        if isSelected.popular {
                            isSelected.popular.toggle()
                        }
                        if isSelected.character {
                            isSelected.character.toggle()
                        }
                        if isSelected.recent {
                            isSelected.recent.toggle()
                        }
                    }
                }
            
            Text("character name")
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .font(.system(size: 12))
                .foregroundColor(isSelected.character ? Color.white : Color.black)
                .background(isSelected.character ? Color("chips_color") : Color.white)
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("chips_color"), lineWidth: 1.5)
                )
                .onTapGesture {
                    withAnimation {
                        if !isSelected.character {
                            isSelected.character.toggle()
                        }
                        if isSelected.name {
                            isSelected.name.toggle()
                        }
                        if isSelected.popular {
                            isSelected.popular.toggle()
                        }
                        if isSelected.recent {
                            isSelected.recent.toggle()
                        }
                    }
                }
            
            if isPersonCredit {
                Text("most recent")
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected.recent ? Color.white : Color.black)
                    .background(isSelected.recent ? Color("chips_color") : Color.white)
                    .cornerRadius(40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color("chips_color"), lineWidth: 1.5)
                    )
                    .onTapGesture {
                        withAnimation {
                            if !isSelected.recent {
                                isSelected.recent.toggle()
                            }
                            if isSelected.name {
                                isSelected.name.toggle()
                            }
                            if isSelected.character {
                                isSelected.character.toggle()
                            }
                            if isSelected.popular {
                                isSelected.popular.toggle()
                            }
                        }
                    }
            }
        }
    }
}
