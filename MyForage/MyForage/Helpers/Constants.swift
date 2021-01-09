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
    static let noteCell = "NoteCell"
    static let weatherCell = "WeatherCell"
    static let headerView = "HeaderView"
    static let footerView = "FooterView"
}

enum MushroomType: String, CaseIterable, Identifiable {
    case chanterelle = "Chanterelle"
    case morel = "Morel"
    case lionsMain = "Lion's Mane"
    case oyster = "Oyster"
    case giantPuffBall = "Giant Puff Ball"
    case wineCap = "Wine Cap"
    case porcini = "Porcini"
    case shiitake = "Shiitake"
    case trumpet = "Trumpet"
    case other = "Other"
    
    var id: String { self.rawValue }
}

struct AppColor {
    let tan: UIColor
    let cream: UIColor
    let gray: UIColor
    let charcoal: UIColor
    let darkGreen: UIColor
    let mediumGreen: UIColor
    let lightGreen: UIColor
    let yellow: UIColor
    let orange: UIColor
    let red: UIColor
}

let appColor = AppColor(tan: UIColor(named: "TanColor")!,
                        cream: UIColor(named: "CreamColor")!,
                        gray: UIColor(named: "GrayColor")!,
                        charcoal: UIColor(named: "CharcoalColor")!,
                        darkGreen: UIColor(named: "DarkGreenColor")!,
                        mediumGreen: UIColor(named: "MediumGreenColor")!,
                        lightGreen: UIColor(named: "LightGreenColor")!,
                        yellow: UIColor(named: "YellowColor")!,
                        orange: UIColor(named: "OrangeColor")!,
                        red: UIColor(named: "RedColor")!)
