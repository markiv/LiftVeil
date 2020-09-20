//
//  LocationModel.swift
//  LiftVeil
//
//  Created by Vikram Kriplaney <vikram@iphonso.ch> on 19.09.2020.
//  Copyright © 2020 iPhonso GmbH. All rights reserved.
//

import Combine
import CoreLocation
import MapKit

/// An observable publisher of the device's location
class LocationModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var location: CLLocation?

    static let shared = LocationModel()
    let manager: CLLocationManager

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}
