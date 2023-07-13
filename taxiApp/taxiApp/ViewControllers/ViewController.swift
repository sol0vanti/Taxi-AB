import UIKit
import MapKit

enum ControllerState {
    case needRoute, needNext
}

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var yourLocationTextField: UITextField!
    @IBOutlet var submitLocationButton: UIButton!
    @IBOutlet var destinationTextField: UITextField!
    @IBOutlet var mapView: MKMapView!
    
    private var finalDestinationSet: Bool = false
    private let finalDestinationPin = MyPointAnnotation()
    private var finalDestinationCoordinate: CLLocationCoordinate2D?
    private let finalDestinationDefaultText: String = "To:"
    
    private var userPin = MyPointAnnotation()
    private var userCoordinate: CLLocationCoordinate2D?
    
    private var currentLocation: CLLocationCoordinate2D?
    private var state: ControllerState = .needRoute
    private var destinationCountry: String = ""
    
    public var distance: Int?
    public var distanceToDriver: Int?
    
    let driver = taxiDriver(
        name: "Alex Balla",
        coordinate: CLLocationCoordinate2D(latitude: 40.897032, longitude: -74.251874),
        identifier: "driver"
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        
        let driverPin = MyPointAnnotation()
        driverPin.coordinate = driver.coordinate
        driverPin.title = "Driver"
        driverPin.identifier = driver.identifier
        mapView.addAnnotation(driverPin)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reset", style: .done, target: self, action: #selector(resetDestination))
        navigationItem.rightBarButtonItem?.isHidden = true
        
        LocationManager.shared.getUserLocation{ [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                
                self?.userPin = MyPointAnnotation()
                self!.currentLocation = location.coordinate
                self!.userCoordinate = self!.currentLocation!
                self!.userPin.coordinate = self!.userCoordinate!
                self!.userPin.title = "Your Location"
                self!.userPin.identifier = "current-location"
                strongSelf.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
                strongSelf.mapView.addAnnotation(self!.userPin)
            }
        }
        
        let onLongTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture))
        self.mapView.addGestureRecognizer(onLongTapGesture)
    }
    
    @objc func resetDestination() {
        if finalDestinationSet != false {
            self.mapView.removeAnnotation(finalDestinationPin)
            navigationItem.rightBarButtonItem?.isHidden = true
            self.destinationTextField.placeholder = finalDestinationDefaultText
            finalDestinationSet = false
        } else { return }
    }
    
    @objc func handleLongTapGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if finalDestinationSet == true { return } else if finalDestinationSet != true {
            if gestureRecognizer.state != UIGestureRecognizer.State.ended {
                let touchLocation = gestureRecognizer.location(in: mapView)
                let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
                
                finalDestinationPin.identifier = "final-destination"
                finalDestinationCoordinate = locationCoordinate
                finalDestinationPin.coordinate = finalDestinationCoordinate!
                finalDestinationPin.title = "Final Destination"
                finalDestinationSet = true
                mapView.addAnnotation(finalDestinationPin)
                
                let ceo: CLGeocoder = CLGeocoder()
                let loc: CLLocation = CLLocation(latitude:locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                
                ceo.reverseGeocodeLocation(loc, completionHandler: { [self](placemarks, error) in
                    if (error != nil) {
                        let ac = UIAlertController(title: "Routes not available", message: "We couldn't get you to this location, please try another one", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        present(ac, animated: true)
                        resetDestination()
                    }
                    
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        
                        print(pm.country ?? "")
                        print(pm.locality ?? "")
                        print(pm.subLocality ?? "")
                        print(pm.thoroughfare ?? "")
                        print(pm.postalCode ?? "")
                        print(pm.subThoroughfare ?? "")
                        
                        var addressString : String = ""
                        destinationCountry = pm.country ?? "not a country"
                        
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + ", "
                        }
                        if pm.subThoroughfare != nil {
                            addressString = addressString + pm.subThoroughfare! + "."
                        }
                        
                        print(addressString)
                        self.destinationTextField.placeholder! = finalDestinationDefaultText + " " + addressString
                        self.navigationItem.rightBarButtonItem?.isHidden = false
                    }
                })
            }
            
            if gestureRecognizer.state != UIGestureRecognizer.State.began { return }
        }
    }
    
    // MARK: viewFor Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MyPointAnnotation else { return nil }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        if annotation.identifier == "current-location" {
            annotationView.markerTintColor = .systemPink
        } else if annotation.identifier == "final-destination" {
            annotationView.markerTintColor = .systemCyan
        } else if annotation.identifier == "driver" {
            annotationView.markerTintColor = .systemYellow
        }
        return annotationView
    }
    
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        if destinationTextField.placeholder?.trimmingCharacters(in: .whitespacesAndNewlines) == finalDestinationDefaultText {
            return
        } else {
            switch state {
            case .needRoute:
                state = .needNext
                if destinationCountry == "Соединённые Штаты Америки" {
                    let sourcePlacemark = MKPlacemark(coordinate: currentLocation!, addressDictionary: nil)
                    let destinationPlacemark = MKPlacemark(coordinate: finalDestinationCoordinate!, addressDictionary: nil)
                    
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
                                self.resetDestination()
                                return
                            }
                            
                            return
                        }
                        
                        let route = response.routes[0]
                        
                        self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                        
                        let rect = route.polyline.boundingMapRect
                        self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                        
                        // MARK: calculate distance
                        let driverLocation = CLLocation(latitude: self.driver.coordinate.latitude, longitude: self.driver.coordinate.longitude)
                        
                        let finalDestinationLocation = CLLocation(latitude: self.finalDestinationCoordinate!.latitude, longitude: self.finalDestinationCoordinate!.longitude)
                        let userLocation = CLLocation(latitude: self.userCoordinate!.latitude, longitude: self.userCoordinate!.longitude)
                        
                        self.distance = Int(userLocation.distance(from: finalDestinationLocation))
                        self.distanceToDriver = Int(userLocation.distance(from: driverLocation))
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.navigationItem.rightBarButtonItem?.isHidden = true
                            self.destinationTextField.isHidden = true
                            self.yourLocationTextField.isHidden = true
                        })
                    }
                    mapView.isUserInteractionEnabled = false
                    self.submitLocationButton.setTitle("Next", for: .normal)
                } else {
                    let ac = UIAlertController(title: "Routes not available", message: "We couldn't get you to this location, please try another one", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                    resetDestination()
                }
            case .needNext:
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShopingDetailViewController") as? ShopingDetailViewController
                secondViewController?.distance = distance ?? 0
                secondViewController?.distanceToDriver = distanceToDriver ?? 0
                self.navigationController?.pushViewController(secondViewController!, animated: true)
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
}
