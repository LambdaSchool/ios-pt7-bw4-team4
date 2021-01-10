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
    var filterViewModel = FilterViewModel()

    // MARK: - Lifecycle
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    func start() {
        setUpAppNavViews()
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
    
    func presentEditForageVC(forageSpot: ForageSpot, delegate: ForageDelegate) {
        let editForageVC = AddForageVC()
        editForageVC.coordinator = self
        editForageVC.forageSpot = forageSpot
        editForageVC.delegate = delegate
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
    
    func presentEditNoteVC(note: Note, delegate: NoteDelegate, isModal: Bool) {
        let editNoteVC = AddNoteVC()
        editNoteVC.coordinator = self
        editNoteVC.note = note
        editNoteVC.delegate = delegate
        editNoteVC.editMode = true
        if isModal {
            if let detail = mapVC.presentedViewController {
                detail.present(editNoteVC, animated: true)
            }
        } else {
            collectionNav.show(editNoteVC, sender: nil)
        }
    }
    
    func presentImageVC(forageSpot: ForageSpot?, note: Note?, delegate: ImageDelegate, presentingVC: UIViewController) {
        let imageVC = ImageVC()
        imageVC.coordinator = self
        imageVC.delegate = delegate
        if let forageSpot = forageSpot {
            imageVC.forageSpot = forageSpot
        } else if let note = note {
            imageVC.note = note
        }
        presentingVC.present(imageVC, animated: true, completion: nil)
    }
    
    func presentFilterView() {
        let filterHC = FilterHC(coordinator: self, contentView: FilterView().environmentObject(filterViewModel))
        collectionNav.present(filterHC, animated: true)
    }
    
    func presentEditMenu(delegate: EditDelegate) {
        let editMenuHC = FilterHC(coordinator: self, contentView: EditMenuView(delegate: delegate))
        collectionNav.present(editMenuHC, animated: true, completion: nil)
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
        
        let splashHC = SplashScreenHC(coordinator: self, contentView: SplashScreen())
        tabBarController.setViewControllers([splashHC], animated: true)
        tabBarController.tabBar.backgroundImage = UIImage()
        tabBarController.tabBar.shadowImage = UIImage()
        
        modelController.coordinator = self
        modelController.updateAllWeatherHistory()
        homeVC = HomeVC(coordinator: self)
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.tabBarController.tabBar.backgroundImage = nil
            self.tabBarController.tabBar.barTintColor = appColor.lightGreen
            self.tabBarController.tabBar.tintColor = appColor.red
            self.tabBarController.tabBar.unselectedItemTintColor = appColor.darkGreen
            
            self.collectionNav.navigationBar.barTintColor = appColor.lightGreen
            self.collectionNav.navigationBar.tintColor = appColor.darkGreen
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : appColor.red]
            
            self.tabBarController.setViewControllers([self.homeVC, self.collectionNav, self.mapVC], animated: false)
            self.homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
            self.collectionNav.tabBarItem = UITabBarItem(title: "My Forage Spots", image: UIImage(named: "TabBarMushroom"), tag: 1)
            self.mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map.fill"), tag: 2)
            
            self.mapVC.coordinator = self
            guard let collectionVC = self.collectionNav.topViewController as? CollectionVC else { return }
            collectionVC.coordinator = self
            self.filterViewModel.delegate = collectionVC
        }
    }
    
}
