//
//  Map + Extention.swift
//  Tourist
//
//  Created by Ismail on 30/03/2021.
//

import Foundation
import MapKit

//Config class for saving app state
class Config {
    
    static var shared = Config()
    private let userDefault = UserDefaults.standard
    private init() {
        
    }
    
    struct Keys {
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        static let latitudeDelta: String = "latitudeDelta"
        static let longitudeDelta: String = "longitudeDelta"
    }
    
    func saveRegion(mapRegion: MKCoordinateRegion?) {
        if let mapRegion = mapRegion {
            userDefault.set(mapRegion.center.latitude, forKey: Keys.latitude)
            userDefault.set(mapRegion.center.longitude, forKey: Keys.longitude)
            userDefault.set(mapRegion.span.latitudeDelta, forKey: Keys.latitudeDelta)
            userDefault.set(mapRegion.span.longitudeDelta, forKey: Keys.longitudeDelta)
        }
    }
    
    func getMapRegion() -> MKCoordinateRegion? {
        let latitude = userDefault.double(forKey: Keys.latitude)
        let longitude = userDefault.double(forKey: Keys.longitude)
        let latitudeDelta = userDefault.double(forKey: Keys.latitudeDelta)
        let longitudeDelta = userDefault.double(forKey: Keys.longitudeDelta)
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        return MKCoordinateRegion(center: center, span: span)
    }
}
