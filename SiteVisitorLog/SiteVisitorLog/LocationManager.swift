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
    private var hasReceivedAuthorizationUpdate = false
    private var shouldPrepareLocation = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func prepareLocation() {
        shouldPrepareLocation = true
        status = .checking

        if hasReceivedAuthorizationUpdate {
            handleAuthorizationStatus(manager.authorizationStatus)
        }
    }

    private func handleAuthorizationStatus(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            if shouldPrepareLocation {
                manager.requestWhenInUseAuthorization()
            }
        case .authorizedAlways, .authorizedWhenInUse:
            guard shouldPrepareLocation else {
                if latitude != nil && longitude != nil {
                    status = .ready
                }
                return
            }

            shouldPrepareLocation = false
            status = .checking
            manager.requestLocation()
        case .denied, .restricted:
            shouldPrepareLocation = false
            status = .denied
            latitude = nil
            longitude = nil
        @unknown default:
            shouldPrepareLocation = false
            status = .unavailable
            latitude = nil
            longitude = nil
        }
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
        hasReceivedAuthorizationUpdate = true
        handleAuthorizationStatus(manager.authorizationStatus)
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
