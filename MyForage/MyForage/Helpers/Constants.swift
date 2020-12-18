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
    case chantrelles = "chantrelles"
    case morel = "morel"
    case lionsMain = "lionsMain"
    case oyster = "oyster"
    case giantPuffBall = "giantPuffBall"
    case wineCap = "wineCap"
    case porcini = "porcini"
    case shitake = "shitake"
    
    var id: String { self.rawValue }
}
