import Foundation
import CoreLocation

func getDistance_km(lat: Double, lon: Double) -> Double {
    if let baseLocation = singletonData.currentLocation {
        let target = CLLocation(latitude: lat, longitude: lon)
        let distance = target.distance(from: baseLocation) / 1000
        return distance
    } else {
        return 0
    }
}
