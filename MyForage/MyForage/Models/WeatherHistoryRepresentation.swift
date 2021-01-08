//
//  WeatherHistoryRepresentation.swift
//  MyForage
//
//  Created by Zachary Thacker on 1/5/21.
//

import Foundation

struct WeatherHistoryResults: Decodable {
    let results: [WeatherHistoryRepresentation]
}

struct WeatherHistoryRepresentation: Decodable {
    let dateTime: Date
    let temperatureHigh: Double
    let totalRain: Double
    
    enum Keys: String, CodingKey {
        case hourly
        case current
        
        enum CurrentKeys: String, CodingKey {
            case dateTime = "dt"
        }
        enum HourlyKeys: String, CodingKey {
            case temp
            case rain
            case rainMm = "1h"
        }
    }
    
    init(from decoder: Decoder) throws {
        let rootDict = try decoder.container(keyedBy: Keys.self)
        
        let curretnContainer = try rootDict.nestedContainer(keyedBy: Keys.CurrentKeys.self, forKey: .current )
        
        let dateInt = try curretnContainer.decode(Int.self, forKey: .dateTime)
        dateTime = Date(timeIntervalSince1970: Double(dateInt))
        
        var hourlyContainer = try rootDict.nestedUnkeyedContainer(forKey: .hourly)
        
        var highestTemp: Double = -100
        var totalRainMm: Double = 0.0
        
        while hourlyContainer.isAtEnd == false {
            
            let hourContainer = try hourlyContainer.nestedContainer(keyedBy: Keys.HourlyKeys.self)
            let hourlyTemp = try hourContainer.decode(Double.self, forKey: .temp)
            if hourlyTemp > highestTemp {
                highestTemp = hourlyTemp
            }
            
            if let rainContainer = try? hourContainer.nestedContainer(keyedBy: Keys.HourlyKeys.self, forKey: .rain) {
                let hourlyRain = try rainContainer.decode(Double.self, forKey: .rainMm)
                totalRainMm += hourlyRain
            }
            
        }
        
        temperatureHigh = highestTemp
        totalRain = (totalRainMm * 0.03937008) // converting millimeters to inches
    }
    
    
}


