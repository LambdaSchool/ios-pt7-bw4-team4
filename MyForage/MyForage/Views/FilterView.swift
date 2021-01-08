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
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 30)
            
            VStack {
                Picker("", selection: $filterViewModel.mushroomType) {
                    ForEach(MushroomType.allCases) { mushroomType in
                        Text(mushroomType.rawValue)
                    }
                }
                .background(Color.blue)
                .frame(width: 200, height: 100)
                .cornerRadius(15)
                .shadow(radius: 8, x: 3, y: 3)
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                Button(action: filterViewModel.typeSelected, label: {
                    Text("Filter by Type")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 8, x: 3, y: 3)
                })
            }
            
            Button(action: filterViewModel.goodSpotsSelected, label: {
                Text("Good Spots")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(10)
                    .background(Color.green)
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            
            Button(action: filterViewModel.clearFilters, label: {
                Text("Clear Filters")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(10)
                    .background(Color.red)
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            .padding(.bottom, 30)
        }
        .background(Color.white)
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
            .environmentObject(FilterViewModel())
    }
}
