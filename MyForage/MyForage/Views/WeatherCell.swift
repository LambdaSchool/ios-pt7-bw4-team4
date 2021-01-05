//
//  WeatherCell.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/20/20.
//

import UIKit

class WeatherCell: UICollectionViewCell {
        
    // MARK: UI Elements
    
    private var tempLabel = UILabel()
    private var rainLabel = UILabel()
    private var rainDrop = UIImageView()
    private var thermometer = UIImageView()
    
    // MARK: - Properties
        
    var weather: WeatherDay? {
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
        tempLabel.text = ""
        rainLabel.text = ""
    }
    
    // MARK: - Private Functions
    
    private func updateViews() {
        guard let weather = weather else { return }
        tempLabel.text = "\(weather.temperature)°F"
        rainLabel.text = "\(weather.precipitation)\""
    }
    
    private func setUpView() {
        backgroundColor = .white
        
        rainDrop.translatesAutoresizingMaskIntoConstraints = false
        rainDrop.image = UIImage(systemName: "drop.fill")
        contentView.addSubview(rainDrop)
        rainDrop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        rainDrop.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        rainDrop.widthAnchor.constraint(equalToConstant: 20).isActive = true
        rainDrop.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        thermometer.translatesAutoresizingMaskIntoConstraints = false
        thermometer.image = UIImage(systemName: "thermometer")
        contentView.addSubview(thermometer)
        thermometer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        thermometer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        thermometer.widthAnchor.constraint(equalToConstant: 20).isActive = true
        thermometer.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tempLabel)
        tempLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        tempLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        
        rainLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rainLabel)
        rainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        rainLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
}
