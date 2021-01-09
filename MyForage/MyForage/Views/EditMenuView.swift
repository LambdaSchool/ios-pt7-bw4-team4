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
                .foregroundColor(Color("CharcoalColor"))
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 30)
                .padding(.bottom, 10)
            
            Button(action: editForageSpot, label: {
                Text("Edit Forage Spot")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("CreamColor"))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color("LightGreenColor"))
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            
            Button(action: updateImage, label: {
                Text("Update Image")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("CreamColor"))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color("LightGreenColor"))
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            
            Button(action: addNote, label: {
                Text("Add Note")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("CreamColor"))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color("LightGreenColor"))
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            .padding(.bottom, 10)
            
            Button(action: delete, label: {
                Text("Delete Forage Spot")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("CreamColor"))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color("RedColor"))
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            .padding(.bottom, 10)
            
            Button(action: cancel, label: {
                Text("Cancel")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("CreamColor"))
                    .padding(10)
                    .frame(width: 280)
                    .background(Color("MediumGreenColor"))
                    .cornerRadius(15)
                    .shadow(radius: 8, x: 3, y: 3)
            })
            .padding(20)
        }
        .background(Color("CreamColor"))
        .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("MediumGreenColor"), lineWidth: 6)
            )
        .cornerRadius(20)
        .shadow(radius: 8, x: 3, y: 3)
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
