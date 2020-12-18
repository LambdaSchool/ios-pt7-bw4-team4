//
//  ForageSpot+Convenience.swift
//  MyForage
//
//  Created by Zachary Thacker on 12/17/20.
//

import Foundation
import CoreData

extension ForageSpot {
    convenience init(mushroomType: MushroomType,
                     favorability: Double,
                     latitude: Double,
                     longitude: Double,
                     identifier: UUID = UUID(),
                     image: String,
                     name: String,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.mushroomType = mushroomType.rawValue
        self.favorability = Double(favorability)
        self.latitude = Double(latitude)
        self.longitude = Double(longitude)
        self.identifier = identifier
        self.image = image
        self.name = name
    }
}
