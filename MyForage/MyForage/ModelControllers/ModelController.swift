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

    // MARK: - Forage Spot Functions
    
    func addForageSpot(name: String, typeString: String, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        guard let type = MushroomType(rawValue: typeString) else { return }
        ForageSpot(mushroomType: type, latitude: latitude, longitude: longitude, name: name)
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
    
    private func saveMOC() -> Bool {
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
