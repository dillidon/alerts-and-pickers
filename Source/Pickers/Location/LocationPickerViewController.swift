import UIKit
import MapKit
import CoreLocation

/// Based on https://github.com/almassapargali/LocationPicker

extension UIAlertController {
    
    /// Add PhotoLibrary Picker
    ///
    /// - Parameters:
    ///   - selection: type and action for selection of asset/assets
    
    func addLocationPicker(location: Location? = nil, completion: @escaping LocationPickerViewController.CompletionHandler) {
        let vc = LocationPickerViewController()
        vc.location = location
        vc.completion = completion
        set(vc: vc)
    }
}

final class LocationPickerViewController: UIViewController {
	
    struct CurrentLocationListener {
		let once: Bool
		let action: (CLLocation) -> ()
	}
    
    public typealias CompletionHandler = (Location?) -> ()
	
	public var completion: CompletionHandler?
	
	// region distance to be used for creation region when user selects place from search results
	public var resultRegionDistance: CLLocationDistance = 600
	
	/// default: true
	public var showCurrentLocationInitially = true

    /// default: false
    /// Select current location only if `location` property is nil.
    public var selectCurrentLocationInitially = true
	
	/// see `region` property of `MKLocalSearchRequest`
	/// default: false
	public var useCurrentLocationAsHint = false
	
	public var searchBarPlaceholder = "Search or enter an address"
	public var searchHistoryLabel = "Search History"
    public var selectButtonTitle = "Select"
	
	public var mapType: MKMapType = .standard {
		didSet {
			if isViewLoaded { mapView.mapType = mapType }
		}
	}
	
	public var location: Location? {
		didSet {
			if isViewLoaded {
				searchController.searchBar.text = location.flatMap { $0.title } ?? ""
				updateAnnotation()
			}
		}
	}
	
	static let SearchTermKey = "SearchTermKey"
	
	let historyManager = SearchHistoryManager()
	let locationManager = CLLocationManager()
	let geocoder = CLGeocoder()
	var localSearch: MKLocalSearch?
	var searchTimer: Timer?
	
	var currentLocationListeners: [CurrentLocationListener] = []
	
    lazy var mapView: MKMapView = {
        $0.mapType = mapType
        $0.showsCompass = false
        $0.showsScale = true
        
        return $0
    }(MKMapView())
    
    lazy var scaleView: MKScaleView = {
        $0.scaleVisibility = .visible
        return $0
    }(MKScaleView(mapView: mapView))
    
    lazy var locationButton: Button = {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.maskToBounds = true
        $0.cornerRadius = 22
        $0.setImage(#imageLiteral(resourceName: "geolocation"), for: UIControlState())
        $0.addTarget(self, action: #selector(LocationPickerViewController.currentLocationPressed),
                         for: .touchUpInside)
        return $0
    }(Button(frame: CGRect(x: 0, y: 0, width: 44, height: 44)))
	
	lazy var results: LocationSearchResultsViewController = {
		let results = LocationSearchResultsViewController()
		results.onSelectLocation = { [weak self] in self?.selectedLocation($0) }
		results.searchHistoryLabel = self.searchHistoryLabel
		return results
	}()
	
	lazy var searchController: UISearchController = {
		
		$0.searchResultsUpdater = self
        $0.searchBar.delegate = self
        $0.dimsBackgroundDuringPresentation = true
        /// true if search bar in tableView header
		$0.hidesNavigationBarDuringPresentation = true
        $0.searchBar.placeholder = searchBarPlaceholder
        $0.searchBar.barStyle = .black
        $0.searchBar.searchBarStyle = .minimal
        $0.searchBar.textField?.textColor = UIColor(hex: 0xf4f4f4)
        $0.searchBar.textField?.setPlaceHolderTextColor(UIColor(hex: 0xf8f8f8))
        $0.searchBar.textField?.clearButtonMode = .whileEditing
		return $0
	}(UISearchController(searchResultsController: results))
    
    fileprivate lazy var searchView: UIView = UIView()
	
	deinit {
		searchTimer?.invalidate()
		localSearch?.cancel()
		geocoder.cancelGeocode()
        // http://stackoverflow.com/questions/32675001/uisearchcontroller-warning-attempting-to-load-the-view-of-a-view-controller/
        let _ = searchController.view
	}
	
	open override func loadView() {
		view = mapView
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
        mapView.addSubview(scaleView)
        mapView.addSubview(locationButton)
        
		locationManager.delegate = self
		mapView.delegate = self
        
		// gesture recognizer for adding by tap
        let locationSelectGesture = UILongPressGestureRecognizer(
            target: self, action: #selector(addLocation(_:)))
        locationSelectGesture.delegate = self
		mapView.addGestureRecognizer(locationSelectGesture)

		// search
        searchView.addSubview(searchController.searchBar)
        view.addSubview(searchView)
        
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .bottom
		definesPresentationContext = true
		
		// user location
		mapView.userTrackingMode = .none
		mapView.showsUserLocation = showCurrentLocationInitially
		
		if useCurrentLocationAsHint {
			getCurrentLocation()
		}
	}
	
	var presentedInitialLocation = false
	
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        searchView.frame = CGRect(x: 8, y: 8, width: view.width - 16, height: 57)
        //searchController.searchBar.sizeToFit()
        searchController.searchBar.width = searchView.width
        searchController.searchBar.height = searchView.height
        
    }
    
    override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
        preferredContentSize.height = UIScreen.main.bounds.height
        
        locationButton.frame.origin = CGPoint(
            x: view.frame.width - locationButton.frame.width - 20,
            y: view.frame.height - locationButton.frame.height - 20
        )
		
		// setting initial location here since viewWillAppear is too early, and viewDidAppear is too late
		if !presentedInitialLocation {
			setInitialLocation()
			presentedInitialLocation = true
		}
	}
	
	func setInitialLocation() {
		if let location = location {
			// present initial location if any
			self.location = location
			showCoordinates(location.coordinate, animated: false)
            return
		} else if showCurrentLocationInitially || selectCurrentLocationInitially {
            if selectCurrentLocationInitially {
                let listener = CurrentLocationListener(once: true) { [weak self] location in
                    if self?.location == nil { // user hasn't selected location still
                        self?.selectLocation(location: location)
                    }
                }
                currentLocationListeners.append(listener)
            }
			showCurrentLocation(false)
		}
	}
	
	func getCurrentLocation() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
    @objc func currentLocationPressed() {
		showCurrentLocation()
	}
	
	func showCurrentLocation(_ animated: Bool = true) {
		let listener = CurrentLocationListener(once: true) { [weak self] location in
			self?.showCoordinates(location.coordinate, animated: animated)
		}
		currentLocationListeners.append(listener)
        getCurrentLocation()
	}
	
	func updateAnnotation() {
		mapView.removeAnnotations(mapView.annotations)
		if let location = location {
			mapView.addAnnotation(location)
			mapView.selectAnnotation(location, animated: true)
		}
	}
	
	func showCoordinates(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
		let region = MKCoordinateRegionMakeWithDistance(coordinate, resultRegionDistance, resultRegionDistance)
		mapView.setRegion(region, animated: animated)
	}

    func selectLocation(location: CLLocation) {
        // add point annotation to map
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { response, error in
            if let error = error as NSError?, error.code != 10 { // ignore cancelGeocode errors
                // show error and remove annotation
                let alert = UIAlertController(style: .alert, title: nil, message: error.localizedDescription)
                alert.addAction(title: "OK", style: .cancel) { action in
                    self.mapView.removeAnnotation(annotation)
                }
                alert.show()
                
            } else if let placemark = response?.first {
                // get POI name from placemark if any
                let name = placemark.areasOfInterest?.first

                // pass user selected location too
                self.location = Location(name: name, location: location, placemark: placemark)
                
                let address = Address(placemark: placemark)
                annotation.title = address.line1
                annotation.subtitle = address.line2
                
                
            }
        }
    }
}

extension LocationPickerViewController: CLLocationManagerDelegate {
    
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else { return }
        currentLocationListeners.forEach { $0.action(location) }
		currentLocationListeners = currentLocationListeners.filter { !$0.once }
		manager.stopUpdatingLocation()
	}
}

// MARK: Searching

extension LocationPickerViewController: UISearchResultsUpdating {
	public func updateSearchResults(for searchController: UISearchController) {
		guard let term = searchController.searchBar.text else { return }
		
		searchTimer?.invalidate()

		let searchTerm = term.trimmingCharacters(in: CharacterSet.whitespaces)
		
		if searchTerm.isEmpty {
			results.locations = historyManager.history()
			results.isShowingHistory = true
			results.tableView.reloadData()
		} else {
			// clear old results
			showItemsForSearchResult(nil)
			
			searchTimer = Timer.scheduledTimer(timeInterval: 0.2,
				target: self, selector: #selector(LocationPickerViewController.searchFromTimer(_:)),
				userInfo: [LocationPickerViewController.SearchTermKey: searchTerm],
				repeats: false)
		}
	}
	
    @objc func searchFromTimer(_ timer: Timer) {
		guard let userInfo = timer.userInfo as? [String: AnyObject],
			let term = userInfo[LocationPickerViewController.SearchTermKey] as? String
			else { return }
		
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = term
		
		if let location = locationManager.location, useCurrentLocationAsHint {
			request.region = MKCoordinateRegion(center: location.coordinate,
				span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
		}
		
		localSearch?.cancel()
		localSearch = MKLocalSearch(request: request)
		localSearch!.start { response, _ in
			self.showItemsForSearchResult(response)
		}
	}
	
	func showItemsForSearchResult(_ searchResult: MKLocalSearchResponse?) {
		results.locations = searchResult?.mapItems.map { Location(name: $0.name, placemark: $0.placemark) } ?? []
		results.isShowingHistory = false
		results.tableView.reloadData()
	}
	
	func selectedLocation(_ location: Location) {
		// dismiss search results
		dismiss(animated: true) {
			// set location, this also adds annotation
			self.location = location
			self.showCoordinates(location.coordinate)
			
			self.historyManager.addToHistory(location)
		}
	}
}

// MARK: Selecting location with gesture

extension LocationPickerViewController {
    @objc func addLocation(_ gestureRecognizer: UIGestureRecognizer) {
		if gestureRecognizer.state == .began {
			let point = gestureRecognizer.location(in: mapView)
			let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
			let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
			
			// clean location, cleans out old annotation too
			self.location = nil
            selectLocation(location: location)
		}
	}
}

// MARK: MKMapViewDelegate

extension LocationPickerViewController: MKMapViewDelegate {
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation { return nil }
		
		let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
		pin.pinTintColor = UIColor(hex: 0xFF2DC6)
        
		// drop only on long press gesture
		let fromLongPress = annotation is MKPointAnnotation
		pin.animatesDrop = fromLongPress
		pin.rightCalloutAccessoryView = selectLocationButton()
		pin.canShowCallout = !fromLongPress
		return pin
	}
	
	func selectLocationButton() -> UIButton {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
		button.setTitle(selectButtonTitle, for: UIControlState())
        if let titleLabel = button.titleLabel {
            let width = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: Int.max, height: 30), limitedToNumberOfLines: 1).width
            button.frame.size = CGSize(width: width + 10, height: 30.0)
        }
        button.backgroundColor = UIColor(hex: 0x007AFF)
		button.setTitleColor(.white, for: UIControlState())
        button.borderWidth = 2
        button.borderColor = UIColor(hex: 0x007AFF)
        button.cornerRadius = 5
        button.titleEdgeInsets.left = 5
        button.titleEdgeInsets.right = 5
		return button
	}
	
	public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		completion?(location)
		if let navigation = navigationController, navigation.viewControllers.count > 1 {
			navigation.popViewController(animated: true)
		} else {
			presentingViewController?.dismiss(animated: true, completion: nil)
		}
	}
	
	public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		let pins = mapView.annotations.filter { $0 is MKPinAnnotationView }
		assert(pins.count <= 1, "Only 1 pin annotation should be on map at a time")

        if let userPin = views.first(where: { $0.annotation is MKUserLocation }) {
            userPin.canShowCallout = false
        }
	}
}

extension LocationPickerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UISearchBarDelegate

extension LocationPickerViewController: UISearchBarDelegate {
	public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		// dirty hack to show history when there is no text in search bar
		// to be replaced later (hopefully)
		if let text = searchBar.text, text.isEmpty {
			searchBar.text = " "
		}
	}
	
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// remove location if user presses clear or removes text
		if searchText.isEmpty {
			location = nil
			searchBar.text = " "
		}
	}
}
