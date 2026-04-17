//
//  LocationManager.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/17/26.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    enum Status {
        case checking
        case ready
        case unavailable
        case denied
    }

    @Published private(set) var status: Status = .checking
    @Published private(set) var latitude: Double?
    @Published private(set) var longitude: Double?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func prepare() {
        let authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            status = .checking
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocation()
        case .denied, .restricted:
            status = .denied
        @unknown default:
            status = .unavailable
        }
    }

    func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            status = .unavailable
            return
        }

        let authorizationStatus = manager.authorizationStatus

        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            prepare()
            return
        }

        status = .checking
        manager.requestLocation()
    }

    var statusText: String {
        switch status {
        case .checking:
            if let latitude, let longitude {
                return "Captured coordinates: \(formattedCoordinate(latitude)), \(formattedCoordinate(longitude))"
            }
            return "Checking location"
        case .ready:
            if let latitude, let longitude {
                return "Captured coordinates: \(formattedCoordinate(latitude)), \(formattedCoordinate(longitude))"
            }
            return "Location ready"
        case .unavailable:
            return "Location unavailable"
        case .denied:
            return "Permission denied"
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocation()
        case .denied, .restricted:
            status = .denied
            latitude = nil
            longitude = nil
        case .notDetermined:
            status = .checking
        @unknown default:
            status = .unavailable
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            status = .unavailable
            return
        }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        status = .ready
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if latitude != nil && longitude != nil {
            status = .ready
        } else {
            status = .unavailable
        }
    }

    private func formattedCoordinate(_ value: Double) -> String {
        String(format: "%.5f", value)
    }
}
