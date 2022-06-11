//
//  ViewController.swift
//  GBMap
//
//  Created by Павел Заруцков on 11.06.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet private var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
    }
}

extension ViewController: MKMapViewDelegate {
    
}
