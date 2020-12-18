//
//  Constants.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/16/20.
//

import Foundation

enum ReuseIdentifier {
    static let forageAnnotation = "ForageAnnotationView"
    static let forageCell = "ForageCell"
}

enum MushroomType: String, CaseIterable, Identifiable {
    case chanterelle = "Chanterelle"
    case morel = "Morel"
    case lionsMain = "Lion's Main"
    case oyster = "Oyster"
    case giantPuffBall = "Giant Puff Ball"
    case wineCap = "Wine Cap"
    case porcini = "Porcini"
    case shiitake = "Shiitake"
    case trumpet = "Trumpet"
    case other = "Other"
    
    var id: String { self.rawValue }
}
