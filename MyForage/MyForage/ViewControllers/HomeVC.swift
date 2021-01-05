//
//  HomeVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit

class HomeVC: UIViewController {
    
    weak var coordinator: MainCoordinator?
    private let apiController = ApiController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        apiController.getWeatherHistory(latitude: "30.43826", longitude: "-84.28073", dateTime: "1609470833")
        // Do any additional setup after loading the view.
    }

}
