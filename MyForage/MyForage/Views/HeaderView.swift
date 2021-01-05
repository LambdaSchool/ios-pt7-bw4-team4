//
//  HeaderView.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/20/20.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    private var titleLabel = UILabel()
    
    func setUpView() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.textColor = UIColor.white
        titleLabel.adjustsFontForContentSizeCategory = true
    }
    
    func configureHeader(sectionType: AnyHashable) {
        setUpView()
        if let header = sectionType as? WeatherSection {
            titleLabel.text = header.sectionTitle
        }
        
        if let header = sectionType as? NotesSection {
            titleLabel.text = header.sectionTitle
        }
    }
    
}
