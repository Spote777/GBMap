//
//  MapViewController.swift
//  GBMap
//
//  Created by Павел Заруцков on 11.06.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - Propesties
    
    var mapView: GMSMapView!
    var viewModel: MapViewModel?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var currentLocation = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)
    var locationManager = LocationManager.instance
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
        setupConstraints()
        createNavBarButton()
        configureLocationManager()
        updateCurrentLocation()
        setupCamera(location: currentLocation)
    }
    
    // MARK: - Configure View
    
    private func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupViews() {
        mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        view.addSubview(mapView)
    }
    
    // MARK: - ConfigureViewModel
    
    func configure(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Configure route
    
    private func setupRoute() {
        mapView.clear()
        route?.map = nil
        route = GMSPolyline()
        route?.strokeColor = .red
        route?.strokeWidth = 10.0
        routePath = GMSMutablePath()
        route?.map = mapView
    }
    
    private func removeRoute() {
        route?.map = nil
        routePath?.removeAllCoordinates()
    }
    
    // MARK: - Create navigationBar button
    
    private func createNavBarButton() {
        let updateButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateButtonTapped))
        let loadButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(loadButtonTapped))
        
        let playButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playButtonTapped))
        let stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        
        navigationItem.rightBarButtonItems = [updateButton, loadButton]
        navigationItem.leftBarButtonItems = [playButton, stopButton]
    }
    
    @objc func updateButtonTapped(sender: UIButton) {
        updateCurrentLocation()
    }
    
    @objc func loadButtonTapped(sender: UIButton) {
        let newRoute = GMSPolyline()
        let newPath = GMSMutablePath()
        newRoute.strokeColor = .blue
        newRoute.strokeWidth = 10.0
        locationManager.stopUpdatingLocation()
        let locations = RealmService.shared.loadListOfLocation()
        routePath?.removeAllCoordinates()
        for i in 0..<locations.count {
            let coordinate = CLLocationCoordinate2D(latitude: locations[i].latitude, longitude: locations[i].longitude)
            newPath.insert(coordinate, at: UInt(locations[i]._number))
        }
        newRoute.path = newPath
        newRoute.map = mapView
        let bounds = GMSCoordinateBounds(path: newPath)
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    @objc func playButtonTapped(sender: UIButton) {
        setupRoute()
        locationManager.startUpdatingLocation()
    }
    
    @objc func stopButtonTapped(sender: UIButton) {
        locationManager.stopUpdatingLocation()
        RealmService.shared.deleteAllLocations()
        guard let pointsCount = routePath?.count() else { return }
        var locations = Array<Location>()
        for i in 0..<pointsCount {
            guard let point = routePath?.coordinate(at: i) else { return }
            let location = Location()
            location.longitude = point.longitude
            location.latitude = point.latitude
            location._number = Int(i)
            locations.append(location)
        }
        RealmService.shared.saveList(locations)
        mapView.clear()
    }
}

// MARK: - Extensions GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }
}

// MARK: - Configure location

extension MapViewController {
    private func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                self?.route?.path = self?.routePath
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
                
            }
    }
    
    private func updateCurrentLocation() {
        locationManager.requestLocation()
        guard let newLocation = locationManager.location.value else {
            return
        }
        let location2D = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        currentLocation = location2D
        updateCamera(location: location2D)
        createMark(location: location2D)
    }
    
    private func setupCamera(location: CLLocationCoordinate2D) {
        mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom:10)
    }
    
    private func updateCamera(location: CLLocationCoordinate2D) {
        mapView.animate(toLocation: location)
    }
    
    private func createMark(location: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: location)
        marker.map = mapView
    }
}
