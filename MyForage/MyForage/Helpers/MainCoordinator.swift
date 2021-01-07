//
//  MainCoordinator.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit
import CoreData

@objcMembers
class MainCoordinator: NSObject, Coordinator {
    
    // MARK: - Properties
    
    var apiController = ApiController()
    var modelController = ModelController()
    var tabBarController: UITabBarController
    var collectionNav = UINavigationController(rootViewController: CollectionVC())
    var mapVC = MapVC()
    var homeVC: HomeVC!

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
        detailVC.forageSpot = forageSpot
        detailVC.isModal = false
        collectionNav.pushViewController(detailVC, animated: true)
    }
    
    @objc
    func presentDetailView(forageSpot: ForageSpot) {
        let detailVC = DetailVC()
        detailVC.coordinator = self
        detailVC.forageSpot = forageSpot
        detailVC.isModal = true
        tabBarController.present(detailVC, animated: true, completion: nil)
    }
    
    func presentAddForageVC() {
        let addForageVC = AddForageVC()
        addForageVC.coordinator = self
        addForageVC.editMode = false
        collectionNav.present(addForageVC, animated: true, completion: nil)
    }
    
    func presentEditForageVC(forageSpot: ForageSpot) {
        let editForageVC = AddForageVC()
        editForageVC.coordinator = self
        editForageVC.forageSpot = forageSpot
        editForageVC.editMode = true
        collectionNav.present(editForageVC, animated: true, completion: nil)
    }
    
    func presentAddNoteVC(forageSpot: ForageSpot, delegate: NoteDelegate) {
        let addNoteVC = AddNoteVC()
        addNoteVC.coordinator = self
        addNoteVC.forageSpot = forageSpot
        addNoteVC.delegate = delegate
        collectionNav.present(addNoteVC, animated: true, completion: nil)
    }
    
    func presentEditNoteVC(note: Note, delegate: NoteDelegate) {
        let editNoteVC = AddNoteVC()
        editNoteVC.coordinator = self
        editNoteVC.note = note
        editNoteVC.delegate = delegate
        editNoteVC.editMode = true
        collectionNav.pushViewController(editNoteVC, animated: true)
    }
    
    func presentImageVC(forageSpot: ForageSpot?, note: Note?, delegate: ImageDelegate) {
        let imageVC = ImageVC()
        imageVC.coordinator = self
        imageVC.delegate = delegate
        if let forageSpot = forageSpot {
            imageVC.forageSpot = forageSpot
        } else if let note = note {
            imageVC.note = note
        }
        collectionNav.present(imageVC, animated: true, completion: nil)
    }
    
    func presentFilterView() {
        
    }
    
    @objc
    func fetchForageSpots() -> [ForageSpot] {
        var forageSpots: [ForageSpot] = []
        let fetchRequest: NSFetchRequest<ForageSpot> = ForageSpot.fetchRequest()
        do {
            forageSpots = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
        } catch {
            NSLog("Unable to fetch ForageSpots")
        }
        return forageSpots.sorted(by: { $0.favorability > $1.favorability })
    }
    
    // MARK: - Private Functions
    
    private func setUpAppNavViews() {
        homeVC = HomeVC(coordinator: self)
        tabBarController.setViewControllers([homeVC, collectionNav, mapVC], animated: false)
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: nil, tag: 0)
        collectionNav.tabBarItem = UITabBarItem(title: "Forage Spots", image: nil, tag: 1)
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: nil, tag: 2)
    }
    
    private func passDependencies() {
        guard let collectionVC = collectionNav.topViewController as? CollectionVC else { return }
        collectionVC.coordinator = self
        mapVC.coordinator = self
        modelController.coordinator = self
    }
}
