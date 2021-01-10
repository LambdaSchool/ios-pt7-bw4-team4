//
//  NoteCell.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/20/20.
//

import UIKit

class NoteCell: UICollectionViewCell {
        
    // MARK: UI Elements
    
    private var dateLabel = UILabel()
    private var imageView = UIImageView()
    
    // MARK: - Properties
        
    var note: Note? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Override Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        imageView.image = nil
    }
    
    // MARK: - Private Functions
    
    private func updateViews() {
        guard let note = note,
              let date = note.date else { return }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
        if let imageData = note.imageData?.img {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imageData)
            }
        } else {
            imageView.image = UIImage(named: "Mushroom")
        }
    }
    
    private func setUpView() {
        backgroundColor = appColor.cream
        
        layer.cornerRadius = 8
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowColor = appColor.gray.cgColor
        layer.shadowOpacity = 0.7
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.backgroundColor = appColor.lightGreen
        contentView.addSubview(dateLabel)
        dateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        dateLabel.layer.cornerRadius = 8
        dateLabel.layer.shadowRadius = 5
        dateLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        dateLabel.layer.shadowColor = appColor.gray.cgColor
        dateLabel.layer.shadowOpacity = 0.7
        dateLabel.layer.masksToBounds = true
    }
    
}
