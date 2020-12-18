//
//  MapVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import UIKit
import MapKit

class Spot: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String
    var favorability: Int
    var image: UIImage
    var identifier: String

    init(coordinate: CLLocationCoordinate2D, name: String, favorability: Int, image: UIImage, identifier: String) {
        self.coordinate = coordinate
        self.name = name
        self.favorability = favorability
        self.image = image
        self.identifier = identifier
    }
}

class MapVC: UIViewController {
    
    // TODO:
    // custom annotation, images, styling
    // remove Spot after data model is merged in
    // remove dummyData
    
    
    // MARK: - UI Elements
    
    private var mapView = MKMapView()
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    fileprivate let locationManager = CLLocationManager()
    var span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    var userLocation: CLLocationCoordinate2D?
    
    var forageSpots: [Spot] = [] {
        didSet {
            let oldSpots = Set(oldValue)
            let newSpots = Set(forageSpots)
            
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
        dummyData()
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
    
    private func dummyData() {
        forageSpots = [Spot(coordinate: CLLocationCoordinate2D(latitude: 37.82, longitude: -122.17), name: "Tasty Mushrooms", favorability: 7, image: UIImage(systemName: "suit.spade.fill")!, identifier: ""),
                       Spot(coordinate: CLLocationCoordinate2D(latitude: 37.88, longitude: -122.21), name: "Chanterelles?", favorability: 5, image: UIImage(systemName: "suit.spade.fill")!, identifier: "")]
    }

}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let forageSpot = annotation as? Spot else { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifier.forageAnnotation, for: forageSpot) as! MKMarkerAnnotationView
        
        annotationView.glyphImage = UIImage(named: "Mushroom")
        annotationView.canShowCallout = true
        let detailView = ForageAnnotationView()
//        detailView.forageSpot = forageSpot
        detailView.coordinator = coordinator
        annotationView.detailCalloutAccessoryView = detailView
        
        switch forageSpot.favorability {
        case 0..<3:
            annotationView.markerTintColor = .systemRed
        case 3..<5:
            annotationView.markerTintColor = .systemOrange
        case 5..<7:
            annotationView.markerTintColor = .systemYellow
        case 7...10:
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
