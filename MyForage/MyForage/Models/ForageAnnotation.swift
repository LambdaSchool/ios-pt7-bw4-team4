//
//  ForageAnnotation.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/18/20.
//

import Foundation
import MapKit
import CoreData

class ForageAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String
    var favorability: Double
    var imageData: Data?
    var identifier: UUID

    init(coordinate: CLLocationCoordinate2D, name: String, favorability: Double, imageData: Data?, identifier: UUID) {
        self.coordinate = coordinate
        self.name = name
        self.favorability = favorability
        self.imageData = imageData
        self.identifier = identifier
    }
}
