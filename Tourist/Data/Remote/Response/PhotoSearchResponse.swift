//
//  PhotoSearchResponse.swift
//  Tourist
//
//  Created by Ismail on 23/03/2021.
//

import Foundation

struct PhotoSearchResponse: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [FlickrPhoto]
}

// MARK: - Photo
struct FlickrPhoto: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
