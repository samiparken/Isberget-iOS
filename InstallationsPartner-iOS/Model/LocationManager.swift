//
//  LocationManager.swift
//  InstallationsPartner-iOS
//
//  Created by Sam on 12/11/20.
//

import Foundation
import CoreLocation

//Manager
var locationManager = LocationManager()

class LocationManager: NSObject {
    
    let coreLocation = CLLocationManager()
    
    override init() {
        super.init()
        self.coreLocation.delegate = self
        self.coreLocation.desiredAccuracy = kCLLocationAccuracyBest
        self.coreLocation.requestWhenInUseAuthorization()
    }
    
}

//MARK: - Get Placemark
extension LocationManager {
    
    func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    func getCoordinateFrom(address: String, orderId: Int, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ orderId: Int?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, orderId, $1) }
    } //passing orderId
    
    /* Usage
     let address = "Rio de Janeiro, Brazil"

     getCoordinateFrom(address: address) { coordinate, error in
         guard let coordinate = coordinate, error == nil else { return }
         // don't forget to update the UI from the main thread
         DispatchQueue.main.async {
             print(address, "Location:", coordinate) // Rio de Janeiro, Brazil Location: CLLocationCoordinate2D(latitude: -22.9108638, longitude: -43.2045436)
         }
     }
     */
}

//MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // Location Authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse   : print("authorizedWhenInUse")  // location authorized
                                    self.coreLocation.requestLocation()
        case .authorizedAlways      : print("authorizedAlways")     // location authorized
                                    self.coreLocation.requestLocation()
        case .notDetermined         : print("notDetermined")        // location permission not asked for yet
        case .restricted            : print("restricted")           // TODO: handle
        case .denied                : print("denied")               // TODO: handle
        default                     : print("location error")
        }
    }
    
    // Updated Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = locations.last {  // last is more accurate
            singletonData.currentLocation = locations.last
            print("currentLocation updated")
        }
    }
}
