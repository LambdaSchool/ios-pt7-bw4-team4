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
