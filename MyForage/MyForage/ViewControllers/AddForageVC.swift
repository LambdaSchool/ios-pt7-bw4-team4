//
//  AddForageVC.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/17/20.
//

import UIKit
import MapKit

class AddForageVC: UIViewController {
    
    // MARK: - UI Elements
    
    private var nameTextField = UITextField()
    private var mushroomTypePicker = UIPickerView()
    private var addressTextField = UITextField()
    private var latitudeTextField = UITextField()
    private var longitudeTextField = UITextField()
    private var mapView = MKMapView()
    
    private var useAddressButton = UIButton()
    private var useCoordinatesButton = UIButton()
    private var useMyLocationButton = UIButton()
    private var clearPinButton = UIButton()
    private var saveForageButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    
    fileprivate let locationManager = CLLocationManager()
    var span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    var userLocation: CLLocationCoordinate2D?
    
    var editMode: Bool = false
    var forageSpot: ForageSpot?
    var foragePin = MKPointAnnotation()
    
//    private let mushroomTypes = MushroomTypes.allCases.map { $0.rawValue }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mushroomTypePicker.delegate = self
        mushroomTypePicker.dataSource = self
        setUpView()
    }
    
    // MARK: - Actions
    
    @objc func saveForageSpot() {
        
    }
    
    @objc func useAddress(_ sender: UIButton) {
        guard let address = addressTextField.text else { return }
        reverseGeocode(address: address) { placemark in
            if let latitude = placemark.location?.coordinate.latitude,
               let longitude = placemark.location?.coordinate.longitude {
                self.foragePin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self.mapView.showAnnotations([self.foragePin], animated: true)
                self.latitudeTextField.text = String(latitude)
                self.longitudeTextField.text = String(longitude)
            } else {
                let alert = UIAlertController(title: "Error", message: "Please enter a valid address.", preferredStyle: .alert)
                let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(button)
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc func useCoordinates(_ sender: UIButton) {
        if let latText = latitudeTextField.text,
           let longText = longitudeTextField.text {
            if let latitude = Double(latText),
               let longitude = Double(longText) {
                addressTextField.text?.removeAll()
                foragePin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapView.showAnnotations([foragePin], animated: true)
            }
        }
    }
    
    @objc func useMyLocation(_ sender: UIButton) {
        if let userLocation = userLocation {
            foragePin.coordinate = userLocation
            mapView.showAnnotations([foragePin], animated: true)
            latitudeTextField.text = String(userLocation.latitude)
            longitudeTextField.text = String(userLocation.longitude)
        }
    }
    
    @objc func clearPin(_ sender: UIButton) {
        let pin = [foragePin]
        mapView.removeAnnotations(pin)
        latitudeTextField.text?.removeAll()
        longitudeTextField.text?.removeAll()
        addressTextField.text?.removeAll()
        if let userLocation = userLocation {
            let coordinateRegion = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    // MARK: - Private Functions
    
    private func updateView() {
//        if let forageSpot = forageSpot,
//           let name = forageSpot.name,
//           let mushroomIndex = mushroomTypes.firstIndex(of: forageSpot.mushroomType) {
//            title = "Edit \(name)"
//            nameTextField.text = forageSpot.name
//            mushroomTypePicker.selectRow(mushroomIndex, inComponent: 0, animated: true)
//            latitudeTextField.text = String(forageSpot.latitude)
//            longitudeTextField.text = String(forageSpot.longitude)
//            foragePin.coordinate = CLLocationCoordinate2D(latitude: forageSpot.latitude, longitude: forageSpot.longitude)
//            mapView.showAnnotations([foragePin], animated: false)
//            let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, span: span)
//            mapView.setRegion(coordinateRegion, animated: true)
//        } else {
//            title = "Add Forage Spot"
//            nameTextField.text = ""
//            addressTextField.text = ""
//            latitudeTextField.text = ""
//            longitudeTextField.text = ""
//        }
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        
        saveForageButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveForageSpot))
        navigationItem.rightBarButtonItem = saveForageButton
        
        setUpTextField(nameTextField, placeholder: "Forage Spot Title")
        nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        mushroomTypePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mushroomTypePicker)
        mushroomTypePicker.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10).isActive = true
        mushroomTypePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        mushroomTypePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        mushroomTypePicker.heightAnchor.constraint(equalToConstant: 150).isActive = true

        setUpButton(useAddressButton, text: "Use Address")
        useAddressButton.addTarget(self, action: #selector(useAddress), for: .touchUpInside)
        useAddressButton.topAnchor.constraint(equalTo: mushroomTypePicker.bottomAnchor, constant: 10).isActive = true
        useAddressButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        setUpTextField(addressTextField, placeholder: "123 Main St, Anytown, CA 54321")
        addressTextField.topAnchor.constraint(equalTo: mushroomTypePicker.bottomAnchor, constant: 10).isActive = true
        addressTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        addressTextField.trailingAnchor.constraint(equalTo: useAddressButton.leadingAnchor, constant: -5).isActive = true

        setUpButton(useCoordinatesButton, text: "Use Coordinates")
        useCoordinatesButton.addTarget(self, action: #selector(useCoordinates), for: .touchUpInside)
        useCoordinatesButton.topAnchor.constraint(equalTo: useAddressButton.bottomAnchor, constant: 10).isActive = true
        useCoordinatesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        setUpTextField(latitudeTextField, placeholder: "Latitude")
        latitudeTextField.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 10).isActive = true
        latitudeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        latitudeTextField.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        setUpTextField(longitudeTextField, placeholder: "Longitude")
        longitudeTextField.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 10).isActive = true
        longitudeTextField.leadingAnchor.constraint(equalTo: latitudeTextField.trailingAnchor, constant: 5).isActive = true
        longitudeTextField.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        setUpButton(useMyLocationButton, text: "Use My Location")
        useMyLocationButton.addTarget(self, action: #selector(useMyLocation), for: .touchUpInside)
        useMyLocationButton.topAnchor.constraint(equalTo: latitudeTextField.bottomAnchor, constant: 10).isActive = true
        useMyLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        setUpButton(clearPinButton, text: "Clear Pin")
        clearPinButton.addTarget(self, action: #selector(clearPin), for: .touchUpInside)
        clearPinButton.topAnchor.constraint(equalTo: useCoordinatesButton.bottomAnchor, constant: 10).isActive = true
        clearPinButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
                
        setUpMap()
        updateView()
    }
    
    private func setUpTextField(_ textField: UITextField, placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        view.addSubview(textField)
        textField.borderStyle = .bezel
    }
    
    private func setUpButton(_ button: UIButton, text: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .brown
        button.setTitleColor(.white, for: .normal)
        view.addSubview(button)
    }
    
    private func setUpMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: useMyLocationButton.bottomAnchor, constant: 20).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    private func reverseGeocode(address: String, completion: @escaping (CLPlacemark) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let placemarks = placemarks,
                  let placemark = placemarks.first else {
                return
            }
            completion(placemark)
        }
    }

}

extension AddForageVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1 // mushroomTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Chanterelle" // mushroomTypes[row]
    }

}

extension AddForageVC: CLLocationManagerDelegate {
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
