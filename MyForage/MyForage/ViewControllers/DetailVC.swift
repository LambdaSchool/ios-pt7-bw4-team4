//
//  DetailVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit
import MapKit

struct Section<HeaderItem: Hashable, SectionItems: Hashable>: Hashable {
    let headerItem: HeaderItem
    let sectionItems: SectionItems
}

struct DataSource<Section: Hashable> {
    let sections: [Section]
}

class WeatherDay: Hashable {
    var precipitation: Double
    var temperature: Int
    
    init(precipitation: Double, temperature: Int) {
        self.precipitation = precipitation
        self.temperature = temperature
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: WeatherDay, rhs: WeatherDay) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    private let identifier = UUID()
}

class WeatherSection: Hashable {
    var sectionTitle = "Recent Weather"
    var weatherDays: [WeatherDay]
    
    // Replace dummy data with weatherHistory.oneDayAgo.precipitation, etc.
//    init(weatherHistory: WeatherHistory) {
    init() {
        let dayOne = WeatherDay(precipitation: 1.5, temperature: 55)
        let dayTwo = WeatherDay(precipitation: 1, temperature: 60)
        let dayThree = WeatherDay(precipitation: 0, temperature: 65)
        let dayFour = WeatherDay(precipitation: 0, temperature: 63)
        let dayFive = WeatherDay(precipitation: 0.5, temperature: 58)
        
        self.weatherDays = [dayOne, dayTwo, dayThree, dayFour, dayFive]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: WeatherSection, rhs: WeatherSection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    private let identifier = UUID()
}

class NotesSection: Hashable {
    var sectionTitle = "Notes"
    var notes: [Note]
        
    init(notes: [Note]) {
        self.notes = notes.sorted(by: { $0.date! < $1.date! })
    }
     
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: NotesSection, rhs: NotesSection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    private let identifier = UUID()
}

class DetailVC: UIViewController {
    
    // MARK: - UI Elements
    
    private var editButton: UIBarButtonItem?
    private var titleLabel = UILabel()
    private var typeLabel = UILabel()
    private var imageView = UIImageView()
    private var mapView = MKMapView()
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    var isModal: Bool = false
    var forageSpot: ForageSpot!
    
    fileprivate let locationManager = CLLocationManager()
    private var span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    private var foragePin = MKPointAnnotation()
    
    private var datasource: UICollectionViewDiffableDataSource<Section<AnyHashable, [AnyHashable]>, AnyHashable>!

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureCollectionView()
    }
    
    // MARK: - Actions
    
    @objc func editActionSheet() {
        let actionSheet = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Edit Forage Spot", style: .default, handler: { _ in
            self.coordinator?.presentEditForageVC(forageSpot: self.forageSpot)
        }))
        actionSheet.addAction(UIAlertAction(title: "Update Image", style: .default, handler: { _ in
            // Add functionality to change image
        }))
        actionSheet.addAction(UIAlertAction(title: "Add a Note", style: .default, handler: { _ in
            self.coordinator?.presentAddNoteVC(forageSpot: self.forageSpot, delegate: self)
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete Forage Spot", style: .destructive, handler: { _ in
            let moc = CoreDataStack.shared.mainContext
            moc.delete(self.forageSpot)
            do {
                try moc.save()
                self.coordinator?.collectionNav.popViewController(animated: true)
            } catch {
                moc.reset()
                NSLog("Error saving managed object context: \(error)")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func mapTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        view.bringSubviewToFront(mapView)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        view.bringSubviewToFront(imageView)
    }

    // MARK: - Private Functions
    
    private func configureCollectionView() {
        let frame = CGRect(x: 20, y: (view.frame.height / 2), width: (view.frame.width - 40), height: ((view.frame.height / 2) - 60))
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout())
        collectionView?.register(WeatherCell.self, forCellWithReuseIdentifier: ReuseIdentifier.weatherCell)
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: ReuseIdentifier.noteCell)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReuseIdentifier.headerView)
        collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ReuseIdentifier.footerView)
        collectionView?.backgroundColor = .blue
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        configureDatasource()
        configureSupplementaryView()
        populateCollectionView()
    }
    
    private func layout() -> UICollectionViewLayout {
            let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
                let sectionType = self.datasource?.snapshot().sectionIdentifiers[sectionIndex].headerItem
                if sectionType is WeatherSection {
                    return self.weatherSectionLayout()
                }
                if sectionType is NotesSection {
                    return self.notesSectionLayout()
                }
                return nil
            }
            return layout
        }
    
    private func weatherSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(85))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        sectionLayout.interGroupSpacing = 20
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 40)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(35))
        
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(2))
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom)
        
        sectionLayout.boundarySupplementaryItems = [headerSupplementary, sectionFooter]
        
        return sectionLayout
    }
    
    private func notesSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        sectionLayout.interGroupSpacing = 20
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 40)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(30))
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionLayout.boundarySupplementaryItems = [headerSupplementary]
        
        return sectionLayout
    }
    
    private func configureDatasource() {
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            if let weather = item as? WeatherDay {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.weatherCell, for: indexPath) as? WeatherCell else { fatalError("Cannot create cell")
                }
                cell.weather = weather
                return cell
            } else if let note = item as? Note {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.noteCell, for: indexPath) as? NoteCell else {
                    fatalError("Cannot create cell")
                }
                cell.note = note
                return cell
            }
            return nil
        })
    }
    
    private func configureSupplementaryView() {
        datasource?.supplementaryViewProvider = { (collectionView: UICollectionView,
                                                   kind: String,
                                                   indexPath: IndexPath) -> UICollectionReusableView? in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: ReuseIdentifier.headerView,
                        for: indexPath) as? HeaderView else { return UICollectionReusableView() }
                headerView.configureHeader(sectionType: (self.datasource?.snapshot().sectionIdentifiers[indexPath.section].headerItem)!)
                return headerView
            default:
                guard let footerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionFooter,
                        withReuseIdentifier: ReuseIdentifier.footerView,
                        for: indexPath) as? FooterView else { return UICollectionReusableView() }
                return footerView
            }
        }
    }
    
    private func populateCollectionView() {
        var sections: [Section<AnyHashable, [AnyHashable]>] = []
//        if let weatherhistory = forageSpot.weatherHistory {
            let weatherSection = WeatherSection()
            sections.append(Section(headerItem: weatherSection, sectionItems: weatherSection.weatherDays))
//        }
        if let notes = forageSpot.notes {
            let noteArray = Array(notes) as! [Note]
            let notesSection = NotesSection(notes: noteArray)
            sections.append(Section(headerItem: notesSection, sectionItems: notesSection.notes))
        }
        let collectionDatasource = DataSource(sections: sections)
        var snapshot = NSDiffableDataSourceSnapshot<Section<AnyHashable, [AnyHashable]>, AnyHashable>()
        collectionDatasource.sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.sectionItems)
        }
        datasource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeLabel)
        typeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        typeLabel.text = forageSpot.mushroomType

        if isModal {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(titleLabel)
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            titleLabel.text = forageSpot.name

            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
            
        } else {
            title = forageSpot.name
            
            editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editActionSheet))
            navigationItem.rightBarButtonItem = editButton
            
            typeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        }

        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 20).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60).isActive = true
        mapView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor).isActive = true
        foragePin.coordinate = CLLocationCoordinate2D(latitude: forageSpot.latitude, longitude: forageSpot.longitude)
        let coordinateRegion = MKCoordinateRegion(center: foragePin.coordinate, span: span)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showAnnotations([foragePin], animated: true)
        
        let mapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(tapGestureRecognizer:)))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(mapGestureRecognizer)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 20).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.image = UIImage(named: "Mushroom")
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

}

extension DetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let note = datasource?.snapshot().sectionIdentifiers[indexPath.section].sectionItems[indexPath.row] as? Note {
            coordinator?.presentEditNoteVC(note: note, delegate: self)
        }
    }
}

extension DetailVC: NoteDelegate {
    func noteWasSaved() {
        populateCollectionView()
    }
}

extension DetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let note = datasource?.snapshot().sectionIdentifiers[indexPath.section].sectionItems[indexPath.row] as? Note {
            NSLog("Note: \(String(describing: note.body))")
            // present note view
        }
    }
}

extension DetailVC: NoteDelegate {
    func noteWasSaved() {
        populateCollectionView()
    }
}
