//
//  CLPlaceMark+Extension.swift
//  Tourist
//
//  Created by Ismail on 31/03/2021.
//

import Foundation
import CoreLocation

extension CLPlacemark {

    // MARK: Properties
    // Generates the name of the placemark based on its own properties.
    var placeName: String? {
        var placeName = ""

        if let administrativeArea = administrativeArea, !administrativeArea.isEmpty {
            placeName += administrativeArea
        }

        if let locality = locality, !locality.isEmpty {
            placeName += (placeName.isEmpty ? "" : ", ") + locality
        }

        return placeName.isEmpty ? nil : placeName
    }
}
