//
//  PhotoAlbumViewController+CollectionView.swift
//  Tourist
//
//  Created by Ismail on 01/04/2021.
//

import Foundation
import UIKit

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fetchResultController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.image = UIImage(named: "placeholder")
        
        let photo = fetchResultController.object(at: indexPath)
        
        if let image = photo.image {
            cell.imageView.image = UIImage(data: image)
        }else{
            
            ApiClient.downloadImageRequest(photo: photo) { (imageData, error) in
                
                if let imageData = imageData{
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: imageData)
                    }
                    photo.image = imageData
                    photo.pin = self.pin
                    try? self.dataController.viewContext.save()
                }
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(at: indexPath)
    }
}
