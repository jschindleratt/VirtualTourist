//
//  MapViewViewController.swift
//  VirtualTourist2
//
//  Created by Joshua Schindler on 5/6/18.
//  Copyright © 2018 Joshua Schindler. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pins]! = []
    var dataController:DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(gestureRecognizer)
        let fetchRequest:NSFetchRequest<Pins> = Pins.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest)
        {
            pins = result
            pinTheMap()
        }
    }
    
    func pinTheMap() {
        if let pins = pins {
            var annotations = [MKPointAnnotation]()
            for pin in pins {
                let lat = CLLocationDegrees(pin.latitude)
                let long = CLLocationDegrees(pin.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(lat) \(long)"
                annotations.append(annotation)
            }
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    @objc func longPress(gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state == .began) {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let pin = Pins(context: dataController.viewContext)
            pin.latitude = newCoordinates.latitude
            pin.longitude = newCoordinates.longitude
            try? dataController.viewContext.save()
            pins.append(pin)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            annotation.title = "new pin"
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        var clickedPin: Pins!
        if let pins = pins {
            for pin in pins {
                if pin.latitude == (view.annotation?.coordinate.latitude)! && pin.longitude == (view.annotation?.coordinate.longitude)! {
                    clickedPin = pin
                }
            }
        }
        let controller: PhotoAlbumViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "photoAlbumVC") as!PhotoAlbumViewController
        controller.selectedLatitude = (view.annotation?.coordinate.latitude)!
        controller.selectedLongtitude = (view.annotation?.coordinate.longitude)!
        controller.dataController = dataController
        controller.pin = clickedPin
        present(controller, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}
