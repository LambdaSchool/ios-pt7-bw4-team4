//
//  ForageSpot+Convenience.swift
//  MyForage
//
//  Created by Zachary Thacker on 12/17/20.
//

import Foundation
import CoreData

extension ForageSpot {
    @discardableResult convenience init(mushroomType: MushroomType,
                     favorability: Double = 0,
                     latitude: Double,
                     longitude: Double,
                     identifier: UUID = UUID(),
                     name: String,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.mushroomType = mushroomType.rawValue
        self.favorability = favorability
        self.latitude = latitude
        self.longitude = longitude
        self.identifier = identifier
        self.name = name
    }
}
