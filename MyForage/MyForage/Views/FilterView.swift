//
//  FilterView.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/7/21.
//

import SwiftUI

struct FilterView: View {
    
    @EnvironmentObject var filterViewModel: FilterViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Filters")
                .foregroundColor(Color("CharcoalColor"))
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 30)
            
            VStack {
                Picker("", selection: $filterViewModel.mushroomType) {
                    ForEach(MushroomType.allCases) { mushroomType in
                        Text(mushroomType.rawValue)
                            .foregroundColor(Color("CreamColor"))
                    }
                }
                .background(Color("OrangeColor"))
                .frame(width: 200, height: 100)
                .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("YellowColor"), lineWidth: 4)
                    )
                .cornerRadius(15)
                .shadow(radius: 8, x: 3, y: 3)
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                Button(action: filterViewModel.typeSelected, label: {
                    Text("Filter by Type")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("CreamColor"))
                        .padding(10)
                        .background(Color("OrangeColor"))
                        .cornerRadius(15)
                        .shadow(radius: 8, x: 3, y: 3)
                })
            }
            
            Button(action: filterViewModel.goodSpotsSelected, label: {
                Text("Good Spots")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("CreamColor"))
                    .padding(10)
                    .background(Color("MediumGreenColor"))
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            
            Button(action: filterViewModel.clearFilters, label: {
                Text("Clear Filters")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("CreamColor"))
                    .padding(10)
                    .background(Color("RedColor"))
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            .padding(.bottom, 30)
        }
        .background(Color("CreamColor"))
        .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("MediumGreenColor"), lineWidth: 6)
            )
        .cornerRadius(20)
        .shadow(radius: 8, x: 3, y: 3)
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
            .environmentObject(FilterViewModel())
    }
}
