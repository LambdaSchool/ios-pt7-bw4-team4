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
        imageView.image = UIImage(named: "Mushroom")
        // need func to fetch image with urlString
    }
    
    private func setUpView() {
        backgroundColor = .white
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.backgroundColor = .white
        contentView.addSubview(dateLabel)
        dateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
    }
    
}
