//
//  ForageSpot+Convenience.swift
//  MyForage
//
//  Created by Zachary Thacker on 12/17/20.
//

import Foundation
import CoreData

extension ForageSpot {
    convenience init(favorability: Int,
                     geotag: String,
                     identifier: String,
                     image: String,
                     name: String,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.favorability = Int32(favorability)
        self.geotag = geotag
        self.identifier = identifier
        self.image = image
        self.name = name
    }
}
