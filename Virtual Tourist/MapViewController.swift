//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Hayne Park on 11/16/16.
//  Copyright © 2016 Alexander Bui. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate  {
    
    //MARK: Properties
    var annotations = [MKPointAnnotation]()
    let locationManager = CLLocationManager()
    var editMode = Bool()
    
    lazy var sharedContext: NSManagedObjectContext = {
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        return stack.context
    }()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        if locationAuthStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        uilpgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilpgr)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        addMapLocations()
    }
    
    func savePinInContexts(_ annotation: MKPointAnnotation) {

        let pinInfo = annotation
        
        let request: NSFetchRequest<NSFetchRequestResult> = Pin.fetchRequest()
        do {
            let results = try sharedContext.fetch(request) as! [Pin]
            if (results.count == 0) {
                // Create new Pin
                _ = Pin(annotation: pinInfo, context: sharedContext)
                // Save pin
                let stack = (UIApplication.shared.delegate as! AppDelegate).stack
                stack.saveContexts()
            }
            if (results.count > 0) {
                    // Create new Pin
                    _ = Pin(annotation: pinInfo, context: sharedContext)
                    // Save pin
                    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
                    stack.saveContexts()
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
    }
    
    func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        mapView.addAnnotation(annotation)
        savePinInContexts(annotation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        print(center)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        
        centerMapOnLocation(annotation, regionRadius: 1000.0)
        savePinInContexts(annotation)
    }
    
    func centerMapOnLocation(_ location: MKPointAnnotation, regionRadius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func addMapLocations() {
        
        annotations.removeAll()
        
        let request: NSFetchRequest<NSFetchRequestResult> = Pin.fetchRequest()
        do {
            let results = try sharedContext.fetch(request) as! [Pin]
            if (results.count > 0) {
                for result in results {
                    print(result.latitude)
                    let latitude = result.latitude as Double!
                    let longitude = result.longitude as Double!
                    let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    let title = result.annotationTitle
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = title
                    annotations.append(annotation)
                }
            } else {
                print("No Pins")
                return
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        mapView.addAnnotations(annotations)
        
        centerMapOnLocation(annotations.last!, regionRadius: 1000.0)
        
    }
    
    
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = (view.annotation?.coordinate)!
        
            self.mapView.deselectAnnotation(view.annotation, animated: true)
            
            let request: NSFetchRequest<NSFetchRequestResult> = Pin.fetchRequest()
            do {
                let results = try sharedContext.fetch(request) as! [Pin]
                print(results)
                if (results.count > 0) {
                        for result in results {
                            if Double(result.latitude) == annotation.coordinate.latitude {
                                performSegue(withIdentifier: "segueToPhotoAlbum", sender: result)
                            }
                        }
                } else {
                    print("No Pins")
                }
            } catch let error as NSError {
                print("Fetch failed: \(error.localizedDescription)")
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToPhotoAlbum" {
            let photoCollectionVC: PhotoAlbumViewController = segue.destination as! PhotoAlbumViewController
            photoCollectionVC.tappedPin = sender as? Pin
        }
    }
}
