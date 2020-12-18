//
//  MainCoordinator.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit

class MainCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var tabBarController: UITabBarController
    var collectionNav = UINavigationController(rootViewController: CollectionVC())
    var mapVC = MapVC()
    var homeVC = HomeVC()

    // MARK: - Lifecycle
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    func start() {
        setUpAppNavViews()
        passDependencies()
    }
    
    // MARK: - Functions
    
    func presentDetailViewFromCollection(forageSpot: ForageSpot) {
        let detailVC = DetailVC()
        detailVC.coordinator = self
        // pass ForageSpot
        collectionNav.pushViewController(detailVC, animated: true)
    }
    
    func presentDetailViewFromMap(forageSpot: ForageSpot) {
        let detailVC = DetailVC()
        detailVC.coordinator = self
        // pass ForageSpot
        tabBarController.present(detailVC, animated: true, completion: nil)
    }
    
    func presentAddForageVC() {
        let addForageVC = AddForageVC()
        addForageVC.coordinator = self
        collectionNav.pushViewController(addForageVC, animated: true)
    }
    
    func presentFilterView() {
        
    }
    
    // MARK: - Private Functions
    
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
