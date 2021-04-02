//
//  PhotoAlbumViewController+MapView.swift
//  Tourist
//
//  Created by Ismail on 01/04/2021.
//

import Foundation
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .black
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

