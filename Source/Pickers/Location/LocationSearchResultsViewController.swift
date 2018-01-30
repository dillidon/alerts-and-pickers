import UIKit
import MapKit

final class LocationSearchResultsViewController: UITableViewController {
	var locations: [Location] = []
	var onSelectLocation: ((Location) -> ())?
	var isShowingHistory = false
	var searchHistoryLabel: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		extendedLayoutIncludesOpaqueBars = true
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.4)
        tableView.backgroundColor = nil
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
	}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize.height = tableView.contentSize.height
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return isShowingHistory ? searchHistoryLabel : nil
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locations.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")
			?? UITableViewCell(style: .subtitle, reuseIdentifier: "LocationCell")

		let location = locations[indexPath.row]
        cell.imageView?.image = UIColor(hex: 0x007AFF).toImage().imageWithSize(size: CGSize(width: 8, height: 8), roundedRadius: 4)
        cell.imageView?.circleCorner = true
		cell.textLabel?.text = location.name
		cell.detailTextLabel?.text = location.address
		cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onSelectLocation?(locations[indexPath.row])
	}
}
