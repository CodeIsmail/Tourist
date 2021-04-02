//
//  ErrorResponse.swift
//  Tourist
//
//  Created by Ismail on 23/03/2021.
//

import Foundation

struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}



