//
//  DetailVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import SwiftUI

class DetailVC: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    var forageSpot: ForageSpot!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = forageSpot.name
    }

}
