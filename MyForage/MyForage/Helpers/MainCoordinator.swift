//
//  MainCoordinator.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit

class MainCoordinator: Coordinator {
    
    var tabBarController: UITabBarController
    var collectionNav = UINavigationController(rootViewController: CollectionVC.instantiate())
    var mapVC = MapVC.instantiate()
    var homeVC = HomeVC.instantiate()

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    func start() {
        setUpAppNavViews()
        passDependencies()
    }
    
    private func setUpAppNavViews() {
        tabBarController.setViewControllers([homeVC, collectionNav, mapVC], animated: false)
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: nil, tag: 0)
        collectionNav.tabBarItem = UITabBarItem(title: "Forage Spots", image: nil, tag: 1)
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: nil, tag: 2)
    }
    
    private func passDependencies() {
        guard let collectionVC = collectionNav.topViewController as? CollectionVC else { return }
        collectionVC.coordinator = self
        mapVC.coordinator = self
        homeVC.coordinator = self
    }
}
