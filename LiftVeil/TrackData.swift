//
//  TrackData.swift
//  LiftVeil
//
//  Created by Vikram Kriplaney <vikram@iphonso.ch> on 19.09.2020.
//  Copyright © 2020 iPhonso GmbH. All rights reserved.
//

import CoreLocation
import Foundation

/// The track data provided as JSON, contains geocoded signal elements.
struct TrackData: Codable {
    let signals: [Signal]

    enum CodingKeys: String, CodingKey {
        case signals = "Trackdata"
    }
}

/// Represents a signal element in the dataset
struct Signal: Codable, Identifiable {
    let id: String
    let elementType: String
    let relativePosition: Double
    let locationName: String
    let latitude, longitude: Double?
    let additionalInformation: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case elementType = "Element Type"
        case relativePosition = "Relative Position"
        case locationName = "Location"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case additionalInformation = "Additional Information"
        case notes = "Notes"
    }
}

extension Signal {
    /// Creates the CoreLocation location of this signal
    var location: CLLocation? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension TrackData {
    /// Bundled data fixture
    static let site: TrackData = {
        try! JSONDecoder()
            .decode(TrackData.self, from: Data(contentsOf:
                Bundle.main.url(forResource: "TrackSiteData_2020_clean", withExtension: "json")!))
    }()

    /// Finds the nearest Signal to a location
    // TODO: Must be optimized for production
    func nearest(to location: CLLocation) -> Signal? {
        Self.site.signals.min {
            ($0.location?.distance(from: location) ?? .infinity)
                < ($1.location?.distance(from: location) ?? .infinity)
        }
    }
}
