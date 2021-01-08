//
//  ModelController.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/6/21.
//

import Foundation
import CoreData

class ModelController {
    
    // MARK: - Properties
    
    let moc = CoreDataStack.shared.mainContext
    weak var coordinator: MainCoordinator?

    // MARK: - Forage Spot Functions
    
    func addForageSpot(name: String, typeString: String, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        guard let type = MushroomType(rawValue: typeString) else { return }
        let forageSpot = ForageSpot(mushroomType: type, latitude: latitude, longitude: longitude, name: name)
        getFiveDayWeather(forageSpot: forageSpot)
        let result = saveMOC()
        completion(result)
    }
    
    func editForageSpot(forageSpot: ForageSpot, newName: String, newType: String, newLat: Double, newLong: Double, completion: @escaping (Bool) -> Void) {
        forageSpot.name = newName
        forageSpot.mushroomType = newType
        if (forageSpot.latitude != newLat || forageSpot.longitude != newLong) {
            replaceFiveDayWeather(forageSpot: forageSpot)
        }
        forageSpot.latitude = newLat
        forageSpot.longitude = newLong
        let result = saveMOC()
        completion(result)
    }
    
    func deleteForageSpot(forageSpot: ForageSpot, completion: @escaping (Bool) -> Void) {
        moc.delete(forageSpot)
        let result = saveMOC()
        completion(result)
    }
    
    // MARK: - Weather History Functions
    
    func addWeatherHistory(forageSpot: ForageSpot, weatherRep: WeatherHistoryRepresentation) {
        let weather = WeatherHistory(weatherHistoryRepresentation: weatherRep)
        forageSpot.addToWeatherHistory(weather)
        setFavorabilityScore(forageSpot: forageSpot)
        saveMOC()
    }
    
    func deleteWeatherHistory(weather: WeatherHistory) {
        moc.delete(weather)
        saveMOC()
    }
    
    func getFiveDayWeather(forageSpot: ForageSpot){
        var dateArray: [String] = []
        let timeInterval = Int(Date().timeIntervalSince1970)
        
        for x in 0...4 {
            let dateString = String(timeInterval - (86400 * x) + timeZoneAdjustment())
            dateArray.append(dateString)
        }
        for date in dateArray {
            coordinator?.apiController.getWeatherHistory(latitude: forageSpot.latitude, longitude: forageSpot.longitude, dateTime: date, completion: { (result) in
                switch result {
                case .success(let weather):
                    self.addWeatherHistory(forageSpot: forageSpot, weatherRep: weather)
                default:
                    return
                }
            })
        }
    }
    
    func updateFiveDayWeather(forageSpot: ForageSpot) {
        let weatherData = Array(forageSpot.weatherHistory as? Set<WeatherHistory> ?? []).sorted(by: { $0.dateTime! > $1.dateTime! })
        
        guard weatherData.count != 0  else {
            getFiveDayWeather(forageSpot: forageSpot)
            return
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.dateStyle = .short

        var dateStringArray: [String] = []
        for x in 0...4 {
            let dateInt = Int(Date().timeIntervalSince1970) - (86400 * x)
            let dateString = formatter.string(from: Date(timeIntervalSince1970: Double(dateInt)))
            dateStringArray.append(dateString)
        }
        

        var weatherDayArray: [String] = []
        for weatherIndex in 0..<weatherData.count {
            let dateString = String(formatter.string(from: weatherData[weatherIndex].dateTime!))
            weatherDayArray.append(dateString)
        }
        
        var daysToRemove: [Int] = []
        for dayIndex in 0..<weatherDayArray.count {
            if let dateIndex = dateStringArray.firstIndex(of: weatherDayArray[dayIndex]) {
                dateStringArray.remove(at: dateIndex)
            } else {
                daysToRemove.insert(dayIndex, at: 0)
            }
        }
        
        for day in daysToRemove {
            deleteWeatherHistory(weather: weatherData[day])
        }
        
        if dateStringArray.count == 0 {
            let dateInt = Int(Date().timeIntervalSince1970)
            let dateString = formatter.string(from: Date(timeIntervalSince1970: Double(dateInt)))
            dateStringArray.append(dateString)
        }
        
        for dateString in dateStringArray {
            let date = formatter.date(from: dateString)
            let urlString = String(Int(date!.timeIntervalSince1970) + timeZoneAdjustment())
            coordinator?.apiController.getWeatherHistory(latitude: forageSpot.latitude, longitude: forageSpot.longitude, dateTime: urlString, completion: { result in
                switch result {
                case .success(let weather):
                    self.addWeatherHistory(forageSpot: forageSpot, weatherRep: weather)
                default:
                    return
                }
            })
        }
    }
    
    private func timeZoneAdjustment() -> Int {
        let timeZoneFormatter = DateFormatter()
        timeZoneFormatter.timeZone = NSTimeZone.local
        timeZoneFormatter.dateFormat = "Z"
        return (Int(timeZoneFormatter.string(from: Date()))! * 60 * 60 / 100)
    }
    
    func replaceFiveDayWeather(forageSpot: ForageSpot) {
        let weatherData = Array(forageSpot.weatherHistory as? Set<WeatherHistory> ?? []).sorted(by: { $0.dateTime! > $1.dateTime! })
        for day in weatherData {
            deleteWeatherHistory(weather: day)
        }
        getFiveDayWeather(forageSpot: forageSpot)
    }
    
    func updateAllWeatherHistory() {
        let fetchRequest: NSFetchRequest<ForageSpot> = ForageSpot.fetchRequest()
        do {
            let forageSpots = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            guard !forageSpots.isEmpty else { return }
            for spot in forageSpots {
                updateFiveDayWeather(forageSpot: spot)
            }
        } catch {
            NSLog("Unable to fetch ForageSpots")
        }
    }
    
    func setFavorabilityScore(forageSpot: ForageSpot) {
        guard let weatherHistory = forageSpot.weatherHistory else { return }
        let weather = Array(weatherHistory) as! [WeatherHistory]
        guard weather.count > 3 else {
            forageSpot.favorability = 0
            return
        }
        
        var score: Double = 0
        
        var totalRain: Double = 0
        for day in weather {
            totalRain += day.totalRain
        }
        
        switch totalRain {
        case 0.5..<2:
            score += 3
        case 2..<4:
            score += 4
        case 4...100:
            score += 5
        default:
            break
        }
        
        var earlyRain: Double = 0
        var earlierDays = weather.sorted(by: { $0.dateTime! > $1.dateTime! })
        earlierDays.remove(at: 0)
        earlierDays.remove(at: 0)
        for day in earlierDays {
            earlyRain += day.totalRain
        }
        
        if earlyRain > (totalRain / 2) {
            score += 2
        } else {
            score -= 1
        }
        
        let averageTemperature = (weather.map { Int($0.temperatureHigh) }).reduce(0, +) / weather.count
        switch averageTemperature {
        case -100...32:
            score = 1
        case 51...69:
            score += 1
        case 70...85:
            score += 5
        case 86...95:
            score += 2
        case 96...150:
            score -= 3
        default:
            break
        }
        
        if score < 1 {
            score = 1
        } else if score > 10 {
            score = 10
        }
        
        forageSpot.favorability = score
    }
    
    // MARK: - Note Functions
    
    func addNote(forageSpot: ForageSpot, body: String, photo: String, completion: @escaping (Bool) -> Void) {
        let note = Note(body: body, photo: photo)
        forageSpot.addToNotes(note)
        let result = saveMOC()
        completion(result)
    }
    
    func editNote(note: Note, newBody: String, newPhoto: String, completion: @escaping (Bool) -> Void) {
        note.body = newBody
        note.photo = newPhoto
        let result = saveMOC()
        completion(result)
    }
    
    func deleteNote(note: Note, completion: @escaping (Bool) -> Void) {
        moc.delete(note)
        let result = saveMOC()
        completion(result)
    }
    
    // MARK: - Image Functions

    // MARK: - Private Functions
    
    @discardableResult private func saveMOC() -> Bool {
        do {
            try moc.save()
            return true
        } catch {
            moc.reset()
            NSLog("Error saving managed object context: \(error)")
            return false
        }
    }
    
}
