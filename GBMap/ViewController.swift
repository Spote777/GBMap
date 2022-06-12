//
//  ViewController.swift
//  GBMap
//
//  Created by Павел Заруцков on 11.06.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController {
    
    // MARK: - Private vars
    
    var currentLocation = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)
    var locationManager: CLLocationManager?
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - IBActions
    
    @IBAction func updateLocation(_ sender: Any) {
        updateCurrentLocation()
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLocationManager()
        setupCamera(location: currentLocation)
        updateCurrentLocation()
    }
    
    // MARK: - Private funcs
    
    private func configureLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.delegate = self
    }
    
    private func updateCurrentLocation() {
        locationManager?.requestLocation()
        guard let location = locationManager?.location?.coordinate else {
            return
        }
        currentLocation = location
        print(currentLocation)
        updateCamera(location: location)
        createMark(location: location)
    }
    
    private func setupCamera(location: CLLocationCoordinate2D) {
        mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom:14)
    }
    
    private func updateCamera(location: CLLocationCoordinate2D) {
        mapView.animate(toLocation: location)
    }
    
    private func createMark(location: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: location)
        marker.map = mapView
    }
}

// MARK: - Extensions

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.first as Any)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }
}
