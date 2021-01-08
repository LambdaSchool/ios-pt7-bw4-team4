//
//  EditMenuView.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/8/21.
//

import SwiftUI

protocol EditDelegate: AnyObject {
    func didSelectOption(editOption: EditOption)
}

enum EditOption {
    case editForageSpot
    case updateImage
    case addNote
    case deleteForageSpot
    case cancel
}

struct EditMenuView: View {
    
    weak var delegate: EditDelegate?
    
    init(delegate: EditDelegate?) {
        self.delegate = delegate
    }
    
    var body: some View {
        VStack {
            Text("Editing Options")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 30)
                .padding(.bottom, 10)
            
            Button(action: editForageSpot, label: {
                Text("Edit Forage Spot")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color.green)
            })
            
            Button(action: updateImage, label: {
                Text("Update Image")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color.green)
            })
            
            Button(action: addNote, label: {
                Text("Add Note")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color.green)
            })
            .padding(.bottom, 10)
            
            Button(action: delete, label: {
                Text("Delete Forage Spot")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color.red)
            })
            .padding(.bottom, 10)
            
            Button(action: cancel, label: {
                Text("Cancel")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color.blue)
            })
            .padding(.bottom, 30)
        }
        .background(Color.white)
    }
    
    func editForageSpot() {
        delegate?.didSelectOption(editOption: .editForageSpot)
    }
    
    func updateImage() {
        delegate?.didSelectOption(editOption: .updateImage)
    }
    
    func addNote() {
        delegate?.didSelectOption(editOption: .addNote)
    }
    
    func delete() {
        delegate?.didSelectOption(editOption: .deleteForageSpot)
    }
    
    func cancel() {
        delegate?.didSelectOption(editOption: .cancel)
    }

}

struct EditMenuView_Previews: PreviewProvider {
    static var previews: some View {
        EditMenuView(delegate: nil)
    }
}
