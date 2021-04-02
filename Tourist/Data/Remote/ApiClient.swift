//
//  ApiClient.swift
//  Tourist
//
//  Created by Ismail on 23/03/2021.
//

import Foundation
import CoreData

class ApiClient {
    
    
    struct Auth {
        
        static var apiKey : String {
            get {
              guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
                fatalError("Couldn't find file 'Info.plist'.")
              }
                
              let plist = NSDictionary(contentsOfFile: filePath)
              guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError("Couldn't find key 'API_KEY' in 'Info.plist'.")
              }
              return value
            }
            
        }
    }
    struct Pagination {
        static var pageCount = 0
        static var pageNumber = 1
    }
    enum Endpoint {
        static let baseUrl = "https://www.flickr.com/services/rest/?"
        static let searchMethod = "method=flickr.photos.search"
        static let imageBaseUrl = "https://live.staticflickr.com/"
        
        case searchPhotos(Double, Double)
        case getPhoto(String, String, String)
        
        var stringValue: String{
            switch self {
                
            case .searchPhotos(let latitude, let longitude):
                return Endpoint.baseUrl + Endpoint.searchMethod +
                    "&api_key=" + Auth.apiKey + "&lat=\(latitude)" +
                    "&lon=\(longitude)" + "&page=\(Pagination.pageNumber)" + "&format=json&nojsoncallback=1"
            case .getPhoto(let serverId, let photoId, let photoSecret):
                return Endpoint.imageBaseUrl + serverId + "/" +
                photoId + "_" + photoSecret + ".jpg" //Image size is 500px
            }
        }
        
        var url:URL{
            return URL(string: stringValue)!
        }
        
    }
    
        static func searchRequest(lat: Double, lng: Double, completion: @escaping (([FlickrPhoto], Error?)->Void)) {
        let task = URLSession.shared.dataTask(with: Endpoint.searchPhotos(lat, lng).url){
            data, response, error in
            guard let data = data else {
                //reset to default
                Pagination.pageCount = 0
                Pagination.pageNumber = 1
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let response = try decoder.decode(PhotoSearchResponse.self, from: data)
                Pagination.pageCount = response.photos.pages
                Pagination.pageNumber = response.photos.page
                
                DispatchQueue.main.async {
                    completion(response.photos.photo, nil)
                }
            }catch{
                //reset to default
                Pagination.pageCount = 0
                Pagination.pageNumber = 1
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
            
        }
        task.resume()
    }
    
        static func downloadImageRequest(photo: Photo, completion: @escaping ((Data?, Error?)->Void)) {
        let task = URLSession.shared.downloadTask(with: URL(string: photo.imageUrl!)!){
            dataUrl, response, error in
            
            guard let dataUrl = dataUrl else {
                completion(nil, error)
                return
            }
            
            if let data = try? Data(contentsOf: dataUrl){
                completion(data, nil)
            }
            
        }
        task.resume()
    }
    
}
