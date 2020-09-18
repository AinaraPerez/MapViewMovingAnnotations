//
//  ViewController.swift
//  MapViewMovingAnnotations
//
//  Created by Ainara Perez on 17/09/2020.
//  Copyright © 2020 Ainara Perez. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lbNewLocation: UILabel!
    
    
    private var manager = CLLocationManager()
    private var mapLocation: CLLocationCoordinate2D?
    private var lastCurrentLatitude: Double?
    private var lastCurrentLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK:- ACTIONS
    @IBAction func btCheckMyPosition(_ sender: Any) {
        mapView.delegate = self
        userCurrentLocation()
    }
    
    //MARK:-LOCATION FUNCTIONS
    
    // Start Location
    private func userCurrentLocation() {
        print(#function)
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //Authoritzation ( + Info.pslist)
        DispatchQueue.main.async {
            //Privacy - Location Usage Description && Privacy - Location When In Use Usage Description
            self.manager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }
    
    // Update Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastCurrentLatitude = locations.last?.coordinate.latitude
        lastCurrentLongitude = locations.last?.coordinate.longitude
        
        mapView.removeAnnotations(mapView.annotations)
        mapLocation = CLLocationCoordinate2D(latitude: lastCurrentLatitude!, longitude: lastCurrentLongitude!)

        let span = MKCoordinateSpan(latitudeDelta: 0.0080, longitudeDelta: 0.0080)
        let region = MKCoordinateRegion(center: self.mapLocation!, span: span)
        self.mapView.setRegion(region, animated: true)
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = self.mapLocation!
        myAnnotation.title = "Press and move"
        mapView.addAnnotation(myAnnotation)
        
        manager.stopUpdatingLocation()
    }
    
 
    //Error Location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Location error", message: "Check your internet connection, or location permissions in the app Settings.", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Check new position
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == MKAnnotationView.DragState.ending {
            showNewLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        }
    }
    
    //Show new location
    func showNewLocation(latitude: Double, longitude: Double) {
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(currentLocation) {(placemarks, error) -> Void in
            if let sites = placemarks {
                let newLocation = sites[0].thoroughfare! + ", " + sites[0].subThoroughfare! + ", " + sites[0].locality!
                self.lbNewLocation.text = "New location: \n\(newLocation)"
            } else {
                self.lbNewLocation.text = "New location not found"
            }
        }
        
    }
    
    //Annotation added
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: "") as? MKPinAnnotationView
        if pinAnnotation == nil {
            pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
            pinAnnotation?.animatesDrop = true
            pinAnnotation?.canShowCallout = true
            pinAnnotation?.isDraggable = true
        }
        else {
            pinAnnotation?.annotation = annotation
        }
        
        return pinAnnotation
    }
    


}

