//
//  AddNoteVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/4/21.
//

import UIKit

protocol NoteDelegate: AnyObject {
    func noteWasSaved()
    func imageWasAddedToNote()
}

class AddNoteVC: UIViewController {
    
    // MARK: - UI Elements
    
    private var bodyTextView = UITextView()
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var saveButton = UIButton()
    private var editButton = UIButton()
    private var deleteButton = UIButton()
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    weak var delegate: NoteDelegate?
    var forageSpot: ForageSpot!
    var note: Note?
    var newImageData: Data?
    var editMode: Bool = false

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - Actions
    
    @objc func saveNote() {
        guard let body = bodyTextView.text,
              body != "" else {
            let alert = UIAlertController(title: "Error", message: "Note must have a text body to be saved.", preferredStyle: .alert)
            let button = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(button)
            self.present(alert, animated: true)
            return
        }
        if editMode {
            guard let note = note else { return }
            coordinator?.modelController.editNote(note: note, newBody: body, completion: { result in
                switch result {
                case true:
                    let alert = UIAlertController(title: "Note Saved", message: nil, preferredStyle: .alert)
                    let button = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                        self.delegate?.noteWasSaved()
                        self.coordinator?.collectionNav.popViewController(animated: true)
                    })
                    alert.addAction(button)
                    self.present(alert, animated: true)
                case false:
                    self.errorAlert()
                }
            })
        } else {
            coordinator?.modelController.addNote(forageSpot: forageSpot, body: body, completion: { note in
                if let imageData = self.newImageData {
                    self.coordinator?.modelController.saveImage(data: imageData, forageSpot: nil, note: note, completion: { result in
                        switch result {
                        case true:
                            self.successAlertDismiss()
                        case false:
                            self.errorAlert()
                        }
                    })
                } else {
                    self.successAlertDismiss()
                }
            })
        }
    }
    
    @objc func startEditing() {
        bodyTextView.isUserInteractionEnabled = true
        editButton.isHidden = true
        
        setUpButton(saveButton, text: "Save Changes")
        saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        saveButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -35).isActive = true
        
        
        setUpButton(deleteButton, text: "Delete Note")
        deleteButton.addTarget(self, action: #selector(deleteNote), for: .touchUpInside)
        deleteButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -35).isActive = true
    }
    
    @objc func deleteNote() {
        guard let note = note else { return }
        coordinator?.modelController.deleteNote(note: note, completion: { result in
            switch result {
            case true:
                let alert = UIAlertController(title: "Note Deleted", message: nil, preferredStyle: .alert)
                let button = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.delegate?.noteWasSaved()
                    self.coordinator?.collectionNav.popViewController(animated: true)
                })
                alert.addAction(button)
                self.present(alert, animated: true)
            case false:
                self.errorAlert()
            }
        })
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if let note = note {
            coordinator?.presentImageVC(forageSpot: nil, note: note, delegate: self, presentingVC: self)
        } else {
            coordinator?.presentImageVC(forageSpot: nil, note: nil, delegate: self, presentingVC: self)
        }
    }
    
    // MARK: - Private Functions
    
    private func setUpView() {
        view.backgroundColor = appColor.cream
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = appColor.red
        titleLabel.shadowColor = appColor.gray
        titleLabel.shadowOffset = CGSize(width: 0.5, height: 1)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Mushroom")
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.layer.borderWidth = 2.5
        bodyTextView.layer.borderColor = appColor.mediumGreen.cgColor
        bodyTextView.layer.cornerRadius = 15
        view.addSubview(bodyTextView)
        bodyTextView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        bodyTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        if editMode {
            guard let note = note,
                  let date = note.date,
                  let body = note.body else { return }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: date)
            titleLabel.text = "Note from \(dateString)"
            bodyTextView.text = body
            bodyTextView.isUserInteractionEnabled = false
            if let imageData = note.imageData?.img {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imageData)
                }
            } else {
                imageView.image = UIImage(named: "Mushroom")
            }
            
            setUpButton(editButton, text: "Edit Note")
            editButton.addTarget(self, action: #selector(startEditing), for: .touchUpInside)
            editButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20).isActive = true
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            editButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -30).isActive = true
            
        } else {
            guard let name = forageSpot?.name else { return }
            titleLabel.text = "Add Note for \(name)"
            
            setUpButton(saveButton, text: "Save")
            saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
            saveButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20).isActive = true
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -30).isActive = true
        }
    }
    
    private func setUpButton(_ button: UIButton, text: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.backgroundColor = appColor.mediumGreen
        button.setTitleColor(.white, for: .normal)
        view.addSubview(button)
    }
    
    private func errorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong - please try again.", preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
    
    private func successAlertDismiss() {
        let alert = UIAlertController(title: "Note Saved", message: nil, preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            self.delegate?.noteWasSaved()
            self.coordinator?.collectionNav.dismiss(animated: true, completion: nil)
        })
        alert.addAction(button)
        self.present(alert, animated: true)
    }

}

extension AddNoteVC: ImageDelegate {
    func imageWasSaved() {
        self.dismiss(animated: true, completion: nil)
        if let imageData = note?.imageData?.img {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imageData)
            }
        }
        delegate?.imageWasAddedToNote()
    }
    
    func imageWasAddedToNewNote(imageData: Data) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.imageView.image = UIImage(data: imageData)
        }
        newImageData = imageData
        delegate?.imageWasAddedToNote()
    }
}
