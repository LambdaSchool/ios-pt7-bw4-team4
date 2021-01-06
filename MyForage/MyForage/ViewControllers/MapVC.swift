//
//  MapVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController {

    // MARK: - UI Elements
    
    private var mapView = MKMapView()
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    fileprivate let locationManager = CLLocationManager()
    private var span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    private var userLocation: CLLocationCoordinate2D?
    
    private var forageAnnotations: [ForageAnnotation] = [] {
        didSet {
            let oldSpots = Set(oldValue)
            let newSpots = Set(forageAnnotations)
            
            let addedSpots = newSpots.subtracting(oldSpots)
            let removedSpots = oldSpots.subtracting(newSpots)
            
            mapView.removeAnnotations(Array(removedSpots))

            mapView.addAnnotations(Array(addedSpots))
        }
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpMap()
        addAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAnnotations()
    }
    
    // MARK: - Private Functions
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReuseIdentifier.forageAnnotation)
    }
    
    private func addAnnotations() {
        let fetchRequest: NSFetchRequest<ForageSpot> = ForageSpot.fetchRequest()
        do {
            let forageSpots = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            var annotations: [ForageAnnotation] = []
            for spot in forageSpots {
                guard let name = spot.name,
                      let image = spot.image,
                      let identifier = spot.identifier else { return }
                let annotation = ForageAnnotation(coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude), name: name, favorability: spot.favorability, image: image, identifier: identifier)
                annotations.append(annotation)
            }
            forageAnnotations = annotations
        } catch {
            NSLog("Unable to fetch ForageSpots")
        }
    }

}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let forageAnnotation = annotation as? ForageAnnotation else { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifier.forageAnnotation, for: forageAnnotation) as! MKMarkerAnnotationView
        
        annotationView.glyphImage = UIImage(named: "Mushroom")
        annotationView.canShowCallout = true
        let detailView = ForageAnnotationView()
        detailView.forageAnnotation = forageAnnotation
        detailView.coordinator = coordinator
        annotationView.detailCalloutAccessoryView = detailView
        
        switch forageAnnotation.favorability {
        case 0..<3:
            annotationView.markerTintColor = .systemRed
        case 3..<6:
            annotationView.markerTintColor = .systemOrange
        case 6..<9:
            annotationView.markerTintColor = .systemYellow
        case 9...10:
            annotationView.markerTintColor = .systemGreen
        default:
            annotationView.markerTintColor = .systemGray
        }
        
        annotationView.displayPriority = .required
        
        return annotationView
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        userLocation = currentLocation
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, span: span)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
