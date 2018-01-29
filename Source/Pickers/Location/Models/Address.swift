import UIKit
import CoreLocation

struct Address {
    
    // MARK: - Properties
    
    var street: String?
    var building: String?
    var apt: String?
    var zip: String?
    var city: String?
    var state: String?
    var country: String?
    var ISOcountryCode: String?
    var timeZone: TimeZone?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var placemark: CLPlacemark?
    
    // MARK: - Types
    
    init(placemark: CLPlacemark) {
        self.street = placemark.thoroughfare
        self.building = placemark.subThoroughfare
        self.city = placemark.locality
        self.state = placemark.administrativeArea
        self.zip = placemark.postalCode
        self.country = placemark.country
        self.ISOcountryCode = placemark.isoCountryCode
        self.timeZone = placemark.timeZone
        self.latitude = placemark.location?.coordinate.latitude
        self.longitude = placemark.location?.coordinate.longitude
        self.placemark = placemark
    }
    
    // MARK: - Helpers
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
    }
    
    var line: String? {
        return [line1, line2].flatMap{$0}.joined(separator: ", ")
    }
    
    var line1: String? {
        return [[building, street].flatMap{$0}.joined(separator: " "), apt].flatMap{$0}.joined(separator: ", ")
    }
    
    var line2: String? {
        return [[city, zip].flatMap{$0}.joined(separator: " "), country].flatMap{$0}.joined(separator: ", ")
    }
}
