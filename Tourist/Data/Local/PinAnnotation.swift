//
//  PinAnnotation.swift
//  Tourist
//
//  Created by Ismail on 29/03/2021.
//

import Foundation
import MapKit

//Wrapper class for pin
class PinAnnotation: NSObject, MKAnnotation {
    
    
    // MARK: Properties
    var pin: Pin
    var coordinate: CLLocationCoordinate2D
    

    // MARK: Initializer
    init(pin: Pin) {
        self.pin = pin
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        super.init()
    }
}
