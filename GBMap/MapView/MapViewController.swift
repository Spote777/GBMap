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
    
    private var mapView: GMSMapView!
    private var viewModel: MapViewModel?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var currentLocation = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)
    private var locationManager = LocationManager.instance
    
    private var markerImage : UIImage?
    private let markerImageKey : String = "markerImage"
    private let markerImageScale : Int = 85
    
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
        let takePhotoButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhotoButtonAction))
        navigationItem.rightBarButtonItems = [updateButton, loadButton]
        navigationItem.leftBarButtonItems = [playButton, stopButton, takePhotoButton]
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
    
    @objc private func takePhotoButtonAction(sender: UIButton!) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
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
        marker.icon = markerImage
    }
}

extension MapViewController {
    
    private func store(image: UIImage,
                       forKey key: String) {
        if let pngRepresentation = image.pngData() {
            
            UserDefaults.standard.set(pngRepresentation,
                                      forKey: key)
        }
    }
    
    private func loadMarkerImage() {
        DispatchQueue.global(qos: .background).async {
            if let savedImage = self.retrieveImage(forKey: self.markerImageKey) {
                DispatchQueue.main.async {
                    self.markerImage = savedImage
                }
            }
        }
    }
    
    private func retrieveImage(forKey key: String) -> UIImage? {
        if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
           let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
    
}


extension MapViewController:  UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = extractImage(from: info) else { return }
        
        let scaledImage = image.scalePreservingAspectRatio(
            targetSize: CGSize(width: markerImageScale, height: markerImageScale)
        )
        markerImage = scaledImage
        DispatchQueue.global(qos: .background).async {
            self.store(image: scaledImage,
                       forKey: self.markerImageKey)
        }
        picker.dismiss(animated: true)
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}
