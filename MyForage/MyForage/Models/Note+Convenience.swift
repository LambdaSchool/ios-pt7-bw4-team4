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
                     date: Date = Date(),
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.body = body
        self.date = date
        self.identifier = identifier
    }
}
