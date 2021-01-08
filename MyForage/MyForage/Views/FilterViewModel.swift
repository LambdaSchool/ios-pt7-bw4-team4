//
//  FilterViewModel.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/7/21.
//

import SwiftUI

protocol FilterDelegate: AnyObject {
    func filterSpots(predicate: NSPredicate?)
}

class FilterViewModel: ObservableObject {
    
    weak var delegate: FilterDelegate!
    private var typeActive: Bool = false
    private var goodSpotActive: Bool = false
    
    @Published var mushroomType: String = MushroomType.chanterelle.rawValue
    
    func typeSelected() {
        var predicate: NSPredicate
        typeActive = true
        if !goodSpotActive {
            predicate = NSPredicate(format: "mushroomType == %@", mushroomType)
        } else {
            predicate = NSPredicate(format: "mushroomType == %@ AND favorability > %f", mushroomType, 5.0)
        }
        delegate.filterSpots(predicate: predicate)
    }
    
    func goodSpotsSelected() {
        var predicate: NSPredicate
        goodSpotActive = true
        if !typeActive {
            predicate = NSPredicate(format: "favorability > %f", 5.0)
        } else {
            predicate = NSPredicate(format: "mushroomType == %@ AND favorability > %f", mushroomType, 5.0)
        }
        delegate.filterSpots(predicate: predicate)
    }
    
    func clearFilters() {
        typeActive = false
        goodSpotActive = false
        delegate.filterSpots(predicate: nil)
    }
    
}
