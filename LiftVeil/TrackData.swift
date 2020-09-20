//
//  TrackData.swift
//  LiftVeil
//
//  Created by Vikram Kriplaney <vikram@iphonso.ch> on 19.09.2020.
//  Copyright © 2020 iPhonso GmbH. All rights reserved.
//

import CoreLocation
import Foundation

struct TrackData: Codable {
    let signals: [Signal]

    enum CodingKeys: String, CodingKey {
        case signals = "Trackdata"
    }
}

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
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension TrackData {
    static let site: TrackData = {
        try! JSONDecoder()
            .decode(TrackData.self, from: Data(contentsOf:
                Bundle.main.url(forResource: "TrackSiteData_2020_clean", withExtension: "json")!))
    }()

    func nearest(to location: CLLocation) -> Signal? {
        Self.site.signals.min {
            ($0.location?.distance(from: location) ?? .infinity)
                < ($1.location?.distance(from: location) ?? .infinity)
        }
    }
}
