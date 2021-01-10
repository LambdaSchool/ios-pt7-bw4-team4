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

class WeatherSection: Hashable {
    var sectionTitle = "Recent Weather"
    var weatherDays: [WeatherHistory]
    
    init(weather: [WeatherHistory]) {
        self.weatherDays = weather.sorted(by: { $0.dateTime! < $1.dateTime! })
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
        self.notes = notes.sorted(by: { $0.date! > $1.date! })
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
    private var favorabilityView = UIImageView()
    private var mapView = MKMapView()
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    var isModal: Bool = false
    var forageSpot: ForageSpot!
    
    fileprivate let locationManager = CLLocationManager()
    private var span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    private var foragePin = MKPointAnnotation()
    private var forageAnnotation: ForageAnnotation?
    
    private var datasource: UICollectionViewDiffableDataSource<Section<AnyHashable, [AnyHashable]>, AnyHashable>!

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureCollectionView()
    }
    
    // MARK: - Actions
    
    @objc func editActionSheet() {
        coordinator?.presentEditMenu(delegate: self)
    }
    
    @objc func mapTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let mapCenter = mapView.center
        let imageCenter = imageView.center
        UIView.animate(withDuration: 0.5, animations: {
            self.mapView.center = CGPoint(x: self.mapView.center.x + 50, y: self.mapView.center.y)
            self.imageView.center = CGPoint(x: self.imageView.center.x - 50, y: self.imageView.center.y)
        }) { (_) in
            UIView.animate(withDuration: 0.5) {
                self.view.bringSubviewToFront(self.mapView)
                self.mapView.center = CGPoint(x: mapCenter.x, y: self.mapView.center.y)
                self.imageView.center = CGPoint(x: imageCenter.x, y: self.imageView.center.y)
            }
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imageCenter = imageView.center
        let mapCenter = mapView.center
        UIView.animate(withDuration: 0.5, animations: {
            self.mapView.center = CGPoint(x: self.mapView.center.x + 50, y: self.mapView.center.y)
            self.imageView.center = CGPoint(x: self.imageView.center.x - 50, y: self.imageView.center.y)
        }) { (_) in
            UIView.animate(withDuration: 0.5) {
                self.view.bringSubviewToFront(self.imageView)
                self.mapView.center = CGPoint(x: mapCenter.x, y: self.mapView.center.y)
                self.imageView.center = CGPoint(x: imageCenter.x, y: self.imageView.center.y)
            }
        }
    }

    // MARK: - Private Functions
    
    private func configureCollectionView() {
        let frame = CGRect(x: 20, y: (view.frame.height / 2), width: (view.frame.width - 40), height: ((view.frame.height / 2) - 70))
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout())
        collectionView?.register(WeatherCell.self, forCellWithReuseIdentifier: ReuseIdentifier.weatherCell)
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: ReuseIdentifier.noteCell)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReuseIdentifier.headerView)
        collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ReuseIdentifier.footerView)
        collectionView?.backgroundColor = appColor.yellow
        collectionView.layer.cornerRadius = 15
        collectionView.layer.shadowRadius = 5
        collectionView.layer.shadowOffset = CGSize(width: 3, height: 3)
        collectionView.layer.shadowColor = appColor.gray.cgColor
        collectionView.layer.shadowOpacity = 0.7
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
            if let weather = item as? WeatherHistory {
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
        if let weatherHistory = forageSpot.weatherHistory {
            let weatherArray = Array(weatherHistory) as! [WeatherHistory]
            let weatherSection = WeatherSection(weather: weatherArray)
            sections.append(Section(headerItem: weatherSection, sectionItems: weatherSection.weatherDays))
        }
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
        view.backgroundColor = appColor.cream
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeLabel)
        typeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        typeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        typeLabel.textColor = appColor.darkGreen
        if let type = forageSpot.mushroomType {
            typeLabel.text = "Mushroom Type: \(type)"
        }

        if isModal {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(titleLabel)
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            titleLabel.text = forageSpot.name
            titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
            titleLabel.textColor = appColor.red
            titleLabel.shadowColor = appColor.gray
            titleLabel.shadowOffset = CGSize(width: 0.5, height: 1)

            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
            
        } else {
            title = forageSpot.name
            
            editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editActionSheet))
            navigationItem.rightBarButtonItem = editButton
            
            typeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        }
        
        favorabilityView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(favorabilityView)
        favorabilityView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        favorabilityView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        favorabilityView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        favorabilityView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        favorabilityView.image = UIImage(systemName: "bookmark.fill")
        switch forageSpot.favorability {
        case 0..<3:
            favorabilityView.tintColor = appColor.red
        case 3..<6:
            favorabilityView.tintColor = appColor.orange
        case 6..<9:
            favorabilityView.tintColor = appColor.lightGreen
        case 9...10:
            favorabilityView.tintColor = appColor.mediumGreen
        default:
            favorabilityView.tintColor = appColor.gray
        }
        let favorabilityTap = UITapGestureRecognizer(target: self, action: #selector(favorabilityTapped(tapGestureRecognizer:)))
        favorabilityView.isUserInteractionEnabled = true
        favorabilityView.addGestureRecognizer(favorabilityTap)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        if let forageAnnotation = forageAnnotation {
            mapView.removeAnnotations([forageAnnotation])
        }
        mapView.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 20).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60).isActive = true
        mapView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor).isActive = true
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 15
        mapView.layer.borderWidth = 3
        mapView.layer.borderColor = appColor.mediumGreen.cgColor
        
        foragePin.coordinate = CLLocationCoordinate2D(latitude: forageSpot.latitude, longitude: forageSpot.longitude)
        let coordinateRegion = MKCoordinateRegion(center: foragePin.coordinate, span: span)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReuseIdentifier.forageAnnotation)
        forageAnnotation = ForageAnnotation(coordinate: foragePin.coordinate, name: forageSpot.name!, favorability: forageSpot.favorability, imageData: forageSpot.imageData?.img, identifier: UUID())
        if let forageAnnotation = forageAnnotation {
            mapView.addAnnotations([forageAnnotation])
        }
        
        let mapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(tapGestureRecognizer:)))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(mapGestureRecognizer)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 40).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        
        if let imageData = forageSpot.imageData?.img {
            imageView.image = UIImage(data: imageData)
        } else {
            imageView.image = UIImage(named: "Mushroom")
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func goToLocationGPS() {
        let destination = MKPlacemark(coordinate: foragePin.coordinate)
        let destinationItem = MKMapItem(placemark: destination)
        destinationItem.name = forageSpot.name
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        destinationItem.openInMaps(launchOptions: [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                                                   MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span),
                                                   MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @objc private func favorabilityTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        var favorabilityString = ""
        switch forageSpot.favorability {
        case 0..<3:
            favorabilityString = "No"
        case 3..<6:
            favorabilityString = "Low"
        case 6..<9:
            favorabilityString = "Good"
        case 9...10:
            favorabilityString = "Excellent"
        default:
            favorabilityString = "Unknown"
        }
        let alert = UIAlertController(title: "\(favorabilityString) Chance of Finding Mushrooms Here Today", message: nil, preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
    
    private func errorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong - please try again.", preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
    
}

extension DetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let note = datasource?.snapshot().sectionIdentifiers[indexPath.section].sectionItems[indexPath.row] as? Note {
            coordinator?.presentEditNoteVC(note: note, delegate: self, isModal: isModal)
        }
    }
}

extension DetailVC: NoteDelegate {
    func noteWasSaved() {
        populateCollectionView()
    }
    
    func imageWasAddedToNote() {
        populateCollectionView()
    }
}

extension DetailVC: ImageDelegate {
    func imageWasSaved() {
        self.dismiss(animated: true, completion: nil)
        if let imageData = forageSpot.imageData?.img {
            imageView.image = UIImage(data: imageData)
        }
    }
    
    func imageWasAddedToNewNote(imageData: Data) {
    }
}

extension DetailVC: ForageDelegate {
    func forageSpotWasSaved() {
        setUpView()
        populateCollectionView()
    }
}

extension DetailVC: EditDelegate {
    func didSelectOption(editOption: EditOption) {
        switch editOption {
        case .editForageSpot:
            coordinator?.collectionNav.dismiss(animated: true)
            coordinator?.presentEditForageVC(forageSpot: self.forageSpot, delegate: self)
        case .updateImage:
            coordinator?.collectionNav.dismiss(animated: true)
            coordinator?.presentImageVC(forageSpot: self.forageSpot, note: nil, delegate: self, presentingVC: self)
        case .addNote:
            coordinator?.collectionNav.dismiss(animated: true)
            coordinator?.presentAddNoteVC(forageSpot: self.forageSpot, delegate: self)
        case .deleteForageSpot:
            coordinator?.collectionNav.dismiss(animated: true)
            coordinator?.modelController.deleteForageSpot(forageSpot: self.forageSpot, completion: { result in
                switch result {
                case true:
                    let alert = UIAlertController(title: "Forage Spot Deleted", message: nil, preferredStyle: .alert)
                    let button = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                        self.coordinator?.collectionNav.popViewController(animated: true)
                    })
                    alert.addAction(button)
                    self.present(alert, animated: true)
                case false:
                    self.errorAlert()
                }
            })
        case .cancel:
            coordinator?.collectionNav.dismiss(animated: true)
        }
    }
}

extension DetailVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let forageAnnotation = annotation as? ForageAnnotation else { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifier.forageAnnotation, for: forageAnnotation) as! MKMarkerAnnotationView
        
        annotationView.glyphImage = UIImage(named: "Mushroom")
        annotationView.canShowCallout = false
        
        switch forageAnnotation.favorability {
        case 0..<3:
            annotationView.markerTintColor = appColor.red
        case 3..<6:
            annotationView.markerTintColor = appColor.orange
        case 6..<9:
            annotationView.markerTintColor = appColor.lightGreen
        case 9...10:
            annotationView.markerTintColor = appColor.mediumGreen
        default:
            annotationView.markerTintColor = appColor.gray
        }
        
        annotationView.displayPriority = .required
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let alert = UIAlertController(title: "Get Directions", message: "Would you like to open Maps?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.goToLocationGPS()
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
}
