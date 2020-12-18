//
//  Note+Convenience.swift
//  MyForage
//
//  Created by Zachary Thacker on 12/17/20.
//

import Foundation
import CoreData

extension Note {
    convenience init(body: String,
                     date: Date,
                     identifier: UUID = UUID(),
                     photo: String,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.body = body
        self.date = date
        self.identifier = identifier
        self.photo = photo
    }
}
