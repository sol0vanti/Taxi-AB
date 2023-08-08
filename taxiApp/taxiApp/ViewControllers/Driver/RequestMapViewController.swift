//
//  RequestMapViewController.swift
//  taxiApp
//
//  Created by Alex on 04.08.2023.
//

import UIKit
import MapKit
import Firebase

enum SkipState {
    case customerLocation, destination, finish
}

class RequestMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    var timer = Timer()
    private var state: SkipState = .customerLocation
    let ceo: CLGeocoder = CLGeocoder()
    
    public var userLongitude: Double?
    public var userLatitude: Double?
    
    public var destinationLongitude: Double?
    public var destinationLatitude: Double?
    
    private var userCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    
    let driverPin = MyPointAnnotation()
    let customerPin = MyPointAnnotation()
    let destinationPin = MyPointAnnotation()
    
    public var userNickname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        
        getCoordinates()
        setUpPins()
        traceARoutes()
        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateUserLocation), userInfo: nil, repeats: true)
    }
    
    @objc func updateUserLocation(){
        mapView.removeAnnotation(driverPin)
        driverPin.coordinate = ViewController.driver.coordinate
        mapView.addAnnotation(driverPin)
    }
    
    func setUpPins() {
        driverPin.coordinate = ViewController.driver.coordinate
        driverPin.title = "Driver"
        driverPin.identifier = ViewController.driver.identifier
        
        customerPin.coordinate = userCoordinate!
        customerPin.title = "Customer"
        customerPin.identifier = "customer"
        
        destinationPin.coordinate = destinationCoordinate!
        destinationPin.title = "Destination"
        destinationPin.identifier = "destination"
        
        mapView.addAnnotations([driverPin, customerPin, destinationPin])
    }
    
    func getCoordinates(){
        userCoordinate = CLLocationCoordinate2D(latitude: userLatitude!, longitude: userLongitude!)
        destinationCoordinate = CLLocationCoordinate2D(latitude: destinationLatitude!, longitude: destinationLongitude!)
    }
    
    func traceARoutes(){
            self.drawARoute(ViewController.driver.coordinate, self.userCoordinate!)
            self.drawARoute(self.userCoordinate!, self.destinationCoordinate!)
    }
    
    @IBAction func skipButtonClicked(_ sender: UIButton) {
        switch state {
        case .customerLocation:
            ViewController.driver.coordinate.latitude = userCoordinate!.latitude - 0.0001
            ViewController.driver.coordinate.longitude = userCoordinate!.longitude - 0.0001
            
            let seconds = 5.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                let ac = UIAlertController(title: "Already?", message: "Do you see a client?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "No", style: .destructive) {_ in
                    let db = Firestore.firestore()
                    db.collection("drive-requests").whereField("userNickname", isEqualTo: "\(self.userNickname!)").getDocuments { (snapshot, error) in
                        
                    }
                })
                ac.addAction(UIAlertAction(title: "Yes", style: .default){ _ in
                    self.mapView.removeAnnotation(self.customerPin)
                })
                self.present(ac, animated: true)
            }
            state = .destination
        case .destination:
            ViewController.driver.coordinate.latitude = destinationCoordinate!.latitude - 0.0001
            ViewController.driver.coordinate.longitude = destinationCoordinate!.longitude - 0.0001
            
            skipButton.tintColor = .systemPink
            skipButton.titleLabel?.text = "Finish"
            state = .finish
        case .finish:
            let seconds = 5.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                let ac = UIAlertController(title: "Finished?", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Yes", style: .default) {_ in
                    let db = Firestore.firestore()
                    db.collection("drive-requests").whereField("userNickname", isEqualTo: "\(self.userNickname!)").getDocuments { (snapshot, error) in
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                })
                self.present(ac, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MyPointAnnotation else { return nil }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        if annotation.identifier == "customer" {
            annotationView.markerTintColor = .systemPink
        } else if annotation.identifier == "destination" {
            annotationView.markerTintColor = .systemCyan
        } else if annotation.identifier == "driver" {
            annotationView.markerTintColor = .systemYellow
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func drawARoute(_ source: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D){
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if error != nil {
                    let ac = UIAlertController(title: "Routes not available", message: "We couldn't get you to this location,     please try another one", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                } else {
                    return
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true) 
        }
    }
}
