//
//  ImageVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/6/21.
//

import UIKit

protocol ImageDelegate: AnyObject {
    func imageWasSaved()
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
        // need function to save image
        // check whether it is for forageSpot or note
        // use delegate.imageWasSaved - needs implementation in DetailVC and AddNoteVC
        errorAlert()
    }
    
    // MARK: - Private Functions
    
    private func setUpView() {
        view.backgroundColor = .white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.text = "Update Image"
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
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
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: titleInfoLabel.bottomAnchor, constant: 30).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        imageView.image = UIImage(named: "Mushroom")
        
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
        button.backgroundColor = .brown
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
