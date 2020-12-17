//
//  ForageCell.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/16/20.
//

import UIKit

class ForageCell: UICollectionViewCell {
    
    // MARK: UI Elements
    
    private var nameLabel = UILabel()
    private var imageView = UIImageView()
    
    // MARK: - Properties
        
//    var forageSpot: ForageSpot? {
//        didSet {
//            updateViews()
//        }
//    }
    
    // MARK: - Override Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        imageView.image = nil
    }
    
    // MARK: - Private Functions
    
    private func updateViews() {
//        guard let forageSpot = forageSpot else { return }
//        nameLabel.text = forageSpot.name
//        imageView.image = forageSpot.image
    }
    
    private func setUpView() {
        backgroundColor = .white
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(nameLabel)
        nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        imageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -5).isActive = true
    }
    
}
