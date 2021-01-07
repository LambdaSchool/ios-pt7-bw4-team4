//
//  ModelController.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/6/21.
//

import Foundation

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
        saveMOC()
    }
    
    func getFiveDayWeather(forageSpot: ForageSpot){
        var dateArray: [String] = []
        let timeInterval = Int(Date().timeIntervalSince1970)
        for x in 1...5 {
            let dateString = String(timeInterval - (86400 * x))
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
