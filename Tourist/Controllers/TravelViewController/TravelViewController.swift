//
//  TravelViewController.swift
//  Tourist
//
//  Created by Ismail on 21/03/2021.
//

import UIKit
import MapKit
import CoreData

class TravelViewController: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    var dataController: DataController!
    var mapChangedFromUserInteraction = false
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSavedPins()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        mapView.addGestureRecognizer(longPressRecognizer)
        
        if var region = Config.shared.getMapRegion() {
            if region.span.longitudeDelta == 0 {
                //prevent maximum zoom in on the map
                region.span.longitudeDelta = Double.random(in: 50...150)
            }
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }
        
    }
    
    //MARK: Action
    @IBAction func clearPinsOnMap(_ sender: Any) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Pin")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            //delete pins from db
            try dataController.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: dataController.viewContext)
            //clear pins on map
            let annotations = mapView.annotations
            mapView.removeAnnotations(annotations)
        } catch let error as NSError {
            showErrorAlert(message: error.localizedDescription)
        }
    }
    
    //MARK: Utility Functions
    private func loadSavedPins() {
        //load saved pin
        let pins: [Pin]
        do {
            pins =  try dataController.viewContext.fetch(NSFetchRequest(entityName: "Pin")) as! [Pin]
        } catch {
            pins =  []
        }
        
        for pin in pins{
            mapView.addAnnotation(PinAnnotation(pin: pin))
        }
        
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        
        let locationOnMap: CGPoint = sender.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(locationOnMap, toCoordinateFrom: mapView)
        
        createPinAnnnotation(coordinate: coordinate){annotation in
            
            //Add pin to map
            self.mapView.addAnnotation(annotation)
            
            //Save pin
            try? self.dataController.viewContext.save()
        }
        
        
    }
    
    private func createPinAnnnotation(coordinate: CLLocationCoordinate2D, completion: @escaping (PinAnnotation)->Void){
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { (placeMarks, error) in
            let pin = Pin(context: self.dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            
            if let placeMark = placeMarks?.first{
                pin.locationName = placeMark.placeName
                completion(PinAnnotation(pin: pin))
            }

        }
    }
    
    func showErrorAlert(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
}

