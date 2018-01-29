import Foundation

import CoreLocation
import AddressBookUI

// class because protocol
public class Location: NSObject {
	public let name: String?
	
	// difference from placemark location is that if location was reverse geocoded,
	// then location point to user selected location
	public let location: CLLocation
	public let placemark: CLPlacemark
	
	public var address: String {
		// try to build full address first
		if let addressDic = placemark.addressDictionary {
			if let lines = addressDic["FormattedAddressLines"] as? [String] {
				return lines.joined(separator: ", ")
			} else {
				// fallback
				return ABCreateStringWithAddressDictionary(addressDic, true)
			}
		} else {
			return "\(coordinate.latitude), \(coordinate.longitude)"
		}
	}
	
	public init(name: String?, location: CLLocation? = nil, placemark: CLPlacemark) {
		self.name = name
		self.location = location ?? placemark.location!
		self.placemark = placemark
	}
}

import MapKit

extension Location: MKAnnotation {
    @objc public var coordinate: CLLocationCoordinate2D {
		return location.coordinate
	}
	
    public var title: String? {
		return name ?? address
	}
}
