//
//  PhotoAlbumViewController.swift
//  Tourist
//
//  Created by Ismail on 21/03/2021.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButtonView: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    //MARK: Properties
    var pin: Pin!
    var dataController: DataController!
    var fetchResultController: NSFetchedResultsController<Photo>!
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newCollectionButtonView.setTitleColor(UIColor.darkGray, for: .disabled)
        
        var locationName = pin.locationName

        if locationName == nil {
            locationName = "Unknown"
        }
        title = locationName
        
        addLocationOnMap()
        
        configureLayoutSize()
        
        setupFetchResultController()
        
        
        
        if fetchResultController.fetchedObjects!.count == 0 {
            downlaodPhotoURLs()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    //MARK: Action
    @IBAction func loadNewCollection(_ sender: Any) {
        if ApiClient.Pagination.pageCount == 0 {
            return
        }
        deleteAllPhotos()
        ApiClient.Pagination.pageNumber = Int.random(in: 1...ApiClient.Pagination.pageCount)
        downlaodPhotoURLs()
    }
    
    //MARK: Utility Functions
    private func addLocationOnMap(){
        let annotation = PinAnnotation(pin: pin)
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    private func configureLayoutSize(){
        let space: CGFloat = 3.0
        let edgeLength = (self.view.frame.size.width < self.view.frame.size.height) ?
            self.view.frame.size.width : self.view.frame.size.height
        let dimension = (edgeLength - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    internal func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchResultController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    private func setupFetchResultController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
        } catch {
            showErrorAlert(message: "Oops! Something went wrong while loading photos.")
        }
    }

    private func deleteAllPhotos(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                request.predicate = NSPredicate(format: "pin == %@", pin)

                do {
                    let photos = try dataController.viewContext.fetch(request) as! [Photo]
                    for photo in photos {
                        dataController.viewContext.delete(photo)
                        try? dataController.viewContext.save()
                    }
                } catch {
                    showErrorAlert(message: error.localizedDescription)
                }
    }
    private func downlaodPhotoURLs() {
        updateUIState(isLoading: true, isEmpty: true)
        //initiate photo url download
        ApiClient.searchRequest(lat: pin.latitude, lng: pin.longitude) { (flickrPhotos, error) in
            
            guard error == nil else{
                self.noPhotosLabel.text = "Something went wrong"
                self.updateUIState(isLoading: false, isEmpty: true)
                return
            }
            
            if flickrPhotos.isEmpty{
                self.noPhotosLabel.text = "No Photos Available"
                self.updateUIState(isLoading: false, isEmpty: true)
            }else{
                self.updateUIState(isLoading: false, isEmpty: false)
                //save photo url
                for flickrPhoto in flickrPhotos{
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageUrl = ApiClient.Endpoint.getPhoto(flickrPhoto.server, flickrPhoto.id, flickrPhoto.secret).stringValue
                    self.pin.addToPhotos(photo)
                }
                try? self.dataController.viewContext.save()
                self.photoAlbumCollectionView.reloadData()
            }
        }

    }
    
    private func updateUIState(isLoading: Bool, isEmpty: Bool){
        newCollectionButtonView.isEnabled = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
            newCollectionButtonView.backgroundColor = UIColor.gray
            photoAlbumCollectionView.isHidden = isLoading
        }else{
            activityIndicator.stopAnimating()
            newCollectionButtonView.backgroundColor = UIColor.black
            photoAlbumCollectionView.isHidden = isEmpty
            noPhotosLabel.isHidden = !isEmpty
        }
        
    }
    
    
    
}

//MARK: Delegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            photoAlbumCollectionView.insertItems(at: [newIndexPath!])
        case .delete:
            photoAlbumCollectionView.deleteItems(at: [indexPath!])
        default: break
        }
    }
}
