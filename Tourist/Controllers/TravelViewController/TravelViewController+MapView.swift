//
//  TravelViewController+MapView.swift
//  Tourist
//
//  Created by Ismail on 01/04/2021.
//

import Foundation
import MapKit

//MARK: Delegate
extension TravelViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotaion = mapView.selectedAnnotations.first as! PinAnnotation
        
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "photoAlbum") as! PhotoAlbumViewController
        vc.dataController = dataController
        vc.pin = annotaion.pin
            
        navigationController?.pushViewController(vc, animated: true)
    }
    
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapChangedFromUserInteraction {
            Config.shared.saveRegion(mapRegion: self.mapView.region)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
    }
    //MARK: Utility Function
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        return false
    }
}

