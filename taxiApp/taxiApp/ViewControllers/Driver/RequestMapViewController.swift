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
    case customerLocation, destination
}

class RequestMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    var timer = Timer()
    private var state: SkipState = .customerLocation
    let ceo: CLGeocoder = CLGeocoder()
    
    public var userAddressString: String?
    public var destinationAddressString: String?
    
    private var userCoordinates: CLLocationCoordinate2D?
    private var destinationCoordinates: CLLocationCoordinate2D?
    
    let driverPin = MyPointAnnotation()
    
    public var userNickname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCoordinates()
        setUpDriverPin()
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
    
    func setUpDriverPin() {
        driverPin.coordinate = ViewController.driver.coordinate
        driverPin.title = "Driver"
        driverPin.identifier = ViewController.driver.identifier
        mapView.addAnnotation(driverPin)
    }
    
    func getCoordinates() {
        ceo.geocodeAddressString(userAddressString!, completionHandler: { [self](placemarks, error) in
            if (error != nil) {
                return
            } else {
                if let placemark = placemarks?.first {
                    let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                    userCoordinates = coordinates
                }
            }
        })
        ceo.geocodeAddressString(destinationAddressString!, completionHandler: { [self](placemarks, error) in
            if (error != nil) {
                return
            } else {
                if let placemark = placemarks?.first {
                    let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                    destinationCoordinates = coordinates
                }
            }
        })
    }
    
    @IBAction func skipButtonClicked(_ sender: UIButton) {
        switch state {
        case .customerLocation:
            state = .destination
            ViewController.driver.coordinate = userCoordinates!
            let ac = UIAlertController(title: "Already?", message: "Do you see a client?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "No", style: .destructive) {_ in
                let db = Firestore.firestore()
                db.collection("drive-requests").whereField("orderid", isEqualTo: "\(documentId)").delete() { error in
                    if let error = error {
                        print(String(describing: error))
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
            })
            ac.addAction(UIAlertAction(title: "Yes", style: .default))
        case .destination:
            ViewController.driver.coordinate = destinationCoordinates!
        }
    }
}