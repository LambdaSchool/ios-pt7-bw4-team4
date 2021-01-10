//
//  ImageVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/6/21.
//

import UIKit

protocol ImageDelegate: AnyObject {
    func imageWasSaved()
    func imageWasAddedToNewNote(imageData: Data)
}

class ImageVC: UIViewController {
    
    // MARK: - UI Elements
    
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var titleInfoLabel = UILabel()
    private var chooseImageButton = UIButton()
    private var saveButton = UIButton()
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    weak var delegate: ImageDelegate?
    var forageSpot: ForageSpot?
    var note: Note?

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - Actions
    
    @objc func chooseImage() {
        presentImagePickerController()
    }
    
    @objc func saveImage() {
        if let imageData = imageView.image?.pngData() {
            if forageSpot == nil && note == nil {
                let alert = UIAlertController(title: "Image Added", message: nil, preferredStyle: .alert)
                let button = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.delegate?.imageWasAddedToNewNote(imageData: imageData)
                })
                alert.addAction(button)
                self.present(alert, animated: true)
            } else {
                coordinator?.modelController.saveImage(data: imageData, forageSpot: forageSpot, note: note, completion: { result in
                    switch result {
                    case true:
                        let alert = UIAlertController(title: "Image Saved", message: nil, preferredStyle: .alert)
                        let button = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                            self.delegate?.imageWasSaved()
                        })
                        alert.addAction(button)
                        self.present(alert, animated: true)
                    case false:
                        self.errorAlert()
                    }
                })
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func setUpView() {
        view.backgroundColor = appColor.cream
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.text = "Update Image"
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = appColor.red
        titleLabel.shadowColor = appColor.gray
        titleLabel.shadowOffset = CGSize(width: 0.5, height: 1)
        
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleInfoLabel)
        if let forageSpot = forageSpot,
           let name = forageSpot.name {
            titleInfoLabel.text = "for \(name)"
        } else if let note = note,
                  let date = note.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: date)
            titleInfoLabel.text = "for Note from \(dateString)"
        }
        titleInfoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        titleInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleInfoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleInfoLabel.textColor = appColor.mediumGreen
        titleInfoLabel.shadowColor = appColor.darkGreen
        titleInfoLabel.shadowOffset = CGSize(width: 0.5, height: 1)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: titleInfoLabel.bottomAnchor, constant: 30).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        imageView.image = UIImage(named: "Mushroom")
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = appColor.mediumGreen.cgColor
        
        setUpButton(chooseImageButton, text: "Choose Image")
        chooseImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30).isActive = true
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        
        setUpButton(saveButton, text: "Save Image")
        saveButton.topAnchor.constraint(equalTo: chooseImageButton.bottomAnchor, constant: 30).isActive = true
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
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
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            errorLibraryAlert()
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func errorLibraryAlert() {
        let alert = UIAlertController(title: "Error", message: "The photo library is unavailable.", preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
    
    private func errorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong - please try again.", preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true)
    }

}

extension ImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
        } else if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
