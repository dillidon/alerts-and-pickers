import UIKit

extension UIAlertController {

    /// Add Locale Picker
    ///
    /// - Parameters:
    ///   - type: country, phoneCode or currency
    ///   - action: for selected locale
    
    public func addLocalePicker(type: LocalePickerViewController.Kind, action: LocalePickerViewController.Action?) {
        let vc = LocalePickerViewController(type: type, action: action)
        set(vc: vc)
    }
}

public typealias CellConfig = (UITableViewCell?) -> Swift.Void

struct CellData {
    var config: CellConfig?
    var action: CellConfig?
}

final public class LocalePickerViewController: UIViewController {
    
    // MARK: UI Metrics
    
    struct UI {
        static let rowHeight = CGFloat(50)
    }
    
    // MARK: Properties
    
    public typealias Action = (Info?) -> Swift.Void
    
    public enum Kind {
        case country
        case phoneCode
        case currency
    }
    
    public struct Info {
        
        public var locale: Locale?
        
        public var id: String? {
            return locale?.identifier
        }
        
        public var country: String
        public var code: String
        public var phoneCode: String
        
        public var flag: UIImage? {
            return UIImage(named: "Countries.bundle/Images/\(code.uppercased())", in: Bundle.main, compatibleWith: nil)
        }
        
        public var currencyCode: String? {
            return locale?.currencyCode
        }
        
        public var currencySymbol: String? {
            return locale?.currencySymbol
        }
        
        public var currencyName: String? {
            guard let currencyCode = currencyCode else { return nil }
            return locale?.localizedString(forCurrencyCode: currencyCode)
        }
        
        init(country: String, code: String, phoneCode: String) {
            self.country = country
            self.code = code
            self.phoneCode = phoneCode
            
            self.locale = Locale.availableIdentifiers.map { Locale(identifier: $0) }.first(where: { $0.regionCode == code })
        }
    }
    
    fileprivate var info: [Info] = []
    
    fileprivate lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = nil
        $0.tableFooterView = UIView()
        $0.rowHeight = UI.rowHeight
        $0.separatorColor = UIColor.lightGray.withAlphaComponent(0.4)
        $0.separatorInset = .zero
        $0.bounces = true
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .lightGray
        return $0
    }(UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge))
    
    fileprivate var type: Kind
    fileprivate var action: Action?
    fileprivate var dataSource: [CellData] = []
    
    // MARK: Initialize
    
    required public init(type: Kind, action: Action?) {
        self.type = type
        self.action = action
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override public func loadView() {
        view = tableView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(indicatorView)
        
        switch type {
        case .country:
            tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: CountryTableViewCell.identifier)
        case .phoneCode:
            tableView.register(PhoneCodeTableViewCell.self, forCellReuseIdentifier: PhoneCodeTableViewCell.identifier)
        case .currency:
            tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.identifier)
        }
        
        updateDataSource()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indicatorView.center = view.center
    }
    
    func updateDataSource() {
        self.indicatorView.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.updateInfo()
            self.reloadDataSource()

            DispatchQueue.main.async {
                
                self.indicatorView.stopAnimating()
                self.preferredContentSize.height = UIScreen.main.bounds.height
                self.tableView.reloadData()
            }
        }
    }
    
    func updateInfo() {
        info = []
        
        let bundle = Bundle.main//Bundle(for: LocationPickerViewController.self)
        let path = "Countries.bundle/Data/CountryCodes"
        
        guard let jsonPath = bundle.path(forResource: path, ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
                return
        }
        
        if let jsonObjects = (try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)) as? Array<Any> {
            for jsonObject in jsonObjects {
                guard let countryObj = jsonObject as? Dictionary<String, Any> else { continue }
                guard let country = countryObj["name"] as? String,
                    let code = countryObj["code"] as? String,
                    let phoneCode = countryObj["dial_code"] as? String else {
                        continue
                }
                let new = Info(country: country, code: code, phoneCode: phoneCode)
                info.append(new)
            }
        }
    }
    
    func reloadDataSource() {
        dataSource = []
        
        switch type {
        case .currency:
            info = info.filter { i in
                guard let code = i.currencyCode else { return false }
                return Locale.commonISOCurrencyCodes.contains(code)
                }.sorted { $0.currencyCode < $1.currencyCode }
        default: break }
        
        dataSource = self.info.map { location in
            let config: CellConfig = { [unowned self] cell in
                //cell?.imageView?.cornerRadius = 3
                //cell?.imageView?.maskToBounds = true
                
                DispatchQueue.main.async {
                    let size: CGSize = CGSize(width: 32, height: 24)
                    let flag: UIImage? = location.flag?.imageWithSize(size: size, roundedRadius: 3)
                    cell?.imageView?.image = flag
                    cell?.setNeedsLayout()
                    cell?.layoutIfNeeded()
                }
                
                switch self.type {
                case .country:
                    cell?.textLabel?.text = location.country
                    
                case .phoneCode:
                    cell?.textLabel?.text = location.phoneCode
                    cell?.detailTextLabel?.text = location.country
                    
                case .currency:
                    cell?.textLabel?.text = location.currencyCode
                    cell?.detailTextLabel?.text = location.country
                    
                    //if let cell = cell as? CurrencyTableViewCell {
                    //    cell.symbol.text = location.currencySymbol
                    //}
                }
                
                cell?.detailTextLabel?.textColor = .darkGray
            }
            let action: CellConfig = { [unowned self] cell in self.action?(location) }
            
            return CellData(config: config, action: action)
        }
    }
}

// MARK: - TableViewDelegate

extension LocalePickerViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource[indexPath.row].action?(tableView.cellForRow(at: indexPath))
    }
}

// MARK: - TableViewDataSource

extension LocalePickerViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .country:
            let cell = tableView.dequeueReusableCell(withIdentifier: CountryTableViewCell.identifier) as! CountryTableViewCell
            dataSource[indexPath.row].config?(cell)
            return cell
        case .phoneCode:
            let cell = tableView.dequeueReusableCell(withIdentifier: PhoneCodeTableViewCell.identifier) as! PhoneCodeTableViewCell
            dataSource[indexPath.row].config?(cell)
            return cell
        case .currency:
            let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.identifier) as! CurrencyTableViewCell
            dataSource[indexPath.row].config?(cell)
            return cell
        }
    }
}

final class CountryTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: CountryTableViewCell.self)

    // MARK: Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        contentView.backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}

final class PhoneCodeTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: PhoneCodeTableViewCell.self)
    
    // MARK: Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        contentView.backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}

final class CurrencyTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: CurrencyTableViewCell.self)
    
    public lazy var symbol: Label = {
        $0.textAlignment = .right
        return $0
    }(Label())
    
    // MARK: Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        contentView.backgroundColor = nil
        contentView.addSubview(symbol)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbol.size = CGSize(width: 50, height: contentView.height)
        symbol.frame.origin.x = contentView.width - symbol.width - 20
        symbol.center.y = contentView.center.y
    }
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //textLabel?.textColor = selected ? UIColor(hex: 0x007AFF) : .black
        //symbol.textColor = selected ? UIColor(hex: 0x007AFF) : .black
        accessoryType = selected ? .checkmark : .none
        //if let label = accessoryView as? Label {
        //    label.attributedText = selected ? label.text?.bold : label.text?.regular
        //}
    }
}
