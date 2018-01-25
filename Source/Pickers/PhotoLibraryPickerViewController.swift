import Foundation
import UIKit
import Photos

extension UIAlertController {
    
    /// Add PhotoLibrary Picker
    ///
    /// - Parameters:
    ///   - selection: type and action for selection of asset/assets
    
    func addPhotoLibraryPicker(selection: PhotoLibraryPickerViewController.Selection) {
        let vc = PhotoLibraryPickerViewController(selection: selection)
        vc.alertController = self
        set(vc: vc)
    }
}

public enum PhotoLayoutState: Int {
    case square
    case autoWidth
}

final class PhotoLibraryPickerViewController: UIViewController {
    
    enum Selection {
        case single(action: ((PHAsset?) -> Swift.Void)?)
        case multiple(action: (([PHAsset]) -> Swift.Void)?)
    }
    
    public enum ButtonType {
        case photoOrVideo
        case file
        case location
        case contact
        case sendPhotos
        case sendAsFile
    }
    
    func title(for button: ButtonType) -> String {
        switch button {
        case .photoOrVideo: return "Photo of Video"
        case .file: return "File"
        case .location: return "Location"
        case .contact: return "Contact"
        case .sendPhotos: return "Send \(selectedAssets.count) \(selectedAssets.count == 1 ? "Photo" : "Photos")"
        case .sendAsFile: return "Send as File"
        }
    }
    
    func font(for button: ButtonType) -> UIFont {
        switch button {
        case .sendPhotos: return UIFont.boldSystemFont(ofSize: 20)
        default: return UIFont.systemFont(ofSize: 20) }
    }
    
    func action(for button: ButtonType) {
        switch button {
        case .photoOrVideo: break
        case .file: break
        case .location: break
        case .contact:
            alertController?.addContactsPicker(selection: .single(action: { contact in
                Log(contact)
            }))
        case .sendPhotos: break
        case .sendAsFile: break
        }
    }
    
    // MARK: UI Metrics
    
    struct UI {
        static let rowHeight: CGFloat = 58
        static let insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        static let minimumInteritemSpacing: CGFloat = 6
        static let minimumLineSpacing: CGFloat = 6
        static let maxHeight: CGFloat = UIScreen.main.bounds.width / 2
        static let multiplier: CGFloat = 2
        static let animationDuration: TimeInterval = 0.3
    }
    
    var preferredHeight: CGFloat {
        return UI.maxHeight / (selectedAssets.count == 0 ? UI.multiplier : 1) + UI.insets.top + UI.insets.bottom
    }
    
    func sizeFor(asset: PHAsset) -> CGSize {
        let height: CGFloat = UI.maxHeight
        let width: CGFloat = CGFloat(Double(height) * Double(asset.pixelWidth) / Double(asset.pixelHeight))
        return CGSize(width: width, height: height)
    }
    
    func sizeForItem(asset: PHAsset) -> CGSize {
        let size: CGSize = sizeFor(asset: asset)
        if selectedAssets.count == 0 {
            let value: CGFloat = size.height / UI.multiplier
            return CGSize(width: value, height: value)
        } else {
            return size
        }
    }
    
    
    
    // MARK: Properties
    
    var alertController: UIAlertController?
    
    fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        //$0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = UI.insets
        $0.backgroundColor = .clear
        $0.maskToBounds = false
        $0.clipsToBounds = false
        $0.register(ItemWithPhoto.self, forCellWithReuseIdentifier: String(describing: ItemWithPhoto.self))
        
        return $0
        }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    fileprivate lazy var layout: PhotoLayout = { [unowned self] in
        $0.delegate = self
        $0.lineSpacing = UI.minimumLineSpacing
        return $0
        }(PhotoLayout())
    
    //fileprivate var layoutState: PhotoLayoutState = .square
    
    fileprivate lazy var tableView: UITableView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.rowHeight = UI.rowHeight
        $0.separatorColor = UIColor.lightGray.withAlphaComponent(0.4)
        $0.separatorInset = .zero
        $0.backgroundColor = nil
        $0.bounces = false
        $0.tableHeaderView = collectionView
        $0.tableFooterView = UIView()
        $0.register(LikeButtonCell.self, forCellReuseIdentifier: LikeButtonCell.identifier)
        
        return $0
        }(UITableView(frame: .zero, style: .plain))
    
    fileprivate lazy var assets = [PHAsset]()
    fileprivate lazy var selectedAssets = [PHAsset]()
    
    fileprivate var selection: Selection
    
    fileprivate var buttons: [ButtonType] {
        return selectedAssets.count == 0
            ? [.photoOrVideo, .file, .location, .contact]
            : [.sendPhotos, .sendAsFile]
    }
    
    // MARK: Initialize
    
    required init(selection: Selection) {
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
        
        switch selection {
        case .single(_):
            collectionView.allowsSelection = true
        case .multiple(_):
            collectionView.allowsMultipleSelection = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            preferredContentSize.width = UIScreen.main.bounds.width * 0.5
        }
        
        updatePhotos()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()
    }
    
    func layoutSubviews() {
        tableView.tableHeaderView?.height = preferredHeight
        preferredContentSize.height = tableView.contentSize.height
    }
    
    func updatePhotos() {
        checkStatus { [unowned self] assets in
            self.assets.removeAll()
            self.assets.append(contentsOf: assets)
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
    }
    
    func checkStatus(completionHandler: @escaping ([PHAsset]) -> ()) {
        Log("status = \(PHPhotoLibrary.authorizationStatus())")
        switch PHPhotoLibrary.authorizationStatus() {
            
        case .notDetermined:
            /// This case means the user is prompted for the first time for allowing contacts
            Assets.requestAccess { [unowned self] status in
                self.checkStatus(completionHandler: completionHandler)
            }
            
        case .authorized:
            /// Authorization granted by user for this app.
            DispatchQueue.main.async {
                self.fetchPhotos(completionHandler: completionHandler)
            }
            
        case .denied, .restricted:
            /// User has denied the current app to access the contacts.
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            let alert = UIAlertController(style: .alert, title: "Permission denied", message: "\(productName) does not have access to contacts. Please, allow the application to access to your photo library.")
            alert.addAction(title: "Settings", style: .destructive) { action in
                if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            alert.addAction(title: "OK", style: .cancel) { [unowned self] action in
                self.alertController?.dismiss(animated: true)
            }
            alert.show()
        }
    }
    
    func fetchPhotos(completionHandler: @escaping ([PHAsset]) -> ()) {
        Assets.fetch { [unowned self] result in
            switch result {
                
            case .success(let assets):
                completionHandler(assets)
                
            case .error(let error):
                Log("------ error")
                let alert = UIAlertController(style: .alert, title: "Error", message: error.localizedDescription)
                alert.addAction(title: "OK") { [unowned self] action in
                    self.alertController?.dismiss(animated: true)
                }
                alert.show()
            }
        }
    }
    
    func action(withAsset asset: PHAsset, at indexPath: IndexPath) {
        let previousCount = selectedAssets.count
        
        switch selection {
        
        case .single(let action):
            selectedAssets = [asset]
            action?(asset)
        
        case .multiple(let action):
            selectedAssets.contains(asset)
                ? selectedAssets.remove(asset)
                : selectedAssets.append(asset)
            action?(selectedAssets)
        }
        
        let currentCount = selectedAssets.count
        
        if previousCount == 0 && currentCount > 0 {
            self.layoutSubviews()
            self.tableView.reloadData()
            collectionView.performBatchUpdates({
                //self.collectionView.collectionViewLayout.invalidateLayout()
                
            })
        } else if previousCount > 0 && currentCount == 0 {
            self.layoutSubviews()
            self.tableView.reloadData()
            
            collectionView.performBatchUpdates({
                //self.collectionView.collectionViewLayout.invalidateLayout()
                
            })
        } else {
            tableView.reloadData()
        }
        //collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - TableViewDelegate

extension PhotoLibraryPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        layout.selectedCellIndexPath = layout.selectedCellIndexPath == indexPath ? nil : indexPath
        action(withAsset: assets[indexPath.item], at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch selection {
        case .multiple(_): action(withAsset: assets[indexPath.item], at: indexPath)
        default: break }
    }
}

// MARK: - CollectionViewDataSource

extension PhotoLibraryPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemWithPhoto.self), for: indexPath) as? ItemWithPhoto else { return UICollectionViewCell() }
        
        let asset = assets[indexPath.item]
        let size = sizeFor(asset: asset)
        DispatchQueue.main.async {
            Assets.resolve(asset: asset, size: size) { new in
                item.imageView.image = new
            }
        }
        
        return item
    }
}

// MARK: - PhotoLayoutDelegate

extension PhotoLibraryPickerViewController: PhotoLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        let size: CGSize = sizeForItem(asset: assets[indexPath.item])
        Log("size = \(size)")
        return size
    }
}

// MARK: - TableViewDelegate

extension PhotoLibraryPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        action(for: buttons[indexPath.row])
    }
}

// MARK: - TableViewDataSource

extension PhotoLibraryPickerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LikeButtonCell.identifier) as! LikeButtonCell
        cell.textLabel?.font = font(for: buttons[indexPath.row])
        cell.textLabel?.text = title(for: buttons[indexPath.row])
        return cell
    }
}

final class ItemWithPhoto: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.maskToBounds = true
        return $0
    }(UIImageView())
    
    lazy var unselectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = .white
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = .white
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedPoint: UIView = {
        $0.backgroundColor = UIColor(hex: 0x007AFF)
        return $0
    }(UIView())
    
    fileprivate let inset: CGFloat = 6
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public func setup() {
        backgroundColor = .clear
        
        let unselected: UIView = UIView()
        unselected.addSubview(imageView)
        unselected.addSubview(unselectedCircle)
        backgroundView = unselected
        
        let selected: UIView = UIView()
        selected.addSubview(selectedCircle)
        selected.addSubview(selectedPoint)
        selectedBackgroundView = selected
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    /*
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let new: CGSize = CGSize(width: imageView.image?.size.width ?? 0, height: size.height)
        contentView.size = new
        Log("size = \(size), contentView = \(new)")
        layout()
        
        return new
    }
    */
    
    func layout() {
        imageView.frame = contentView.frame
        imageView.cornerRadius = 12
        updateAppearance(forCircle: unselectedCircle)
        updateAppearance(forCircle: selectedCircle)
        updateAppearance(forPoint: selectedPoint)
    }
    
    func updateAppearance(forCircle view: UIView) {
        view.frame.size = CGSize(width: 28, height: 28)
        view.frame.origin.x = imageView.bounds.width - unselectedCircle.bounds.width - inset
        view.frame.origin.y = inset
        view.circleCorner = true
        view.shadowColor = UIColor.black.withAlphaComponent(0.4)
        view.shadowOffset = .zero
        view.shadowRadius = 4
        view.shadowOpacity = 0.2
        view.shadowPath = UIBezierPath(roundedRect: unselectedCircle.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: unselectedCircle.bounds.width / 2, height: unselectedCircle.bounds.width / 2)).cgPath
        view.shadowShouldRasterize = true
        view.shadowRasterizationScale = UIScreen.main.scale
    }
    
    func updateAppearance(forPoint view: UIView) {
        view.frame.size = CGSize(width: unselectedCircle.width - unselectedCircle.borderWidth * 2, height: unselectedCircle.height - unselectedCircle.borderWidth * 2)
        view.center = selectedCircle.center
        view.circleCorner = true
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}

protocol PhotoLayoutDelegate: class {
    
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize
}


class PhotoLayout: UICollectionViewLayout {
    
    weak var delegate: PhotoLayoutDelegate!
    
    public var lineSpacing: CGFloat = 6
    
    fileprivate var previousAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var currentAttributes = [UICollectionViewLayoutAttributes]()
    
    var contentSize: CGSize = .zero
    var selectedCellIndexPath: IndexPath?
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override public var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    private var inset: UIEdgeInsets {
        return collectionView.contentInset
    }
    
    private var numberOfSections: Int {
        return collectionView.numberOfSections
    }
    
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    override public func invalidateLayout() {
        super.invalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
        previousAttributes = currentAttributes
        
        contentSize = .zero
        currentAttributes = []
        
        var xOffset: CGFloat = 0
        let yOffset: CGFloat = 0
        
        let height: CGFloat = collectionView.bounds.height - (inset.top + inset.bottom)
        
        for item in 0 ..< numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let photoWidth: CGFloat = delegate.collectionView(collectionView, sizeForPhotoAtIndexPath: indexPath).width
            
            let width: CGFloat = photoWidth
            
            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            currentAttributes.append(attributes)
            
            contentSize.width = max(contentSize.width, frame.maxX)
            xOffset += width + lineSpacing
        }
        
        contentSize.height = height
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return currentAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return currentAttributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView.bounds
        if !oldBounds.size.equalTo(newBounds.size) {
            return true
        }
        return false
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return previousAttributes[itemIndexPath.item]
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let selectedCellIndexPath = selectedCellIndexPath else { return proposedContentOffset }
        
        var finalContentOffset = proposedContentOffset
        
        if let itemFrame = layoutAttributesForItem(at: selectedCellIndexPath)?.frame {
            let width = collectionView.bounds.size.width
            
            let contentLeft = proposedContentOffset.x
            let contentRight = contentLeft + width
            
            let itemLeft = itemFrame.origin.x
            let itemRight = itemLeft + itemFrame.size.width
            
            if itemRight > contentRight {
                finalContentOffset = CGPoint(x: contentLeft + (itemRight - contentRight) + lineSpacing, y: -inset.top)
            } else if itemLeft < contentLeft {
                finalContentOffset = CGPoint(x: contentLeft - (contentLeft - itemLeft) - lineSpacing, y: -inset.top)
            }
            Log(finalContentOffset)
        }
        return finalContentOffset
    }
}
