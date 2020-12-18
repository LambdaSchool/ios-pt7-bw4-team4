//
//  ForageAnnotation.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/18/20.
//

import Foundation
import MapKit

class ForageAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String
    var favorability: Double
    var image: String

    init(coordinate: CLLocationCoordinate2D, name: String, favorability: Double, image: String) {
        self.coordinate = coordinate
        self.name = name
        self.favorability = favorability
        self.image = image
    }
}
