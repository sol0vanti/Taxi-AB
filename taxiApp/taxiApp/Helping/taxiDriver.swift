//
//  taxiDriver.swift
//  taxiApp
//
//  Created by Alex on 11.07.2023.
//

import UIKit
import MapKit

class taxiDriver: NSObject, MKAnnotation {
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var identifier: String?
    
    init(name: String? = nil, coordinate: CLLocationCoordinate2D, identifier: String? = nil) {
        self.name = name
        self.coordinate = coordinate
        self.identifier = identifier
    }
}
