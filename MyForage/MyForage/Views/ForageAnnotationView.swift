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
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        titleLabel.adjustsFontSizeToFitWidth = true
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
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
        imageView.image = UIImage(named: "Mushroom")
        // need func to fetch image with urlString
        
        switch forageAnnotation.favorability {
        case 0..<3:
            backgroundColor = .systemRed
        case 3..<5:
            backgroundColor = .systemOrange
        case 5..<7:
            backgroundColor = .systemYellow
        case 7...10:
            backgroundColor = .systemGreen
        default:
            backgroundColor = .systemGray
        }
    }

}
