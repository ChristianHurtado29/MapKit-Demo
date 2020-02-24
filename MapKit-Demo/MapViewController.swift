//
//  ViewController.swift
//  MapKit-Demo
//
//  Created by Christian Hurtado on 2/24/20.
//  Copyright © 2020 Christian Hurtado. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchTextField: UITextField!
    
    private var userTrackingButton: MKUserTrackingButton!
    
    private var annotations = [MKPointAnnotation]()
    
    private let locationSession = CoreLocationSession()
    
    private var isShowingNewAnnotations = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let's attempt to show the user's lovation
        mapView.showsUserLocation = true
        
        // set our self as the text field delegate
        searchTextField.delegate = self
        
        // configure tracking button
        userTrackingButton = MKUserTrackingButton(frame: CGRect(x: 370, y: 30, width: 40, height: 40))
        mapView.addSubview(userTrackingButton)
            userTrackingButton.mapView = mapView
        
        loadMap()
        
        // set map view delegate to this view controller
        mapView.delegate = self
    }
    
    private func loadMap() {
        let annotations = makeAnnotations()
        mapView.addAnnotations(annotations)
    }
    
    private func makeAnnotations() -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for location in Location.getLocations() {
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            annotation.coordinate = location.coordinate
            annotations.append(annotation)
        }
        isShowingNewAnnotations = true
        self.annotations = annotations
        return annotations
    }
    
    
    private func convertPlaceNameToCoordinate(_ placeName: String) {
        locationSession.convertPlaceNameToCoordinate(addressString: placeName) {(result) in
            switch result {
            case .failure(let error):
                print("geocoding error: \(error)")
            case .success(let coordinate):
            print("coordinate: \(coordinate)")
            // set map view at given coordinate
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            self.mapView.setRegion(region, animated: true)
            }
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let searchText = textField.text,
        !searchText.isEmpty else {
            return true
        }
        
        convertPlaceNameToCoordinate(searchText)
        return true
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("\(view.annotation?.title) was selected")
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isShowingNewAnnotations {
            mapView.showAnnotations(annotations, animated: false)
        }
        isShowingNewAnnotations = false
    }
    
}
