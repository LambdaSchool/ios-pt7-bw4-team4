//
//  WeatherHistory+Convinience.swift
//  MyForage
//
//  Created by Zachary Thacker on 1/5/21.
//

import Foundation
import CoreData

extension WeatherHistory {
    @discardableResult convenience init(dateTime: Date,
                                        temperatureHigh: Double,
                                        totalRain: Double,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.dateTime = dateTime
        self.temperatureHigh = temperatureHigh
        self.totalRain = totalRain
    }
    
    convenience init(representation: WeatherHistoryRepresentation) {
        self.init(dateTime: representation.dateTime,
                  temperatureHigh: representation.temperatureHigh,
                  totalRain: representation.totalRain)
    }
    
    @discardableResult convenience init(weatherHistoryRepresentation: WeatherHistoryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(dateTime: weatherHistoryRepresentation.dateTime,
                  temperatureHigh: weatherHistoryRepresentation.temperatureHigh,
                  totalRain: weatherHistoryRepresentation.totalRain,
                  context: context)
                  
    }
    
}
