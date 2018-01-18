import UIKit

class ViewController: UIViewController {
    
    // MARK: Enums
    
    enum AlertType: String {
        
        case simple = "Simple"
        case simpleWithImages = "Simple +Images"
        case oneTextField = "One TextField"
        case twoTextFields = "Login form"
        case dataPicker = "Date Picker"
        case pickerView = "Picker View"
        case countryPicker = "Country Picker"
        case phoneCodePicker = "Phone Code Picker"
        case currencyPicker = "Currency Picker"
        case horizontalImagePicker = "Horizontal Image Picker"
        case verticalImagePicker = "Vertical Image Picker"
        case colorPicker = "Color Picker"
        case photoLibraryPicker = "Photo Library Picker"
        
        var description: String {
            switch self {
            case .simple: return "3 different buttons"
            case .simpleWithImages: return "3 buttons with image"
            case .dataPicker: return "Select date and time"
            case .pickerView: return "Select alert's main view height"
            case .oneTextField: return "Input text"
            case .twoTextFields: return "2 TextFields"
            case .countryPicker: return "TableView"
            case .phoneCodePicker: return "TableView"
            case .currencyPicker: return "TableView"
            case .horizontalImagePicker: return "CollectionView"
            case .verticalImagePicker: return "CollectionView"
            case .colorPicker: return "Storyboard & Autolayout"
            case .photoLibraryPicker: return "Like in Telegram"
            }
        }
        
        var image: UIImage {
            switch self {
            case .simple: return #imageLiteral(resourceName: "title")
            case .simpleWithImages: return #imageLiteral(resourceName: "two_squares")
            case .dataPicker: return #imageLiteral(resourceName: "calendar")
            case .pickerView: return #imageLiteral(resourceName: "picker")
            case .oneTextField: return #imageLiteral(resourceName: "pen")
            case .twoTextFields: return #imageLiteral(resourceName: "login")
            case .countryPicker: return #imageLiteral(resourceName: "globe")
            case .phoneCodePicker: return #imageLiteral(resourceName: "telephone")
            case .currencyPicker: return #imageLiteral(resourceName: "currency")
            case .horizontalImagePicker: return #imageLiteral(resourceName: "listings")
            case .verticalImagePicker: return #imageLiteral(resourceName: "four_rect")
            case .colorPicker: return #imageLiteral(resourceName: "colors")
            case .photoLibraryPicker: return #imageLiteral(resourceName: "library")
            }
        }
        
        var color: UIColor? {
            switch self {
            case .simple, .simpleWithImages: return UIColor(hex: 0x007AFF)//UIColor(hex: 0x5AC8FA)
            case .oneTextField, .twoTextFields: return UIColor(hex: 0x5AC8FA)//UIColor(hex: 0x4CD964)
            case .dataPicker, .pickerView: return UIColor(hex: 0x4CD964)//UIColor(hex: 0xFFCC00)
            case .countryPicker, .phoneCodePicker, .currencyPicker: return UIColor(hex: 0xFF5722)
            case .horizontalImagePicker, .verticalImagePicker: return UIColor(hex: 0xFF2DC6)
            case .colorPicker: return nil//return UIColor(hex: 0x5AC8FA)
            case .photoLibraryPicker: return .gray//UIColor(hex: 0x5AC8FA)
            }
        }
    }
    
    fileprivate lazy var alerts: [AlertType] = [.simple, .simpleWithImages, .oneTextField, .twoTextFields, .dataPicker, .pickerView, .countryPicker, .phoneCodePicker, .currencyPicker, .horizontalImagePicker, .verticalImagePicker, .colorPicker]
    
    // MARK: UI Metrics
    
    struct UI {
        static let cellIdentifier: String = UUID().uuidString
        static let rowHeight: CGFloat = 50
    }
    
    
    // MARK: Properties
    
    fileprivate var alertStyle: UIAlertControllerStyle = .actionSheet
    
    fileprivate lazy var segments: SegmentedControl = {
        let styles: [String] = ["Alert", "ActionSheet"]
        $0.segmentTitles = styles
        $0.action { [unowned self] index in
            switch styles[index] {
            case "Alert":           self.alertStyle = .alert
            case "ActionSheet":     self.alertStyle = .actionSheet
            default: break }
        }
        $0.tintColor = UIColor(hex: 0xFF2DC6)//UIColor(hex: 0x3C3C3C)
        return $0
    }(SegmentedControl())
    
    fileprivate lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .white
        $0.rowHeight = 56
        $0.sectionHeaderHeight = 20
        $0.sectionFooterHeight = 0
        $0.separatorColor = .clear
        $0.separatorInset = .zero
        $0.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        return $0
    }(UITableView(frame: .zero, style: .grouped))
    
    fileprivate var dataSource: [CellData] = []
    
    fileprivate var photos: [UIImage] {
        return [#imageLiteral(resourceName: "interior_design_1"), #imageLiteral(resourceName: "interior_design_2"), #imageLiteral(resourceName: "interior_design_3"), #imageLiteral(resourceName: "interior_design_4"), #imageLiteral(resourceName: "interior_design_5"), #imageLiteral(resourceName: "interior_design_8"), #imageLiteral(resourceName: "interior_design_9"), #imageLiteral(resourceName: "interior_design_10"), #imageLiteral(resourceName: "interior_design_11"), #imageLiteral(resourceName: "interior_design_12"), #imageLiteral(resourceName: "interior_design_13"), #imageLiteral(resourceName: "interior_design_14"), #imageLiteral(resourceName: "interior_design_15"), #imageLiteral(resourceName: "interior_design_16"), #imageLiteral(resourceName: "interior_design_17"), #imageLiteral(resourceName: "interior_design_18"), #imageLiteral(resourceName: "interior_design_19"), #imageLiteral(resourceName: "interior_design_20"), #imageLiteral(resourceName: "interior_design_21"), #imageLiteral(resourceName: "interior_design_22"), #imageLiteral(resourceName: "interior_design_23"), #imageLiteral(resourceName: "interior_design_24"), #imageLiteral(resourceName: "interior_design_25"), #imageLiteral(resourceName: "interior_design_26"), #imageLiteral(resourceName: "interior_design_27"), #imageLiteral(resourceName: "interior_design_28"), #imageLiteral(resourceName: "interior_design_29"), #imageLiteral(resourceName: "interior_design_30"), #imageLiteral(resourceName: "interior_design_31"), #imageLiteral(resourceName: "interior_design_32"), #imageLiteral(resourceName: "interior_design_33"), #imageLiteral(resourceName: "interior_design_34"), #imageLiteral(resourceName: "interior_design_35"), #imageLiteral(resourceName: "interior_design_36"), #imageLiteral(resourceName: "interior_design_37"), #imageLiteral(resourceName: "interior_design_38"), #imageLiteral(resourceName: "interior_design_39")]
    }
    // MARK: Initialize
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewController LifeCycle
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Alerts & Pickers"
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }
        
        navigationItem.titleView = segments
        alertStyle = .actionSheet
        segments.selectedSegmentIndex = 1
        
        updateDataSource()
    }
    
    func updateDataSource() {
        dataSource = alerts.map { type in
            
            let config: CellConfig = { cell in

                cell?.imageView?.image = type.image
                cell?.textLabel?.text = type.rawValue
                cell?.detailTextLabel?.text = type.description
                cell?.detailTextLabel?.textColor = .darkGray
                
                cell?.imageView?.tintColor = type.color
            }
            
            let action: CellConfig = { [unowned self] cell in
                switch type {
                    
                case .simple:
                    Log("start --- ")
                    let alert = UIAlertController(style: self.alertStyle, title: "Simple Alert", message: "3 kinds of actions")
                    alert.addAction(title: "Default", style: .default)
                    alert.addAction(title: "Cancel", style: .cancel)
                    alert.addAction(title: "Destructive", style: .destructive)
                    alert.show()
                    Log("stop --- ")
                case .simpleWithImages:
                    let alert = UIAlertController(style: self.alertStyle)
                    alert.set(title: "Simple Alert", font: .systemFont(ofSize: 20), color: UIColor(hex: 0xFF2D55))
                    alert.set(message: "3 kinds of actions with images", font: .systemFont(ofSize: 14), color: UIColor(hex: 0xFF9500))
                    alert.addAction(image: #imageLiteral(resourceName: "clip"), title: "Attache File", color: UIColor(hex: 0xFF2DC6), style: .default)
                    alert.addAction(title: "Cancel", style: .cancel) //.cancel action will always be at the end
                    alert.addAction(image: #imageLiteral(resourceName: "login"), title: "Login", style: .destructive, isEnabled: false)
                    alert.show()
                    
                case .oneTextField:
                    let alert = UIAlertController(style: self.alertStyle, title: "TextField", message: "Secure Entry")
                    
                    let textField: TextField.Config = { textField in
                        textField.left(image: #imageLiteral(resourceName: "pen"), color: .black)
                        textField.leftViewPadding = 12
                        textField.becomeFirstResponder()
                        textField.borderWidth = 1
                        textField.cornerRadius = 8
                        textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                        textField.backgroundColor = nil
                        textField.textColor = .black
                        textField.placeholder = "Type something"
                        textField.keyboardAppearance = .default
                        textField.keyboardType = .default
                        //textField.isSecureTextEntry = true
                        textField.returnKeyType = .done
                        textField.action { textField in
                            Log("textField = \(String(describing: textField.text))")
                        }
                    }
                    
                    alert.addOneTextField(configuration: textField)
                    
                    alert.addAction(title: "OK", style: .cancel)
                    alert.show()
                    
                case .twoTextFields:
                    let alert = UIAlertController(style: self.alertStyle)
                    
                    let textFieldOne: TextField.Config = { textField in
                        textField.left(image: #imageLiteral(resourceName: "user"), color: UIColor(hex: 0x007AFF))
                        textField.leftViewPadding = 16
                        textField.leftTextPadding = 12
                        textField.becomeFirstResponder()
                        textField.backgroundColor = nil
                        textField.textColor = .black
                        textField.placeholder = "Name"
                        textField.clearButtonMode = .whileEditing
                        textField.autocapitalizationType = .none
                        textField.keyboardAppearance = .default
                        textField.keyboardType = .default
                        textField.returnKeyType = .continue
                        textField.action { textField in
                            Log("textField = \(String(describing: textField.text))")
                        }
                    }
                    
                    let textFieldTwo: TextField.Config = { textField in
                        textField.left(image: #imageLiteral(resourceName: "padlock"), color: UIColor(hex: 0x007AFF))
                        textField.leftViewPadding = 16
                        textField.leftTextPadding = 12
                        textField.borderWidth = 1
                        textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                        textField.backgroundColor = nil
                        textField.textColor = .black
                        textField.placeholder = "Password"
                        textField.clearsOnBeginEditing = true
                        textField.autocapitalizationType = .none
                        textField.keyboardAppearance = .default
                        textField.keyboardType = .default
                        textField.isSecureTextEntry = true
                        textField.returnKeyType = .done
                        textField.action { textField in
                            Log("textField = \(String(describing: textField.text))")
                        }
                    }
                    
                    alert.addTwoTextFields(
                        height: self.alertStyle == .alert ? 44 : 58,
                        hInset: self.alertStyle == .alert ? 12 : 0,
                        vInset: self.alertStyle == .alert ? 12 : 0,
                        textFieldOne: textFieldOne,
                        textFieldTwo: textFieldTwo)
                    
                    alert.addAction(title: "Sign in", style: .cancel)
                    alert.show()
                    
                case .dataPicker:
                    let alert = UIAlertController(style: self.alertStyle, title: "Date Picker", message: "Select Date")
                    alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: nil, maximumDate: nil) { new in
                        cell?.detailTextLabel?.text = new.dateTimeString(ofStyle: .long)
                    }
                    alert.addAction(title: "Done", style: .cancel)
                    alert.show()
                    
                case .pickerView:
                    let alert = UIAlertController(style: self.alertStyle, title: "Picker View", message: "Preferred Content Height")
                    
                    let frameSizes: [CGFloat] = (150...300).map { CGFloat($0) }
                    let pickerViewValues: [[String]] = [frameSizes.map { Int($0).description }]
                    let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: frameSizes.index(of: 216) ?? 0)
                    
                    alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
                        
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 1) {
                                vc.preferredContentSize.height = frameSizes[index.row]
                            }
                        }
                    }
                    alert.addAction(title: "Done", style: .cancel)
                    alert.show()
                    
                case .countryPicker:
                    let alert = UIAlertController(style: self.alertStyle, message: "Select Countries")
                    alert.addLocalePicker(type: .country) { info in
                        Log(info)
                    }
                    alert.addAction(title: "OK", style: .cancel)
                    alert.show()
                
                case .phoneCodePicker:
                    let alert = UIAlertController(style: self.alertStyle, title: "Select Phone Code")
                    alert.addLocalePicker(type: .phoneCode) { info in
                        Log(info)
                    }
                    alert.addAction(title: "OK", style: .cancel)
                    alert.show()
                    
                case .currencyPicker:
                    let alert = UIAlertController(style: self.alertStyle, title: "Currencies", message: "Select one")
                    alert.addLocalePicker(type: .currency) { info in
                        alert.title = info?.currencyCode
                        alert.message = "is selected"
                    }
                    alert.addAction(title: "OK", style: .cancel)
                    alert.show()
                    
                case .horizontalImagePicker:
                    let alert = UIAlertController(style: self.alertStyle)
                    alert.addImagePicker(
                        flow: .horizontal,
                        paging: true,
                        images: self.photos,
                        selection: .single(action: { image in
                            Log(image)
                        }))
                    alert.addAction(title: "OK", style: .cancel)
                    alert.show()
                    
                case .verticalImagePicker:
                    let alert = UIAlertController(style: self.alertStyle)
                    alert.addImagePicker(
                        flow: .vertical,
                        paging: false,
                        height: UIScreen.main.bounds.height,
                        images: self.photos,
                        selection: .multiple(action: { images in
                            Log(images)
                        }))
                    alert.addAction(title: "OK", style: .cancel)
                    alert.show()
                    
                case .colorPicker:
                    var color: UIColor = UIColor(hex: 0xFF2DC6)
                    let alert = UIAlertController(style: self.alertStyle)
                    alert.set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
                    alert.addColorPicker(color: color) { new in
                        color = new
                        alert.set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
                    }
                    alert.addAction(title: "Done", style: .cancel)
                    alert.show()
                    
                case .photoLibraryPicker:
                    break
                }
            }
            return CellData(config: config, action: action)
        }
    }
}

// MARK: - TableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Log("selected alert - \(alerts[indexPath.section].rawValue)")
        let cell = tableView.cellForRow(at: indexPath)
        self.dataSource[indexPath.section].action?(cell)
    }
}

// MARK: - TableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier) as! MainTableViewCell
        dataSource[indexPath.section].config?(cell)
        return cell
    }
}

final class MainTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: MainTableViewCell.self)
    
    fileprivate var originalWidth: CGFloat?
    
    // MARK: Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        maskToBounds = false
        backgroundColor = .white
        cornerRadius = 12
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        // Set the width of the cell
        if originalWidth == nil {
            originalWidth = size.width
        }
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: (originalWidth ?? size.width) - 40, height: bounds.size.height)
        super.layoutSubviews()
    }
    
    override var bounds: CGRect {
        didSet {
            shadowColor = .black
            shadowOffset = CGSize(width: 2, height: 4)
            shadowRadius = 8
            shadowOpacity = 0.2
            shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
            shadowShouldRasterize = true
            shadowRasterizationScale = UIScreen.main.scale
        }
    }
}
