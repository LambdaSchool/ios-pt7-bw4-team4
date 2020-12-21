//
//  CollectionVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit
import CoreData

class CollectionVC: UIViewController {
    
    // TODO:
    // Create filter and sort functions

    
    // MARK: - UI Elements
    
    private var addButton: UIBarButtonItem!
    private var filterButton: UIBarButtonItem!
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    
    var sorters: [NSSortDescriptor] = [NSSortDescriptor(key: "name", ascending: true)]
    var predicate: NSPredicate?
    
    private var datasource: UICollectionViewDiffableDataSource<Int, ForageSpot>!
    private var fetchedResultsController: NSFetchedResultsController<ForageSpot>!
    private let moc = CoreDataStack.shared.mainContext

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureDatasource()
        initFetchedResultsController()
    }
    
    // MARK: - Private Functions
    
    private func setUpView() {
        title = "My Forage Spots"
        
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVC))
        navigationItem.rightBarButtonItem = addButton
        
        filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterVC))
        navigationItem.leftBarButtonItem = filterButton
        
        let view = UIView()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 120, height: 140)
                
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView?.register(ForageCell.self, forCellWithReuseIdentifier: ReuseIdentifier.forageCell)
        collectionView?.backgroundColor = .white
        collectionView.delegate = self
        
        view.addSubview(collectionView ?? UICollectionView())
        self.view = view
    }
    
    @objc private func addVC() {
        coordinator?.presentAddForageVC()
    }
    
    @objc private func filterVC() {
        coordinator?.presentFilterView()
    }
    
    private func configureDatasource() {
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, forageSpot) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.forageCell, for: indexPath) as? ForageCell else { fatalError("Cannot create cell") }
            cell.forageSpot = forageSpot
            return cell
        })
    }
    
    private func initFetchedResultsController() {
        let fetchRequest: NSFetchRequest<ForageSpot> = ForageSpot.fetchRequest()
        fetchRequest.sortDescriptors = sorters
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            NSLog("Unable to fetch forage collection from main context: \(error)")
        }
    }

}

extension CollectionVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, ForageSpot>()
            diffableDataSourceSnapshot.appendSections([0])
            diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
            datasource?.apply(diffableDataSourceSnapshot, animatingDifferences: view.window != nil)
    }
}

extension CollectionVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedSpot = datasource.itemIdentifier(for: indexPath) else { return }
        coordinator?.presentDetailViewFromCollection(forageSpot: selectedSpot)
    }
}
