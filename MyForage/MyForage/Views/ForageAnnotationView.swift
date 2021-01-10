//
//  ForageAnnotationView.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/16/20.
//

import UIKit
import MapKit
import CoreData

class ForageAnnotationView: UIView {
    
    // MARK: - UI Elements
    
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let backgroundView = UIView()
    
    // MARK: - Properties
    
    var coordinator: MainCoordinator?
    var forageAnnotation: ForageAnnotation? {
        didSet {
            updateSubviews()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = appColor.cream
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let forageAnnotation = forageAnnotation else { return }
        let fetchRequest: NSFetchRequest<ForageSpot> = ForageSpot.fetchRequest()
        let idString = forageAnnotation.identifier.uuidString
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", idString)
        do {
            if let forageSpot = try CoreDataStack.shared.mainContext.fetch(fetchRequest).first {
                coordinator?.presentDetailView(forageSpot: forageSpot)
            }
        } catch {
            NSLog("Unable to fetch forage spot")
        }
    }
    
    private func updateSubviews() {
        guard let forageAnnotation = forageAnnotation else { return }
        titleLabel.text = forageAnnotation.name
        if let imageData = forageAnnotation.imageData {
            imageView.image = UIImage(data: imageData)
        } else {
            imageView.image = UIImage(named: "Mushroom")
        }
        
        switch forageAnnotation.favorability {
        case 0..<3:
            backgroundColor = appColor.red
        case 3..<6:
            backgroundColor = appColor.orange
        case 6..<9:
            backgroundColor = appColor.lightGreen
        case 9...10:
            backgroundColor = appColor.mediumGreen
        default:
            backgroundColor = appColor.gray
        }
    }

}
